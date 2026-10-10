import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/cdss_dao.dart';
import 'package:clinical_companion/core/database/daos/clinical_rule_dao.dart';
import 'package:clinical_companion/core/database/daos/ingestion_inbox_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/models/clinical_rule_suggestion.dart';
import 'package:clinical_companion/core/models/document_task.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:clinical_companion/core/services/omni_ingestion_service.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _TrackingPipeline extends ExtractionPipelineService {
  _TrackingPipeline(
    super.aiService, {
    this.extractionResult = const AiExtractionResult(
      clinicalSummary: 'structured text',
    ),
  });

  final AiExtractionResult extractionResult;
  int ocrCalls = 0;
  int textCalls = 0;
  int documentCalls = 0;

  @override
  Future<String> recognizeRawText(File file) async {
    ocrCalls++;
    return 'scan text without local matches';
  }

  @override
  Future<PipelineExtraction> processTextPayload(
    String rawText, {
    String? activeCensusJson,
    bool ambientAudioTranscription = false,
  }) async {
    textCalls++;
    return PipelineExtraction(
      result: extractionResult,
      source: PipelineSource.ai,
    );
  }

  @override
  Future<PipelineExtraction> processRecognizedDocumentWithProvenance(
    File image,
    String rawText, {
    String? activeCensusJson,
  }) async {
    documentCalls++;
    return PipelineExtraction(
      result: extractionResult,
      source: PipelineSource.ai,
    );
  }

  @override
  void close() {}
}

class _LearningAiService extends DocumentAiService {
  _LearningAiService() : super(apiKey: 'test-key');

  @override
  Future<List<ClinicalRuleSuggestion>> generateClinicalRulesFromGuideline(
    String sourceText, {
    ThinkingLevel thinkingLevel = ThinkingLevel.high,
  }) async => const [
    ClinicalRuleSuggestion(
      triggerType: 'diagnosis',
      triggerValue: 'nephrotic syndrome',
      suggestedAction: 'Review documented treatment course',
      evidenceRationale: 'Supported by the ingested clinical note.',
      differentialDiagnoses: ['Minimal change disease'],
      recommendedManagement: ['Confirm steroid plan'],
    ),
  ];
}

Future<AppDatabase> _database() async {
  final db = AppDatabase(NativeDatabase.memory());
  return db;
}

void main() {
  group('sanitizeStructuredJsonText', () {
    test('strips markdown fences', () {
      expect(sanitizeStructuredJsonText('```json\n{"a": 1}\n```'), '{"a": 1}');
    });
    test('extracts object from prose', () {
      expect(sanitizeStructuredJsonText('Here: {"a": 1} done.'), '{"a": 1}');
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

    test('text and audio bypass OCR while images and PDFs use it', () async {
      final db = await _database();
      addTearDown(db.close);
      final pipeline = _TrackingPipeline(_ThrowingAiService());
      final service = OmniIngestionService(
        aiService: _ThrowingAiService(),
        pipeline: pipeline,
        ruleDao: ClinicalRuleDao(db),
        cdssDao: CdssDao(db),
        database: db,
      );

      await service.ingest(const TextPayload('pasted discharge note'));
      await service.ingest(const AudioPayload('transcribed consultation'));
      expect(pipeline.ocrCalls, 0);
      expect(pipeline.textCalls, 2);

      await service.ingest(ImagePayload(File('/tmp/scan.jpg')));
      await service.ingest(PdfPayload(File('/tmp/report.pdf')));
      expect(pipeline.ocrCalls, 2);
      expect(pipeline.documentCalls, 2);
    });

    test('treatment courses create unverified proposed protocols', () async {
      final db = await _database();
      addTearDown(db.close);
      final treatmentPipeline = _TrackingPipeline(
        _ThrowingAiService(),
        extractionResult: const AiExtractionResult(
          problems: [AiProblem(diagnosis: 'nephrotic syndrome')],
          medicationsOrdered: [OrderedMedication(drugName: 'prednisolone')],
        ),
      );
      final learningService = OmniIngestionService(
        aiService: _LearningAiService(),
        pipeline: treatmentPipeline,
        ruleDao: ClinicalRuleDao(db),
        cdssDao: CdssDao(db),
        database: db,
      );

      await learningService.ingest(
        const TextPayload(
          'Nephrotic syndrome treated with prednisolone and albumin.',
        ),
      );

      final proposed = await ClinicalRuleDao(db)
          .watchPendingPathways()
          .firstWhere((rules) => rules.isNotEmpty)
          .timeout(const Duration(seconds: 5));
      expect(proposed, hasLength(1));
      expect(proposed.single.isVerified, isFalse);
      expect(proposed.single.triggerValue, 'nephrotic syndrome');
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

  group('Local ingestion inbox', () {
    test(
      'persists processing input before the structured review record',
      () async {
        final db = await _database();
        addTearDown(db.close);
        final dao = IngestionInboxDao(db);
        await dao.saveProcessing(
          id: 'inbox-1',
          payloadType: 'text',
          rawInput: 'raw discharge note',
        );

        var item = (await dao.getOpenItems()).single;
        expect(item.status, 'processing');
        expect(item.rawInput, 'raw discharge note');
        expect(item.patientId, isNull);

        const extraction = AiExtractionResult(
          problems: [AiProblem(diagnosis: 'pneumonia')],
        );
        await dao.markReady(
          id: item.id,
          result: extraction,
          rawText: 'normalized discharge note',
        );
        item = (await dao.getOpenItems()).single;
        expect(item.status, 'ready_for_review');
        expect(item.extractedJson, contains('"pneumonia"'));
        expect(item.rawInput, 'normalized discharge note');
      },
    );

    test('restores interrupted processing as a retryable error', () async {
      final db = await _database();
      addTearDown(db.close);
      final dao = IngestionInboxDao(db);
      await dao.saveProcessing(
        id: 'interrupted-inbox-item',
        payloadType: 'text',
        rawInput: 'saved discharge note',
      );
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await container.read(batchExtractionProvider.notifier).restoreInbox();

      final task = container.read(batchExtractionProvider).single;
      expect(task.status, ExtractionStatus.error);
      expect(task.errorMessage, contains('Processing was interrupted'));
      expect((await dao.getOpenItems()).single.status, 'error');
    });

    test(
      'omni queue persists structured output and restores it for review',
      () async {
        final db = await _database();
        addTearDown(db.close);
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            documentAiServiceProvider.overrideWithValue(_ThrowingAiService()),
            extractionPipelineProvider.overrideWithValue(
              _TrackingPipeline(_ThrowingAiService()),
            ),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(batchExtractionProvider.notifier);
        notifier.addOmniText('pasted discharge note');

        for (var attempt = 0; attempt < 100; attempt++) {
          if (container
              .read(batchExtractionProvider)
              .any((task) => task.status == ExtractionStatus.readyForReview)) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        final task = container.read(batchExtractionProvider).single;
        expect(task.status, ExtractionStatus.readyForReview);

        final item = (await IngestionInboxDao(db).getOpenItems()).single;
        expect(item.status, 'ready_for_review');
        expect(item.extractedJson, contains('structured text'));
        expect(item.rawInput, 'pasted discharge note');

        notifier.removeTask(task.id);
        await notifier.restoreInbox();
        expect(
          container.read(batchExtractionProvider).single.status,
          ExtractionStatus.readyForReview,
        );
      },
    );
  });
}
