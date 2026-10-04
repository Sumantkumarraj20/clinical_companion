import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/ai_extraction_result.dart';
import '../../../features/billing/services/clinical_coding_service.dart';
import '../../services/extraction_pipeline_service.dart';
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
    required this.mrn,
  });

  final InvestigationOrder investigation;
  final Patient patient;
  final String mrn;
}

/// All data needed to derive registry cohort tags. Loaded in one joined query
/// so a ward-sized patient list never turns into an N+1 read storm.
class PatientCohortInputs {
  const PatientCohortInputs({
    required this.problems,
    required this.interventions,
  });

  final List<PatientProblem> problems;
  final List<ClinicalIntervention> interventions;
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
    clinical_records.Admissions,
    ClinicalLearningLogs,
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

  /// Persists an AI/OCR extraction as a single atomic encounter + vitals +
  /// labs + problems + prescriptions write.
  ///
  /// **Idempotency:** a captured page is identified by
  /// (`patientId`, `imagePath`). Committing the same page twice — a double tap
  /// on "Save & Next", a retry after a flaky write, or re-opening a document
  /// that is already filed — returns the encounter that already exists instead
  /// of minting a duplicate. The queue itself also guarantees one task per
  /// unique file path.
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

      final dedupeKey = imagePath.trim();
      if (dedupeKey.isNotEmpty) {
        final existing =
            await (select(clinicalEncounters)
                  ..where(
                    (row) =>
                        row.imagePath.equals(dedupeKey) &
                        row.patientId.equals(patientId),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (existing != null) return existing;
      }

      // FIX 4 — the printed document date takes priority. `_date` handles only
      // ISO8601/unix forms, which almost never appear on an Indian lab report
      // (`12/03/2024`, `03-Sep-2023`), so it used to return null and the
      // encounter was filed under `DateTime.now()` — the ingestion date.
      final occurredAt =
          _date(result.encounterContext.date) ??
          resolveDocumentedAt(result.clinicalSummary, imagePath);
      final vitals = result.vitals;
      final encounterId = _ids.v4();

      // Sprint 15 — the facility this document was captured at.
      //
      // Falls back to the patient's primary facility, then to the default one.
      // Every encounter must carry a hospital: without it the multi-hospital
      // timeline cannot say *where* the care happened, and a clinician working
      // across institutions cannot tell two visits apart.
      final hospitalId = await _resolveHospitalId(
        patientId: patientId,
        requested: result.patientIdentity.hospitalId,
      );

      final encounter = ClinicalEncountersCompanion.insert(
        id: Value(encounterId),
        ownerId: defaultOwnerId,
        patientId: patientId,
        hospitalId: Value(hospitalId),
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

      // STEP 1 (Sprint 14) — give the scanned page a first-class row in
      // `document_registries`. Nothing wrote this table before, so the
      // timeline's document cards could never appear and the tables that
      // FK-reference it (prescriptions, microbiology, imaging) had no parent.
      //
      // [occurredAt] already holds the date *printed on the document*
      // (ClinicalDateParser -> file mtime -> now), which is exactly what
      // `documentedAt` must mean: when the care happened, not when we
      // scanned it.
      final documentId = _ids.v4();
      await into(documentRegistries).insert(
        DocumentRegistriesCompanion.insert(
          id: documentId,
          patientId: patientId,
          documentCategory: result.encounterContext.documentType.trim().isEmpty
              ? 'Clinical Document'
              : result.encounterContext.documentType.trim(),
          imagePath: imagePath,
          rawOcrTranscript: Value(result.clinicalSummary),
          confidenceScore: const Value(0.0),
          documentedAt: occurredAt,
        ),
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
    return (select(
      patients,
    )..orderBy([(row) => OrderingTerm(expression: row.fullName)])).watch();
  }

  Future<Map<String, PatientCohortInputs>> getCohortInputsForPatients() async {
    final query = select(patients).join([
      leftOuterJoin(
        patientProblems,
        patientProblems.patientId.equalsExp(patients.id) &
            patientProblems.currentStatus.equals('Active'),
      ),
      leftOuterJoin(
        clinicalInterventions,
        clinicalInterventions.patientId.equalsExp(patients.id),
      ),
    ]);
    final rows = await query.get();
    final problems = <String, Map<String, PatientProblem>>{};
    final interventions = <String, Map<String, ClinicalIntervention>>{};
    for (final row in rows) {
      final patient = row.readTable(patients);
      final problem = row.readTableOrNull(patientProblems);
      final intervention = row.readTableOrNull(clinicalInterventions);
      if (problem != null) {
        (problems[patient.id] ??= {})[problem.id] = problem;
      }
      if (intervention != null) {
        (interventions[patient.id] ??= {})[intervention.id] = intervention;
      }
    }
    return {
      for (final patient in rows.map((row) => row.readTable(patients)))
        patient.id: PatientCohortInputs(
          problems: (problems[patient.id] ?? const {}).values.toList(),
          interventions: (interventions[patient.id] ?? const {}).values
              .toList(),
        ),
    };
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
        clientUpdatedAt: DateTime.now().toUtc(),
      );
      return row;
    });
  }

