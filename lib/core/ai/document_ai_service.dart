import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;

import 'package:http/http.dart' as http;

import '../database/daos/pharmacopeia_dao.dart';
import '../models/ai_extraction_result.dart';
import '../models/clinical_insight.dart';
import '../models/clinical_rule_suggestion.dart';
import 'ai_schema.dart';
import 'clinical_prompts.dart';
import 'interactions_api_client.dart';

export 'interactions_api_client.dart' show ThinkingLevel;

/// JSON decoding is CPU work and can be substantial for multi-page results.
/// Keep it off the UI isolate after the network response has arrived.
///
/// Sprint 28 — the Interactions model sometimes wraps the payload in
/// markdown fences (```json ... ```) or prepends prose; both present as
/// "malformed or schema-invalid data". The sanitizer strips fences and
/// extracts the outermost JSON object before decoding.
String sanitizeStructuredJsonText(String source) {
  var text = source.trim();
  if (text.isEmpty) return text;
  // Strip ```json ... ``` / ``` ... ``` fences (possibly multiple).
  final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
  final fenceMatch = fence.firstMatch(text);
  if (fenceMatch != null) {
    text = fenceMatch.group(1)!.trim();
  }
  if (text.startsWith('{') && text.endsWith('}')) return text;
  // Fall back to the outermost {...} span when prose surrounds the payload.
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start >= 0 && end > start) {
    return text.substring(start, end + 1).trim();
  }
  return text;
}

Map<String, dynamic> _decodeStructuredJson(String source) {
  final sanitized = sanitizeStructuredJsonText(source);
  final decoded = jsonDecode(sanitized);
  if (decoded is! Map) {
    throw const FormatException('Expected a JSON object.');
  }
  return Map<String, dynamic>.from(decoded);
}

enum DocumentAiErrorType {
  configuration,
  invalidRequest,
  authentication,
  permissionDenied,
  modelNotFound,
  rateLimited,
  network,
  timeout,
  server,
  emptyResponse,
  malformedJson,
  schemaViolation,
  imageInvalid,
  imageTooLarge,
  unknown,
}

class DocumentAiException implements Exception {
  const DocumentAiException(
    this.message, {
    this.type = DocumentAiErrorType.unknown,
    this.cause,
    this.retryable = false,
    this.retryAfterMs,
    this.requestId,
  });

  final String message;
  final DocumentAiErrorType type;
  final Object? cause;
  final bool retryable;
  final int? retryAfterMs;
  final String? requestId;

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (type != DocumentAiErrorType.unknown) {
      buffer.write(' [${type.name}]');
    }
    if (cause != null) {
      buffer.write(' [Cause: $cause]');
    }
    if (retryable) {
      buffer.write(' [retryable]');
    }
    if (requestId != null) {
      buffer.write(' [request: $requestId]');
    }
    return buffer.toString();
  }
}

class DocumentAiService {
  /// [httpClient] lets tests inject a mock Interactions transport; production
  /// code relies on the default `http.Client`.
  DocumentAiService({this.apiKey = '', http.Client? httpClient})
    : _interactions = InteractionsApiClient(apiKey: apiKey, client: httpClient);

  // Sprint 27 — GA Interactions API targets. `gemini-3.8-flash` is the latest
  // Flash release; `gemini-3.7-flash` is on the stable /v1 model list, so a
  // model-specific failure on the primary always has somewhere to escalate
  // (see [shouldEscalateToFallback]).
  static const String defaultModel = 'gemini-3.8-flash';
  static const String fallbackModel = 'gemini-3.7-flash';
  static const int maxAttempts = 3;

  final String apiKey;
  final InteractionsApiClient _interactions;

