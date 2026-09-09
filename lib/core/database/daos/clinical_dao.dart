import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/ai_extraction_result.dart';
import '../../../features/billing/services/clinical_coding_service.dart';
import '../local_database.dart';
import '../schema/clinical_records.dart' as clinical_records;
import '../services/identity_resolution_service.dart';

part 'clinical_dao.g.dart';

typedef Investigation = InvestigationOrder;
typedef InvestigationsCompanion = InvestigationOrdersCompanion;
typedef ClinicalAction = ClinicalIntervention;
typedef ClinicalActionsCompanion = ClinicalInterventionsCompanion;
typedef ClinicalOutcome = ClinicalOutcomeMetric;
typedef ClinicalOutcomesCompanion = ClinicalOutcomeMetricsCompanion;

/// Typed result used by the lab tracker to display a patient beside a test.
class PendingInvestigation {
  const PendingInvestigation({
    required this.investigation,
    required this.patient,
    required this.hospitalRegNo,
  });

  final InvestigationOrder investigation;
  final Patient patient;
  final String hospitalRegNo;
}

@DriftAccessor(
  tables: [
    Patients,
    Hospitals,
    Wards,
    PatientHospitalIdentifiers,
    ClinicalEncounters,
    PatientProblems,
    ProblemProgressSnapshots,
    ClinicalInterventions,
    ClinicalOutcomeMetrics,
    PrescriptionOrders,
    InvestigationOrders,
    InvestigationResults,
    LearnedCatalog,
    Drugs,
    PersonalWiki,
    OfflineSyncQueue,
    CdssRules,
    AyushmanPackages,
    HbpProcedures,
    HbpImplants,
    HbpStratifications,
    clinical_records.DocumentRegistries,
    clinical_records.ClinicalObservations,
  ],
)
class ClinicalDao extends DatabaseAccessor<AppDatabase>
    with _$ClinicalDaoMixin {
  ClinicalDao(super.db, {this.defaultOwnerId = 'local-practitioner'});

  final _ids = const Uuid();
  final String defaultOwnerId;

  // =========================================================================
  // 1. AI DOCUMENT EXTRACTION TRANSACTION
  // =========================================================================
  Future<ClinicalEncounter> processAiExtraction(
    AiExtractionResult result,
    String imagePath, {
    String? patientIdOverride,
  }) async {
    return transaction(() async {
      final patientId =
          patientIdOverride ??
          await IdentityResolutionService(
            database: attachedDatabase,
            ownerId: defaultOwnerId,
          ).resolvePatient(result.patientIdentity);

      final occurredAt =
          _date(result.encounterContext.date) ?? DateTime.now().toUtc();
      final vitals = result.vitals;
      final encounterId = _ids.v4();

      final encounter = ClinicalEncountersCompanion.insert(
        id: Value(encounterId),
        ownerId: defaultOwnerId,
        patientId: patientId,
        encounterType: Value(result.encounterContext.documentType),
        occurredAt: Value(occurredAt),
        sbp: Value(vitals.sbp),
        dbp: Value(vitals.dbp),
        pulse: Value(vitals.pr),
        temperatureC: Value(vitals.temperatureC),
        spo2: Value(vitals.spo2),
        chiefComplaints: Value(
          result.clinicalSummary.trim().isEmpty
              ? null
              : result.clinicalSummary.trim(),
        ),
        clinicalAssessment: Value(
          result.clinicalSummary.trim().isEmpty
              ? null
              : result.clinicalSummary.trim(),
        ),
        consultantAdvice: Value(
          result.clinicalSummary.trim().isEmpty
              ? null
              : result.clinicalSummary.trim(),
        ),
        dynamicData: Value(result.toJson()),
        department: Value(result.encounterContext.department),
        wardName: Value(result.encounterContext.wardBed),
        imagePath: Value(imagePath),
        aiSummary: Value(result.clinicalSummary),
      );

      await into(clinicalEncounters).insert(encounter);

      final savedEncounter = await (select(
        clinicalEncounters,
      )..where((row) => row.id.equals(encounterId))).getSingle();

      await _enqueue(
        ownerId: defaultOwnerId,
        entityType: 'clinical_encounters',
        entityId: savedEncounter.id,
        operation: 'insert',
        payload: _clinicalEncounterPayload(savedEncounter),
        clientUpdatedAt: savedEncounter.updatedAt,
      );

      // Track extracted laboratory investigations
      for (final lab in result.labResults) {
        final orderId = _ids.v4();
        await into(investigationOrders).insert(
          InvestigationOrdersCompanion.insert(
            id: Value(orderId),
            ownerId: Value(defaultOwnerId),
            patientId: patientId,
            encounterId: Value(encounterId),
            testName: lab.testName,
            status: const Value('result_received'),
            orderedAt: Value(occurredAt),
            resultReceivedAt: Value(occurredAt),
            clinicalIndication: Value(
              lab.isAbnormal ? 'AI flagged abnormal' : null,
            ),
          ),
        );

        final resultId = _ids.v4();
        final numVal = double.tryParse(
          lab.value.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        await into(investigationResults).insert(
          InvestigationResultsCompanion.insert(
            id: Value(resultId),
            orderId: Value(orderId),
            patientId: patientId,
            testName: lab.testName,
            numericValue: Value(numVal),
            textValue: Value(lab.value),
            unit: Value(lab.unit),
            isAbnormal: Value(lab.isAbnormal),
            resultDate: Value(occurredAt),
          ),
        );
      }

      // Track medications and synthesize baseline problem record
      if (result.medicationsOrdered.isNotEmpty) {
        final problemId = _ids.v4();
        await into(patientProblems).insert(
          PatientProblemsCompanion.insert(
            id: Value(problemId),
            patientId: patientId,
            initialEncounterId: Value(encounterId),
            problemName: 'AI Capture Active Finding',
            currentStatus: const Value('Active'),
            onsetDate: Value(occurredAt),
          ),
        );

        for (final medication in result.medicationsOrdered) {
          final medId = _ids.v4();
          await into(prescriptionOrders).insert(
            PrescriptionOrdersCompanion.insert(
              id: Value(medId),
              patientId: patientId,
              encounterId: encounterId,
              problemId: Value(problemId),
              drugName: medication.drugName,
              doseStrength: Value(medication.dosage),
              frequency: Value(medication.frequency),
              orderedAt: Value(occurredAt),
            ),
          );
        }
      }

      return savedEncounter;
    });
  }

  // =========================================================================
  // 2. PATIENTS & MULTI-HOSPITAL IDENTIFIERS
  // =========================================================================
  Stream<List<Patient>> watchAllPatients() {
    return (select(patients)
          ..where((row) => row.isActive.equals(true))
          ..orderBy([(row) => OrderingTerm(expression: row.fullName)]))
        .watch();
  }

  Future<Patient?> findPatient(String id) {
    return (select(
      patients,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<Patient> insertPatient(PatientsCompanion values) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    final normalized = values.copyWith(id: Value(id));
    return transaction(() async {
      await into(patients).insert(normalized);
      final row = await (select(
        patients,
      )..where((item) => item.id.equals(id))).getSingle();
      await _enqueue(
        ownerId: row.ownerId,
        entityType: 'patients',
        entityId: row.id,
        operation: 'insert',
        payload: _patientPayload(row),
        clientUpdatedAt: row.updatedAt,
      );
      return row;
    });
  }

  Future<Patient> insertPatientWithHospitalId({
    required PatientsCompanion patient,
    required String hospitalId,
    required String hospitalRegNo,
  }) async {
    final patientId = patient.id.present ? patient.id.value : _ids.v4();
    return transaction(() async {
      await into(patients).insert(patient.copyWith(id: Value(patientId)));
      await into(patientHospitalIdentifiers).insert(
        PatientHospitalIdentifiersCompanion.insert(
          id: Value(_ids.v4()),
          patientId: patientId,
          hospitalId: hospitalId,
          hospitalRegNo: hospitalRegNo.trim(),
          isPrimary: const Value(true),
        ),
      );
      final saved = await (select(
        patients,
      )..where((row) => row.id.equals(patientId))).getSingle();
      await _enqueue(
        ownerId: saved.ownerId,
        entityType: 'patients',
        entityId: saved.id,
        operation: 'insert',
        payload: _patientPayload(saved),
        clientUpdatedAt: saved.updatedAt,
      );
      return saved;
    });
  }

  Future<String> ensureDefaultHospitalId() async {
    final existing =
        await (select(hospitals)
              ..where((row) => row.isActive.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    final id = _ids.v4();
    await into(hospitals).insert(
      HospitalsCompanion.insert(
        id: Value(id),
        name: 'Primary Facility',
        shortName: const Value('Primary'),
      ),
    );
    return id;
  }

  Future<void> upsertPatientHospitalIdentifier({
    required String patientId,
    required String hospitalId,
    required String hospitalRegNo,
    bool isPrimary = true,
  }) async {
    final existing =
        await (select(patientHospitalIdentifiers)..where(
              (row) =>
                  row.patientId.equals(patientId) &
                  row.hospitalId.equals(hospitalId),
            ))
            .getSingleOrNull();

    final values = PatientHospitalIdentifiersCompanion(
      id: existing == null ? Value(_ids.v4()) : Value(existing.id),
      patientId: Value(patientId),
      hospitalId: Value(hospitalId),
      hospitalRegNo: Value(hospitalRegNo.trim()),
      isPrimary: Value(isPrimary),
      updatedAt: Value(DateTime.now().toUtc()),
    );

    if (existing == null) {
      await into(patientHospitalIdentifiers).insert(values);
    } else {
      await update(patientHospitalIdentifiers).replace(values);
    }
  }

  Future<String> getPatientHospitalRegNo(String patientId) async {
    final identifier =
        await (select(patientHospitalIdentifiers)..where(
              (row) =>
                  row.patientId.equals(patientId) & row.isPrimary.equals(true),
            ))
            .getSingleOrNull();
    return identifier?.hospitalRegNo ?? 'No Reg No';
  }

  Future<void> updatePatient(Patient patient) async {
    await transaction(() async {
      final updated = patient.copyWith(updatedAt: DateTime.now().toUtc());
      await update(patients).replace(updated);
      await _enqueue(
        ownerId: updated.ownerId,
        entityType: 'patients',
        entityId: updated.id,
        operation: 'update',
        payload: _patientPayload(updated),
        clientUpdatedAt: updated.updatedAt,
      );
    });
  }

  Future<void> deletePatient(Patient patient) async {
    await transaction(() async {
      await _enqueue(
        ownerId: patient.ownerId,
        entityType: 'patients',
        entityId: patient.id,
        operation: 'delete',
        payload: {'id': patient.id},
        clientUpdatedAt: DateTime.now().toUtc(),
      );
      await delete(patients).delete(patient);
    });
  }

  // =========================================================================
  // 3. PROBLEM-ORIENTED MEDICAL RECORD (POMR) & ENCOUNTER TRANSACTIONS
  // =========================================================================
  Future<void> savePOMREncounter({
    required ClinicalEncountersCompanion encounter,
    List<PatientProblemsCompanion> newProblems = const [],
    List<ProblemProgressSnapshotsCompanion> progressSnapshots = const [],
    List<ClinicalInterventionsCompanion> interventions = const [],
    List<PrescriptionOrdersCompanion> prescriptions = const [],
    List<InvestigationOrdersCompanion> investigations = const [],
  }) async {
    await transaction(() async {
      final encounterId = encounter.id.present ? encounter.id.value : _ids.v4();
      final normalizedEncounter = encounter.copyWith(id: Value(encounterId));

      await into(clinicalEncounters).insert(normalizedEncounter);

      for (final problem in newProblems) {
        await into(patientProblems).insertOnConflictUpdate(problem);
      }
      for (final snapshot in progressSnapshots) {
        await into(
          problemProgressSnapshots,
        ).insert(snapshot.copyWith(encounterId: Value(encounterId)));
      }
      for (final intervention in interventions) {
        await into(
          clinicalInterventions,
        ).insert(intervention.copyWith(encounterId: Value(encounterId)));
      }
      for (final prescription in prescriptions) {
        await into(
          prescriptionOrders,
        ).insert(prescription.copyWith(encounterId: Value(encounterId)));
      }
      for (final investigation in investigations) {
        await into(
          investigationOrders,
        ).insert(investigation.copyWith(encounterId: Value(encounterId)));
      }

      final saved = await (select(
        clinicalEncounters,
      )..where((row) => row.id.equals(encounterId))).getSingle();
      await _enqueue(
        ownerId: saved.ownerId,
        entityType: 'clinical_encounters',
        entityId: saved.id,
        operation: 'insert',
        payload: _clinicalEncounterPayload(saved),
        clientUpdatedAt: saved.updatedAt,
      );
    });
  }

  Future<ClinicalEncounter> saveManualEncounter({
    required String ownerId,
    required String? patientId,
    required String patientName,
    required int? patientAge,
    required String? patientGender,
    required String? patientPhone,
    required int? sbp,
    required int? dbp,
    required int? pulse,
    required int? spo2,
    required String chiefComplaint,
    required String note,
  }) async {
    return transaction(() async {
      var resolvedPatientId = patientId;
      if (resolvedPatientId == null) {
        final identity = PatientIdentity(
          name: patientName.trim().isEmpty ? null : patientName.trim(),
          age: patientAge,
          gender: patientGender?.trim().isEmpty == true
              ? null
              : patientGender?.trim(),
        );
        resolvedPatientId = await IdentityResolutionService(
          database: attachedDatabase,
          ownerId: ownerId,
        ).resolvePatient(identity);

        if (patientPhone?.trim().isNotEmpty == true) {
          final patient = await findPatient(resolvedPatientId);
          if (patient != null && patient.phone == null) {
            final updatedAt = DateTime.now().toUtc();
            await update(patients).write(
              PatientsCompanion(
                phone: Value(patientPhone!.trim()),
                updatedAt: Value(updatedAt),
              ),
            );
          }
        }
      }

      final id = _ids.v4();
      await into(clinicalEncounters).insert(
        ClinicalEncountersCompanion.insert(
          id: Value(id),
          ownerId: ownerId,
          patientId: resolvedPatientId,
          encounterType: const Value('Manual Quick Entry'),
          sbp: Value(sbp),
          dbp: Value(dbp),
          pulse: Value(pulse),
          spo2: Value(spo2),
          chiefComplaints: Value(
            chiefComplaint.trim().isEmpty ? null : chiefComplaint.trim(),
          ),
          clinicalAssessment: Value(note.trim().isEmpty ? null : note.trim()),
          consultantAdvice: Value(note.trim().isEmpty ? null : note.trim()),
        ),
      );

      final saved = await (select(
        clinicalEncounters,
      )..where((row) => row.id.equals(id))).getSingle();
      await _enqueue(
        ownerId: ownerId,
        entityType: 'clinical_encounters',
        entityId: saved.id,
        operation: 'insert',
        payload: _clinicalEncounterPayload(saved),
        clientUpdatedAt: saved.updatedAt,
      );
      return saved;
    });
  }

  Stream<List<ClinicalEncounter>> watchClinicalEncounters(DateTime day) {
    final start = DateTime(day.year, day.month, day.day).toUtc();
    final end = start.add(const Duration(days: 1));
    return (select(clinicalEncounters)
          ..where((row) => row.occurredAt.isBetweenValues(start, end))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.occurredAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Stream<List<ClinicalEncounter>> watchWardEncounters({
    required String department,
    required String wardName,
    required String bedNumber,
  }) =>
      (select(clinicalEncounters)
            ..where(
              (row) =>
                  row.department.equals(department) &
                  row.wardName.equals(wardName) &
                  row.bedNumber.equals(bedNumber),
            )
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.occurredAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<List<ClinicalEncounter>> getEncountersForPatient(String patientId) {
    return (select(clinicalEncounters)
          ..where((row) => row.patientId.equals(patientId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.occurredAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<ClinicalEncounter> insertClinicalEncounter(
    ClinicalEncountersCompanion values,
  ) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    final normalized = values.copyWith(id: Value(id));
    return transaction(() async {
      await into(clinicalEncounters).insert(normalized);
      final row = await (select(
        clinicalEncounters,
      )..where((item) => item.id.equals(id))).getSingle();
      await _enqueue(
        ownerId: row.ownerId,
        entityType: 'clinical_encounters',
        entityId: row.id,
        operation: 'insert',
        payload: _clinicalEncounterPayload(row),
        clientUpdatedAt: row.updatedAt,
      );
      return row;
    });
  }

  Future<void> updateClinicalEncounter(ClinicalEncounter encounter) async {
    await transaction(() async {
      final updated = encounter.copyWith(updatedAt: DateTime.now().toUtc());
      await update(clinicalEncounters).replace(updated);
      await _enqueue(
        ownerId: updated.ownerId,
        entityType: 'clinical_encounters',
        entityId: updated.id,
        operation: 'update',
        payload: _clinicalEncounterPayload(updated),
        clientUpdatedAt: updated.updatedAt,
      );
    });
  }

  Future<void> deleteClinicalEncounter(ClinicalEncounter encounter) async {
    await transaction(() async {
      await _enqueue(
        ownerId: encounter.ownerId,
        entityType: 'clinical_encounters',
        entityId: encounter.id,
        operation: 'delete',
        payload: {'id': encounter.id},
        clientUpdatedAt: DateTime.now().toUtc(),
      );
      await delete(clinicalEncounters).delete(encounter);
    });
  }

  // =========================================================================
  // 4. PROBLEM TRAJECTORIES & INTERVENTIONS
  // =========================================================================
  Stream<List<PatientProblem>> watchPatientProblems(String patientId) =>
      (select(patientProblems)
            ..where((row) => row.patientId.equals(patientId))
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<PatientProblem> insertPatientProblem(
    PatientProblemsCompanion values,
  ) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    await into(patientProblems).insert(values.copyWith(id: Value(id)));
    return (select(
      patientProblems,
    )..where((row) => row.id.equals(id))).getSingle();
  }

  Future<PatientProblem?> getPatientProblem(String id) => (select(
    patientProblems,
  )..where((row) => row.id.equals(id))).getSingleOrNull();

  Stream<List<ClinicalIntervention>> watchInterventionsForProblem(
    String problemId,
  ) =>
      (select(clinicalInterventions)
            ..where((row) => row.problemId.equals(problemId))
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.performedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<void> insertClinicalIntervention(
    ClinicalInterventionsCompanion values,
  ) => into(clinicalInterventions).insert(values);

  Stream<List<ClinicalOutcomeMetric>> watchOutcomesForProblem(
    String problemId,
  ) =>
      (select(clinicalOutcomeMetrics)
            ..where((row) => row.problemId.equals(problemId))
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.measuredAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Stream<List<ClinicalIntervention>> watchActionsForProblem(String problemId) =>
      watchInterventionsForProblem(problemId);

  Future<void> insertClinicalAction(ClinicalInterventionsCompanion values) =>
      insertClinicalIntervention(values);

  // =========================================================================
  // 5. INVESTIGATION ORDERS & LAB TRACKER
  // =========================================================================
  Stream<List<InvestigationOrder>> watchPendingInvestigations() {
    return (select(investigationOrders)
          ..where((row) => row.status.isIn(const ['ordered', 'sample_sent']))
          ..orderBy([(row) => OrderingTerm(expression: row.orderedAt)]))
        .watch();
  }

  Stream<List<PendingInvestigation>> watchPendingInvestigationsWithPatients({
    DateTime? day,
  }) {
    final selectedDay = day ?? DateTime.now();
    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    ).toUtc();
    final end = start.add(const Duration(days: 1));

    final query =
        select(investigationOrders).join([
            innerJoin(
              patients,
              patients.id.equalsExp(investigationOrders.patientId),
            ),
            leftOuterJoin(
              patientHospitalIdentifiers,
              patientHospitalIdentifiers.patientId.equalsExp(patients.id) &
                  patientHospitalIdentifiers.isPrimary.equals(true),
            ),
          ])
          ..where(
            investigationOrders.status.isIn(const ['ordered', 'sample_sent']) &
                investigationOrders.orderedAt.isBetweenValues(start, end),
          )
          ..orderBy([OrderingTerm(expression: investigationOrders.orderedAt)]);

    return query.watch().map((rows) {
      return rows
          .map((row) {
            final identifier = row.readTableOrNull(patientHospitalIdentifiers);
            return PendingInvestigation(
              investigation: row.readTable(investigationOrders),
              patient: row.readTable(patients),
              hospitalRegNo: identifier?.hospitalRegNo ?? 'No Reg No',
            );
          })
          .toList(growable: false);
    });
  }

  Future<InvestigationOrder?> findInvestigation(String id) {
    return (select(
      investigationOrders,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<List<InvestigationOrder>> getInvestigationsForPatient(
    String patientId,
  ) {
    return (select(investigationOrders)
          ..where((row) => row.patientId.equals(patientId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.orderedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<void> updateInvestigationStatus(String id, String status) async {
    final current = await findInvestigation(id);
    if (current == null) return;
    final now = DateTime.now().toUtc();
    final updated = current.copyWith(
      status: status,
      sampleSentAt: Value(status == 'sample_sent' ? now : current.sampleSentAt),
      resultReceivedAt: Value(
        status == 'result_received' ? now : current.resultReceivedAt,
      ),
      updatedAt: now,
    );
    await update(investigationOrders).replace(updated);
  }

  Future<void> addInvestigation(InvestigationOrdersCompanion values) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    await into(investigationOrders).insert(values.copyWith(id: Value(id)));
  }

  Future<void> deleteInvestigation(InvestigationOrder investigation) async {
    await transaction(() async {
      await (delete(
        investigationOrders,
      )..where((row) => row.id.equals(investigation.id))).go();
    });
  }

  // =========================================================================
  // 6. PHARMACOPEIA & DRUG INVENTORY
  // =========================================================================
  Stream<List<Drug>> watchDrugs(String search) {
    final query = select(drugs)..where((row) => row.isActive.equals(true));
    if (search.trim().isNotEmpty) {
      final term = '%${search.trim().toLowerCase()}%';
      query.where(
        (row) =>
            row.genericName.like(term) |
            (row.brandName.isNotNull() &
                row.brandName.dartCast<String>().like(term)),
      );
    }
    query.orderBy([(row) => OrderingTerm(expression: row.genericName)]);
    return query.watch();
  }

  Future<void> insertDrug(DrugsCompanion values) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    await into(drugs).insert(values.copyWith(id: Value(id)));
  }

  // =========================================================================
  // 7. PERSONAL WIKI & CLINICAL KNOWLEDGE BASE
  // =========================================================================
  Stream<List<PersonalWikiEntry>> watchWikiEntries({
    String query = '',
    String? ownerId,
  }) {
    final normalized = query.trim().toLowerCase();
    final statement = select(personalWiki)
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.updatedAt, mode: OrderingMode.desc),
      ]);
    if (ownerId != null) statement.where((row) => row.ownerId.equals(ownerId));
    if (normalized.isNotEmpty) {
      for (final token
          in normalized.split(RegExp(r'\s+')).where((v) => v.isNotEmpty)) {
        final pattern = '%${token.replaceAll('%', '\\%')}%';
        statement.where(
          (row) =>
              row.topic.like(pattern) |
              row.markdownContent.like(pattern) |
              row.tags.dartCast<String>().like(pattern) |
              row.departmentRelevance.dartCast<String>().like(pattern),
        );
      }
    }
    return statement.watch();
  }

  Future<PersonalWikiEntry> insertWikiEntry(
    PersonalWikiCompanion values,
  ) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    final normalized = values.copyWith(id: Value(id));
    return transaction(() async {
      await into(personalWiki).insert(normalized);
      return (select(
        personalWiki,
      )..where((item) => item.id.equals(id))).getSingle();
    });
  }

  Future<void> updateWikiEntry(PersonalWikiEntry entry) async {
    final updated = entry.copyWith(updatedAt: DateTime.now().toUtc());
    await update(personalWiki).replace(updated);
  }

  Future<void> deleteWikiEntry(PersonalWikiEntry entry) async {
    await (delete(personalWiki)..where((row) => row.id.equals(entry.id))).go();
  }

  // =========================================================================
  // 8. AYUSHMAN BHARAT & CODING REFERENCE
  // =========================================================================
  Future<List<AyushmanPackage>> searchAyushmanPackages(String query) async {
    final term = query.trim();
    if (term.isEmpty) return const [];
    final escaped = term.replaceAll('"', ' ');
    return customSelect(
          'SELECT p.* FROM ayushman_packages p JOIN ayushman_packages_fts f ON f.rowid = p.rowid WHERE f MATCH ? ORDER BY p.package_name LIMIT 50',
          variables: [Variable<String>('"$escaped"*')],
          readsFrom: {ayushmanPackages},
        )
        .map(
          (row) => AyushmanPackage(
            code: row.read<String>('code'),
            packageName: row.read<String>('package_name'),
            stratification: row.readNullable<String>('stratification'),
            rate: row.readNullable<double>('rate'),
          ),
        )
        .get();
  }

  Future<List<HbpProcedureDetails>> searchAyushmanPackagesWithDetails(
    String query,
  ) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];
    final terms = normalized
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .map((term) => '${term.replaceAll('"', '')}*')
        .join(' ');

    final rows = await customSelect(
      '''
      SELECT
        p.procedure_code AS p_code,
        p.package_name AS p_package,
        p.procedure_name AS p_name,
        p.rate AS p_rate,
        p.specialty AS p_specialty,
        i.implant_code AS i_code,
        i.implant_name AS i_name,
        i.maximum_price AS i_price,
        s.stratification_code AS s_code,
        s.stratification_name AS s_name,
        s.rule AS s_rule
      FROM hbp_fts f
      JOIN hbp_procedures p ON p.rowid = f.rowid
      LEFT JOIN hbp_implants i ON i.procedure_code = p.procedure_code
      LEFT JOIN hbp_stratifications s ON s.procedure_code = p.procedure_code
      WHERE hbp_fts MATCH ?
      ORDER BY p.package_name, p.procedure_name
      LIMIT 500
      ''',
      variables: [Variable<String>(terms)],
      readsFrom: {hbpProcedures, hbpImplants, hbpStratifications},
    ).get();

    final grouped = <String, _HbpAccumulator>{};
    for (final row in rows) {
      final code = row.read<String>('p_code');
      final item = grouped.putIfAbsent(
        code,
        () => _HbpAccumulator(
          procedureCode: code,
          packageName: row.read<String>('p_package'),
          procedureName: row.read<String>('p_name'),
          specialty: row.read<String>('p_specialty'),
          rate: row.readNullable<double>('p_rate'),
        ),
      );
      final implantCode = row.readNullable<String>('i_code');
      if (implantCode != null && implantCode.isNotEmpty) {
        item.implants.putIfAbsent(
          implantCode,
          () => HbpImplantDetail(
            code: implantCode,
            name: row.read<String>('i_name'),
            maximumPrice: row.readNullable<double>('i_price'),
          ),
        );
      }
      final stratificationCode = row.readNullable<String>('s_code');
      if (stratificationCode != null && stratificationCode.isNotEmpty) {
        item.stratifications.putIfAbsent(
          stratificationCode,
          () => HbpStratificationDetail(
            code: stratificationCode,
            name: row.read<String>('s_name'),
            rule: row.read<String>('s_rule'),
          ),
        );
      }
    }
    return [for (final item in grouped.values) item.toDetails()];
  }

  // =========================================================================
  // 9. OFFLINE SYNC QUEUE & REMOTE UPSERTS
  // =========================================================================
  Future<List<SyncQueueEntry>> pendingQueue({DateTime? now}) {
    final cutoff = now ?? DateTime.now().toUtc();
    return (select(offlineSyncQueue)
          ..where(
            (row) =>
                row.processedAt.isNull() &
                row.nextAttemptAt.isSmallerOrEqualValue(cutoff),
          )
          ..orderBy([(row) => OrderingTerm(expression: row.createdAt)]))
        .get();
  }

  Future<void> markQueueFailure(SyncQueueEntry entry, Object error) async {
    final attempts = entry.attempts + 1;
    final exponent = attempts.clamp(0, 8).toInt();
    final seconds = 1 << exponent;
    final now = DateTime.now().toUtc();
    await (update(offlineSyncQueue)..where((t) => t.id.equals(entry.id))).write(
      OfflineSyncQueueCompanion(
        attempts: Value(attempts),
        lastError: Value(error.toString()),
        nextAttemptAt: Value(now.add(Duration(seconds: seconds))),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> removeQueueEntry(String id) async {
    await (delete(offlineSyncQueue)..where((row) => row.id.equals(id))).go();
  }

  Future<void> upsertRemoteWiki(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final id = json['id'] as String;
    final existing = await (select(
      personalWiki,
    )..where((row) => row.id.equals(id))).getSingleOrNull();

    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }

    await into(personalWiki).insertOnConflictUpdate(
      PersonalWikiCompanion(
        id: Value(id),
        ownerId: Value(json['owner_id'] as String),
        topic: Value(json['topic'] as String),
        markdownContent: Value(json['markdown_content'] as String? ?? ''),
        tags: Value(
          (json['tags'] as List? ?? const [])
              .map((e) => e.toString())
              .toList(growable: false),
        ),
        departmentRelevance: Value(
          (json['department_relevance'] as List? ?? const [])
              .map((e) => e.toString())
              .toList(growable: false),
        ),
        createdAt: Value(_date(json['created_at']) ?? syncedAt),
        updatedAt: Value(_date(json['updated_at']) ?? syncedAt),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  Future<void> upsertRemotePatient(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final id = json['id'] as String;
    final existing = await findPatient(id);
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await into(patients).insertOnConflictUpdate(
      PatientsCompanion(
        id: Value(id),
        ownerId: Value(json['owner_id'] as String),
        fullName: Value(json['full_name'] as String),
        dateOfBirth: Value(_date(json['date_of_birth'])),
        approximateAge: Value(json['approximate_age'] as int?),
        gender: Value(json['gender'] as String?),
        heightCm: Value((json['height_cm'] as num?)?.toDouble()),
        weightKg: Value((json['weight_kg'] as num?)?.toDouble()),
        addressOrLocation: Value(json['address_or_location'] as String?),
        occupation: Value(json['occupation'] as String?),
        phone: Value(json['phone'] as String?),
        alternatePhone: Value(json['alternate_phone'] as String?),
        isActive: Value(json['is_active'] as bool? ?? true),
        metadata: Value(jsonEncode(json['metadata'] ?? <String, dynamic>{})),
        createdAt: Value(_date(json['created_at']) ?? syncedAt),
        updatedAt: Value(_date(json['updated_at']) ?? syncedAt),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  Future<void> upsertRemoteEncounter(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final id = json['id'] as String;
    final existing = await (select(
      clinicalEncounters,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await into(clinicalEncounters).insertOnConflictUpdate(
      ClinicalEncountersCompanion(
        id: Value(id),
        ownerId: Value(json['owner_id'] as String),
        patientId: Value(json['patient_id'] as String),
        hospitalId: Value(json['hospital_id'] as String?),
        encounterType: Value(json['encounter_type'] as String? ?? 'OPD'),
        occurredAt: Value(_date(json['occurred_at']) ?? syncedAt),
        department: Value(json['department'] as String?),
        wardName: Value(json['ward_name'] as String?),
        bedNumber: Value(json['bed_number'] as String?),
        clinicalDiagnosis: Value(json['clinical_diagnosis'] as String?),
        icd11Code: Value(json['icd11_code'] as String?),
        disposition: Value(json['disposition'] as String?),
        sbp: Value(json['sbp'] as int?),
        dbp: Value(json['dbp'] as int?),
        pulse: Value(json['pulse'] as int?),
        temperatureC: Value((json['temperature_c'] as num?)?.toDouble()),
        respiratoryRate: Value(json['respiratory_rate'] as int?),
        spo2: Value(json['spo2'] as int?),
        meanArterialPressure: Value((json['map'] as num?)?.toDouble()),
        chiefComplaints: Value(json['chief_complaints'] as String?),
        historyOfPresentIllness: Value(
          json['history_of_present_illness'] as String?,
        ),
        pastHistory: Value(json['past_history'] as String?),
        drugAndAllergyHistory: Value(
          json['drug_and_allergy_history'] as String?,
        ),
        personalAndSocialHistory: Value(
          json['personal_and_social_history'] as String?,
        ),
        examinationFindings: Value(json['examination_findings'] as String?),
        clinicalAssessment: Value(json['clinical_assessment'] as String?),
        consultantAdvice: Value(json['consultant_advice'] as String?),
        imagePath: Value(json['image_path'] as String?),
        aiSummary: Value(json['ai_summary'] as String?),
        dynamicData: Value(
          json['dynamic_data'] is Map
              ? Map<String, dynamic>.from(json['dynamic_data'] as Map)
              : <String, dynamic>{},
        ),
        createdAt: Value(_date(json['created_at']) ?? syncedAt),
        updatedAt: Value(_date(json['updated_at']) ?? syncedAt),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  Future<void> upsertRemoteInvestigation(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final id = json['id'] as String;
    final existing = await findInvestigation(id);
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await into(investigationOrders).insertOnConflictUpdate(
      InvestigationOrdersCompanion(
        id: Value(id),
        ownerId: Value(json['owner_id'] as String? ?? defaultOwnerId),
        patientId: Value(json['patient_id'] as String),
        encounterId: Value(json['encounter_id'] as String?),
        problemId: Value(json['problem_id'] as String?),
        testName: Value(json['test_name'] as String),
        testCode: Value(json['test_code'] as String?),
        clinicalIndication: Value(json['clinical_indication'] as String?),
        status: Value(json['status'] as String? ?? 'ordered'),
        orderedAt: Value(_date(json['ordered_at']) ?? syncedAt),
        sampleSentAt: Value(_date(json['sample_sent_at'])),
        resultReceivedAt: Value(_date(json['result_received_at'])),
        createdAt: Value(_date(json['created_at']) ?? syncedAt),
        updatedAt: Value(_date(json['updated_at']) ?? syncedAt),
      ),
    );
  }

  // =========================================================================
  // 10. MULTI-PATIENT MERGE & DE-DUPLICATION (INSIDE CLASS)
  // =========================================================================
  Future<void> mergePatients({
    required String primaryPatientId,
    required String duplicatePatientId,
  }) async {
    if (primaryPatientId == duplicatePatientId) {
      throw ArgumentError(
        'Primary and duplicate patients must be distinct records.',
      );
    }

    await transaction(() async {
      final primary = await findPatient(primaryPatientId);
      final duplicate = await findPatient(duplicatePatientId);

      if (primary == null || duplicate == null) {
        throw StateError('Both patient profiles must exist before merging.');
      }

      final now = DateTime.now().toUtc();

      // 1. Reassign Multi-Hospital Identifiers (avoiding duplicate primary flags)
      final existingPrimaryHospIds =
          (await (select(
                patientHospitalIdentifiers,
              )..where((r) => r.patientId.equals(primaryPatientId))).get())
              .map((r) => r.hospitalId)
              .toSet();

      final dupIdentifiers = await (select(
        patientHospitalIdentifiers,
      )..where((r) => r.patientId.equals(duplicatePatientId))).get();

      for (final idRow in dupIdentifiers) {
        if (!existingPrimaryHospIds.contains(idRow.hospitalId)) {
          await (update(
            patientHospitalIdentifiers,
          )..where((r) => r.id.equals(idRow.id))).write(
            PatientHospitalIdentifiersCompanion(
              patientId: Value(primaryPatientId),
              isPrimary: const Value(false),
              updatedAt: Value(now),
            ),
          );
        } else {
          await (delete(
            patientHospitalIdentifiers,
          )..where((r) => r.id.equals(idRow.id))).go();
        }
      }

      // 2. Reassign Encounters
      final encounters = await (select(
        clinicalEncounters,
      )..where((r) => r.patientId.equals(duplicatePatientId))).get();
      for (final enc in encounters) {
        await (update(
          clinicalEncounters,
        )..where((r) => r.id.equals(enc.id))).write(
          ClinicalEncountersCompanion(
            patientId: Value(primaryPatientId),
            updatedAt: Value(now),
          ),
        );
      }

      // 3. Reassign Problems & Problem Snapshots
      await (update(
        patientProblems,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        PatientProblemsCompanion(
          patientId: Value(primaryPatientId),
          updatedAt: Value(now),
        ),
      );

      await (update(
        problemProgressSnapshots,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        ProblemProgressSnapshotsCompanion(patientId: Value(primaryPatientId)),
      );

      // 4. Reassign Interventions (Procedures) & Outcome Metrics
      await (update(
        clinicalInterventions,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        ClinicalInterventionsCompanion(patientId: Value(primaryPatientId)),
      );

      await (update(
        clinicalOutcomeMetrics,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        ClinicalOutcomeMetricsCompanion(patientId: Value(primaryPatientId)),
      );

      // 5. Reassign Prescriptions & Workorders
      await (update(
        prescriptionOrders,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        PrescriptionOrdersCompanion(patientId: Value(primaryPatientId)),
      );

      await (update(
        investigationOrders,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        InvestigationOrdersCompanion(
          patientId: Value(primaryPatientId),
          updatedAt: Value(now),
        ),
      );

      await (update(
        investigationResults,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        InvestigationResultsCompanion(
          patientId: Value(primaryPatientId),
          updatedAt: Value(now),
        ),
      );

      // 6. Reassign Scanned Documents & Observations
      await (update(
        documentRegistries,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        DocumentRegistriesCompanion(patientId: Value(primaryPatientId)),
      );

      await (update(
        clinicalObservations,
      )..where((r) => r.patientId.equals(duplicatePatientId))).write(
        ClinicalObservationsCompanion(patientId: Value(primaryPatientId)),
      );

      // 7. Enqueue Sync Tombstone & Purge Duplicate Record
      await _enqueue(
        ownerId: duplicate.ownerId,
        entityType: 'patients',
        entityId: duplicate.id,
        operation: 'delete',
        payload: {
          'id': duplicate.id,
          'merged_into': primary.id,
          'merged_at': now.toIso8601String(),
        },
        clientUpdatedAt: now,
      );

      await (delete(
        patients,
      )..where((r) => r.id.equals(duplicatePatientId))).go();
    });
  }

  // =========================================================================
  // 11. REPLICATION PAYLOAD SERIALIZERS
  // =========================================================================
  Future<void> _enqueue({
    required String ownerId,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required DateTime clientUpdatedAt,
  }) {
    return into(offlineSyncQueue).insert(
      OfflineSyncQueueCompanion.insert(
        ownerId: ownerId,
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: Value(jsonEncode(payload)),
        clientUpdatedAt: Value(clientUpdatedAt.toUtc()),
      ),
    );
  }

  Map<String, dynamic> _patientPayload(Patient row) => {
    'id': row.id,
    'owner_id': row.ownerId,
    'full_name': row.fullName,
    'date_of_birth': row.dateOfBirth?.toIso8601String(),
    'approximate_age': row.approximateAge,
    'gender': row.gender,
    'height_cm': row.heightCm,
    'weight_kg': row.weightKg,
    'address_or_location': row.addressOrLocation,
    'occupation': row.occupation,
    'phone': row.phone,
    'alternate_phone': row.alternatePhone,
    'is_active': row.isActive,
    'metadata': _decodedOrEmpty(row.metadata),
    'created_at': row.createdAt.toIso8601String(),
    'updated_at': row.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _clinicalEncounterPayload(ClinicalEncounter row) => {
    'id': row.id,
    'owner_id': row.ownerId,
    'patient_id': row.patientId,
    'hospital_id': row.hospitalId,
    'encounter_type': row.encounterType,
    'occurred_at': row.occurredAt.toIso8601String(),
    'department': row.department,
    'ward_name': row.wardName,
    'bed_number': row.bedNumber,
    'clinical_diagnosis': row.clinicalDiagnosis,
    'icd11_code': row.icd11Code,
    'disposition': row.disposition,
    'sbp': row.sbp,
    'dbp': row.dbp,
    'pulse': row.pulse,
    'temperature_c': row.temperatureC,
    'respiratory_rate': row.respiratoryRate,
    'spo2': row.spo2,
    'map': row.meanArterialPressure,
    'chief_complaints': row.chiefComplaints,
    'history_of_present_illness': row.historyOfPresentIllness,
    'past_history': row.pastHistory,
    'drug_and_allergy_history': row.drugAndAllergyHistory,
    'personal_and_social_history': row.personalAndSocialHistory,
    'examination_findings': row.examinationFindings,
    'clinical_assessment': row.clinicalAssessment,
    'consultant_advice': row.consultantAdvice,
    'dynamic_data': row.dynamicData,
    'image_path': row.imagePath,
    'ai_summary': row.aiSummary,
    'created_at': row.createdAt.toIso8601String(),
    'updated_at': row.updatedAt.toIso8601String(),
  };

  DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toUtc();

  Object _decodedOrEmpty(String value) {
    try {
      return jsonDecode(value) ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  bool _remoteIsOlder(
    DateTime? localUpdatedAt,
    Object? remoteUpdatedAt,
    DateTime fallback,
  ) {
    final remote = _date(remoteUpdatedAt) ?? fallback;
    return localUpdatedAt != null && localUpdatedAt.isAfter(remote);
  }
}

class _HbpAccumulator {
  _HbpAccumulator({
    required this.procedureCode,
    required this.packageName,
    required this.procedureName,
    required this.specialty,
    required this.rate,
  });

  final String procedureCode;
  final String packageName;
  final String procedureName;
  final String specialty;
  final double? rate;
  final implants = <String, HbpImplantDetail>{};
  final stratifications = <String, HbpStratificationDetail>{};

  HbpProcedureDetails toDetails() => HbpProcedureDetails(
    procedureCode: procedureCode,
    packageName: packageName,
    procedureName: procedureName,
    specialty: specialty,
    rate: rate,
    implants: implants.values.toList(growable: false),
    stratifications: stratifications.values.toList(growable: false),
  );
}
