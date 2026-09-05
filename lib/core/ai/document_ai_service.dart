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
  DocumentAiService({this.apiKey = ''});

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
          responseSchema: Schema.object(
            properties: {
              'patient_identity': Schema.object(properties: {
                'name': Schema.string(nullable: true),
                'age': Schema.integer(nullable: true),
                'gender': Schema.string(nullable: true),
                'hospital_reg_no': Schema.string(nullable: true),
              }),
              'encounter_context': Schema.object(properties: {
                'document_type': Schema.string(),
                'date': Schema.string(nullable: true),
                'department': Schema.string(nullable: true),
                'ward_bed': Schema.string(nullable: true),
              }),
              'vitals': Schema.object(properties: {
                'sbp': Schema.integer(nullable: true),
                'dbp': Schema.integer(nullable: true),
                'pulse': Schema.integer(nullable: true),
                'spo2': Schema.integer(nullable: true),
                'temp_f': Schema.number(nullable: true),
              }),
              'medications_ordered': Schema.array(items: Schema.object(properties: {
                'drug_name': Schema.string(),
                'dosage': Schema.string(nullable: true),
                'frequency': Schema.string(nullable: true),
              })),
              'lab_results': Schema.array(items: Schema.object(properties: {
                'test_name': Schema.string(),
                'value': Schema.string(),
                'unit': Schema.string(nullable: true),
                'is_abnormal': Schema.boolean(),
              })),
              'clinical_summary': Schema.string(),
            },
          ),
        ),
      );
      final bytes = await image.readAsBytes();
      final response = await model.generateContent([
        Content.multi([
          TextPart(
            '$prompt\nReturn only JSON matching the requested schema. '
            'Use null for values not visible in the image. Include '
            'Do not infer patient identity or clinical facts that are not legible.',
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