  /// Audits a chart summary and returns concise, evidence-grounded
  /// recommendations. The caller runs this asynchronously and surfaces any
  /// configuration/network errors to the clinician.
  ///
  /// [thinkingLevel] routes adaptive compute (Sprint 27). Chart audits
  /// default to `medium`: standard POMR linkage without the deep-literature
  /// cost of `high`.
  Future<List<ClinicalInsight>> generateClinicalInsights(
    String chartSummary, {
    ThinkingLevel thinkingLevel = ThinkingLevel.medium,
  }) async {
    if (chartSummary.trim().isEmpty) {
      throw ArgumentError.value(
        chartSummary,
        'chartSummary',
        'A chart summary is required for audit.',
      );
    }
    final schema = Schema.object(
      properties: {
        'clinical_insights': Schema.array(
          items: Schema.object(
            properties: {
              'type': Schema.enumString(
                enumValues: [
                  'missing_investigation',
                  'management_suggestion',
                  'differential_diagnosis',
                  'warning',
                ],
              ),
              'title': Schema.string(),
              'reasoning': Schema.string(),
              'actionable_items': Schema.array(items: Schema.string()),
            },
            requiredProperties: [
              'type',
              'title',
              'reasoning',
              'actionable_items',
            ],
          ),
        ),
      },
      requiredProperties: ['clinical_insights'],
    );
    final response = await _extractStructuredJson(
      image: null,
      thinkingLevel: thinkingLevel,
      prompt:
          '''
You are an elite academic attending physician auditing a patient's chart.
Review active problems, medications, and investigation results to catch
cognitive blind spots. Identify missing standard-of-care investigations,
cost-effective next steps, and conflicting treatments. Every suggestion MUST
include a brief, evidence-based rationale. Be specific to the information
present; do not invent patient history, results, or diagnoses. Avoid duplicate
tests already completed or active. Return an empty array when no actionable
gap or safety concern is supported. Recommendations are decision support, not
orders; a clinician must review each item.

Return JSON matching the clinical_insights schema. Each insight has:
- type: missing_investigation, management_suggestion,
  differential_diagnosis, or warning
- title: concise clinician-facing title
- reasoning: short rationale referencing standard-of-care evidence
- actionable_items: standardized laboratory or medication names to order, or
  an empty array when no order is appropriate

PATIENT CHART SUMMARY:
$chartSummary
''',
      schema: schema,
      validator: (json) {
        final raw = json['clinical_insights'];
        if (raw is! List) {
          throw const FormatException(
            'Clinical audit response omitted clinical_insights.',
          );
        }
        for (final item in raw) {
          if (item is! Map) {
            throw const FormatException(
              'Clinical audit insight must be a JSON object.',
            );
          }
          ClinicalInsight.fromJson(Map<String, dynamic>.from(item));
        }
        return json;
      },
    );
    return (response['clinical_insights']! as List)
        .map(
          (item) =>
              ClinicalInsight.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  /// Generates a reusable, patient-independent rule for a single clinical
  /// trigger. The caller only invokes this after a local cache miss.
  ///
  /// [thinkingLevel] defaults to `high` — this call powers the Proactive
  /// Clinical Navigator's DDx generation (Sprint 25) and the Multi-Variable
  /// Guardrails' contraindication reasoning (Sprint 24), both of which need
  /// deep clinical-literature reasoning.
  Future<ClinicalRuleSuggestion> generateClinicalRule({
    required String triggerType,
    required String triggerValue,
    ThinkingLevel thinkingLevel = ThinkingLevel.high,
  }) async {
    final normalizedType = triggerType.trim().toLowerCase();
    final value = triggerValue.trim();
    if (normalizedType != 'diagnosis' &&
        normalizedType != 'symptom' &&
        normalizedType != 'medication') {
      throw ArgumentError.value(triggerType, 'triggerType');
    }
    if (value.isEmpty) {
      throw ArgumentError.value(triggerValue, 'triggerValue');
    }

    final schema = Schema.object(
      properties: {
        'trigger_type': Schema.string(),
        'trigger_value': Schema.string(),
        'suggested_action': Schema.string(),
        'evidence_rationale': Schema.string(),
        'contraindicating_conditions': Schema.array(items: Schema.string()),
        'required_monitoring': Schema.array(items: Schema.string()),
        'differential_diagnoses': Schema.array(items: Schema.string()),
        'recommended_investigations': Schema.array(items: Schema.string()),
        'recommended_management': Schema.array(items: Schema.string()),
        'source_reference': Schema.string(),
      },
      requiredProperties: [
        'trigger_type',
        'trigger_value',
        'suggested_action',
        'evidence_rationale',
        'contraindicating_conditions',
        'required_monitoring',
        'differential_diagnoses',
        'recommended_investigations',
        'recommended_management',
        'source_reference',
      ],
    );
    final response = await _extractStructuredJson(
      image: null,
      thinkingLevel: thinkingLevel,
      prompt:
          '''
You are an elite clinical informatician. The clinician just logged the
$normalizedType "$value". Generate an evidence-based universal pathway with
an ordered differential diagnosis, investigations that narrow the
differential, and initial management suggestions.

Use only the trigger provided. Do not infer or mention patient-specific
demographics, history, results, or other clinical context. Keep lists focused
and ordered by clinical priority. If evidence is uncertain, say so in the
rationale rather than inventing certainty. Include contraindications and
monitoring when relevant. The clinician must verify the pathway before it
becomes active.

Return JSON with exactly these fields:
- trigger_type: "$normalizedType"
- trigger_value: "$value"
- suggested_action: concise clinician-facing action or safety warning
- evidence_rationale: concise rationale grounded in standard-of-care evidence
- contraindicating_conditions: strict conditions where this action must not
  proceed, as concise strings (empty array when none are stated)
- required_monitoring: parameters to check or monitor (empty array when none
  are stated)
- differential_diagnoses: ordered likely diagnoses for this trigger
- recommended_investigations: specific investigations to narrow the DDx
- recommended_management: initial evidence-based drugs or procedures
- source_reference: guideline, trial, or other source when identified, else
  "Not specified"
''',
      schema: schema,
      validator: (json) {
        final suggestion = ClinicalRuleSuggestion.fromJson(json);
        if (suggestion.triggerType != normalizedType ||
            suggestion.triggerValue.toLowerCase() != value.toLowerCase()) {
          throw const FormatException(
            'Clinical rule response changed its requested trigger.',
          );
        }
        if (suggestion.differentialDiagnoses.isEmpty &&
            suggestion.recommendedInvestigations.isEmpty &&
            suggestion.recommendedManagement.isEmpty) {
          throw const FormatException(
            'Clinical rule response omitted pathway suggestions.',
          );
        }
        return json;
      },
    );
    return ClinicalRuleSuggestion.fromJson(response);
  }

  /// Extracts reusable contraindication and monitoring rules from clinician-
  /// supplied medical literature.
  ///
  /// [thinkingLevel] defaults to `high`: mining contraindication thresholds
  /// and monitoring parameters from source literature is a Multi-Variable
  /// Guardrails task (Sprint 24) that must not be truncated by shallow
  /// reasoning.
  Future<List<ClinicalRuleSuggestion>> generateClinicalRulesFromGuideline(
    String sourceText, {
    ThinkingLevel thinkingLevel = ThinkingLevel.high,
  }) async {
    if (sourceText.trim().isEmpty) {
      throw ArgumentError.value(sourceText, 'sourceText');
    }
    final schema = Schema.object(
      properties: {
        'rules': Schema.array(
          items: Schema.object(
            properties: {
              'trigger_type': Schema.string(),
              'trigger_value': Schema.string(),
              'suggested_action': Schema.string(),
              'evidence_rationale': Schema.string(),
              'contraindicating_conditions': Schema.array(
                items: Schema.string(),
              ),
              'required_monitoring': Schema.array(items: Schema.string()),
              'differential_diagnoses': Schema.array(
                items: Schema.string(),
              ),
              'recommended_investigations': Schema.array(
                items: Schema.string(),
              ),
              'recommended_management': Schema.array(
                items: Schema.string(),
              ),
              'source_reference': Schema.string(),
            },
            requiredProperties: [
              'trigger_type',
              'trigger_value',
              'suggested_action',
              'evidence_rationale',
              'contraindicating_conditions',
              'required_monitoring',
              'differential_diagnoses',
              'recommended_investigations',
              'recommended_management',
              'source_reference',
            ],
          ),
        ),
      },
      requiredProperties: ['rules'],
    );
    final response = await _extractStructuredJson(
      image: null,
      prompt:
          '''
You are an elite Medical Informatician. Extract reusable proactive pathways
from the supplied medical literature. Identify triggers such as conditions,
symptoms, or medications. For each trigger, output an ordered, data-backed
differential diagnosis and the next best investigations and initial management
steps. Include contraindicating conditions and monitoring when supported by
the source. Only include recommendations supported by the supplied text; do
not invent recommendations or patient-specific facts. Preserve clinically
meaningful thresholds and qualifiers. Include a concise rationale and source
reference. Split distinct triggers into separate rules and return an empty
array when no defensible pathway is present.

Each rule must contain:
- trigger_type: "diagnosis", "symptom", or "medication"
- trigger_value: canonical diagnosis or medication
- suggested_action: concise action overview
- evidence_rationale: concise rationale grounded in the supplied literature
- contraindicating_conditions: string array; use "allergy: <substance>" for
  allergy restrictions and retain numeric thresholds
- required_monitoring: string array of monitoring parameters
- differential_diagnoses: ordered likely alternatives
- recommended_investigations: prioritized specific labs or imaging
- recommended_management: prioritized drugs or procedures
- source_reference: named guideline/trial or "Not specified"

MEDICAL LITERATURE:
$sourceText
''',
      schema: schema,
      thinkingLevel: thinkingLevel,
      validator: (json) {
        final rawRules = json['rules'];
        if (rawRules is! List) {
          throw const FormatException(
            'Guideline extraction response omitted rules.',
          );
        }
        for (final rawRule in rawRules) {
          if (rawRule is! Map) {
            throw const FormatException(
              'Guideline extraction rule must be a JSON object.',
            );
          }
          ClinicalRuleSuggestion.fromJson(Map<String, dynamic>.from(rawRule));
        }
        return json;
      },
    );
    return (response['rules']! as List)
        .map(
          (rule) => ClinicalRuleSuggestion.fromJson(
            Map<String, dynamic>.from(rule as Map),
          ),
        )
        .toList(growable: false);
  }

  static bool shouldEscalateToFallback(Object error) {
    // Classified exceptions carry the authoritative signal: only a genuine
    // "this model does not exist" answer means the fallback model may help.
    // (String matching on the wrapper message would false-positive on any
    // text that merely mentions a model name.)
    if (error is DocumentAiException) {
      return error.type == DocumentAiErrorType.modelNotFound;
    }

    final text = error.toString().toLowerCase();
    final mentionsModel =
        text.contains('model') ||
        text.contains('gemini') ||
        text.contains('flash');
    if (!mentionsModel) return false;
    return text.contains('model not found') ||
        text.contains('model unavailable') ||
        text.contains('unsupported model') ||
        text.contains('404');
  }

  /// Failures a *different* Gemini model is likely to fix. Account-wide
  /// problems (missing key, rate limit, network) are deliberately excluded so
  /// we never burn quota repeating an identical failure on a second model.
  static bool shouldTryFallbackModel(Object error) {
    if (shouldEscalateToFallback(error)) return true;
    if (error is! DocumentAiException) return false;
    return switch (error.type) {
      DocumentAiErrorType.schemaViolation ||
      DocumentAiErrorType.malformedJson ||
      DocumentAiErrorType.emptyResponse ||
      DocumentAiErrorType.server ||
      DocumentAiErrorType.invalidRequest ||
      DocumentAiErrorType.unknown => true,
      DocumentAiErrorType.configuration ||
      DocumentAiErrorType.authentication ||
      DocumentAiErrorType.permissionDenied ||
      DocumentAiErrorType.rateLimited ||
      DocumentAiErrorType.network ||
      DocumentAiErrorType.timeout ||
      DocumentAiErrorType.modelNotFound ||
      DocumentAiErrorType.imageInvalid ||
      DocumentAiErrorType.imageTooLarge => false,
    };
  }

  static DocumentAiException classifyError(
    Object error, {
    required String model,
  }) => _classifyError(error, model: model);

  String _mimeType(File image) {
    final extension = path.extension(image.path).toLowerCase();
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
      case '.heif':
        return 'image/heic';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }

  Future<File> _prepareImage(File image) async {
    if (!await image.exists()) {
      throw const DocumentAiException(
        'The selected image is no longer available.',
        type: DocumentAiErrorType.imageInvalid,
      );
    }

    final sizeInBytes = await image.length();
    if (sizeInBytes <= 0) {
      throw const DocumentAiException(
        'The selected image is empty.',
        type: DocumentAiErrorType.imageInvalid,
      );
    }

    if (sizeInBytes > 20 * 1024 * 1024) {
      throw const DocumentAiException(
        'The selected image is too large for reliable ClinCom extraction.',
        type: DocumentAiErrorType.imageTooLarge,
      );
    }

    return image;
  }

  static DocumentAiException _classifyError(
    Object error, {
    required String model,
  }) {
    final text = error.toString().toLowerCase();

    if (error is SocketException ||
        text.contains('socket') ||
        text.contains('failed host lookup') ||
        // Sprint 27: the Interactions client prefixes wrapped transport
        // failures with 'network:' so they never fall through to `unknown`.
        text.contains('network')) {
      return DocumentAiException(
        'Network connectivity failed. Please verify internet connection.',
        type: DocumentAiErrorType.network,
        cause: error,
        retryable: true,
      );
    }
    if (text.contains('api key') ||
        text.contains('api_key') ||
        text.contains('invalid api key')) {
      return DocumentAiException(
        'AI configuration is invalid or API key is missing.',
        type: DocumentAiErrorType.configuration,
        cause: error,
      );
    }
    if (text.contains('429') ||
        text.contains('rate limit') ||
        text.contains('quota') ||
        text.contains('resource_exhausted')) {
      return DocumentAiException(
        'AI rate limit or quota reached. Please wait a moment.',
        type: DocumentAiErrorType.rateLimited,
        cause: error,
        retryable: true,
        retryAfterMs: 2000,
      );
    }
    if (text.contains('401') ||
        text.contains('403') ||
        text.contains('permission') ||
        text.contains('unauthenticated')) {
      return DocumentAiException(
        'AI access is not authorized. Check your API key credentials.',
        type: DocumentAiErrorType.authentication,
        cause: error,
      );
    }
    // Sprint 27 — authoritative HTTP status carried by the Interactions
    // transport. 400 INVALID_ARGUMENT is how the GA API reports a removed
    // parameter (temperature, top_p, top_k, thinking_budget) or any other
    // malformed field. Classify it as an invalid request so callers surface
    // a clean, non-blocking message instead of crashing the Encounter UI.
    if (error is InteractionsApiException && error.statusCode != null) {
      final status = error.statusCode!;
      if (status == 400) {
        return DocumentAiException(
          "ClinCom's AI request was rejected as invalid (400 INVALID_ARGUMENT). "
          'A legacy sampling parameter (temperature, top_p, top_k, '
          'thinking_budget) is no longer accepted by the Interactions API.',
          type: DocumentAiErrorType.invalidRequest,
          cause: error,
        );
      }
      if (status == 401 || status == 403) {
        return DocumentAiException(
          'AI access is not authorized. Check your API key credentials.',
          type: DocumentAiErrorType.authentication,
          cause: error,
        );
      }
      if (status == 429) {
        return DocumentAiException(
          'AI rate limit or quota reached. Please wait a moment.',
          type: DocumentAiErrorType.rateLimited,
          cause: error,
          retryable: true,
          retryAfterMs: 2000,
        );
      }
      if (status >= 500) {
        return DocumentAiException(
          'AI service is temporarily unavailable.',
          type: DocumentAiErrorType.server,
          cause: error,
          retryable: true,
        );
      }
      // 404 falls through: only a model-flavoured 404 escalates the fallback.
    } else if (error is! InteractionsApiException &&
        (text.contains('invalid_argument') || text.contains('400'))) {
      // Plain-string simulation of an INVALID_ARGUMENT failure (tests and
      // any transport that lost its status code).
      return DocumentAiException(
        "ClinCom's AI request was rejected as invalid (400 INVALID_ARGUMENT). "
        'A legacy sampling parameter (temperature, top_p, top_k, '
        'thinking_budget) is no longer accepted by the Interactions API.',
        type: DocumentAiErrorType.invalidRequest,
        cause: error,
      );
    }
    // A 404 only means "model missing" when the payload actually talks about a
    // model. A stray "404: patient record not found" must stay a plain error,
    // otherwise we escalate to the fallback model for the wrong reason.
    final mentionsModel =
        text.contains('model') ||
        text.contains('gemini') ||
        text.contains('flash');
    if (mentionsModel &&
        (text.contains('404') ||
            text.contains('model not found') ||
            text.contains('model unavailable') ||
            text.contains('unsupported model') ||
            text.contains('not_found'))) {
      return DocumentAiException(
        'The configured ClinCom model ($model) is unavailable.',
        type: DocumentAiErrorType.modelNotFound,
        cause: error,
      );
    }
    if (text.contains('timeout')) {
      return DocumentAiException(
        'AI request timed out. Please try again.',
        type: DocumentAiErrorType.timeout,
        cause: error,
        retryable: true,
      );
    }
    if (text.contains('500') || text.contains('server')) {
      return DocumentAiException(
        'AI service is temporarily unavailable.',
        type: DocumentAiErrorType.server,
        cause: error,
        retryable: true,
      );
    }
    if (text.contains('schema') || text.contains('json')) {
      return DocumentAiException(
        'AI returned malformed or schema-invalid data.',
        type: DocumentAiErrorType.schemaViolation,
        cause: error,
      );
    }
    if (text.contains('empty')) {
      return DocumentAiException(
        'AI returned no usable content.',
        type: DocumentAiErrorType.emptyResponse,
        cause: error,
      );
    }
    if (error is DocumentAiException) {
      return error;
    }
    return DocumentAiException(
      'AI extraction failed while using model $model: $error',
      type: DocumentAiErrorType.unknown,
      cause: error,
    );
  }

  /// Runs [request] against [modelName] and, when the failure looks specific
  /// to that model, retries the whole request against [fallbackModel].
  ///
  /// Each model gets its own retry budget so an escalation can never be
  /// starved by earlier attempts (the previous implementation shared one
  /// counter and could exhaust it before ever reaching the fallback model).
  Future<T> _executeWithRetry<T>({
    required Future<T> Function(String model) request,
    required String modelName,
  }) async {
    final models = fallbackModel == modelName
        ? <String>[modelName]
        : <String>[modelName, fallbackModel];

    Object? lastError;
    for (var m = 0; m < models.length; m++) {
      final currentModel = models[m];
      final isLastModel = m == models.length - 1;

      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          return await request(currentModel);
        } on DocumentAiException catch (error) {
          lastError = error;

          // Hand the request to the next model as soon as this one looks
          // broken in a model-specific way.
          if (!isLastModel && shouldTryFallbackModel(error)) {
            break;
          }

          final canRetrySameModel = error.retryable && attempt < maxAttempts;
          if (canRetrySameModel) {
            final backoffMs = 500 * (1 << (attempt - 1));
            await Future<void>.delayed(Duration(milliseconds: backoffMs));
            continue;
          }
          rethrow;
        }
      }
    }

    if (lastError is DocumentAiException) throw lastError;
    throw const DocumentAiException(
      'AI extraction failed after multiple attempts.',
      type: DocumentAiErrorType.server,
      retryable: false,
    );
  }