  Future<Patient> insertPatientWithHospitalId({
    required PatientsCompanion patient,
    required String hospitalId,
    required String mrn,
    String identifierType = 'MRN',
  }) async {
    final patientId = patient.id.present ? patient.id.value : _ids.v4();
    return transaction(() async {
      await into(patients).insert(patient.copyWith(id: Value(patientId)));
      await into(patientHospitalIdentifiers).insert(
        PatientHospitalIdentifiersCompanion.insert(
          id: Value(_ids.v4()),
          patientId: patientId,
          hospitalId: hospitalId,
          mrn: Value(mrn.trim().isEmpty ? null : mrn.trim()),
          identifierType: Value(identifierType),
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
        clientUpdatedAt: DateTime.now().toUtc(),
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
      HospitalsCompanion.insert(id: Value(id), name: 'Primary Facility'),
    );
    return id;
  }

  /// Upserts the canonical hospital MRN for a patient. Older rows written
  /// against the legacy `hospitalRegNo` column are read transparently through
  /// [getPatientHospitalRegNo] after the v17 migration backfills `mrn`.
  /// Registers a new hospital / clinic and returns the created row.
  ///
  /// Sprint 14.5 — supports inline facility creation from the demographics and
  /// document-review forms so a clinician covering multiple institutions is not
  /// limited to whichever rows were seeded in the database.
  Future<Hospital> createHospital(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Hospital name cannot be empty');
    }

    // Reuse an exact existing match so repeatedly adding "City General" from two
    // devices does not create duplicate facilities.
    final existing =
        await (select(hospitals)
              ..where((row) => row.name.lower().equals(trimmed.toLowerCase())))
            .getSingleOrNull();
    if (existing != null) return existing;

    final id = _ids.v4();
    await into(
      hospitals,
    ).insert(HospitalsCompanion.insert(id: Value(id), name: trimmed));
    return (select(hospitals)..where((row) => row.id.equals(id))).getSingle();
  }

  /// Sprint 14.5 — applies corrections to an already-saved document (Edit Mode).
  ///
  /// This exists because [processAiExtraction] deliberately returns early when a
  /// document with the same `(patientId, imagePath)` already exists, so routing
  /// an Edit Mode save through it would silently discard the clinician's
  /// corrections while reporting success. Corrections must UPDATE, never
  /// duplicate.
  ///
  /// Returns true when a row was updated.
  Future<bool> applyDocumentEdits({
    required String documentId,
    required DateTime documentedAt,
    String? rawOcrTranscript,
    String? documentCategory,
  }) async {
    final existing = await (select(
      documentRegistries,
    )..where((row) => row.id.equals(documentId))).getSingleOrNull();
    if (existing == null) return false;

    await (update(
      documentRegistries,
    )..where((row) => row.id.equals(documentId))).write(
      DocumentRegistriesCompanion(
        // `documentedAt` is the whole point: correcting a document must move
        // its clinical date, never re-date it to "now".
        documentedAt: Value(documentedAt),
        rawOcrTranscript: rawOcrTranscript == null
            ? const Value.absent()
            : Value(rawOcrTranscript),
        documentCategory: documentCategory == null
            ? const Value.absent()
            : Value(documentCategory),
      ),
    );
    return true;
  }

  Future<void> upsertPatientHospitalIdentifier({
    required String patientId,
    required String hospitalId,
    required String mrn,
    String identifierType = 'MRN',
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
      mrn: Value(mrn.trim().isEmpty ? null : mrn.trim()),
      identifierType: Value(identifierType),
      isPrimary: Value(isPrimary),
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
    final mrn = identifier?.mrn;
    return mrn == null || mrn.trim().isEmpty ? 'No Reg No' : mrn.trim();
  }

  /// Streams all currently-active inpatient stays for a hospital (MRN / bed
  /// board feed). Emits a fresh list whenever an admission is created,
  /// discharged or updated, oldest-stay-first.
  Stream<List<Admission>> watchActiveAdmissions(String hospitalId) {
    return (select(admissions)
          ..where(
            (row) =>
                row.hospitalId.equals(hospitalId) & row.status.equals('active'),
          )
          ..orderBy([(row) => OrderingTerm(expression: row.admissionTime)]))
        .watch();
  }

  /// Creates or updates the patient's *active* inpatient episode.
  ///
  /// STEP 1 (Sprint 14): demographics previously wrote only the hospital-scoped
  /// MRN, so "where is this patient admitted?" had no answer. This keeps a
  /// single active [Admission] row per patient — ward and bed live on the
  /// episode, not on the patient master, so one patient can be tracked across
  /// hospitals without their identity record being rewritten.
  ///
  /// Passing a null [wardName]/[bedNumber] leaves the existing value intact so
  /// a demographics-only edit does not wipe the bed board.
  Future<void> upsertActiveAdmission({
    required String patientId,
    required String hospitalId,
    String? wardName,
    String? bedNumber,
    DateTime? admissionTime,
  }) async {
    await transaction(() async {
      final existing =
          await (select(admissions)..where(
                (row) =>
                    row.patientId.equals(patientId) &
                    row.status.equals('active'),
              ))
              .getSingleOrNull();

      if (existing == null) {
        await into(admissions).insert(
          AdmissionsCompanion.insert(
            patientId: patientId,
            hospitalId: hospitalId,
            wardName: Value(_blankToNull(wardName)),
            bedNumber: Value(_blankToNull(bedNumber)),
            admissionTime: Value(admissionTime ?? DateTime.now()),
            status: const Value('active'),
          ),
        );
        return;
      }

      await (update(
        admissions,
      )..where((row) => row.id.equals(existing.id))).write(
        AdmissionsCompanion(
          hospitalId: Value(hospitalId),
          wardName: wardName == null
              ? const Value.absent()
              : Value(_blankToNull(wardName)),
          bedNumber: bedNumber == null
              ? const Value.absent()
              : Value(_blankToNull(bedNumber)),
        ),
      );
    });
  }

  /// Post-operative day for [patientId], or null when no surgery is recorded.
  ///
  /// Returns 0 for an operation performed today. A future-dated procedure
  /// returns null rather than a negative day: that is a scheduling or
  /// data-entry state, not a post-operative one, and rendering "POD #-1" on a
  /// patient card would be actively misleading.
  Future<int?> getPostOpDay(String patientId) async {
    final surgery = await getLastSurgicalIntervention(patientId);
    if (surgery == null) return null;

    final performed = surgery.performedAt.toLocal();
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day)
        .difference(DateTime(performed.year, performed.month, performed.day))
        .inDays;
    return day < 0 ? null : day;
  }

  /// The patient's current inpatient episode, or null when they are not admitted.
  Future<Admission?> getActiveAdmission(String patientId) {
    return (select(admissions)..where(
          (row) =>
              row.patientId.equals(patientId) & row.status.equals('active'),
        ))
        .getSingleOrNull();
  }

  /// Closes the active admission for [patientId] (discharge / death / LAMA).
  Future<void> closeActiveAdmission(
    String patientId, {
    DateTime? dischargeTime,
  }) async {
    await (update(admissions)..where(
          (row) =>
              row.patientId.equals(patientId) & row.status.equals('active'),
        ))
        .write(
          AdmissionsCompanion(
            status: const Value('discharged'),
            dischargeTime: Value(dischargeTime ?? DateTime.now()),
          ),
        );
  }

  static String? _blankToNull(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();

  /// Resolves the facility an encounter should be filed under.
  ///
  /// Order: an explicitly chosen facility → the patient's primary facility →
  /// the seeded default. A requested id that no longer exists (deleted on
  /// another device, stale cached form) is ignored rather than throwing, so a
  /// scan is never lost to a dangling reference.
  Future<String> _resolveHospitalId({
    required String patientId,
    String? requested,
  }) async {
    final candidate = _blankToNull(requested);
    if (candidate != null) {
      final exists = await (select(
        hospitals,
      )..where((row) => row.id.equals(candidate))).getSingleOrNull();
      if (exists != null) return exists.id;
    }

    final primary =
        await (select(patientHospitalIdentifiers)..where(
              (row) =>
                  row.patientId.equals(patientId) & row.isPrimary.equals(true),
            ))
            .getSingleOrNull();
    if (primary != null) return primary.hospitalId;

    return ensureDefaultHospitalId();
  }

  /// Currently-admitted patients, joined with demographics and MRN in a single
  /// query so the bed board needs no per-row lookups (STEP 2 — avoids N+1).
  Stream<List<WardRoundPatient>> watchActiveWardRounds({String? hospitalId}) {
    final query =
        select(admissions).join([
            innerJoin(patients, patients.id.equalsExp(admissions.patientId)),
            leftOuterJoin(
              patientHospitalIdentifiers,
              patientHospitalIdentifiers.patientId.equalsExp(
                    admissions.patientId,
                  ) &
                  patientHospitalIdentifiers.isPrimary.equals(true) &
                  patientHospitalIdentifiers.hospitalId.equalsExp(
                    admissions.hospitalId,
                  ),
            ),
          ])
          ..where(
            admissions.status.equals('active') &
                (hospitalId == null
                    ? const Constant(true)
                    : admissions.hospitalId.equals(hospitalId)),
          )
          ..orderBy([
            OrderingTerm(expression: admissions.wardName),
            OrderingTerm(expression: admissions.bedNumber),
          ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => WardRoundPatient(
              admission: row.readTable(admissions),
              patient: row.readTable(patients),
              mrn: row.readTableOrNull(patientHospitalIdentifiers)?.mrn,
            ),
          )
          .toList(growable: false),
    );
  }

  /// Every investigation still awaiting a result, joined to the patient and MRN
  /// in one statement (STEP 2 — avoids the N+1 the old day-scoped query caused
  /// when the workspace lists everything outstanding, not just today's).
  ///
  /// Distinct from [watchPendingInvestigationsWithPatients], which is scoped
  /// to a single calendar day for the lab tracker.
  Stream<List<PendingInvestigation>> watchOutstandingInvestigations({
    int limit = 50,
  }) {
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
            investigationOrders.resultReceivedAt.isNull() &
                investigationOrders.status.isIn(const [
                  'ordered',
                  'sample_sent',
                ]),
          )
          ..orderBy([OrderingTerm(expression: investigationOrders.orderedAt)])
          ..limit(limit);

    return query.watch().map(
      (rows) => rows
          .map((row) {
            final mrn = row.readTableOrNull(patientHospitalIdentifiers)?.mrn;
            return PendingInvestigation(
              investigation: row.readTable(investigationOrders),
              patient: row.readTable(patients),
              mrn: (mrn == null || mrn.trim().isEmpty)
                  ? 'No Reg No'
                  : mrn.trim(),
            );
          })
          .toList(growable: false),
    );
  }

  /// Follow-up *candidates*: patients who had a recent procedure, or who carry an
  /// unresolved problem. The clinician decides who actually needs review — this
  /// query organises attention, it does not recommend care.
  Stream<List<SmartFollowUp>> watchSmartFollowUps({
    Duration since = const Duration(days: 7),
    int limit = 50,
  }) {
    final cutoff = DateTime.now().subtract(since);

    final recentProcedures = selectOnly(clinicalInterventions)
      ..addColumns([clinicalInterventions.patientId])
      ..where(clinicalInterventions.performedAt.isBiggerOrEqualValue(cutoff))
      ..groupBy([clinicalInterventions.patientId]);

    final activeProblems = selectOnly(patientProblems)
      ..addColumns([patientProblems.patientId])
      ..where(
        patientProblems.currentStatus.isIn(const [
              'Active',
              'Improving',
              'Deteriorating',
            ]) &
            patientProblems.resolvedDate.isNull(),
      )
      ..groupBy([patientProblems.patientId]);

    // A subquery union keeps this to one statement instead of two round trips.
    final flagged = selectOnly(patients, distinct: true)
      ..addColumns([patients.id])
      ..where(
        patients.id.isInQuery(recentProcedures) |
            patients.id.isInQuery(activeProblems),
      );

    final query =
        select(patients).join([
            leftOuterJoin(
              clinicalEncounters,
              clinicalEncounters.patientId.equalsExp(patients.id),
            ),
          ])
          ..where(patients.id.isInQuery(flagged))
          ..orderBy([
            OrderingTerm(
              expression: clinicalEncounters.occurredAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit);

    return query.watch().map((rows) {
      // The encounter join fans one patient out into many rows; collapse back
      // to the most recent encounter so the tab stays N rows, not N*M.
      final seen = <String, SmartFollowUp>{};
      for (final row in rows) {
        final patient = row.readTable(patients);
        seen.putIfAbsent(
          patient.id,
          () => SmartFollowUp(
            patient: patient,
            lastSeenAt: row.readTableOrNull(clinicalEncounters)?.occurredAt,
          ),
        );
      }
      return seen.values.toList(growable: false);
    });
  }

  /// Encounters saved as drafts and not yet signed (STEP 2).
  Stream<List<PendingNote>> watchPendingNotes({int limit = 50}) {
    final query =
        select(clinicalEncounters).join([
            innerJoin(
              patients,
              patients.id.equalsExp(clinicalEncounters.patientId),
            ),
          ])
          ..where(clinicalEncounters.isDraft.equals(true))
          ..orderBy([
            OrderingTerm(
              expression: clinicalEncounters.updatedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => PendingNote(
              encounter: row.readTable(clinicalEncounters),
              patient: row.readTable(patients),
            ),
          )
          .toList(growable: false),
    );
  }

  /// Most recent *surgical* intervention for [patientId] — the Post-Op Day
  /// badge's data source. Returns null when no surgery is on record.
  ///
  /// Restricted to `interventionRole = 'Surgical'`: a diagnostic imaging study
  /// is not an operation and must never produce a "POD #1".
  Future<ClinicalIntervention?> getLastSurgicalIntervention(String patientId) {
    return (select(clinicalInterventions)
          ..where(
            (row) =>
                row.patientId.equals(patientId) &
                row.interventionRole.equals('Surgical'),
          )
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.performedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  // ===========================================================================
  // SPRINT 15 — CLINICAL LEARNING LOG (PRIVATE REFLECTION)
  // ===========================================================================

  /// Saves a clinician's private reflection.
  ///
  /// Deliberately **not** enqueued for sync. A reflection is the clinician's own
  /// reasoning — including what they considered and rejected — and it must not
  /// leave the device, appear in another clinician's chart, or leak into an
  /// audit export. Phase 2's cohort builder must never read this table.
  ///
  /// [confidenceScore] is clamped to 1–10 rather than rejected: an out-of-range
  /// value from a slider or an import should degrade gracefully, not throw and
  /// lose the clinician's actual written reasoning.
  Future<ClinicalLearningLog> saveReflection({
    required String patientId,
    String? encounterId,
    required int confidenceScore,
    required String differentialDiagnoses,
    required String decisionRationale,
    required String clinicalTakeaway,
    DateTime? createdAt,
    String? ownerId,
  }) async {
    final id = _ids.v4();
    // Sprint 16 — pull #hashtags out of the prose into a searchable column so
    // reflections cross-link into the wiki instead of living as prose.
    final tags = extractHashtags(
      '$differentialDiagnoses\n$decisionRationale\n$clinicalTakeaway',
    );
    await into(clinicalLearningLogs).insert(
      ClinicalLearningLogsCompanion.insert(
        id: Value(id),
        patientId: patientId,
        encounterId: Value(encounterId),
        ownerId: Value(ownerId ?? defaultOwnerId),
        diagnosisConfidenceScore: Value(confidenceScore.clamp(1, 10)),
        differentialDiagnoses: Value(differentialDiagnoses.trim()),
        decisionRationale: Value(decisionRationale.trim()),
        clinicalTakeaway: Value(clinicalTakeaway.trim()),
        tags: Value(tags),
        createdAt: Value(createdAt ?? DateTime.now().toUtc()),
      ),
    );
    return (select(
      clinicalLearningLogs,
    )..where((row) => row.id.equals(id))).getSingle();
  }

  /// Reflections for one patient, newest first. Owner-scoped: a shared device
  /// must not leak one clinician's private reasoning to another.
  Future<List<ClinicalLearningLog>> getReflectionsForPatient(
    String patientId, {
    String? ownerId,
  }) {
    return (select(clinicalLearningLogs)
          ..where(
            (row) =>
                row.patientId.equals(patientId) &
                row.ownerId.equals(ownerId ?? defaultOwnerId),
          )
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Extracts `#hashtags` from free text.
  ///
  /// Sprint 16 — a clinician types `#hyponatremia` inside their takeaway and the
  /// tag is pulled out into a searchable column. Returns lower-cased, de-duped
  /// tags without the `#`, in first-appearance order.
  ///
  /// Bounded to 32 characters per tag and 12 tags per reflection so a pasted
  /// paragraph of hashes cannot blow up the row or the chip strip.
  @visibleForTesting
  static List<String> extractHashtags(String text) {
    final matches = RegExp(r'#([A-Za-z0-9_]{2,32})').allMatches(text);
    final seen = <String>{};
    final tags = <String>[];
    for (final match in matches) {
      final tag = match.group(1)!.toLowerCase();
      if (!seen.add(tag)) continue;
      tags.add(tag);
      if (tags.length >= 12) break;
    }
    return tags;
  }

  /// Reflections carrying [tag], newest first. Powers the wiki cross-link:
  /// tapping `#hyponatremia` in the guidelines shows the clinician's own
  /// reflections on the same topic.
  Future<List<ClinicalLearningLog>> getReflectionsByTag(
    String tag, {
    String? ownerId,
  }) {
    final needle = tag.trim().replaceFirst('#', '').toLowerCase();
    if (needle.isEmpty) return Future.value(const []);
    return (select(clinicalLearningLogs)
          ..where(
            (row) =>
                row.ownerId.equals(ownerId ?? defaultOwnerId) &
                row.tags.like('%"$needle"%'),
          )
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Every reflection for this clinician, newest first — the Case Reflections
  /// feed of the knowledge hub.
  Future<List<ClinicalLearningLog>> getAllReflections({
    String? ownerId,
    int limit = 200,
  }) {
    return (select(clinicalLearningLogs)
          ..where((row) => row.ownerId.equals(ownerId ?? defaultOwnerId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.createdAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  Future<int> countReflectionsForPatient(
    String patientId, {
    String? ownerId,
  }) async {
    final expression = clinicalLearningLogs.id.count();
    final query = selectOnly(clinicalLearningLogs)
      ..addColumns([expression])
      ..where(
        clinicalLearningLogs.patientId.equals(patientId) &
            clinicalLearningLogs.ownerId.equals(ownerId ?? defaultOwnerId),
      );
    return await (await query.getSingle()).read(expression) ?? 0;
  }

  /// Builds the unified, reverse-chronological timeline for [patientId].
  ///
  /// Merges five tables that were previously read separately: admissions (with
  /// ward/bed context), encounters, lab results (with abnormal flags),
  /// prescriptions and scanned documents.
  ///
  /// Each source is one indexed query and the merge happens in Dart. That is
  /// deliberate rather than lazy: a SQL `UNION ALL` across five schemas with
  /// heterogeneous columns cannot be watched by Drift, so a UNION would have
  /// forced manual refreshes and lost the offline-reactive behaviour. Five
  /// parallel indexed reads plus an in-memory sort stay fully reactive and avoid
  /// the N+1 a naive per-row lookup would cause.
  Stream<List<TimelineEvent>> watchUnifiedTimeline(String patientId) {
    // Watching the admissions table is what makes this reactive: any write to
    // any of the five merged tables re-triggers the merge, because the merge
    // re-reads all five sources on each emission.
    final admissionsForPatient = select(admissions)
      ..where((row) => row.patientId.equals(patientId));
    return admissionsForPatient.watch().asyncMap(
      (_) => _mergeTimeline(patientId),
    );
  }

  /// Pure, testable merge of the five sources.
  ///
  /// Extracted from [watchUnifiedTimeline] so the ordering rules can be
  /// asserted directly in unit tests without a stream subscription.
  @visibleForTesting
  Future<List<TimelineEvent>> mergeTimeline(String patientId) =>
      _mergeTimeline(patientId);

  Future<List<TimelineEvent>> _mergeTimeline(String patientId) async {
    final events = <TimelineEvent>[];

    final admissionRows = await (select(
      admissions,
    )..where((row) => row.patientId.equals(patientId))).get();
    for (final row in admissionRows) {
      events.add(
        TimelineEvent(
          id: 'admission:${row.id}',
          kind: TimelineEventKind.admission,
          timestamp: row.admissionTime,
          title: row.status == 'active' ? 'Admitted' : 'Admission',
          subtitle: [
            row.wardName,
            if (row.bedNumber != null && row.bedNumber!.trim().isNotEmpty)
              'Bed ${row.bedNumber}',
          ].whereType<String>().join(' · '),
          detail: row.status,
          wardName: row.wardName,
          bedNumber: row.bedNumber,
          hospitalId: row.hospitalId,
        ),
      );
    }

    final encounterRows = await (select(
      clinicalEncounters,
    )..where((row) => row.patientId.equals(patientId))).get();
    for (final row in encounterRows) {
      final diagnosis = row.clinicalDiagnosis?.trim();
      events.add(
        TimelineEvent(
          id: 'encounter:${row.id}',
          kind: TimelineEventKind.encounter,
          timestamp: row.occurredAt,
          title: (diagnosis == null || diagnosis.isEmpty)
              ? row.encounterType
              : diagnosis,
          subtitle: row.encounterType,
          detail: row.chiefComplaints,
          wardName: row.wardName,
          bedNumber: row.bedNumber,
          hospitalId: row.hospitalId,
          encounterId: row.id,
        ),
      );
    }

    final resultRows = await (select(
      investigationResults,
    )..where((row) => row.patientId.equals(patientId))).get();
    for (final row in resultRows) {
      final value =
          row.textValue ??
          (row.numericValue == null ? null : '${row.numericValue}');
      events.add(
        TimelineEvent(
          id: 'labResult:${row.id}',
          kind: TimelineEventKind.labResult,
          // `resultDate` is when the specimen was resulted.
          timestamp: row.resultDate,
          title: row.testName,
          subtitle: [
            if (value != null) value,
            if (row.unit != null) row.unit,
          ].join(' '),
          detail: row.isAbnormal ? 'Abnormal' : null,
          isAbnormal: row.isAbnormal,
        ),
      );
    }

    final prescriptionRows = await (select(
      prescriptionOrders,
    )..where((row) => row.patientId.equals(patientId))).get();
    for (final row in prescriptionRows) {
      events.add(
        TimelineEvent(
          id: 'prescription:${row.id}',
          kind: TimelineEventKind.prescription,
          timestamp: row.orderedAt,
          title: row.drugName,
          subtitle: [
            if (row.doseStrength?.trim().isNotEmpty == true) row.doseStrength,
            if (row.frequency?.trim().isNotEmpty == true) row.frequency,
          ].whereType<String>().join(' · '),
          detail: row.dosageForm,
        ),
      );
    }

    final documentRows = await (select(
      documentRegistries,
    )..where((row) => row.patientId.equals(patientId))).get();
    for (final row in documentRows) {
      events.add(
        TimelineEvent(
          id: 'document:${row.id}',
          kind: TimelineEventKind.document,
          timestamp: row.documentedAt,
          title: row.documentCategory,
          subtitle: 'Scanned report',
          detail: row.rawOcrTranscript.isEmpty ? null : row.rawOcrTranscript,
          imagePath: row.imagePath,
        ),
      );
    }

    sortTimeline(events);
    return events;
  }

  /// Newest first, with a deterministic tie-break.
  ///
  /// Without the secondary keys, two events sharing a timestamp would swap
  /// places on every emission and the feed would visibly jitter.
  @visibleForTesting
  static void sortTimeline(List<TimelineEvent> events) {
    events.sort((a, b) {
      final byTime = b.timestamp.compareTo(a.timestamp);
      if (byTime != 0) return byTime;
      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;
      return a.id.compareTo(b.id);
    });
  }

  Future<void> updatePatient(Patient patient) async {
    await transaction(() async {
      await update(patients).replace(patient);
      await _enqueue(
        ownerId: patient.ownerId,
        entityType: 'patients',
        entityId: patient.id,
        operation: 'update',
        payload: _patientPayload(patient),
        clientUpdatedAt: DateTime.now().toUtc(),
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

  /// Documents scanned for this patient (the paper-chart side of the hybrid
  /// record), newest first. Feeds the timeline feed's document cards.
  Future<List<DocumentRegistry>> getDocumentsForPatient(String patientId) {
    return (select(documentRegistries)
          ..where((row) => row.patientId.equals(patientId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.documentedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Lab results for a patient, newest first.
  ///
  /// Results are joined to their order (when one exists) so the feed can show
  /// the order's status alongside the numeric value; results captured directly
  /// by the AI pipeline have a null `orderId` and still appear.
  Future<List<InvestigationResult>> getResultsForPatient(String patientId) {
    return (select(investigationResults)
          ..where((row) => row.patientId.equals(patientId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.resultDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Prescriptions written for one patient, newest first. Used to summarise
  /// "prescribed drugs" on an encounter card in the unified feed.
  Future<List<PrescriptionOrder>> getPrescriptionsForPatient(String patientId) {
    return (select(prescriptionOrders)
          ..where((row) => row.patientId.equals(patientId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.orderedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Interventions (procedures/operations) performed for a patient, newest
  /// first. These also drive the automatic `#PostOp*` cohort tags.
  Future<List<ClinicalIntervention>> getInterventionsForPatient(
    String patientId,
  ) {
    return (select(clinicalInterventions)
          ..where((row) => row.patientId.equals(patientId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.performedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
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

  /// All currently active prescription orders for a patient (continuous
  /// orders review in IPD mode). Ordered newest-first.
  /// Uses [PrescriptionOrders.isActive] since that table has no status col.
  Stream<List<PrescriptionOrder>> watchActivePrescriptions(String patientId) =>
      (select(prescriptionOrders)
            ..where(
              (row) =>
                  row.patientId.equals(patientId) & row.isActive.equals(true),
            )
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.orderedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  /// Mark a problem Resolved / Active from the IPD problem list.
  /// Writes via Drift companion (no raw SQL) and enqueues a sync update.
  /// Note: [PatientProblem] carries no ownerId — falls back to DAO default.
  Future<void> setProblemStatus({
    required String problemId,
    required bool resolved,
  }) async {
    final existing = await getPatientProblem(problemId);
    if (existing == null) return;
    final now = DateTime.now().toUtc();
    await (update(
      patientProblems,
    )..where((row) => row.id.equals(problemId))).write(
      PatientProblemsCompanion(
        currentStatus: Value(resolved ? 'Resolved' : 'Active'),
        resolvedDate: Value(resolved ? now : null),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(
      ownerId: defaultOwnerId,
      entityType: 'patient_problems',
      entityId: problemId,
      operation: 'update',
      payload: {
        'id': problemId,
        'current_status': resolved ? 'Resolved' : 'Active',
        'resolved_date': resolved ? now.toIso8601String() : null,
        'updated_at': now.toIso8601String(),
      },
      clientUpdatedAt: now,
    );
  }

  /// Create a new active problem for [patientId] and return its id.
  Future<String> addPatientProblem({
    required String patientId,
    required String problemName,
    String? encounterId,
    DateTime? onsetDate,
  }) async {
    final name = problemName.trim();
    if (name.isEmpty) throw ArgumentError('problemName must not be empty');
    final existingOwner = await (select(
      patients,
    )..where((row) => row.id.equals(patientId))).getSingleOrNull();
    final ownerId = existingOwner?.ownerId ?? defaultOwnerId;
    final now = DateTime.now().toUtc();
    final id = _ids.v4();
    await into(patientProblems).insert(
      PatientProblemsCompanion.insert(
        id: Value(id),
        patientId: patientId,
        initialEncounterId: Value(encounterId),
        problemName: name,
        currentStatus: const Value('Active'),
        onsetDate: Value(onsetDate ?? now),
      ),
    );
    await _enqueue(
      ownerId: ownerId,
      entityType: 'patient_problems',
      entityId: id,
      operation: 'insert',
      payload: {
        'id': id,
        'patient_id': patientId,
        'problem_name': name,
        'current_status': 'Active',
        'onset_date': (onsetDate ?? now).toIso8601String(),
      },
      clientUpdatedAt: now,
    );
    return id;
  }

  /// Stop / discontinue a continuous medication order (IPD review).
  /// Uses [PrescriptionOrders.isActive] as the stop flag.
  Future<void> stopPrescriptionOrder(String orderId) async {
    final existing = await (select(
      prescriptionOrders,
    )..where((row) => row.id.equals(orderId))).getSingleOrNull();
    if (existing == null) return;
    final now = DateTime.now().toUtc();
    await (update(prescriptionOrders)..where((row) => row.id.equals(orderId)))
        .write(const PrescriptionOrdersCompanion(isActive: Value(false)));
    await _enqueue(
      ownerId: defaultOwnerId,
      entityType: 'prescription_orders',
      entityId: orderId,
      operation: 'update',
      payload: {'id': orderId, 'is_active': false},
      clientUpdatedAt: now,
    );
  }

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
            final mrn = identifier?.mrn;
            return PendingInvestigation(
              investigation: row.readTable(investigationOrders),
              patient: row.readTable(patients),
              mrn: mrn == null || mrn.trim().isEmpty ? 'No Reg No' : mrn,
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
  /// One-shot wiki search for a `#tag` cross-link.
  ///
  /// Sprint 16 — [watchWikiEntries] is a live stream, which is the wrong shape
  /// for a modal that just needs the matching guidelines once.
  Future<List<PersonalWikiEntry>> searchWikiEntries({
    String query = '',
    String? ownerId,
    int limit = 10,
  }) async {
    final normalized = query.trim().toLowerCase();
    final statement = select(personalWiki)
      ..orderBy([(row) => OrderingTerm(expression: row.updatedAt)])
      ..limit(limit);
    if (normalized.isNotEmpty) {
      statement.where(
        (row) =>
            row.topic.lower().like('%$normalized%') |
            row.markdownContent.lower().like('%$normalized%') |
            row.tags.like('%$normalized%'),
      );
    }
    return statement.get();
  }

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
        i.id AS i_id,
        i.implant_code AS i_code,
        i.implant_name AS i_name,
        i.maximum_price AS i_price,
        s.id AS s_id,
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
          procedure: HbpProcedure(
            procedureCode: code,
            packageName: row.read<String>('p_package'),
            procedureName: row.read<String>('p_name'),
            specialty: row.read<String>('p_specialty'),
            rate: row.readNullable<double>('p_rate'),
          ),
        ),
      );

      final implantId = row.readNullable<int>('i_id');
      if (implantId != null) {
        final implantCode = row.read<String>('i_code');
        item.implants.putIfAbsent(
          implantCode,
          () => HbpImplant(
            id: implantId,
            procedureCode: code,
            implantCode: implantCode,
            implantName: row.read<String>('i_name'),
            maximumPrice: row.readNullable<double>('i_price'),
          ),
        );
      }

      final stratId = row.readNullable<int>('s_id');
      if (stratId != null) {
        final stratCode = row.read<String>('s_code');
        item.stratifications.putIfAbsent(
          stratCode,
          () => HbpStratification(
            id: stratId,
            procedureCode: code,
            stratificationCode: stratCode,
            stratificationName: row.read<String>('s_name'),
            rule: row.read<String>('s_rule'),
          ),
        );
      }
    }
    return [for (final item in grouped.values) item.toDetails()];
  }

  Stream<List<HbpProcedure>> searchProcedures(String query) {
    final term = query.trim();
    final statement = select(hbpProcedures)..limit(100);

    if (term.isNotEmpty) {
      final pattern = '%${term.replaceAll('%', '\\%')}%';
      statement.where(
        (row) =>
            row.procedureName.like(pattern) |
            row.packageName.like(pattern) |
            row.procedureCode.like(pattern) |
            row.specialty.like(pattern),
      );
    }
    return statement.watch();
  }

  Future<void> upsertProcedure(HbpProceduresCompanion companion) {
    return into(hbpProcedures).insertOnConflictUpdate(companion);
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

  /// Retains a cloud extraction request locally when connectivity disappears.
  /// It is intentionally not sent as a normal table upsert: the image remains
  /// in the clinician's review queue and needs explicit retry/upload handling.
  Future<void> enqueuePendingAiExtraction({
    required String taskId,
    required String imagePath,
    required String rawOcrText,
  }) => _enqueue(
    ownerId: defaultOwnerId,
    entityType: 'ai_extraction',
    entityId: taskId,
    operation: 'deferred',
    payload: {'image_path': imagePath, 'raw_ocr_text': rawOcrText},
    clientUpdatedAt: DateTime.now().toUtc(),
  );

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
    // Patients no longer carry an `updated_at` column (stable identity table).
    // Guard against older remote frames overwriting a newer local edit by
    // comparing against the most recent local pending sync-frame instead.
    if (existing != null) {
      final pending =
          await (select(offlineSyncQueue)
                ..where(
                  (row) =>
                      row.entityType.equals('patients') &
                      row.entityId.equals(id),
                )
                ..orderBy([
                  (row) => OrderingTerm(
                    expression: row.clientUpdatedAt,
                    mode: OrderingMode.desc,
                  ),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (pending != null && pending.clientUpdatedAt.isAfter(syncedAt)) {
        return;
      }
    }
    final residence =
        json['residence'] as String? ?? json['address_or_location'] as String?;
    await into(patients).insertOnConflictUpdate(
      PatientsCompanion(
        id: Value(id),
        ownerId: Value(json['owner_id'] as String? ?? defaultOwnerId),
        fullName: Value(json['full_name'] as String? ?? 'Unknown patient'),
        dateOfBirth: Value(_date(json['date_of_birth'])),
        gender: Value(json['gender'] as String?),
        residence: Value(residence),
        occupation: Value(json['occupation'] as String?),
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
  // 11. SMART LEARNED CATALOG & AUTOCOMPLETE
  // =========================================================================

  /// Searches catalog items by category, sorted by usage frequency and recency.
  Future<List<String>> searchLearnedCatalog({
    required String category,
    required String query,
    int limit = 8,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.length < 2) return const [];

    final rows =
        await (select(learnedCatalog)
              ..where(
                (t) =>
                    t.category.equals(category) &
                    t.term.lower().like('%$cleanQuery%'),
              )
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.frequency,
                  mode: OrderingMode.desc,
                ),
                (t) => OrderingTerm(
                  expression: t.lastUsedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    return rows.map((r) => r.term).toList(growable: false);
  }

  /// Increments the frequency counter or inserts a newly used clinical term.
  Future<void> recordCatalogUsage({
    required String category,
    required String term,
  }) async {
    final cleanTerm = term.trim();
    if (cleanTerm.isEmpty) return;

    final now = DateTime.now().toUtc();
    final existing =
        await (select(learnedCatalog)
              ..where(
                (t) =>
                    t.category.equals(category) &
                    t.term.lower().equals(cleanTerm.toLowerCase()),
              )
              ..limit(1))
            .getSingleOrNull();

    if (existing == null) {
      await into(learnedCatalog).insert(
        LearnedCatalogCompanion.insert(
          id: Value(_ids.v4()),
          category: category,
          term: cleanTerm,
          frequency: const Value(1),
          lastUsedAt: Value(now),
        ),
      );
    } else {
      await (update(
        learnedCatalog,
      )..where((t) => t.id.equals(existing.id))).write(
        LearnedCatalogCompanion(
          frequency: Value(existing.frequency + 1),
          lastUsedAt: Value(now),
        ),
      );
    }
  }

  // =========================================================================
  // 12. REPLICATION PAYLOAD SERIALIZERS
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
    'gender': row.gender,
    'residence': row.residence,
    // Legacy alias kept so older sync peers can still map the field.
    'address_or_location': row.residence,
    'occupation': row.occupation,
  };

  Map<String, dynamic> _clinicalEncounterPayload(ClinicalEncounter row) => {
    'id': row.id,
    'owner_id': row.ownerId,
    'patient_id': row.patientId,
    'hospital_id': row.hospitalId,
    'encounter_type': row.encounterType,
    'care_setting': row.careSetting,
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
    'pediatric_history': row.pediatricHistory,
    'ob_gyn_history': row.obGynHistory,
    'image_path': row.imagePath,
    'ai_summary': row.aiSummary,
    'created_at': row.createdAt.toIso8601String(),
    'updated_at': row.updatedAt.toIso8601String(),
  };

  DateTime? _date(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    if (value is int) return _fromEpochValue(value.toDouble());
    if (value is double) return _fromEpochValue(value);
    if (value is num) return _fromEpochValue(value.toDouble());
    if (value is String) {
      var trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.length >= 2 &&
          ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
              (trimmed.startsWith("'") && trimmed.endsWith("'")))) {
        trimmed = trimmed.substring(1, trimmed.length - 1).trim();
        if (trimmed.isEmpty) return null;
      }
      // Handle "1789216146Z": strip a trailing Z/z when the remainder is
      // purely numeric, then treat it as a unix timestamp.
      var candidate = trimmed;
      if ((candidate.endsWith('Z') || candidate.endsWith('z')) &&
          candidate.length > 1) {
        final stripped = candidate.substring(0, candidate.length - 1).trim();
        if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(stripped)) {
          candidate = stripped;
        }
      }
      // Pure integer timestamp (seconds or milliseconds).
      final asInt = int.tryParse(candidate);
      if (asInt != null) return _fromEpochValue(asInt.toDouble());
      // Floating timestamp.
      final asDouble = double.tryParse(candidate);
      if (asDouble != null && RegExp(r'^-?\d+\.\d+$').hasMatch(candidate)) {
        return _fromEpochValue(asDouble);
      }
      // Standard ISO8601 (try original first so offsets/zones are preserved).
      return DateTime.tryParse(trimmed)?.toUtc() ??
          DateTime.tryParse(candidate)?.toUtc();
    }
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  DateTime _fromEpochValue(double val) {
    final abs = val.abs();
    if (abs >= 1e14) {
      // Microseconds (current epoch micros ~1.7e15).
      return DateTime.fromMicrosecondsSinceEpoch(val.toInt(), isUtc: true);
    }
    if (abs >= 1e11) {
      // Milliseconds (current epoch millis ~1.7e12).
      return DateTime.fromMillisecondsSinceEpoch(val.toInt(), isUtc: true);
    }
    // Seconds (current epoch seconds ~1.7e9).
    return DateTime.fromMillisecondsSinceEpoch(
      (val * 1000).toInt(),
      isUtc: true,
    );
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

// ===========================================================================
// SPRINT 14 — "TODAY" WORKSPACE VIEW MODELS
// ===========================================================================

/// One row of the Ward Rounds tab: an active admission plus the demographics
/// and MRN needed to render a patient card without further queries.
class WardRoundPatient {
  const WardRoundPatient({
    required this.admission,
    required this.patient,
    this.mrn,
  });

  final Admission admission;
  final Patient patient;
  final String? mrn;

  String? get wardName => admission.wardName;
  String? get bedNumber => admission.bedNumber;
}

/// One row of the Follow-ups tab.
class SmartFollowUp {
  const SmartFollowUp({required this.patient, this.lastSeenAt});

  final Patient patient;
  final DateTime? lastSeenAt;
}

/// One row of the Drafts tab.
class PendingNote {
  const PendingNote({required this.encounter, required this.patient});

  final ClinicalEncounter encounter;
  final Patient patient;
}

class _HbpAccumulator {
  _HbpAccumulator({required this.procedure});

  final HbpProcedure procedure;
  final implants = <String, HbpImplant>{};
  final stratifications = <String, HbpStratification>{};

  HbpProcedureDetails toDetails() => HbpProcedureDetails(
    procedure: procedure,
    implants: implants.values.toList(growable: false),
    stratifications: stratifications.values.toList(growable: false),
  );
}

/// One item in the unified patient timeline.
///
/// Phase 2 merges five historically separate stores into a single
/// reverse-chronological story so a clinician reads one continuous account
/// instead of cross-referencing tabs.
enum TimelineEventKind {
  admission,
  encounter,
  labResult,
  prescription,
  document,
}

/// A single row of the universal timeline.
///
/// Exactly one payload field is non-null per event, matching [kind]. Modelling
/// it this way keeps the merge honest: a caller must switch on [kind] and cannot
/// accidentally read an encounter field off a lab result.
class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.kind,
    required this.timestamp,
    this.title,
    this.subtitle,
    this.detail,
    this.isAbnormal = false,
    this.wardName,
    this.bedNumber,
    this.hospitalId,
    this.encounterId,
    this.imagePath,
  });

  /// Stable identity: `"<kind>:<rowId>"`, so keys never collide across tables
  /// that each use their own uuid space.
  final String id;
  final TimelineEventKind kind;
  final DateTime timestamp;
  final String? title;
  final String? subtitle;
  final String? detail;

  /// Only ever true for [TimelineEventKind.labResult]. Surfaced prominently so
  /// an abnormal value is not scrolled past.
  final bool isAbnormal;

  final String? wardName;
  final String? bedNumber;
  final String? hospitalId;

  /// Links back to the encounter, for encounter-typed events only.
  final String? encounterId;

  /// Set for [TimelineEventKind.document] so the card can open the scan.
  final String? imagePath;
}
