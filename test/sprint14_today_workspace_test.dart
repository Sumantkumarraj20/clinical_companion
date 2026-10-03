import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
// drift's query-builder `isNull`/`isNotNull` collide with matcher's; the test
// assertions need the matcher versions.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sprint 14 STEP 2 — the "Today" workspace queries, and STEP 1's admission
/// write path. These run against a real in-memory SQLite schema, so a query
/// that compiles but returns nothing (or everything) fails here.
void main() {
  late AppDatabase db;
  late ClinicalDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = ClinicalDao(db);
  });

  tearDown(() async => db.close());

  /// `admissions.hospital_id` is a hard FK, so every admission fixture needs a
  /// real hospital row first. Insert-or-ignore: several tests legitimately
  /// reference the same hospital more than once.
  Future<void> addHospital(String id, {String name = 'City General'}) async {
    await db
        .into(db.hospitals)
        .insert(
          HospitalsCompanion.insert(id: Value(id), name: name),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> addPatient(
    String id, {
    String name = 'Test Patient',
    String ownerId = 'owner-1',
    int? ageYears,
    String? gender,
  }) async {
    final now = DateTime.now();
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: Value(id),
            ownerId: ownerId,
            fullName: name,
            dateOfBirth: Value(
              ageYears == null
                  ? null
                  : DateTime(now.year - ageYears, now.month, now.day),
            ),
            gender: Value(gender),
          ),
        );
  }

  Future<void> addAdmission(
    String id,
    String patientId, {
    String hospitalId = 'hosp-1',
    String? ward,
    String? bed,
    String status = 'active',
  }) async {
    await addHospital(hospitalId);
    await db
        .into(db.admissions)
        .insert(
          AdmissionsCompanion.insert(
            id: Value(id),
            patientId: patientId,
            hospitalId: hospitalId,
            wardName: Value(ward),
            bedNumber: Value(bed),
            status: Value(status),
          ),
        );
  }

  /// Clinical interventions require an encounter FK, so any surgery/procedure
  /// fixture needs one.
  Future<void> addEncounter(String patientId, {String id = 'enc-1'}) async {
    await db
        .into(db.clinicalEncounters)
        .insert(
          ClinicalEncountersCompanion.insert(
            id: Value(id),
            ownerId: 'owner-1',
            patientId: patientId,
          ),
        );
  }

  Future<void> addProcedure(
    String id,
    String patientId, {
    required DateTime performedAt,
    String role = 'Surgical',
    String name = 'Laparoscopic Appendectomy',
  }) async {
    await db
        .into(db.clinicalInterventions)
        .insert(
          ClinicalInterventionsCompanion.insert(
            id: Value(id),
            patientId: patientId,
            encounterId: 'enc-1',
            procedureName: name,
            interventionRole: Value(role),
            performedAt: Value(performedAt),
          ),
        );
  }

  // =========================================================================
  // STEP 1.2 — ADMISSIONS WRITE PATH
  // =========================================================================
  group('upsertActiveAdmission', () {
    test('creates the admission on first save', () async {
      await addPatient('p1');
      await addHospital('hosp-1');
      await dao.upsertActiveAdmission(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        wardName: 'ICU',
        bedNumber: '12',
      );

      final admission = await dao.getActiveAdmission('p1');
      expect(admission, isNotNull);
      expect(admission!.wardName, 'ICU');
      expect(admission.bedNumber, '12');
      expect(admission.hospitalId, 'hosp-1');
    });

    test(
      'is idempotent — repeated saves never duplicate the episode',
      () async {
        await addPatient('p1');
        await addHospital('hosp-1');
        for (var i = 0; i < 3; i++) {
          await dao.upsertActiveAdmission(
            patientId: 'p1',
            hospitalId: 'hosp-1',
            wardName: 'ICU',
          );
        }
        final all = await (db.select(
          db.admissions,
        )..where((row) => row.patientId.equals('p1'))).get();
        expect(all, hasLength(1), reason: 'one active episode per patient');
      },
    );

    test('updates ward/bed on an existing admission', () async {
      await addPatient('p1');
      await addHospital('hosp-1');
      await dao.upsertActiveAdmission(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        wardName: 'ICU',
        bedNumber: '12',
      );
      await dao.upsertActiveAdmission(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        wardName: 'HDU',
        bedNumber: '14',
      );

      final admission = await dao.getActiveAdmission('p1');
      expect(admission!.wardName, 'HDU');
      expect(admission.bedNumber, '14');
    });

    test('a null ward leaves the bed board untouched', () async {
      // The key safety property: a demographics-only edit (e.g. a corrected
      // phone number) must not silently wipe the ward the patient occupies.
      await addPatient('p1');
      await addHospital('hosp-1');
      await dao.upsertActiveAdmission(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        wardName: 'ICU',
        bedNumber: '12',
      );
      await dao.upsertActiveAdmission(patientId: 'p1', hospitalId: 'hosp-1');

      final admission = await dao.getActiveAdmission('p1');
      expect(admission!.wardName, 'ICU');
      expect(admission.bedNumber, '12');
    });

    test('blank ward strings normalise to null', () async {
      await addPatient('p1');
      await addHospital('hosp-1');
      await dao.upsertActiveAdmission(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        wardName: '   ',
      );
      expect((await dao.getActiveAdmission('p1'))!.wardName, isNull);
    });

    test('a closed admission is replaced, not resurrected', () async {
      await addPatient('p1');
      await addHospital('hosp-1');
      await dao.upsertActiveAdmission(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        wardName: 'ICU',
      );
      await dao.closeActiveAdmission('p1');
      expect(await dao.getActiveAdmission('p1'), isNull);

      await dao.upsertActiveAdmission(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        wardName: 'HDU',
      );
      expect((await dao.getActiveAdmission('p1'))!.wardName, 'HDU');
    });

    test('discharge records a discharge time', () async {
      await addPatient('p1');
      await addHospital('hosp-1');
      await dao.upsertActiveAdmission(patientId: 'p1', hospitalId: 'hosp-1');
      await dao.closeActiveAdmission('p1');

      final rows = await (db.select(
        db.admissions,
      )..where((row) => row.patientId.equals('p1'))).get();
      expect(rows.single.dischargeTime, isNotNull);
      expect(rows.single.status, 'discharged');
    });

    test('getActiveAdmission returns null for an outpatient', () async {
      await addPatient('p1');
      expect(await dao.getActiveAdmission('p1'), isNull);
    });
  });

  // =========================================================================
  // STEP 2.1 — WARD ROUNDS
  // =========================================================================
  group('watchActiveWardRounds', () {
    test('returns only active admissions', () async {
      await addPatient('p1', name: 'Active One');
      await addPatient('p2', name: 'Discharged One');
      await addAdmission('adm-1', 'p1', ward: 'ICU', bed: '1');
      await addAdmission(
        'adm-2',
        'p2',
        ward: 'ICU',
        bed: '2',
        status: 'discharged',
      );

      final rows = await dao.watchActiveWardRounds().first;
      expect(rows, hasLength(1));
      expect(rows.single.patient.fullName, 'Active One');
    });

    test('joins demographics and ward in one query (no N+1)', () async {
      await addPatient(
        'p1',
        name: 'Ramesh Kumar',
        ageYears: 54,
        gender: 'Male',
      );
      await addAdmission('adm-1', 'p1', ward: 'HDU', bed: '7');

      final row = (await dao.watchActiveWardRounds().first).single;
      expect(row.patient.fullName, 'Ramesh Kumar');
      expect(row.patient.gender, 'Male');
      expect(row.wardName, 'HDU');
      expect(row.bedNumber, '7');
    });

    test('filters by hospital', () async {
      await addPatient('p1');
      await addPatient('p2');
      await addAdmission('adm-1', 'p1', hospitalId: 'hosp-1');
      await addAdmission('adm-2', 'p2', hospitalId: 'hosp-2');

      final rows = await dao.watchActiveWardRounds(hospitalId: 'hosp-2').first;
      expect(rows, hasLength(1));
      expect(rows.single.admission.hospitalId, 'hosp-2');
    });

    test('empty when nobody is admitted', () async {
      expect(await dao.watchActiveWardRounds().first, isEmpty);
    });

    test('one row per admitted patient even with many encounters', () async {
      await addPatient('p1');
      await addAdmission('adm-1', 'p1');
      for (var i = 1; i <= 3; i++) {
        await addEncounter('p1', id: 'enc-$i');
      }
      expect(await dao.watchActiveWardRounds().first, hasLength(1));
    });
  });
  // =========================================================================
  // STEP 2.2 — PENDING INVESTIGATIONS
  // =========================================================================
  group('watchOutstandingInvestigations', () {
    Future<void> addOrder(
      String id,
      String patientId, {
      String status = 'ordered',
      DateTime? resultAt,
    }) async {
      await db
          .into(db.investigationOrders)
          .insert(
            InvestigationOrdersCompanion.insert(
              id: Value(id),
              patientId: patientId,
              testName: 'Complete Blood Count',
              status: Value(status),
              resultReceivedAt: Value(resultAt),
            ),
          );
    }

    test('lists orders with no result', () async {
      await addPatient('p1');
      await addOrder('ord-1', 'p1');

      final rows = await dao.watchOutstandingInvestigations().first;
      expect(rows, hasLength(1));
      expect(rows.single.investigation.testName, 'Complete Blood Count');
    });

    test('excludes orders that already have a result', () async {
      await addPatient('p1');
      await addOrder('ord-1', 'p1', status: 'result_received');
      await addOrder(
        'ord-2',
        'p1',
        status: 'result_received',
        resultAt: DateTime.now(),
      );

      expect(await dao.watchOutstandingInvestigations().first, isEmpty);
    });

    test('excludes cancelled orders', () async {
      await addPatient('p1');
      await addOrder('ord-1', 'p1', status: 'cancelled');
      expect(await dao.watchOutstandingInvestigations().first, isEmpty);
    });

    test('includes sample_sent (awaiting result, not yet reported)', () async {
      await addPatient('p1');
      await addOrder('ord-1', 'p1', status: 'sample_sent');
      expect(await dao.watchOutstandingInvestigations().first, hasLength(1));
    });

    test('attaches patient and MRN so the card needs no extra query', () async {
      await addPatient('p1', name: 'Sunita Devi');
      await addOrder('ord-1', 'p1');
      await addHospital('hosp-1');
      await dao.upsertPatientHospitalIdentifier(
        patientId: 'p1',
        hospitalId: 'hosp-1',
        mrn: 'MRN-42',
      );

      final row = (await dao.watchOutstandingInvestigations().first).single;
      expect(row.patient.fullName, 'Sunita Devi');
      expect(row.mrn, 'MRN-42');
    });

    test(
      'falls back to a placeholder MRN rather than an empty label',
      () async {
        await addPatient('p1');
        await addOrder('ord-1', 'p1');
        final row = (await dao.watchOutstandingInvestigations().first).single;
        expect(row.mrn, 'No Reg No');
      },
    );

    test('reacts to new inserts (it is a watch stream)', () async {
      await addPatient('p1');
      final emissions = <int>[];
      final sub = dao.watchOutstandingInvestigations().listen(
        (rows) => emissions.add(rows.length),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await addOrder('ord-1', 'p1');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();

      expect(emissions.last, 1);
    });
  });

  // =========================================================================
  // STEP 2.3 — SMART FOLLOW-UPS
  // =========================================================================
  group('watchSmartFollowUps', () {
    Future<void> addProblem(
      String id,
      String patientId, {
      String status = 'Active',
      DateTime? resolvedAt,
    }) async {
      await db
          .into(db.patientProblems)
          .insert(
            PatientProblemsCompanion.insert(
              id: Value(id),
              patientId: patientId,
              problemName: 'Acute Appendicitis',
              currentStatus: Value(status),
              resolvedDate: Value(resolvedAt),
            ),
          );
    }

    test('surfaces a patient with a recent procedure', () async {
      await addPatient('p1', name: 'Post-op Patient');
      await addEncounter('p1');
      await addProcedure(
        'proc-1',
        'p1',
        performedAt: DateTime.now().subtract(const Duration(days: 2)),
      );

      final rows = await dao.watchSmartFollowUps().first;
      expect(rows.map((r) => r.patient.fullName), contains('Post-op Patient'));
    });

    test('surfaces a patient with an unresolved problem', () async {
      await addPatient('p1', name: 'Active Problem');
      await addProblem('prob-1', 'p1');
      final rows = await dao.watchSmartFollowUps().first;
      expect(rows.map((r) => r.patient.fullName), contains('Active Problem'));
    });

    test('excludes a RESOLVED problem', () async {
      await addPatient('p1', name: 'Resolved Problem');
      await addProblem(
        'prob-1',
        'p1',
        status: 'Resolved',
        resolvedAt: DateTime.now(),
      );
      final rows = await dao.watchSmartFollowUps().first;
      expect(
        rows.map((r) => r.patient.fullName),
        isNot(contains('Resolved Problem')),
      );
    });

    test('ignores procedures older than the window', () async {
      await addPatient('p1', name: 'Old Procedure');
      await addEncounter('p1');
      await addProcedure(
        'proc-1',
        'p1',
        performedAt: DateTime.now().subtract(const Duration(days: 90)),
      );
      final rows = await dao.watchSmartFollowUps().first;
      expect(
        rows.map((r) => r.patient.fullName),
        isNot(contains('Old Procedure')),
      );
    });

    test('a patient matching both criteria appears exactly once', () async {
      // The encounter join fans out; the dedupe must collapse it or the tab
      // shows the same patient N times.
      await addPatient('p1', name: 'Both');
      await addEncounter('p1');
      await addProcedure(
        'proc-1',
        'p1',
        performedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      await addProblem('prob-1', 'p1');

      final rows = await dao.watchSmartFollowUps().first;
      expect(rows.where((r) => r.patient.id == 'p1'), hasLength(1));
    });

    test('reports the most recent encounter as lastSeenAt', () async {
      await addPatient('p1');
      await addProblem('prob-1', 'p1');
      await addEncounter('p1');
      final rows = await dao.watchSmartFollowUps().first;
      expect(rows.single.lastSeenAt, isNotNull);
    });

    test('a never-seen follow-up reports null, not a crash', () async {
      await addPatient('p1');
      await addProblem('prob-1', 'p1');
      final rows = await dao.watchSmartFollowUps().first;
      expect(rows.single.lastSeenAt, isNull);
    });
  });

  // =========================================================================
  // STEP 2.4 — PENDING NOTES (DRAFTS)
  // =========================================================================
  group('watchPendingNotes', () {
    Future<void> addNote(
      String id,
      String patientId, {
      required bool isDraft,
      DateTime? updatedAt,
    }) async {
      await db
          .into(db.clinicalEncounters)
          .insert(
            ClinicalEncountersCompanion.insert(
              id: Value(id),
              ownerId: 'owner-1',
              patientId: patientId,
              chiefComplaints: const Value('Abdominal pain'),
              isDraft: Value(isDraft),
              updatedAt: Value(updatedAt ?? DateTime.now()),
            ),
          );
    }

    test('returns only drafts', () async {
      await addPatient('p1');
      await addNote('enc-1', 'p1', isDraft: true);
      await addNote('enc-2', 'p1', isDraft: false);

      final rows = await dao.watchPendingNotes().first;
      expect(rows, hasLength(1));
      expect(rows.single.encounter.id, 'enc-1');
    });

    test('signed encounters never leak into the queue', () async {
      await addPatient('p1');
      await addNote('enc-1', 'p1', isDraft: false);
      expect(await dao.watchPendingNotes().first, isEmpty);
    });

    test('most recently updated draft is first', () async {
      await addPatient('p1');
      await addNote(
        'enc-old',
        'p1',
        isDraft: true,
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      await addNote('enc-new', 'p1', isDraft: true);

      final rows = await dao.watchPendingNotes().first;
      expect(rows.first.encounter.id, 'enc-new');
    });

    test('attaches the patient name', () async {
      await addPatient('p1', name: 'Draft Patient');
      await addNote('enc-1', 'p1', isDraft: true);
      final row = (await dao.watchPendingNotes().first).single;
      expect(row.patient.fullName, 'Draft Patient');
      expect(row.encounter.chiefComplaints, 'Abdominal pain');
    });
  });

  // =========================================================================
  // STEP 3 — POST-OP DAY
  // =========================================================================
  group('getPostOpDay', () {
    test('returns 0 for surgery performed today', () async {
      await addPatient('p1');
      await addEncounter('p1');
      await addProcedure('proc-1', 'p1', performedAt: DateTime.now());
      expect(await dao.getPostOpDay('p1'), 0);
    });

    test('counts calendar days since surgery', () async {
      await addPatient('p1');
      await addEncounter('p1');
      await addProcedure(
        'proc-1',
        'p1',
        performedAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(await dao.getPostOpDay('p1'), 2);
    });

    test('null when no surgery is recorded', () async {
      await addPatient('p1');
      expect(await dao.getPostOpDay('p1'), isNull);
    });

    test('ignores NON-surgical interventions', () async {
      // A diagnostic imaging study is not an operation; a "POD #3" badge on one
      // would be a false clinical statement.
      await addPatient('p1');
      await addEncounter('p1');
      await addProcedure(
        'proc-1',
        'p1',
        performedAt: DateTime.now().subtract(const Duration(days: 3)),
        role: 'Diagnostic',
      );
      expect(await dao.getPostOpDay('p1'), isNull);
    });

    test('a future-dated procedure yields null, not a negative day', () async {
      await addPatient('p1');
      await addEncounter('p1');
      await addProcedure(
        'proc-1',
        'p1',
        performedAt: DateTime.now().add(const Duration(days: 5)),
      );
      expect(await dao.getPostOpDay('p1'), isNull);
    });

    test('uses the MOST RECENT surgery when there are several', () async {
      await addPatient('p1');
      await addEncounter('p1');
      await addProcedure(
        'proc-old',
        'p1',
        performedAt: DateTime.now().subtract(const Duration(days: 40)),
      );
      await addProcedure(
        'proc-new',
        'p1',
        performedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(await dao.getPostOpDay('p1'), 1);
    });
  });

  // =========================================================================
  // SCHEMA: isDraft defaults to false
  // =========================================================================
  group('isDraft default', () {
    test('new encounters are NOT drafts unless explicitly flagged', () async {
      await addPatient('p1');
      await addEncounter('p1');
      final row = await db.select(db.clinicalEncounters).getSingle();
      expect(
        row.isDraft,
        isFalse,
        reason:
            'a bulk draft=true backfill would flood the pending queue '
            'with already-signed notes',
      );
    });
  });
}