  Future<void> routeMedicationKnowledge({
    required AiExtractionResult result,
    required PharmacopeiaDao pharmacopeiaDao,
    required String ownerId,
  }) async {
    for (final medication in result.medicationsMentioned) {
      await pharmacopeiaDao.upsertLearnedDrug(
        brand: medication.brand,
        generic: medication.generic,
        dose: medication.dose,
        problemNames: result.identifiedProblems,
        ownerId: ownerId,
      );
    }
  }

  Future<Map<String, dynamic>> _extractStructuredJson({
    required File? image,
    required String prompt,
    required Schema schema,
    required ThinkingLevel thinkingLevel,
    required Map<String, dynamic> Function(Map<String, dynamic>) validator,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const DocumentAiException(
        'No Gemini API key configured. Open Settings → Configuration and save '
        'your Gemini key, then retry.',
        type: DocumentAiErrorType.configuration,
      );
    }

    // Sprint 17 — ClinCom's cost-optimising text-only path. When the on-device
    // OCR was dense and confident we skip the image entirely: no base64 upload,
    // no vision tokens. `image` is null on that path.
    final preparedImage = image == null ? null : await _prepareImage(image);
    final mimeType = preparedImage == null ? null : _mimeType(preparedImage);

    Future<Map<String, dynamic>> request(String modelName) async {
      try {
        // Sprint 27 — one GA Interactions call replaces the legacy
        // `GenerativeModel.generateContent` flow. The payload carries NO
        // sampling knobs (temperature/top_p/top_k/thinking_budget are gone);
        // structured output rides in `response_format` and reasoning depth in
        // `generation_config.thinking_level`.
        final interaction = await _interactions.create(
          model: modelName,
          prompt:
              '$prompt\n'
              'STRICT OUTPUT CONTRACT: Return ONLY raw JSON matching the requested schema. '
              'Do not wrap the payload in markdown fences, do not prepend or append prose, '
              'and do not invent or infer values that are not visible in the source. '
              'Use null for missing values and preserve the original source wording. '
              'The response MIME type is application/json.',
          imageBytes: preparedImage == null
              ? null
              : await preparedImage.readAsBytes(),
          imageMimeType: mimeType,
          jsonSchema: schema.toJson(),
          thinkingLevel: thinkingLevel,
        );

        final text = interaction.text;
        if (text.trim().isEmpty) {
          throw const DocumentAiException(
            'ClinCom returned an empty document result.',
            type: DocumentAiErrorType.emptyResponse,
          );
        }

        Map<String, dynamic> decoded;
        try {
          decoded = await Isolate.run(() => _decodeStructuredJson(text));
        } on FormatException {
          throw const DocumentAiException(
            'ClinCom returned malformed or schema-invalid data. The result was '
            'sanitized and re-parsed, but no valid JSON object was found.',
            type: DocumentAiErrorType.malformedJson,
          );
        }

        final normalized = validator(decoded);
        return normalized;
      } on DocumentAiException {
        rethrow;
      } catch (error) {
        throw classifyError(error, model: modelName);
      }
    }

    return _executeWithRetry(request: request, modelName: defaultModel);
  }

