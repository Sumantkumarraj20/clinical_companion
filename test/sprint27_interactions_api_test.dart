import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/ai/interactions_api_client.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Sprint 27 — "The Interactions API Migration & Adaptive Compute".
///
/// Locks the migration contract:
///  1. Requests target the GA `POST /v1/interactions` endpoint with
///     `gemini-3.8-flash` and NO deprecated sampling parameters
///     (temperature / top_p / top_k / thinking_budget).
///  2. Mocked responses use the Interactions response structure
///     (`steps` / `model_output` / `output_text`), never the legacy
///     `candidates` array.
///  3. `thinking_level` routing: low (Sprint 21 text/OCR routing), medium
///     (Sprint 19 POMR structuring + audits), high (Sprint 25 DDx + Sprint 24
///     guardrails) — exclusively.
///  4. A 400/500 failure surfaces as a typed, non-blocking
///     [DocumentAiException] instead of crashing the Encounter UI.

/// A dense, handwriting-marker-free transcript so `chooseEscalation` stays on
/// the text-only path (no ML Kit / image-compress platform channels in tests).
const _denseClinicalTranscript =
    'Pathology report for patient Asha Rao, age forty two years. Haemoglobin '
    'twelve point four grams per decilitre. Total leucocyte count eight thousand '
    'six hundred per cubic millilitre. Serum creatinine zero point nine '
    'milligrams per decilitre. Blood urea twenty eight milligrams per decilitre. '
    'Final report: sections show reactive changes with no evidence of '
    'malignancy described anywhere in the concluding narrative block.';

/// A `generateContent` response (`candidates[0].content.parts[0].text`).
String interactionsResponseBody(
  String outputText, {
  bool includeOutputText = true,
}) => jsonEncode({
  'responseId': 'int_sprint27_test',
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'text': outputText},
        ],
      },
      'finishReason': 'STOP',
    },
  ],
});

/// Minimal valid ClinicalRuleSuggestion payload for mocked responses.
Map<String, dynamic> _ruleJson({required String triggerValue}) =>
    <String, dynamic>{
      'trigger_type': 'diagnosis',
      'trigger_value': triggerValue,
      'suggested_action': 'Start standard therapy',
      'evidence_rationale': 'Grounded in the supplied guideline.',
      'contraindicating_conditions': <String>[],
      'required_monitoring': <String>[],
      'differential_diagnoses': <String>['Bacterial infection'],
      'recommended_investigations': <String>['Baseline blood work'],
      'recommended_management': <String>['First line therapy'],
      'source_reference': 'Not specified',
    };

String _inputTextOf(Map<String, dynamic> body) {
  final buffer = StringBuffer();
  final contents = body['contents'];
  if (contents is List) {
    for (final content in contents) {
      final parts = content is Map ? content['parts'] : null;
      if (parts is! List) continue;
      for (final part in parts) {
        if (part is Map && part['text'] is String) buffer.writeln(part['text']);
      }
    }
  }
  return buffer.toString();
}

String? _thinkingLevelOf(Map<String, dynamic> body) {
  final config = body['generationConfig'];
  final thinking = config is Map ? config['thinkingConfig'] : null;
  return thinking is Map ? thinking['thinkingLevel'] as String? : null;
}

