import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../database/daos/pharmacopeia_dao.dart';
import '../models/ai_extraction_result.dart';

class DocumentAiException implements Exception {
  const DocumentAiException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class DocumentAiService {
  DocumentAiService({required this.apiKey});

  final String apiKey;

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

  Future<AiExtractionResult> extractDocument({
    required File image,
    required String prompt,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const DocumentAiException(
        'AI capture is not configured. Add GEMINI_API_KEY at build time.',
      );
    }
    if (!await image.exists()) {
      throw const DocumentAiException(
        'The selected image is no longer available.',
      );
    }
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );
      final bytes = await image.readAsBytes();
      final response = await model.generateContent([
        Content.multi([
          TextPart(
            '$prompt\nReturn only JSON matching the requested schema. '
            'Use null for values not visible in the image. Include '
            'identified_problems as a string list and medications_mentioned '
            'as objects containing brand, generic, and dose.',
          ),
          DataPart('image/jpeg', bytes),
        ]),
      ]);
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw const DocumentAiException(
          'AI returned an empty document result.',
        );
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        throw const DocumentAiException('AI returned invalid structured JSON.');
      }
      return AiExtractionResult.fromJson(Map<String, dynamic>.from(decoded));
    } on DocumentAiException {
      rethrow;
    } catch (error) {
      throw DocumentAiException(
        'Could not read the document. Check image clarity and connectivity, then try again.',
        cause: error,
      );
    }
  }
}
