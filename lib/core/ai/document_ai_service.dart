import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:google_generative_ai/google_generative_ai.dart';

import '../database/daos/pharmacopeia_dao.dart';
import '../models/ai_extraction_result.dart';
import 'clinical_prompts.dart';

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
  DocumentAiService({this.apiKey = ''});

  // Updated to active free-tier models
  static const String defaultModel = 'gemini-3.6-flash';
  static const String fallbackModel = 'gemini-2.5-flash';
  static const int maxAttempts = 3;

  final String apiKey;

  static bool shouldEscalateToFallback(Object error) {
    if (error is DocumentAiException) {
      if (error.type == DocumentAiErrorType.modelNotFound) {
        return true;
      }
    }

    final text = error.toString().toLowerCase();
    if (text.contains('model not found') ||
        text.contains('model unavailable') ||
        text.contains('unsupported model') ||
        text.contains('404')) {
      return true;
    }
    return false;
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
        'The selected image is too large for reliable AI extraction.',
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
        text.contains('failed host lookup')) {
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
    if (text.contains('404') ||
        text.contains('model not found') ||
        text.contains('model unavailable') ||
        text.contains('unsupported model')) {
      return DocumentAiException(
        'The configured AI model ($model) is unavailable.',
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

  Future<T> _executeWithRetry<T>({
    required Future<T> Function(String model) request,
    required String modelName,
  }) async {
    var currentModel = modelName;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await request(currentModel);
      } on DocumentAiException catch (error) {
        final shouldRetrySameModel =
            error.retryable &&
            attempt < maxAttempts &&
            !shouldEscalateToFallback(error);
        final shouldEscalate =
            currentModel == modelName && shouldEscalateToFallback(error);

        if (shouldRetrySameModel) {
          final backoffMs = 500 * (1 << (attempt - 1));
          await Future<void>.delayed(Duration(milliseconds: backoffMs));
          continue;
        }
        if (shouldEscalate) {
          currentModel = fallbackModel;
          continue;
        }
        rethrow;
      }
    }

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
    required File image,
    required String prompt,
    required Schema schema,
    required Map<String, dynamic> Function(Map<String, dynamic>) validator,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const DocumentAiException(
        'AI capture is not configured. Add GEMINI_API_KEY at build time.',
        type: DocumentAiErrorType.configuration,
      );
    }

    final preparedImage = await _prepareImage(image);
    final mimeType = _mimeType(preparedImage);

    Future<Map<String, dynamic>> request(String modelName) async {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: schema,
          ),
        );
        final bytes = await preparedImage.readAsBytes();
        final response = await model.generateContent([
          Content.multi([
            TextPart(
              '$prompt\n'
              'Return only valid JSON matching the requested schema. '
              'Do not invent or infer values that are not visible in the source. '
              'Use null for missing values and preserve the original source wording.',
            ),
            DataPart(mimeType, bytes),
          ]),
        ]);

        final text = response.text;
        if (text == null || text.trim().isEmpty) {
          throw const DocumentAiException(
            'AI returned an empty document result.',
            type: DocumentAiErrorType.emptyResponse,
          );
        }

        final decoded = jsonDecode(text);
        if (decoded is! Map) {
          throw const DocumentAiException(
            'AI returned invalid structured JSON.',
            type: DocumentAiErrorType.malformedJson,
          );
        }

        final normalized = validator(Map<String, dynamic>.from(decoded));
        return normalized;
      } on DocumentAiException {
        rethrow;
      } catch (error) {
        throw classifyError(error, model: modelName);
      }
    }

    return _executeWithRetry(request: request, modelName: defaultModel);
  }

  Future<AiExtractionResult> extractDocument({
    required File image,
    required String prompt,
  }) async {
    final schema = Schema.object(
      properties: {
        'patient_identity': Schema.object(
          properties: {
            'name': Schema.string(nullable: true),
            'age': Schema.integer(nullable: true),
            'gender': Schema.string(nullable: true),
            'hospital_reg_no': Schema.string(nullable: true),
          },
        ),
        'encounter_context': Schema.object(
          properties: {
            'document_type': Schema.string(),
            'date': Schema.string(nullable: true),
            'department': Schema.string(nullable: true),
            'ward_bed': Schema.string(nullable: true),
          },
        ),
        'vitals': Schema.object(
          properties: {
            'sbp': Schema.integer(nullable: true),
            'dbp': Schema.integer(nullable: true),
            'pulse': Schema.integer(nullable: true),
            'spo2': Schema.integer(nullable: true),
            'temp_f': Schema.number(nullable: true),
          },
        ),
        'medications_ordered': Schema.array(
          items: Schema.object(
            properties: {
              'drug_name': Schema.string(),
              'dosage': Schema.string(nullable: true),
              'frequency': Schema.string(nullable: true),
            },
          ),
        ),
        'lab_results': Schema.array(
          items: Schema.object(
            properties: {
              'test_name': Schema.string(),
              'value': Schema.string(),
              'unit': Schema.string(nullable: true),
              'is_abnormal': Schema.boolean(),
            },
          ),
        ),
        'clinical_summary': Schema.string(),
      },
    );

    final raw = await _extractStructuredJson(
      image: image,
      prompt: prompt,
      schema: schema,
      validator: (value) => value,
    );
    return AiExtractionResult.fromJson(raw);
  }

  Future<Map<String, dynamic>> extractClinicalDocument({
    required File image,
    required ClinicalDocumentCategory category,
  }) async {
    final prompt = ClinicalPromptContracts.promptFor(category);
    final schema = ClinicalPromptContracts.responseSchemaFor(category);

    return _extractStructuredJson(
      image: image,
      prompt: prompt,
      schema: schema,
      validator: (value) => value,
    );
  }
}