void main() {
  group('Sprint 27: Interactions request payload', () {
    test('targets the generateContent endpoint with the latest model', () {
      expect(
        InteractionsApiClient.endpointFor('gemini-3.8-flash'),
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-3.8-flash:generateContent',
      );
      expect(DocumentAiService.defaultModel, 'gemini-3.8-flash');
      expect(
        DocumentAiService.fallbackModel,
        isNot(DocumentAiService.defaultModel),
      );
    });

    test('payload carries response_format + thinking_level and purges every '
        'deprecated sampling parameter', () {
      final body = InteractionsApiClient(apiKey: 'test-key').buildRequestBody(
        model: DocumentAiService.defaultModel,
        prompt: 'Structure this encounter as POMR.',
        jsonSchema: <String, dynamic>{
          'type': 'object',
          'properties': <String, dynamic>{
            'diagnosis': <String, dynamic>{'type': 'string'},
          },
          'required': <String>['diagnosis'],
        },
        thinkingLevel: ThinkingLevel.medium,
      );

      expect(body.containsKey('model'), isFalse);
      expect(body['contents'], [
        {
          'parts': [
            {'text': 'Structure this encounter as POMR.'},
          ],
        },
      ]);
      expect(body['generationConfig'], <String, dynamic>{
        'responseMimeType': 'application/json',
        'responseSchema': <String, dynamic>{
          'type': 'object',
          'properties': <String, dynamic>{
            'diagnosis': <String, dynamic>{'type': 'string'},
          },
          'required': <String>['diagnosis'],
        },
        'thinkingConfig': <String, dynamic>{'thinkingLevel': 'medium'},
      });

      // The legacy generateContent config surface must be gone entirely.
      final encoded = jsonEncode(body);
      for (final banned in kDeprecatedGenerationParameters) {
        expect(
          body.containsKey(banned),
          isFalse,
          reason: '$banned leaked into payload',
        );
        expect(
          encoded.contains('"$banned"'),
          isFalse,
          reason: '$banned leaked into payload',
        );
      }
      expect(body.containsKey('input'), isFalse);
      expect(body.containsKey('response_format'), isFalse);
    });

    test(
      'every adaptive-compute tier maps to a valid thinking_level value',
      () {
        const wireValues = <String>{'minimal', 'low', 'medium', 'high'};
        expect(ThinkingLevel.all, hasLength(4));
        for (final tier in ThinkingLevel.all) {
          expect(
            wireValues.contains(tier.value),
            isTrue,
            reason: '${tier.value} is not a valid tier',
          );
          final body = InteractionsApiClient(apiKey: 'k').buildRequestBody(
            model: DocumentAiService.defaultModel,
            prompt: 'p',
            thinkingLevel: tier,
          );
          expect(_thinkingLevelOf(body), tier.value);
        }
      },
    );
  });

  group('Sprint 27: Interactions response parsing', () {
    test(
      'reads output_text and the steps timeline from a GA response',
      () async {
        http.Request? captured;
        final client = InteractionsApiClient(
          apiKey: 'test-key',
          client: MockClient((request) async {
            captured = request;
            return http.Response(
              interactionsResponseBody('{"clinical_insights":[]}'),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );

        final result = await client.create(
          model: DocumentAiService.defaultModel,
          prompt: 'audit the chart',
          thinkingLevel: ThinkingLevel.high,
        );

        expect(result.text, '{"clinical_insights":[]}');
        expect(result.interactionId, 'int_sprint27_test');

        // Request shape on the wire.
        expect(captured, isNotNull);
        expect(
          captured!.url.toString(),
          InteractionsApiClient.endpointFor(DocumentAiService.defaultModel),
        );
        expect(captured!.headers['x-goog-api-key'], 'test-key');
        final sent = jsonDecode(captured!.body) as Map<String, dynamic>;
        expect(_thinkingLevelOf(sent), 'high');
        for (final banned in kDeprecatedGenerationParameters) {
          expect(sent.containsKey(banned), isFalse);
        }
      },
    );

    test('sends images as inlineData parts', () {
      final body = InteractionsApiClient(apiKey: 'k').buildRequestBody(
        model: 'm',
        prompt: 'read it',
        imageBytes: Uint8List.fromList([1, 2, 3]),
        imageMimeType: 'image/png',
      );
      final parts = ((body['contents'] as List).single as Map)['parts'] as List;
      expect(parts[0], {'text': 'read it'});
      expect(parts[1], {
        'inlineData': {'mimeType': 'image/png', 'data': 'AQID'},
      });
    });

    test('a payload without candidates text throws a classified error', () {
      final client = InteractionsApiClient(
        apiKey: 'test-key',
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({'steps': []}),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      expect(
        client.create(model: 'm', prompt: 'p'),
        throwsA(
          isA<InteractionsApiException>().having(
            (e) => e.message,
            'message',
            contains('candidates[0].content.parts'),
          ),
        ),
      );
    });
  });

  group('Sprint 27: adaptive thinking-level routing', () {
    test('pipeline text routing (Sprint 21) requests the low tier', () async {
      final ai = _TierCapturingAiService();
      final pipeline = ExtractionPipelineService(ai);

      await pipeline.processTextWithProvenance(_denseClinicalTranscript);

      expect(ai.lastThinkingLevel, ThinkingLevel.low);
    });

    test('document refinement (Sprint 19 POMR structuring) requests the medium '
        'tier', () async {
      final ai = _TierCapturingAiService();
      final pipeline = ExtractionPipelineService(ai);

      await pipeline.refineWithAi(File('chart.png'), _denseClinicalTranscript);

      expect(ai.lastThinkingLevel, ThinkingLevel.medium);
    });

    test('chart audit defaults to medium; DDx rule generation and guideline '
        'contraindication mining default to high', () async {
      final sentBodies = <Map<String, dynamic>>[];
      final service = DocumentAiService(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          sentBodies.add(body);
          final input = _inputTextOf(body);

          final Object output;
          if (input.contains('elite academic attending physician')) {
            output = {'clinical_insights': <dynamic>[]};
          } else if (input.contains('MEDICAL LITERATURE')) {
            output = {
              'rules': [_ruleJson(triggerValue: 'Metformin')],
            };
          } else {
            output = _ruleJson(triggerValue: 'Community acquired pneumonia');
          }
          return http.Response(
            interactionsResponseBody(jsonEncode(output)),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await service.generateClinicalInsights('longitudinal POMR summary');
      expect(_thinkingLevelOf(sentBodies.last), 'medium');

      await service.generateClinicalRule(
        triggerType: 'diagnosis',
        triggerValue: 'Community acquired pneumonia',
      );
      expect(_thinkingLevelOf(sentBodies.last), 'high');

      await service.generateClinicalRulesFromGuideline(
        'Metformin is contraindicated in severe renal impairment.',
      );
      expect(_thinkingLevelOf(sentBodies.last), 'high');
    });
  });

  group('Sprint 27: 400/500 fallback validation', () {
    test('a rogue legacy parameter (400 INVALID_ARGUMENT) surfaces as a typed '
        'non-blocking error', () async {
      var calls = 0;
      final service = DocumentAiService(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          calls++;
          return http.Response(
            jsonEncode({
              'error': {
                'code': 400,
                'message':
                    'Unknown name "temperature" at \'generation_config\'',
                'status': 'INVALID_ARGUMENT',
              },
            }),
            400,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await expectLater(
        service.generateClinicalInsights('chart summary'),
        throwsA(
          isA<DocumentAiException>()
              .having(
                (error) => error.type,
                'type',
                DocumentAiErrorType.invalidRequest,
              )
              .having(
                (error) => error.message,
                'message',
                contains('INVALID_ARGUMENT'),
              )
              .having((error) => error.retryable, 'retryable', isFalse),
        ),
      );
      // Primary + fallback model, exactly once each — never a retry storm.
      expect(calls, 2);
    });

    test('a 500 outage classifies as a retryable server error', () async {
      final service = DocumentAiService(
        apiKey: 'test-key',
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'error': {
                'code': 500,
                'message': 'Internal error',
                'status': 'INTERNAL',
              },
            }),
            500,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      await expectLater(
        service.generateClinicalInsights('chart summary'),
        throwsA(
          isA<DocumentAiException>()
              .having((error) => error.type, 'type', DocumentAiErrorType.server)
              .having((error) => error.retryable, 'retryable', isTrue),
        ),
      );
    });

    test('classifyError maps plain 400/500/network markers for callers', () {
      final invalid = DocumentAiService.classifyError(
        '400: INVALID_ARGUMENT: Unknown name "top_p"',
        model: DocumentAiService.defaultModel,
      );
      expect(invalid.type, DocumentAiErrorType.invalidRequest);
      expect(invalid.retryable, isFalse);
      expect(DocumentAiService.shouldTryFallbackModel(invalid), isTrue);

      final server = DocumentAiService.classifyError(
        '500: internal server error',
        model: DocumentAiService.defaultModel,
      );
      expect(server.type, DocumentAiErrorType.server);
      expect(server.retryable, isTrue);

      final network = DocumentAiService.classifyError(
        'network: request to interactions failed: SocketException(refused)',
        model: DocumentAiService.defaultModel,
      );
      expect(network.type, DocumentAiErrorType.network);
      expect(network.retryable, isTrue);
    });
  });
}

/// Captures the tier the pipeline routes into `extractDocument`.
class _TierCapturingAiService extends DocumentAiService {
  _TierCapturingAiService() : super(apiKey: 'test-key');

  ThinkingLevel? lastThinkingLevel;

  @override
  Future<AiExtractionResult> extractDocument({
    required File? image,
    required String prompt,
    ThinkingLevel thinkingLevel = ThinkingLevel.medium,
  }) async {
    lastThinkingLevel = thinkingLevel;
    return const AiExtractionResult();
  }
}
