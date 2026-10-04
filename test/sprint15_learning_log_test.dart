import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
// drift's query-builder isNull/isNotNull collide with matcher's; tests need
// the matcher versions.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sprint 15 STEP 3 - the Clinical Learning Log.
///
/// Two properties matter more than the CRUD: a reflection must never leave
/// the device (no sync enqueue), and the confidence score must stay inside
/// 1-10 so calibration data cannot be corrupted by a bad value.
void main() {
  late AppDatabase db;
  late ClinicalDao dao;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dao = ClinicalDao(db);
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: const Value('p1'),
            ownerId: 'owner-1',
            fullName: 'Ramesh Kumar',
          ),
        );
  });

  tearDown(() async => db.close());

  Future<ClinicalLearningLog> save({
    int confidence = 7,
    String differentials = 'Perforated ulcer, LBO',
    String rationale = 'Peri-umbilical tenderness with guarding',
    String takeaway = 'Earlier imaging when guarding is localised',
    String? encounterId,
  }) {
    return dao.saveReflection(
      patientId: 'p1',
      encounterId: encounterId,
      confidenceScore: confidence,
      differentialDiagnoses: differentials,
      decisionRationale: rationale,
      clinicalTakeaway: takeaway,
    );
  }

  // =========================================================================
  // PERSISTENCE
  // =========================================================================
  group('saveReflection', () {
    test('persists every field verbatim', () async {
      final log = await save();
      expect(log.differentialDiagnoses, 'Perforated ulcer, LBO');
      expect(log.decisionRationale, 'Peri-umbilical tenderness with guarding');
      expect(
        log.clinicalTakeaway,
        'Earlier imaging when guarding is localised',
      );
      expect(log.diagnosisConfidenceScore, 7);
      expect(log.patientId, 'p1');
    });

    test('trims whitespace so blank padding is not stored', () async {
      final log = await save(rationale: '  spaced out  ');
      expect(log.decisionRationale, 'spaced out');
    });

    test('encounterId is optional', () async {
      expect((await save()).encounterId, isNull);
    });

    test('links to an encounter when there was one', () async {
      await db
          .into(db.clinicalEncounters)
          .insert(
            ClinicalEncountersCompanion.insert(
              id: const Value('enc-1'),
              ownerId: 'owner-1',
              patientId: 'p1',
            ),
          );
      final log = await save(encounterId: 'enc-1');
      expect(log.encounterId, 'enc-1');
    });

    test('each reflection is an independent row', () async {
      await save();
      await save();
      expect(await dao.countReflectionsForPatient('p1'), 2);
    });
  });

  // =========================================================================
  // CONFIDENCE SCORE BOUNDS
  // =========================================================================
  group('confidence score is clamped to 1-10', () {
    test('accepts the full valid range', () async {
      for (final score in [1, 5, 10]) {
        final log = await save(confidence: score);
        expect(log.diagnosisConfidenceScore, score);
      }
    });

    test('clamps above the range instead of throwing', () async {
      // A bad import or a slider glitch must degrade gracefully rather than
      // lose the clinician's actual written reasoning.
      expect((await save(confidence: 99)).diagnosisConfidenceScore, 10);
    });

    test('clamps below the range', () async {
      expect((await save(confidence: 0)).diagnosisConfidenceScore, 1);
      expect((await save(confidence: -5)).diagnosisConfidenceScore, 1);
    });
  });

  // =========================================================================
  // PRIVACY - the reason this is a separate table at all
  // =========================================================================
  group('reflections never leave the device', () {
    test('no sync-queue row is created for a reflection', () async {
      final before = await db.select(db.offlineSyncQueue).get();
      await save();
      final after = await db.select(db.offlineSyncQueue).get();
      // If a reflection were enqueued it would carry the clinician's private
      // reasoning to a server and into other clinicians' charts.
      expect(after.length, before.length);
    });

    test(
      'is owner-scoped so a shared device does not leak reasoning',
      () async {
        await save();
        expect(await dao.countReflectionsForPatient('p1'), 1);
        expect(
          await dao.countReflectionsForPatient('p1', ownerId: 'someone-else'),
          0,
        );
        expect(
          await dao.getReflectionsForPatient('p1', ownerId: 'nope'),
          isEmpty,
        );
      },
    );
  });

  // =========================================================================
  // READS
  // =========================================================================
  group('reading reflections', () {
    test('returns newest first', () async {
      final at = DateTime.utc(2026, 3, 10);
      await dao.saveReflection(
        patientId: 'p1',
        confidenceScore: 3,
        differentialDiagnoses: 'older',
        decisionRationale: 'older',
        clinicalTakeaway: 'older',
        createdAt: at.subtract(const Duration(days: 2)),
      );
      await dao.saveReflection(
        patientId: 'p1',
        confidenceScore: 9,
        differentialDiagnoses: 'newer',
        decisionRationale: 'newer',
        clinicalTakeaway: 'newer',
        createdAt: at,
      );

      final rows = await dao.getReflectionsForPatient('p1');
      expect(rows, hasLength(2));
      expect(rows.first.differentialDiagnoses, 'newer');
    });

    test('never returns another patient reflections', () async {
      await db
          .into(db.patients)
          .insert(
            PatientsCompanion.insert(
              id: const Value('p2'),
              ownerId: 'owner-1',
              fullName: 'Someone Else',
            ),
          );
      await save();
      await dao.saveReflection(
        patientId: 'p2',
        confidenceScore: 6,
        differentialDiagnoses: 'theirs',
        decisionRationale: 'theirs',
        clinicalTakeaway: 'theirs',
      );

      final rows = await dao.getReflectionsForPatient('p1');
      expect(rows, hasLength(1));
      expect(rows.single.differentialDiagnoses, isNot('theirs'));
    });

    test('a patient with no reflections returns an empty list', () async {
      expect(await dao.getReflectionsForPatient('p1'), isEmpty);
      expect(await dao.countReflectionsForPatient('p1'), 0);
    });
  });

  // =========================================================================
  // DELETE CASCADE
  // =========================================================================
  group('lifecycle', () {
    test('deleting a patient cascades their reflections away', () async {
      await save();
      await (db.delete(db.patients)..where((row) => row.id.equals('p1'))).go();
      expect(await dao.countReflectionsForPatient('p1'), 0);
    });

    test(
      'deleting an encounter nulls the link, keeping the reflection',
      () async {
        // A reflection is the clinician's own memory of a decision. Losing it
        // because a merged duplicate encounter was removed would be a data loss
        // that cannot be recovered.
        await db
            .into(db.clinicalEncounters)
            .insert(
              ClinicalEncountersCompanion.insert(
                id: const Value('enc-1'),
                ownerId: 'owner-1',
                patientId: 'p1',
              ),
            );
        await save(encounterId: 'enc-1');

        await (db.delete(
          db.clinicalEncounters,
        )..where((row) => row.id.equals('enc-1'))).go();

        final rows = await dao.getReflectionsForPatient('p1');
        expect(rows, hasLength(1));
        expect(rows.single.encounterId, isNull);
      },
    );
  });
}
