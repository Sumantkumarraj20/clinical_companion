import 'dart:convert';
import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/core/services/clincom_escalation.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:clinical_companion/core/utils/document_image_hasher.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sprint 17 — ClinCom: the deduplication guarantee, cost control, semantic
/// merging, and the manual-save guarantee.

/// Counts the expensive calls a real pipeline would make, so a test can assert
/// on API spend directly rather than inferring it from side effects.
class _CountingPipeline extends ExtractionPipelineService {
  _CountingPipeline({this.aiResult}) : super(DocumentAiService());

  AiExtractionResult? aiResult;

  int ocrCalls = 0;
  int refineCalls = 0;
  String? lastCensus;

  @override
  Future<String> recognizeRawText(File image) async {
    ocrCalls++;
    return '';
  }

  @override
  AiExtractionResult? parseLocalText(String rawText) => null;

  @override
  Future<PipelineExtraction> refineWithAi(
    File image,
    String rawText, {
    String? activeCensusJson,
  }) async {
    refineCalls++;
    lastCensus = activeCensusJson;
    return PipelineExtraction(
      result: aiResult ?? const AiExtractionResult(),
      source: PipelineSource.ai,
    );
  }

  @override
  void close() {}
}

Future<AppDatabase> _db() async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

Future<File> _tempImage(String name, {String bytes = 'page-one-bytes'}) async {
  final dir = await Directory.systemTemp.createTemp('clincom_s17');
  addTearDown(() => dir.delete(recursive: true));
  final file = File('${dir.path}/$name');
  await file.writeAsString(bytes);
  return file;
}

/// Seeds a patient the way the app does, so FKs and defaults stay realistic.
Future<String> _seedPatient(AppDatabase db, String name) async {
  final saved = await ClinicalDao(db).insertPatient(
    PatientsCompanion.insert(
      ownerId: 'local-practitioner',
      fullName: name,
    ),
  );
  return saved.id;
}