  /// Sprint 17 — nullable [image] enables ClinCom's text-only path.
  ///
  /// [thinkingLevel] routes adaptive compute: defaults to `medium` for
  /// Sprint 19 POMR structuring (linking medications to known problems);
  /// the Sprint 21 Omni-Schema text/OCR routing passes `low` explicitly.
  Future<AiExtractionResult> extractDocument({
    required File? image,
    required String prompt,
    ThinkingLevel thinkingLevel = ThinkingLevel.medium,
  }) async {
    final schema = Schema.object(
      properties: {
        'inferredPatientDemographics': Schema.object(
          properties: {
            'name': Schema.string(nullable: true),
            'age': Schema.integer(nullable: true),
            'gender': Schema.string(nullable: true),
            'mrn': Schema.string(nullable: true),
          },
        ),
        'encounterDetails': Schema.object(
          properties: {
            'date': Schema.string(nullable: true),
            'type': Schema.string(
              description: 'One of OPD, IPD, ER, or Clinical Note.',
            ),
            'department': Schema.string(nullable: true),
            'ward_bed': Schema.string(nullable: true),
            'vitals': Schema.object(
              properties: {
                'sbp': Schema.integer(nullable: true),
                'dbp': Schema.integer(nullable: true),
                'pulse': Schema.integer(nullable: true),
                'spo2': Schema.integer(nullable: true),
                'temperature_c': Schema.number(nullable: true),
                'respiratory_rate': Schema.integer(nullable: true),
                'map': Schema.number(nullable: true),
              },
            ),
          },
        ),
        'pomr_data': Schema.array(
          items: Schema.object(
            properties: {
              'diagnosis': Schema.string(),
              'linked_medications': Schema.array(
                items: Schema.object(
                  properties: {
                    'name': Schema.string(),
                    'dose': Schema.string(nullable: true),
                    'frequency': Schema.string(nullable: true),
                    'route': Schema.string(nullable: true),
                    'duration': Schema.string(nullable: true),
                  },
                ),
              ),
              'linked_investigations': Schema.array(
                items: Schema.object(
                  properties: {
                    'test_name': Schema.string(),
                    'value': Schema.string(),
                    'unit': Schema.string(nullable: true),
                    'is_abnormal': Schema.boolean(),
                  },
                ),
              ),
              'linked_procedures': Schema.array(
                items: Schema.object(
                  properties: {'procedure_name': Schema.string()},
                ),
              ),
              'reasoning': Schema.string(),
            },
          ),
        ),
        'unlinked_data': Schema.object(
          properties: {
            'medications': Schema.array(
              items: Schema.object(
                properties: {
                  'name': Schema.string(),
                  'dose': Schema.string(nullable: true),
                  'frequency': Schema.string(nullable: true),
                  'route': Schema.string(nullable: true),
                  'duration': Schema.string(nullable: true),
                },
              ),
            ),
            'investigations': Schema.array(
              items: Schema.object(
                properties: {
                  'test_name': Schema.string(),
                  'value': Schema.string(),
                  'unit': Schema.string(nullable: true),
                  'is_abnormal': Schema.boolean(),
                },
              ),
            ),
            'procedures': Schema.array(
              items: Schema.object(
                properties: {'procedure_name': Schema.string()},
              ),
            ),
          },
        ),
        // Resolved from bed/ward number via the appended active census JSON.
        'inferred_patient_id': Schema.string(nullable: true),
        'chief_complaints': Schema.array(items: Schema.string()),
        // Source authority, drives semantic merging: a formal Scanned Document
        // report outranks a hastily jotted Ward Round Note for the same test.
        'source_authority': Schema.string(
          nullable: true,
          description:
              'One of: Ward Round Note, Scanned Document, Typed Note, Unknown.',
        ),
        'clinical_summary': Schema.string(),
        'conclusion': Schema.string(),
      },
    );

    final raw = await _extractStructuredJson(
      image: image,
      prompt: prompt,
      schema: schema,
      thinkingLevel: thinkingLevel,
      validator: (value) => value,
    );
    return AiExtractionResult.fromJson(raw);
  }

  /// Structured digest of a single clinical document category.
  /// [thinkingLevel] defaults to `medium` (standard document structuring).
  Future<Map<String, dynamic>> extractClinicalDocument({
    required File image,
    required ClinicalDocumentCategory category,
    ThinkingLevel thinkingLevel = ThinkingLevel.medium,
  }) async {
    final prompt = ClinicalPromptContracts.promptFor(category);
    final schema = ClinicalPromptContracts.responseSchemaFor(category);

    return _extractStructuredJson(
      image: image,
      prompt: prompt,
      schema: schema,
      thinkingLevel: thinkingLevel,
      validator: (value) => value,
    );
  }
}
