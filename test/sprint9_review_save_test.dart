import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/models/document_task.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:clinical_companion/features/ingestion/screens/adaptive_review_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _labPage = AiExtractionResult(
  patientIdentity: PatientIdentity(
    name: 'Asha Rao',
    age: 45,
    gender: 'Female',
    hospitalRegNo: 'CR-7781',
  ),
  encounterContext: EncounterContext(documentType: 'Lab Report'),
  vitals: AiVitals(sbp: 128, dbp: 82, pr: 88, spo2: 97),
  labResults: [AiLabResult(testName: 'Hb', value: '11.2', unit: 'g/dL')],
  clinicalSummary: 'CBC panel reviewed at the bedside.',
);

/// Lets a test start the review screen on a fixed set of documents without
/// running ML Kit.
class _SeededBatch extends BatchExtractionNotifier {
  _SeededBatch(this._seed);

  final List<DocumentTask> _seed;

  @override
  List<DocumentTask> build() => _seed;
}

class _FakePipeline extends ExtractionPipelineService {
  _FakePipeline() : super(DocumentAiService());

  AiExtractionResult localResult = _labPage;

  @override
  Future<String> recognizeRawText(File image) async =>
      'Patient Name: Asha Rao  Age: 45  Sex: Female';

  @override
  AiExtractionResult? parseLocalText(String rawText) => localResult;

  @override
  void close() {}
}

DocumentTask _task(
  String id, {
  ExtractionStatus status = ExtractionStatus.readyForReview,
  AiExtractionResult? data,
  String? error,
  String path = '/tmp/missing-page.jpg',
}) {
  return DocumentTask(
    id: id,
    originalFile: File(path),
    status: status,
    extractedData: data,
    source: ExtractionSource.local,
    errorMessage: error,
  );
}

GoRouter _router() => GoRouter(
  initialLocation: '/adaptive-review',
  routes: [
    GoRoute(
      path: '/adaptive-review',
      builder: (_, __) => const AdaptiveReviewScreen(),
    ),
    GoRoute(
      path: '/smart-capture',
      builder: (_, __) => const Scaffold(body: Text('capture')),
    ),
  ],
);

Future<ProviderContainer> _pumpReview(
  WidgetTester tester,
  AppDatabase db, {
  required List<DocumentTask> seed,
}) async {
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      extractionPipelineProvider.overrideWithValue(_FakePipeline()),
      batchExtractionProvider.overrideWith(() => _SeededBatch(seed)),
    ],
  );
  addTearDown(container.dispose);

  final router = _router();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
      ),
    ),
  );
  return container;
}

Future<AppDatabase> _database() async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  // Let any confirmation SnackBar run its auto-dismiss timer so the binding
  // does not fail the test on a pending timer at teardown.
  await tester.pump(const Duration(seconds: 5));
}

/// Unmounts the tree while the tester is still alive so Drift can cancel its
/// stream queries and flush the zero-duration cleanup timer, instead of
/// leaving it pending when the binding tears the tree down.
Future<void> _shutdown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Drift cancels its stream queries during unmount and schedules a
  // zero-duration cleanup timer, which is created from a microtask. Pump a
  // few times so it is created *and* flushed before the binding verifies its
  // "no pending timers" invariant.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
}

const _secondPage = AiExtractionResult(
  patientIdentity: PatientIdentity(name: 'Vikram Singh', age: 60),
  encounterContext: EncounterContext(documentType: 'Prescription Sheet'),
  clinicalSummary: 'Discharge prescriptions.',
);