/// Pumps until [condition] holds, so queue-driven tests never rely on sleeps.
Future<void> _waitUntil(
  bool Function() condition, {
  int maxPumps = 60,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  group('STEP 1 — the image hash layer', () {
    test('identical bytes produce an identical SHA-256', () async {
      final a = await _tempImage('a.png');
      final b = await _tempImage('b.png');
      expect(
        await hashDocumentImageOrNull(a.path),
        await hashDocumentImageOrNull(b.path),
      );
    });

    test('different bytes produce different hashes', () async {
      final a = await _tempImage('a.png', bytes: 'page-one');
      final b = await _tempImage('b.png', bytes: 'page-two');
      expect(
        await hashDocumentImageOrNull(a.path),
        isNot(await hashDocumentImageOrNull(b.path)),
      );
    });

    test('an unreadable file yields null rather than throwing', () async {
      // Losing the dedup key is acceptable; breaking the save is not.
      expect(await hashDocumentImageOrNull('/nope/missing.png'), isNull);
    });

    test('a saved hash is found again for the same image', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');
      final file = await _tempImage('page.png');
      final hash = (await hashDocumentImageOrNull(file.path))!;

      await db.into(db.documentRegistries).insert(
        DocumentRegistriesCompanion.insert(
          id: 'doc-1',
          patientId: patientId,
          documentCategory: 'Lab Report',
          imagePath: file.path,
          documentedAt: DateTime.utc(2024, 3, 12),
        ),
      );
      await dao.attachImageHash('doc-1', hash);
      final found = await dao.findDocumentByImageHash(hash);
      expect(found, isNotNull);
      expect(found!.patientId, patientId);
    });

    test('a legacy NULL hash is never treated as a duplicate', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      // Two pre-Sprint-17 documents, both with NULL hashes. Matching them
      // against each other would falsely call every legacy page a duplicate.
      for (final id in ['old-1', 'old-2']) {
        await db.into(db.documentRegistries).insert(
          DocumentRegistriesCompanion.insert(
            id: id,
            patientId: await _seedPatient(db, 'Patient \$id'),
            documentCategory: 'Lab Report',
            imagePath: '/legacy/\$id.jpg',
            documentedAt: DateTime.utc(2024),
          ),
        );
      }
      expect(await dao.findDocumentByImageHash(null), isNull);
      expect(await dao.findDocumentByImageHash(''), isNull);
      expect(await dao.findDocumentByImageHash('   '), isNull);
    });

    test('a never-before-seen image is not a duplicate', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final file = await _tempImage('fresh.png');
      final hash = (await hashDocumentImageOrNull(file.path))!;
      expect(await dao.findDocumentByImageHash(hash), isNull);
    });

    test('DEDUPLICATION ABORTS THE AI: a repeat capture costs nothing',
        () async {
      // The headline Sprint 17 guarantee. A second capture of the same physical
      // page must spend nothing: no OCR, no API call, no new document row.
      final db = await _db();
      final patientId = await _seedPatient(db, 'Asha Rao');
      final file = await _tempImage('repeat.jpg');
      final hash = (await hashDocumentImageOrNull(file.path))!;

      // The page is already on file, under this patient.
      await db.into(db.documentRegistries).insert(
        DocumentRegistriesCompanion.insert(
          id: 'existing-doc',
          patientId: patientId,
          documentCategory: 'Lab Report',
          imagePath: file.path,
          imageHash: Value(hash),
          documentedAt: DateTime.utc(2024, 3, 12),
        ),
      );

      final pipeline = _CountingPipeline();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          extractionPipelineProvider.overrideWithValue(pipeline),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(batchExtractionProvider.notifier);

      // The intercept finds the existing document, so the screen routes to
      // Edit Mode instead of queueing the page. The pipeline is never called.
      final duplicate = await notifier.findDuplicate(file);
      expect(duplicate, isNotNull);
      expect(duplicate!.id, 'existing-doc');
      expect(pipeline.ocrCalls, 0);
      expect(pipeline.refineCalls, 0);

      // And no second document row exists for those same bytes.
      expect(await db.select(db.documentRegistries).get(), hasLength(1));
    });

    test('a genuinely new image is queued and does reach ClinCom', () async {
      final db = await _db();
      final pipeline = _CountingPipeline(
        aiResult: const AiExtractionResult(
          patientIdentity: PatientIdentity(name: 'Asha Rao', age: 45),
          encounterContext: EncounterContext(documentType: 'Lab Report'),
          clinicalSummary: 'CBC panel',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          extractionPipelineProvider.overrideWithValue(pipeline),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(batchExtractionProvider.notifier);
      final file = await _tempImage('brand-new.png');

      expect(await notifier.findDuplicate(file), isNull);
      notifier.addFiles([file]);
      await _waitUntil(() => pipeline.refineCalls > 0);
      expect(pipeline.ocrCalls, 1);
      expect(pipeline.refineCalls, 1);
    });

    test('an unreadable image does not block capture', () async {
      final db = await _db();
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      // A hash failure must degrade to "not a duplicate", never to a refusal.
      expect(
        await container
            .read(batchExtractionProvider.notifier)
            .findDuplicate(File('/nope/missing.png')),
        isNull,
      );
    });
  });

  group('STEP 2 — smart fallback keeps API cost down', () {
    test('dense printed OCR takes the free text-only path', () {
      final dense = List.filled(
        30,
        'Haemoglobin concentration was measured and reported within normal limits.',
      ).join(' ');
      expect(chooseEscalation(ocrText: dense), ClinComEscalation.textOnly);
    });

    test('sparse OCR escalates to the vision model', () {
      expect(
        chooseEscalation(ocrText: 'Bed 12'),
        ClinComEscalation.multimodalVision,
      );
      expect(chooseEscalation(ocrText: ''), ClinComEscalation.multimodalVision);
    });

    test('handwriting markers escalate even when the text is dense', () {
      final handwritten = 'C/o fever ${'tab paracetamol 650mg bd. ' * 12}';
      expect(
        chooseEscalation(ocrText: handwritten),
        ClinComEscalation.multimodalVision,
      );
    });

    test('fragment soup escalates rather than trusting garbage', () {
      final soup = List.filled(40, 'a b').join(' ');
      expect(
        chooseEscalation(ocrText: '$soup tail'),
        ClinComEscalation.multimodalVision,
      );
    });
  });

  group('STEP 2 — contextual patient inference', () {
    test('the census captured at enqueue time reaches the prompt', () async {
      final db = await _db();
      final pipeline = _CountingPipeline(
        aiResult: const AiExtractionResult(
          encounterContext: EncounterContext(documentType: 'Lab Report'),
          clinicalSummary: 'Bed 12 report',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          extractionPipelineProvider.overrideWithValue(pipeline),
        ],
      );
      addTearDown(container.dispose);
      final file = await _tempImage('census-page.jpg');

      container.read(batchExtractionProvider.notifier).addFiles(
        [file],
        activeCensusJson: '[{"patient_id":"p-1","bed":"12"}]',
      );
      await _waitUntil(() => pipeline.refineCalls > 0);
      expect(pipeline.lastCensus, contains('p-1'));
      expect(pipeline.lastCensus, contains('"bed":"12"'));
    });

    test('no active inpatients means no census block', () async {
      final db = await _db();
      // No block, so a page with no bed number is never nudged into inventing
      // a patient match.
      expect(
        await BatchExtractionNotifier.buildActiveCensusJson(ClinicalDao(db)),
        isNull,
      );
    });
  });

  group('STEP 3 — semantic merging of lab results', () {
    test('a formal report supersedes a ward note inside the window', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');
      final at = DateTime.utc(2024, 3, 12, 8);

      await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Haemoglobin',
        resultDate: at,
        textValue: '9.1',
        unit: 'g/dL',
        sourceAuthority: 'Ward Round Note',
      );

      // The lab report for the same test six hours later wins.
      final merged = await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Haemoglobin',
        resultDate: at.add(const Duration(hours: 6)),
        textValue: '11.4',
        unit: 'g/dL',
        sourceAuthority: 'Scanned Document',
      );

      expect(merged.merged, isTrue);
      expect(merged.result.textValue, '11.4');
      expect(merged.result.sourceAuthority, 'Scanned Document');
      // Still exactly ONE row: no duplicate for the clinician to reconcile.
      expect(await db.select(db.investigationResults).get(), hasLength(1));
    });

    test('a weak note arriving after a lab report never overwrites it', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');
      final at = DateTime.utc(2024, 3, 12, 8);

      await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Creatinine',
        resultDate: at,
        textValue: '1.6',
        sourceAuthority: 'Scanned Document',
      );
      final later = await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Creatinine',
        resultDate: at.add(const Duration(hours: 2)),
        textValue: '2',
        sourceAuthority: 'Ward Round Note',
      );

      expect(later.merged, isFalse);
      expect(later.result.textValue, '1.6');
      expect(await db.select(db.investigationResults).get(), hasLength(1));
    });

    test('results outside the 12-hour window stay separate', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');
      final at = DateTime.utc(2024, 3, 12, 8);

      await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Potassium',
        resultDate: at,
        textValue: '4.0',
      );
      // 24h later is a genuinely different clinical episode.
      await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Potassium',
        resultDate: at.add(const Duration(hours: 24)),
        textValue: '5.6',
      );
      expect(await db.select(db.investigationResults).get(), hasLength(2));
    });

    test('merging is case-insensitive so terminology cannot fork the data',
        () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');
      final at = DateTime.utc(2024, 3, 12, 8);

      await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'TLC',
        resultDate: at,
        textValue: '11200',
        sourceAuthority: 'Ward Round Note',
      );
      final merged = await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'tlc',
        resultDate: at.add(const Duration(hours: 1)),
        textValue: '9800',
        sourceAuthority: 'Scanned Document',
      );
      expect(merged.merged, isTrue);
      expect(await db.select(db.investigationResults).get(), hasLength(1));
    });

    test('a legacy row with no provenance is superseded by a real report',
        () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');
      final at = DateTime.utc(2024, 3, 12, 8);

      await db.into(db.investigationResults).insert(
        InvestigationResultsCompanion.insert(
          id: const Value('legacy'),
          patientId: patientId,
          testName: 'Sodium',
          textValue: const Value('130'),
          resultDate: Value(at),
        ),
      );
      final merged = await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Sodium',
        resultDate: at.add(const Duration(hours: 1)),
        textValue: '138',
        sourceAuthority: 'Scanned Document',
      );
      expect(merged.merged, isTrue);
      expect(merged.result.id, 'legacy');
      expect(merged.result.textValue, '138');
    });

    test('source authority ranks a lab report above a ward note', () {
      expect(
        ClinicalDao.authorityRank('Scanned Document'),
        greaterThan(ClinicalDao.authorityRank('Ward Round Note')),
      );
      expect(
        ClinicalDao.authorityRank('Ward Round Note'),
        greaterThan(ClinicalDao.authorityRank(null)),
      );
    });

    test('the merge keeps the earliest clinical time so trends stay true',
        () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');
      final early = DateTime.utc(2024, 3, 12, 8);

      await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Urea',
        resultDate: early,
        textValue: '40',
        sourceAuthority: 'Ward Round Note',
      );
      final merged = await dao.upsertInvestigationResult(
        patientId: patientId,
        testName: 'Urea',
        resultDate: early.add(const Duration(hours: 5)),
        textValue: '52',
        sourceAuthority: 'Scanned Document',
      );
      expect(merged.result.resultDate, early);
    });
  });

  group('STEP 3 — the ClinCom JSON contract', () {
    test('the semantic layer round-trips out of the model JSON', () {
      final parsed = AiExtractionResult.fromJson(<String, dynamic>{
        'patient_identity': <String, dynamic>{'name': 'Asha Rao'},
        'encounter_context': <String, dynamic>{'document_type': 'Lab Report'},
        'document_date': '2024-03-12',
        'is_date_assumed': false,
        'inferred_patient_id': 'patient-7',
        'chief_complaints': <String>['Fever for 3 days'],
        'diagnoses': <String>['Enteric Fever'],
        'planned_investigations': <String>['Blood Culture'],
        'source_authority': 'Scanned Document',
        'clinical_summary': 'Enteric fever workup.',
      });

      // The document date is the one PRINTED on the page, not today.
      expect(parsed.documentDate, '2024-03-12');
      expect(parsed.isDateAssumed, isFalse);
      expect(parsed.inferredPatientId, 'patient-7');
      expect(parsed.chiefComplaints, ['Fever for 3 days']);
      expect(parsed.diagnoses, ['Enteric Fever']);
      expect(parsed.plannedInvestigations, ['Blood Culture']);
      expect(parsed.sourceAuthority, 'Scanned Document');
      expect(parsed.hasClinicalNarrative, isTrue);
    });

    test('a legacy document with no semantic fields still parses', () {
      final parsed = AiExtractionResult.fromJson(<String, dynamic>{
        'clinical_summary': 'CBC panel',
      });
      expect(parsed.documentDate, '');
      expect(parsed.inferredPatientId, isNull);
      expect(parsed.sourceAuthority, isNull);
      expect(parsed.hasClinicalNarrative, isFalse);
    });

    test('a page with no narrative renders no empty sections', () {
      // Drives STEP 4: the Medications / Diagnoses cards disappear entirely
      // rather than showing blank shells.
      const bare = AiExtractionResult(
        encounterContext: EncounterContext(documentType: 'Prescription'),
        medicationsOrdered: <OrderedMedication>[],
      );
      expect(bare.hasClinicalNarrative, isFalse);
    });
  });

  group('STEP 4 — nothing is saved without the clinician', () {
    test('extraction alone writes no document row', () async {
      final db = await _db();
      final file = await _tempImage('review-only.png');
      final pipeline = _CountingPipeline(
        aiResult: const AiExtractionResult(
          patientIdentity: PatientIdentity(name: 'Asha Rao', age: 45),
          encounterContext: EncounterContext(documentType: 'Lab Report'),
          clinicalSummary: 'CBC',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          extractionPipelineProvider.overrideWithValue(pipeline),
        ],
      );
      addTearDown(container.dispose);

      container.read(batchExtractionProvider.notifier).addFiles([file]);
      await _waitUntil(() => pipeline.refineCalls > 0);
      // ClinCom produced a result and it lives only in Riverpod state...
      expect(
        container.read(batchExtractionProvider).single.extractedData,
        isNotNull,
      );
      // ...SQLite is untouched until the clinician taps "Save document".
      expect(await db.select(db.documentRegistries).get(), isEmpty);
      expect(await db.select(db.clinicalEncounters).get(), isEmpty);
    });
  });

  group('Sprint 17.5 — Edit Mode hydration (the 1-year lifecycle)', () {
    test('a saved extraction round-trips every semantic field', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');

      // Exactly what the review screen persists after a clinician reviews it.
      final reviewed = AiExtractionResult(
        patientIdentity: PatientIdentity(name: 'Asha Rao', age: 45),
        encounterContext: EncounterContext(
          documentType: 'Lab Report',
          date: '2024-03-12',
        ),
        chiefComplaints: const ['Fever for 3 days', 'Rash on trunk'],
        diagnoses: const ['Enteric Fever'],
        plannedInvestigations: const ['Blood Culture', 'Widal Test'],
        labResults: const [
          AiLabResult(testName: 'Haemoglobin', value: '11.4', unit: 'g/dL'),
        ],
        clinicalSummary: 'Enteric fever workup.',
      );

      await dao.processAiExtraction(
        reviewed,
        '/itest/rehydrate.jpg',
        patientIdOverride: patientId,
        clincomJson: jsonEncode(reviewed.toJson()),
      );

      // Reopen it the way editExisting() does, a year later.
      final document = await dao.findDocumentByImagePath('/itest/rehydrate.jpg');
      expect(document, isNotNull);
      expect(document!.clincomJson, isNotNull,
          reason: 'The extraction JSON must be stored, or the form reopens empty.');

      final restored = AiExtractionResult.fromJson(
        jsonDecode(document.clincomJson!) as Map<String, dynamic>,
      );

      // Every section the clinician reviewed must come back, not just summary.
      expect(restored.chiefComplaints, ['Fever for 3 days', 'Rash on trunk']);
      expect(restored.diagnoses, ['Enteric Fever']);
      expect(restored.plannedInvestigations, ['Blood Culture', 'Widal Test']);
      expect(restored.labResults.single.testName, 'Haemoglobin');
      expect(restored.clinicalSummary, 'Enteric fever workup.');
    });

    test('a legacy document with no stored JSON still opens safely', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Legacy Patient');

      // A pre-Sprint-17.5 row: no clincomJson at all.
      await db.into(db.documentRegistries).insert(
        DocumentRegistriesCompanion.insert(
          id: 'legacy-doc',
          patientId: patientId,
          documentCategory: 'Lab Report',
          imagePath: '/legacy/old.jpg',
          rawOcrTranscript: const Value('Old CBC panel'),
          documentedAt: DateTime.utc(2023),
        ),
      );

      final document = await dao.findDocumentByImagePath('/legacy/old.jpg');
      expect(document, isNotNull);
      // Null JSON must degrade, not throw — the screen catches and falls back.
      expect(document!.clincomJson, isNull);
    });

    test('a corrupt stored JSON does not break opening the document', () {
      // The screen catches this and falls back to the summary-only form, so a
      // truncated write can never make a document permanently unopenable.
      expect(() => AiExtractionResult.fromJson(
        jsonDecode('{not valid json') as Map<String, dynamic>,
      ), throwsA(isA<FormatException>()));
    });

    test('applyDocumentEdits refreshes the stored JSON', () async {
      final db = await _db();
      final dao = ClinicalDao(db);
      final patientId = await _seedPatient(db, 'Asha Rao');

      await dao.processAiExtraction(
        const AiExtractionResult(
          encounterContext: EncounterContext(documentType: 'Lab Report'),
          diagnoses: <String>['Provisional'],
          clinicalSummary: 'First pass',
        ),
        '/itest/edit.jpg',
        patientIdOverride: patientId,
        clincomJson: '{"diagnoses":["Provisional"]}',
      );

      final corrected = const AiExtractionResult(
        encounterContext: EncounterContext(documentType: 'Lab Report'),
        diagnoses: <String>['Enteric Fever (confirmed)'],
        clinicalSummary: 'Corrected',
      );

      final applied = await dao.applyDocumentEdits(
        documentId: (await dao.findDocumentByImagePath('/itest/edit.jpg'))!.id,
        documentedAt: DateTime.utc(2024, 3, 12),
        clincomJson: jsonEncode(corrected.toJson()),
      );
      expect(applied, isTrue);

      final after = await dao.findDocumentByImagePath('/itest/edit.jpg');
      final restored = AiExtractionResult.fromJson(
        jsonDecode(after!.clincomJson!) as Map<String, dynamic>,
      );
      // Reopening must show the CORRECTION, not resurrect the stale value.
      expect(restored.diagnoses, ['Enteric Fever (confirmed)']);
    });
  });
}