import 'dart:convert';
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

/// A GA Interactions API response (`steps` timeline + `output_text`).
String interactionsResponseBody(
  String outputText, {
  bool includeOutputText = true,
}) =>
    jsonEncode({
      'id': 'int_sprint27_test',
      'object': 'interaction',
      'status': 'completed',
      if (includeOutputText) 'output_text': outputText,
      'steps': [
        {
          'type': 'user_input',
          'status': 'done',
          'content': [
            {'type': 'text', 'text': 'clinician prompt'},
          ],
        },
        {
          'type': 'model_output',
          'status': 'done',
          'content': [
            {'type': 'text', 'text': outputText},
          ],
        },
      ],
      'usage': {
        'total_input_tokens': 120,
        'total_output_tokens': 80,
        'total_tokens': 200,
      },
    });

/// Minimal valid ClinicalRuleSuggestion payload for mocked responses.
Map<String, dynamic> _ruleJson({required String triggerValue}) => <String, dynamic>{
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
  final input = body['input'];
  if (input is String) return input;
  if (input is List) {
    final buffer = StringBuffer();
    for (final block in input) {
      if (block is Map && block['type'] == 'text') {
        buffer.writeln(block['text']);
      }
    }
    return buffer.toString();
  }
  return '';
}

String? _thinkingLevelOf(Map<String, dynamic> body) {
  final config = body['generation_config'];
  return config is Map ? config['thinking_level'] as String? : null;
}

void main() {
  group('Sprint 27: Interactions request payload', () {
    test('targets the stable GA endpoint with the latest supported model', () {
      expect(
        InteractionsApiClient.endpoint,
        'https://generativelanguage.googleapis.com/v1/interactions',
      );
      expect(DocumentAiService.defaultModel, 'gemini-3.8-flash');
      expect(
        DocumentAiService.fallbackModel,
        isNot(DocumentAiService.defaultModel),
      );
    });

    test(
      'payload carries response_format + thinking_level and purges every '
      'deprecated sampling parameter',
      () {
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

        expect(body['model'], 'gemini-3.8-flash');
        // Stateless: clinical text must not be retained server-side.
        expect(body['store'], isFalse);
        expect(
          body['response_format'],
          <String, dynamic>{
            'type': 'text',
            'mime_type': 'application/json',
            'schema': <String, dynamic>{
              'type': 'object',
              'properties': <String, dynamic>{
                'diagnosis': <String, dynamic>{'type': 'string'},
              },
              'required': <String>['diagnosis'],
            },
          },
        );
        expect(
          body['generation_config'],
          <String, dynamic>{'thinking_level': 'medium'},
        );

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
        expect(body.containsKey('generationConfig'), isFalse);
        expect(body.containsKey('candidates'), isFalse);
      },
    );

    test('every adaptive-compute tier maps to a valid thinking_level value', () {
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
        expect(
          (body['generation_config'] as Map)['thinking_level'],
          tier.value,
        );
      }
    });
  });

  group('Sprint 27: Interactions response parsing', () {
    test('reads output_text and the steps timeline from a GA response',
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
      expect(captured!.url.toString(), InteractionsApiClient.endpoint);
      expect(captured!.headers['x-goog-api-key'], 'test-key');
      final sent = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(sent['model'], 'gemini-3.8-flash');
      expect((sent['generation_config'] as Map)['thinking_level'], 'high');
      for (final banned in kDeprecatedGenerationParameters) {
        expect(sent.containsKey(banned), isFalse);
      }
    });

    test('falls back to the steps array when output_text is absent', () async {
      final client = InteractionsApiClient(
        apiKey: 'test-key',
        client: MockClient(
          (request) async => http.Response(
            interactionsResponseBody(
              '{"raw_ocr_transcript":"lab report"}',
              includeOutputText: false,
            ),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      final result = await client.create(
        model: DocumentAiService.defaultModel,
        prompt: 'digest the report',
      );
      expect(result.text, '{"raw_ocr_transcript":"lab report"}');
    });

    test(
      'a legacy generateContent candidates payload fails cleanly as an empty '
      'response instead of crashing',
      () async {
        final service = DocumentAiService(
          apiKey: 'test-key',
          httpClient: MockClient(
            (request) async => http.Response(
              jsonEncode({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {'text': 'legacy'},
                      ],
                    },
                  },
                ],
              }),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );

        await expectLater(
          service.generateClinicalInsights('chart summary'),
          throwsA(
            isA<DocumentAiException>().having(
              (error) => error.type,
              'type',
              DocumentAiErrorType.emptyResponse,
            ),
          ),
        );
      },
    );
  });

  group('Sprint 27: adaptive thinking-level routing', () {
    test('pipeline text routing (Sprint 21) requests the low tier', () async {
      final ai = _TierCapturingAiService();
      final pipeline = ExtractionPipelineService(ai);

      await pipeline.processTextWithProvenance(_denseClinicalTranscript);

      expect(ai.lastThinkingLevel, ThinkingLevel.low);
    });

    test(
      'document refinement (Sprint 19 POMR structuring) requests the medium '
      'tier',
      () async {
        final ai = _TierCapturingAiService();
        final pipeline = ExtractionPipelineService(ai);

        await pipeline.refineWithAi(
          File('chart.png'),
          _denseClinicalTranscript,
        );

        expect(ai.lastThinkingLevel, ThinkingLevel.medium);
      },
    );

    test(
      'chart audit defaults to medium; DDx rule generation and guideline '
      'contraindication mining default to high',
      () async {
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
              output = {'rules': [_ruleJson(triggerValue: 'Metformin')]};
            } else {
              output = _ruleJson(
                triggerValue: 'Community acquired pneumonia',
              );
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
      },
    );
  });

  group('Sprint 27: 400/500 fallback validation', () {
    test(
      'a rogue legacy parameter (400 INVALID_ARGUMENT) surfaces as a typed '
      'non-blocking error',
      () async {
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
                .having(
                  (error) => error.retryable,
                  'retryable',
                  isFalse,
                ),
          ),
        );
        // Primary + fallback model, exactly once each — never a retry storm.
        expect(calls, 2);
      },
    );

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
              .having(
                (error) => error.type,
                'type',
                DocumentAiErrorType.server,
              )
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