void main() {
  group('processAiExtraction', () {
    test('writes encounter, vitals and labs in one go', () async {
      final db = await _database();
      final dao = ClinicalDao(db, defaultOwnerId: 'tester');

      final encounter = await dao.processAiExtraction(
        _labPage,
        '/tmp/lab-page.jpg',
      );

      expect(encounter.imagePath, '/tmp/lab-page.jpg');
      expect(encounter.sbp, 128);
      expect(encounter.dbp, 82);
      expect(encounter.pulse, 88);
      expect(encounter.spo2, 97);
      expect(await db.select(db.investigationOrders).get(), hasLength(1));
      expect(await db.select(db.investigationResults).get(), hasLength(1));
    });

    test('never creates a duplicate encounter for the same page', () async {
      final db = await _database();
      final dao = ClinicalDao(db, defaultOwnerId: 'tester');

      final first = await dao.processAiExtraction(
        _labPage,
        '/tmp/lab-page.jpg',
      );
      final second = await dao.processAiExtraction(
        _labPage,
        '/tmp/lab-page.jpg',
      );
      final third = await dao.processAiExtraction(
        _labPage,
        '/tmp/lab-page.jpg',
      );

      expect(second.id, first.id);
      expect(third.id, first.id);
      expect(await db.select(db.clinicalEncounters).get(), hasLength(1));
      expect(await db.select(db.investigationOrders).get(), hasLength(1));
      expect(await db.select(db.investigationResults).get(), hasLength(1));
    });

    test(
      'the same page filed for a different patient is not a duplicate',
      () async {
        final db = await _database();
        final dao = ClinicalDao(db, defaultOwnerId: 'tester');
        const otherPatient = PatientIdentity(name: 'Vikram Singh', age: 60);

        await dao.processAiExtraction(_labPage, '/tmp/lab-page.jpg');
        await dao.processAiExtraction(
          _labPage.copyWith(patientIdentity: otherPatient),
          '/tmp/lab-page.jpg',
        );

        expect(await db.select(db.clinicalEncounters).get(), hasLength(2));
      },
    );
  });

  group('AdaptiveReviewScreen', () {
    testWidgets('Save & Next persists the page and advances the queue', (
      tester,
    ) async {
      final db = await _database();
      final container = await _pumpReview(
        tester,
        db,
        seed: [
          _task('t1', data: _labPage, path: '/tmp/page-1.jpg'),
          _task('t2', data: _secondPage, path: '/tmp/page-2.jpg'),
        ],
      );
      await tester.pump();

      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Save & Next'), findsOneWidget);

      await tester.tap(find.text('Save & Next'));
      await _settle(tester);

      final encounters = await db.select(db.clinicalEncounters).get();
      expect(encounters, hasLength(1));
      expect(encounters.single.imagePath, '/tmp/page-1.jpg');

      final remaining = container.read(batchExtractionProvider);
      expect(remaining, hasLength(1));
      expect(remaining.single.id, 't2');

      // The PageView now shows the second (previously "next") document.
      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('Save document'), findsOneWidget);

      await _shutdown(tester);
    });

    testWidgets('an impatient double tap cannot file the page twice', (
      tester,
    ) async {
      final db = await _database();
      await _pumpReview(
        tester,
        db,
        seed: [_task('t1', data: _labPage, path: '/tmp/page-1.jpg')],
      );
      await tester.pump();

      // Tapping twice in quick succession must not file the page twice: the
      // FAB is disabled while the write is in flight and the DAO is
      // idempotent for the same image + patient.
      await tester.tap(find.text('Save document'));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
      await _settle(tester);

      expect(await db.select(db.clinicalEncounters).get(), hasLength(1));
      await _shutdown(tester);
    });

    testWidgets('shows a local-OCR progress message while reading', (
      tester,
    ) async {
      await _pumpReview(
        tester,
        await _database(),
        seed: [_task('t1', status: ExtractionStatus.processingOcr)],
      );
      await tester.pump();

      expect(find.text('Extracting text locally…'), findsOneWidget);
      // Saving is impossible until extraction finishes.
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .onPressed,
        isNull,
      );
    });

    testWidgets('shows a cloud-AI progress message while normalising', (
      tester,
    ) async {
      await _pumpReview(
        tester,
        await _database(),
        seed: [_task('t1', status: ExtractionStatus.processingAiFallback)],
      );
      await tester.pump();

      expect(find.text('Normalizing with Cloud AI…'), findsOneWidget);
    });

    testWidgets('an error page explains itself and can be retried', (
      tester,
    ) async {
      final container = await _pumpReview(
        tester,
        await _database(),
        seed: [
          _task(
            't1',
            status: ExtractionStatus.error,
            error: 'Local OCR could not read this image.',
          ),
        ],
      );
      await tester.pump();

      expect(find.text('Could not extract this page'), findsOneWidget);
      expect(find.text('Local OCR could not read this image.'), findsOneWidget);

      await tester.tap(find.text('Retry extraction'));
      await _settle(tester);

      expect(
        container.read(batchExtractionProvider).single.status,
        ExtractionStatus.readyForReview,
      );
      expect(find.text('Save document'), findsOneWidget);

      await _shutdown(tester);
    });
  });
}
