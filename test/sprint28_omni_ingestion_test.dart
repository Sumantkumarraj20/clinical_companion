import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/cdss_dao.dart';
import 'package:clinical_companion/core/database/daos/clinical_rule_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:clinical_companion/core/services/omni_ingestion_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingAiService extends DocumentAiService {
  _ThrowingAiService() : super(apiKey: 'test-key');

  @override
  Future<AiExtractionResult> extractDocument({
    required File? image,
    required String prompt,
    ThinkingLevel thinkingLevel = ThinkingLevel.medium,
  }) async {
    throw const DocumentAiException('must not be called on local wins');
  }
}

class _LocalPipeline extends ExtractionPipelineService {
  _LocalPipeline(super.aiService);

  @override
  Future<PipelineExtraction> processTextPayload(
    String rawText, {
    String? activeCensusJson,
    bool ambientAudioTranscription = false,
  }) async {
    return const PipelineExtraction(
      result: AiExtractionResult(clinicalSummary: 'cloud fallback'),
      source: PipelineSource.ai,
    );
  }

  @override
  void close() {}
}

Future<AppDatabase> _database() async {
  final db = AppDatabase(NativeDatabase.memory());
  return db;
}

void main() {
  group('sanitizeStructuredJsonText', () {
    test('strips markdown fences', () {
      expect(
        sanitizeStructuredJsonText('```json\n{"a": 1}\n```'),
        '{"a": 1}',
      );
    });
    test('extracts object from prose', () {
      expect(
        sanitizeStructuredJsonText('Here: {"a": 1} done.'),
        '{"a": 1}',
      );
    });
  });
  group('OmniIngestionService', () {
    test('TextPayload hydrates locally without any API call', () async {
      final db = await _database();
      addTearDown(db.close);
      await db
          .into(db.clinicalRules)
          .insert(
            ClinicalRulesCompanion.insert(
              id: const Value('rule-htn'),
              triggerType: 'diagnosis',
              triggerValue: 'hypertension',
              suggestedAction: 'Start amlodipine 5 mg daily',
              evidenceRationale: 'Local protocol v1',
              isVerified: const Value(true),
            ),
          );
      final service = OmniIngestionService(
        aiService: _ThrowingAiService(),
        pipeline: _LocalPipeline(_ThrowingAiService()),
        ruleDao: ClinicalRuleDao(db),
        cdssDao: CdssDao(db),
        database: db,
      );
      final result = await service.preCompute(
        'hypertension review, BP 150/95, start therapy',
      );
      expect(result.matchedRuleIds, contains('rule-htn'));
      expect(result.data.problems.single.diagnosis, 'hypertension');
      expect(result.data.vitals.sbp, 150);
      expect(result.localConfidence, greaterThanOrEqualTo(0.75));
    });

    test('low-confidence text escalates to the cloud', () async {
      final db = await _database();
      addTearDown(db.close);
      final service = OmniIngestionService(
        aiService: _ThrowingAiService(),
        pipeline: _LocalPipeline(_ThrowingAiService()),
        ruleDao: ClinicalRuleDao(db),
        cdssDao: CdssDao(db),
        database: db,
      );
      final result = await service.ingest(
        const TextPayload('vague fatigue, needs review'),
      );
      expect(result.source, OmniIngestionSource.cloud);
      expect(result.data.clinicalSummary, 'cloud fallback');
    });
  });
  group('Clinical protocols CRUD', () {
    test('manual edits overwrite rules and win pre-compute', () async {
      final db = await _database();
      addTearDown(db.close);
      final dao = ClinicalRuleDao(db);
      final created = await dao.upsertManualRule(
        triggerType: 'diagnosis',
        triggerValue: 'CKD',
        suggestedAction: 'Old dose',
        evidenceRationale: 'v1',
      );
      final updated = await dao.upsertManualRule(
        id: created.id,
        triggerType: 'diagnosis',
        triggerValue: 'CKD',
        suggestedAction: 'New KDIGO dose',
        evidenceRationale: 'v2',
      );
      expect(updated.id, created.id);
      expect(updated.suggestedAction, 'New KDIGO dose');
      final service = OmniIngestionService(
        aiService: _ThrowingAiService(),
        pipeline: _LocalPipeline(_ThrowingAiService()),
        ruleDao: dao,
        cdssDao: CdssDao(db),
        database: db,
      );
      final pre = await service.preCompute('CKD follow-up visit');
      expect(pre.matchedRuleIds, contains(created.id));
      await dao.deleteRule(created.id);
      expect(await dao.activeProtocols(), isEmpty);
    });
  });
}
