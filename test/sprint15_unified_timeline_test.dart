import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sprint 15 STEP 2 - the unified timeline merge.
///
/// The risk in a five-way merge is silent data loss: a source that quietly
/// returns nothing, or a sort that is nearly-right. These assert both the union
/// (every source appears) and the ordering (reverse-chronological, stable).
void main() {
  late AppDatabase db;
  late ClinicalDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = ClinicalDao(db);
  });

  tearDown(() async => db.close());

  Future<void> seedPatient([String id = 'p1']) async {
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: Value(id),
            ownerId: 'owner-1',
            fullName: 'Ramesh Kumar',
          ),
        );
  }

  Future<void> seedHospital([String id = 'hosp-1']) async {
    await db
        .into(db.hospitals)
        .insert(HospitalsCompanion.insert(id: Value(id), name: 'City General'));
  }

  Future<void> seedEncounter(String id) async {
    await db
        .into(db.clinicalEncounters)
        .insert(
          ClinicalEncountersCompanion.insert(
            id: Value(id),
            ownerId: 'owner-1',
            patientId: 'p1',
          ),
        );
  }

  // =========================================================================
  // THE UNION - every source must appear
  // =========================================================================
  group('merge includes every source', () {
    test('an empty patient yields an empty timeline', () async {
      await seedPatient();
      expect(await dao.mergeTimeline('p1'), isEmpty);
    });

    test('all five sources merge into one list', () async {
      await seedPatient();
      await seedHospital();

      await db
          .into(db.admissions)
          .insert(
            AdmissionsCompanion.insert(
              id: Value('adm-1'),
              patientId: 'p1',
              hospitalId: 'hosp-1',
              wardName: const Value('ICU'),
              bedNumber: const Value('12'),
            ),
          );
      await db
          .into(db.clinicalEncounters)
          .insert(
            ClinicalEncountersCompanion.insert(
              id: Value('enc-1'),
              ownerId: 'owner-1',
              patientId: 'p1',
              hospitalId: const Value('hosp-1'),
              wardName: const Value('ICU'),
            ),
          );
      await db
          .into(db.investigationResults)
          .insert(
            InvestigationResultsCompanion.insert(
              id: Value('res-1'),
              patientId: 'p1',
              testName: 'Haemoglobin',
              numericValue: const Value(8.4),
            ),
          );
      // prescription_orders.encounterId is a hard FK.
      await db
          .into(db.prescriptionOrders)
          .insert(
            PrescriptionOrdersCompanion.insert(
              id: Value('rx-1'),
              patientId: 'p1',
              encounterId: 'enc-1',
              drugName: 'Amoxicillin',
              route: const Value('PO'),
              frequency: const Value('TDS'),
            ),
          );
      await db
          .into(db.documentRegistries)
          .insert(
            DocumentRegistriesCompanion.insert(
              id: 'doc-1',
              patientId: 'p1',
              documentCategory: 'Histopathology Report',
              imagePath: '/tmp/a.jpg',
              documentedAt: DateTime.utc(2026, 2, 1),
            ),
          );

      final events = await dao.mergeTimeline('p1');
      expect(events, hasLength(5));
      expect(
        events.map((e) => e.kind).toSet(),
        TimelineEventKind.values.toSet(),
        reason: 'all five sources must be represented',
      );
    });

    test('another patient records never leak in', () async {
      await seedPatient('p1');
      await seedPatient('p2');
      await db
          .into(db.documentRegistries)
          .insert(
            DocumentRegistriesCompanion.insert(
              id: 'doc-1',
              patientId: 'p1',
              documentCategory: 'Mine',
              imagePath: '/tmp/a.jpg',
              documentedAt: DateTime.utc(2026, 2, 1),
            ),
          );
      await db
          .into(db.documentRegistries)
          .insert(
            DocumentRegistriesCompanion.insert(
              id: 'doc-2',
              patientId: 'p2',
              documentCategory: 'Theirs',
              imagePath: '/tmp/b.jpg',
              documentedAt: DateTime.utc(2026, 2, 1),
            ),
          );

      final events = await dao.mergeTimeline('p1');
      expect(events, hasLength(1));
      expect(events.single.title, 'Mine');
    });
  });

  // =========================================================================
  // FIELD EXTRACTION
  // =========================================================================
  group('per-kind field extraction', () {
    test('admissions carry ward and bed context', () async {
      await seedPatient();
      await seedHospital();
      await db
          .into(db.admissions)
          .insert(
            AdmissionsCompanion.insert(
              id: Value('res-1'),
              patientId: 'p1',
              hospitalId: 'hosp-1',
              wardName: const Value('HDU'),
              bedNumber: const Value('7'),
            ),
          );

      final event = (await dao.mergeTimeline('p1')).single;
      expect(event.kind, TimelineEventKind.admission);
      expect(event.wardName, 'HDU');
      expect(event.bedNumber, '7');
      expect(event.subtitle, contains('HDU'));
      expect(event.subtitle, contains('Bed 7'));
      expect(event.hospitalId, 'hosp-1');
    });

    test('abnormal labs are flagged and clearly labelled', () async {
      await seedPatient();
      await db
          .into(db.investigationResults)
          .insert(
            InvestigationResultsCompanion.insert(
              id: Value('res-1'),
              patientId: 'p1',
              testName: 'Platelet count',
              numericValue: const Value(42),
              isAbnormal: const Value(true),
            ),
          );

      final event = (await dao.mergeTimeline('p1')).single;
      expect(event.isAbnormal, isTrue);
      expect(event.detail, 'Abnormal');
      expect(event.title, 'Platelet count');
    });

    test('normal labs are never flagged abnormal', () async {
      await seedPatient();
      await db
          .into(db.investigationResults)
          .insert(
            InvestigationResultsCompanion.insert(
              id: Value('res-1'),
              patientId: 'p1',
              testName: 'Haemoglobin',
              numericValue: const Value(13.2),
            ),
          );
      expect((await dao.mergeTimeline('p1')).single.isAbnormal, isFalse);
    });

    test('prescriptions show drug, strength and frequency', () async {
      await seedPatient();
      await seedEncounter('enc-1');
      await db
          .into(db.prescriptionOrders)
          .insert(
            PrescriptionOrdersCompanion.insert(
              id: Value('rx-1'),
              patientId: 'p1',
              encounterId: 'enc-1',
              drugName: 'Pantoprazole',
              doseStrength: const Value('40mg'),
              route: const Value('PO'),
              frequency: const Value('OD'),
            ),
          );

      final event = (await dao.mergeTimeline(
        'p1',
      )).firstWhere((e) => e.kind == TimelineEventKind.prescription);
      expect(event.title, 'Pantoprazole');
      expect(event.subtitle, contains('40mg'));
      expect(event.subtitle, contains('OD'));
    });

    test('documents carry the scan path for the edit-mode hand-off', () async {
      await seedPatient();
      await db
          .into(db.documentRegistries)
          .insert(
            DocumentRegistriesCompanion.insert(
              id: 'doc-1',
              patientId: 'p1',
              documentCategory: 'CT Scan',
              imagePath: '/tmp/ct.jpg',
              documentedAt: DateTime.utc(2026, 2, 1),
            ),
          );

      final event = (await dao.mergeTimeline('p1')).single;
      expect(event.kind, TimelineEventKind.document);
      // Without this the card cannot route into
      // AdaptiveReviewScreen.editExisting().
      expect(event.imagePath, '/tmp/ct.jpg');
      expect(event.id, 'document:doc-1');
    });

    test('event ids are namespaced so they never collide', () async {
      await seedPatient();
      await db
          .into(db.documentRegistries)
          .insert(
            DocumentRegistriesCompanion.insert(
              id: 'doc-1',
              patientId: 'p1',
              documentCategory: 'A',
              imagePath: '/tmp/a.jpg',
              documentedAt: DateTime.utc(2026, 2, 1),
            ),
          );
      await seedEncounter('same-id');
      final ids = (await dao.mergeTimeline('p1')).map((e) => e.id).toList();
      expect(ids.toSet(), hasLength(2));
    });
  });

  // =========================================================================
  // ORDERING
  // =========================================================================
  group('ordering', () {
    test('is strictly reverse-chronological', () {
      final now = DateTime(2026, 3, 10, 12);
      final events = [
        TimelineEvent(
          id: 'a',
          kind: TimelineEventKind.encounter,
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        TimelineEvent(
          id: 'b',
          kind: TimelineEventKind.labResult,
          timestamp: now,
        ),
        TimelineEvent(
          id: 'c',
          kind: TimelineEventKind.document,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ];
      ClinicalDao.sortTimeline(events);
      expect(events.map((e) => e.id).toList(), ['b', 'c', 'a']);
    });

    test('ties break deterministically, not by insertion order', () {
      final at = DateTime(2026, 3, 10);
      List<TimelineEvent> build() => [
        TimelineEvent(id: 'z', kind: TimelineEventKind.document, timestamp: at),
        TimelineEvent(
          id: 'a',
          kind: TimelineEventKind.encounter,
          timestamp: at,
        ),
        TimelineEvent(
          id: 'm',
          kind: TimelineEventKind.admission,
          timestamp: at,
        ),
      ];
      final first = build();
      ClinicalDao.sortTimeline(first);
      final second = build();
      ClinicalDao.sortTimeline(second);

      // Same input must always yield the same order, otherwise the feed
      // visibly jitters on every stream emission.
      expect(first.map((e) => e.id).toList(), second.map((e) => e.id).toList());
      expect(first.first.kind, TimelineEventKind.admission);
    });

    test('sorting an empty or single-item list is safe', () {
      ClinicalDao.sortTimeline([]);
      final one = [
        TimelineEvent(
          id: 'x',
          kind: TimelineEventKind.encounter,
          timestamp: DateTime(2026),
        ),
      ];
      ClinicalDao.sortTimeline(one);
      expect(one, hasLength(1));
    });

    test('the merged feed really is sorted newest-first', () async {
      await seedPatient();
      await seedHospital();
      await db
          .into(db.admissions)
          .insert(
            AdmissionsCompanion.insert(
              id: Value('adm-old'),
              patientId: 'p1',
              hospitalId: 'hosp-1',
              admissionTime: Value(DateTime.utc(2024, 1, 1)),
            ),
          );
      await db
          .into(db.documentRegistries)
          .insert(
            DocumentRegistriesCompanion.insert(
              id: 'doc-new',
              patientId: 'p1',
              documentCategory: 'Recent',
              imagePath: '/tmp/new.jpg',
              documentedAt: DateTime.utc(2026, 1, 1),
            ),
          );

      final events = await dao.mergeTimeline('p1');
      expect(events.first.kind, TimelineEventKind.document);
      expect(events.last.kind, TimelineEventKind.admission);
    });
  });
}
