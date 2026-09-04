import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/local_database.dart';

part 'clinical_dao.g.dart';

/// Typed result used by the lab tracker to display a patient beside a test.
class PendingInvestigation {
  const PendingInvestigation({
    required this.investigation,
    required this.patient,
  });

  final Investigation investigation;
  final Patient patient;
}

@DriftAccessor(
  tables: [
    Patients,
    ClinicalEncounters,
    Investigations,
    Drugs,
    PersonalWiki,
    OfflineSyncQueue,
    PatientProblems,
    ClinicalActions,
    ClinicalOutcomes,
  ],
)
class ClinicalDao extends DatabaseAccessor<AppDatabase>
    with _$ClinicalDaoMixin {
  ClinicalDao(super.db);

  final _ids = const Uuid();

  Stream<List<Patient>> watchAllPatients() {
    return (select(patients)..orderBy([
          (row) =>
              OrderingTerm(expression: row.isActive, mode: OrderingMode.desc),
          (row) => OrderingTerm(expression: row.fullName),
        ]))
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

  Stream<List<ClinicalEncounter>> watchNotesForDay(DateTime day) =>
      watchClinicalEncounters(day);

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

  Stream<List<ClinicalAction>> watchActionsForProblem(String problemId) =>
      (select(clinicalActions)
            ..where((row) => row.problemId.equals(problemId))
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.occurredAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<void> insertClinicalAction(ClinicalActionsCompanion values) =>
      into(clinicalActions).insert(values);

  Stream<List<ClinicalOutcome>> watchOutcomesForProblem(String problemId) =>
      (select(clinicalOutcomes)
            ..where((row) => row.problemId.equals(problemId))
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.measuredAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<List<Map<String, Object?>>> comparativeOutcomes(
    String? problemId,
  ) async {
    final query = customSelect(
      '''
      SELECT p.id AS problem_id, p.problem_name,
             o.treatment_method, AVG(o.metric_value) AS average_value
      FROM clinical_outcomes o
      JOIN patient_problems p ON p.id = o.problem_id
      WHERE (?1 IS NULL OR p.id = ?1)
      GROUP BY p.id, p.problem_name, o.treatment_method
      ORDER BY p.problem_name, average_value DESC
      ''',
      variables: [Variable<String>(problemId ?? '')],
      readsFrom: {clinicalOutcomes, patientProblems},
    );
    final rows = await query.get();
    return rows.map((row) => row.data).toList(growable: false);
  }

  Future<List<Investigation>> getInvestigationsForPatient(String patientId) {
    return (select(investigations)
          ..where((row) => row.patientId.equals(patientId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.orderedAt,
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
      if (!normalized.patientId.present || !normalized.ownerId.present) {
        throw ArgumentError('ownerId and patientId are required');
      }
      final patient = await findPatient(normalized.patientId.value);
      if (patient == null || patient.ownerId != normalized.ownerId.value) {
        throw StateError('Patient is not available for this owner');
      }
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

  Future<ClinicalEncounter> insertDailyNote(DailyNotesCompanion values) =>
      insertClinicalEncounter(values);

  Future<void> updateClinicalEncounter(ClinicalEncounter note) async {
    await transaction(() async {
      final updated = note.copyWith(updatedAt: DateTime.now().toUtc());
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

  Future<void> updateDailyNote(DailyNote note) => updateClinicalEncounter(note);

  Future<void> deleteClinicalEncounter(ClinicalEncounter note) async {
    await transaction(() async {
      await _enqueue(
        ownerId: note.ownerId,
        entityType: 'clinical_encounters',
        entityId: note.id,
        operation: 'delete',
        payload: {'id': note.id},
        clientUpdatedAt: DateTime.now().toUtc(),
      );
      await delete(clinicalEncounters).delete(note);
    });
  }

  Future<void> deleteDailyNote(DailyNote note) => deleteClinicalEncounter(note);

  Stream<List<Investigation>> watchPendingInvestigations() {
    return (select(investigations)
          ..where((row) => row.status.isIn(const ['pending', 'sample_sent']))
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
        select(investigations).join([
            innerJoin(
              patients,
              patients.id.equalsExp(investigations.patientId),
            ),
          ])
          ..where(
            investigations.status.isIn(const ['pending', 'sample_sent']) &
                investigations.orderedAt.isBetweenValues(start, end),
          )
          ..orderBy([OrderingTerm(expression: investigations.orderedAt)]);
    return query.watch().map((rows) {
      return rows
          .map((row) {
            return PendingInvestigation(
              investigation: row.readTable(investigations),
              patient: row.readTable(patients),
            );
          })
          .toList(growable: false);
    });
  }

  Future<Investigation?> findInvestigation(String id) {
    return (select(
      investigations,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateInvestigation(Investigation investigation) async {
    await transaction(() async {
      await update(investigations).replace(investigation);
      await _enqueue(
        ownerId: investigation.ownerId,
        entityType: 'investigation_tracker',
        entityId: investigation.id,
        operation: 'update',
        payload: _investigationPayload(investigation),
        clientUpdatedAt: investigation.updatedAt,
      );
    });
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
    await updateInvestigation(updated);
  }

  Future<void> addInvestigation(InvestigationsCompanion values) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    final normalized = values.copyWith(id: Value(id));
    await transaction(() async {
      if (!normalized.patientId.present || !normalized.ownerId.present) {
        throw ArgumentError('ownerId and patientId are required');
      }
      final patient = await findPatient(normalized.patientId.value);
      if (patient == null || patient.ownerId != normalized.ownerId.value) {
        throw StateError('Patient is not available for this owner');
      }
      await into(investigations).insert(normalized);
      final row = await (select(
        investigations,
      )..where((item) => item.id.equals(id))).getSingle();
      await _enqueue(
        ownerId: row.ownerId,
        entityType: 'investigation_tracker',
        entityId: row.id,
        operation: 'insert',
        payload: _investigationPayload(row),
        clientUpdatedAt: row.updatedAt,
      );
    });
  }

  Future<void> deleteInvestigation(Investigation investigation) async {
    await transaction(() async {
      await _enqueue(
        ownerId: investigation.ownerId,
        entityType: 'investigation_tracker',
        entityId: investigation.id,
        operation: 'delete',
        payload: {'id': investigation.id},
        clientUpdatedAt: DateTime.now().toUtc(),
      );
      await delete(investigations).delete(investigation);
    });
  }

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
    final normalized = values.copyWith(id: Value(id));
    await transaction(() async {
      await into(drugs).insert(normalized);
      final row = await (select(
        drugs,
      )..where((item) => item.id.equals(id))).getSingle();
      await _enqueue(
        ownerId: row.ownerId,
        entityType: 'drug_master',
        entityId: row.id,
        operation: 'insert',
        payload: {
          'id': row.id,
          'owner_id': row.ownerId,
          'generic_name': row.genericName,
          'brand_name': row.brandName,
          'strength': row.strength,
          'dosage_form': row.dosageForm,
          'route': row.route,
          'category': row.category,
          'substitutes': row.substitutes,
          'side_effects': row.sideEffects,
          'uses': row.uses,
          'chemical_class': row.chemicalClass,
          'price_estimate': row.priceEstimate,
          'is_trusted': row.isTrusted,
          'custom_notes': row.customNotes,
          'is_active': row.isActive,
          'metadata': _decodedOrEmpty(row.metadata),
          'created_at': row.createdAt.toIso8601String(),
          'updated_at': row.updatedAt.toIso8601String(),
        },
        clientUpdatedAt: row.updatedAt,
      );
    });
  }

  Stream<List<WikiEntry>> watchWikiEntries({
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
          in normalized
              .split(RegExp(r'\s+'))
              .where((value) => value.isNotEmpty)) {
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

  Future<WikiEntry> insertWikiEntry(PersonalWikiCompanion values) async {
    final id = values.id.present ? values.id.value : _ids.v4();
    final normalized = values.copyWith(id: Value(id));
    return transaction(() async {
      if (!normalized.ownerId.present || !normalized.topic.present) {
        throw ArgumentError('ownerId and topic are required');
      }
      await into(personalWiki).insert(normalized);
      final row = await (select(
        personalWiki,
      )..where((item) => item.id.equals(id))).getSingle();
      await _enqueue(
        ownerId: row.ownerId,
        entityType: 'personal_wiki',
        entityId: row.id,
        operation: 'insert',
        payload: _wikiPayload(row),
        clientUpdatedAt: row.updatedAt,
      );
      return row;
    });
  }

  Future<void> updateWikiEntry(WikiEntry entry) async {
    final updated = entry.copyWith(updatedAt: DateTime.now().toUtc());
    await transaction(() async {
      await update(personalWiki).replace(updated);
      await _enqueue(
        ownerId: updated.ownerId,
        entityType: 'personal_wiki',
        entityId: updated.id,
        operation: 'update',
        payload: _wikiPayload(updated),
        clientUpdatedAt: updated.updatedAt,
      );
    });
  }

  Future<void> deleteWikiEntry(WikiEntry entry) async {
    await transaction(() async {
      await _enqueue(
        ownerId: entry.ownerId,
        entityType: 'personal_wiki',
        entityId: entry.id,
        operation: 'delete',
        payload: {'id': entry.id},
        clientUpdatedAt: DateTime.now().toUtc(),
      );
      await delete(personalWiki).delete(entry);
    });
  }

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
    await transaction(() async {
      await update(offlineSyncQueue).replace(
        entry.copyWith(
          attempts: attempts,
          lastError: Value(error.toString()),
          nextAttemptAt: now.add(Duration(seconds: seconds)),
          updatedAt: now,
        ),
      );
    });
  }

  Future<void> removeQueueEntry(String id) async {
    await (delete(offlineSyncQueue)..where((row) => row.id.equals(id))).go();
  }

  Future<DateTime?> latestRemoteSync() async {
    final dates = (await Future.wait<DateTime?>([
      _latestPatientSync(),
      _latestEncounterSync(),
      _latestInvestigationSync(),
      _latestDrugSync(),
      _latestWikiSync(),
    ])).whereType<DateTime>().toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.last;
  }

  Future<DateTime?> _latestPatientSync() async {
    final rows =
        await (select(patients)
              ..where((row) => row.lastSyncedAt.isNotNull())
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.lastSyncedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.lastSyncedAt;
  }

  Future<DateTime?> _latestEncounterSync() async {
    final rows =
        await (select(clinicalEncounters)
              ..where((row) => row.lastSyncedAt.isNotNull())
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.lastSyncedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.lastSyncedAt;
  }

  Future<DateTime?> _latestInvestigationSync() async {
    final rows =
        await (select(investigations)
              ..where((row) => row.lastSyncedAt.isNotNull())
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.lastSyncedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.lastSyncedAt;
  }

  Future<DateTime?> _latestDrugSync() async {
    final rows =
        await (select(drugs)
              ..where((row) => row.lastSyncedAt.isNotNull())
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.lastSyncedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.lastSyncedAt;
  }

  Future<DateTime?> _latestWikiSync() async {
    final rows =
        await (select(personalWiki)
              ..where((row) => row.lastSyncedAt.isNotNull())
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.lastSyncedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.lastSyncedAt;
  }

  Future<void> upsertRemotePatient(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final existing = await findPatient(json['id'] as String);
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await transaction(() async {
      await into(
        patients,
      ).insertOnConflictUpdate(_patientCompanion(json, syncedAt));
    });
  }

  Future<void> upsertRemoteEncounter(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final existing = await (select(
      clinicalEncounters,
    )..where((row) => row.id.equals(json['id'] as String))).getSingleOrNull();
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await transaction(() async {
      await into(
        clinicalEncounters,
      ).insertOnConflictUpdate(_clinicalEncounterCompanion(json, syncedAt));
    });
  }

  Future<void> upsertRemoteNote(Map<String, dynamic> json, DateTime syncedAt) =>
      upsertRemoteEncounter(json, syncedAt);

  Future<void> upsertRemoteInvestigation(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final existing = await findInvestigation(json['id'] as String);
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await transaction(() async {
      await into(
        investigations,
      ).insertOnConflictUpdate(_investigationCompanion(json, syncedAt));
    });
  }

  Future<void> upsertRemoteDrug(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final existing = await (select(
      drugs,
    )..where((row) => row.id.equals(json['id'] as String))).getSingleOrNull();
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await transaction(() async {
      await into(drugs).insertOnConflictUpdate(
        DrugsCompanion(
          id: Value(json['id'] as String),
          ownerId: Value(json['owner_id'] as String),
          genericName: Value(json['generic_name'] as String),
          brandName: Value(json['brand_name'] as String?),
          strength: Value(json['strength'] as String?),
          dosageForm: Value(json['dosage_form'] as String?),
          route: Value(json['route'] as String?),
          category: Value(json['category'] as String?),
          substitutes: Value(json['substitutes'] as String? ?? ''),
          sideEffects: Value(json['side_effects'] as String? ?? ''),
          uses: Value(json['uses'] as String? ?? ''),
          chemicalClass: Value(json['chemical_class'] as String? ?? ''),
          priceEstimate: Value(json['price_estimate'] as String?),
          isTrusted: Value(json['is_trusted'] as bool? ?? false),
          customNotes: Value(json['custom_notes'] as String?),
          isActive: Value(json['is_active'] as bool? ?? true),
          metadata: Value(jsonEncode(json['metadata'] ?? <String, dynamic>{})),
          createdAt: Value(_date(json['created_at']) ?? syncedAt),
          updatedAt: Value(_date(json['updated_at']) ?? syncedAt),
          lastSyncedAt: Value(syncedAt),
        ),
      );
    });
  }

  Future<void> upsertRemoteWiki(
    Map<String, dynamic> json,
    DateTime syncedAt,
  ) async {
    final existing = await (select(
      personalWiki,
    )..where((row) => row.id.equals(json['id'] as String))).getSingleOrNull();
    if (_remoteIsOlder(existing?.updatedAt, json['updated_at'], syncedAt)) {
      return;
    }
    await transaction(() async {
      await into(personalWiki).insertOnConflictUpdate(
        PersonalWikiCompanion(
          id: Value(json['id'] as String),
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
    });
  }

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
    'hospital_reg_no': row.hospitalRegNo,
    'full_name': row.fullName,
    'date_of_birth': row.dateOfBirth?.toIso8601String(),
    'sex': row.sex,
    'phone': row.phone,
    'diagnosis': row.diagnosis,
    'current_department': row.currentDepartment,
    'surgery_type': row.surgeryType,
    'complications': row.complications,
    'admission_date': row.admissionDate?.toIso8601String(),
    'discharge_date': row.dischargeDate?.toIso8601String(),
    'is_active': row.isActive,
    'metadata': _decodedOrEmpty(row.metadata),
    'created_at': row.createdAt.toIso8601String(),
    'updated_at': row.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _clinicalEncounterPayload(ClinicalEncounter row) => {
    'id': row.id,
    'owner_id': row.ownerId,
    'patient_id': row.patientId,
    'encounter_type': row.encounterType,
    'occurred_at': row.occurredAt.toIso8601String(),
    'sbp': row.sbp,
    'dbp': row.dbp,
    'pulse': row.pulse,
    'temperature_c': row.temperatureC,
    'respiratory_rate': row.respiratoryRate,
    'spo2': row.spo2,
    'map': row.meanArterialPressure,
    'chief_complaint': row.chiefComplaint,
    'consultant_advice': row.consultantAdvice,
    'note': row.note,
    'dynamic_data': row.dynamicData,
    'department': row.department,
    'ward_name': row.wardName,
    'bed_number': row.bedNumber,
    'image_path': row.imagePath,
    'ai_summary': row.aiSummary,
    'created_at': row.createdAt.toIso8601String(),
    'updated_at': row.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _investigationPayload(Investigation row) => {
    'id': row.id,
    'owner_id': row.ownerId,
    'patient_id': row.patientId,
    'test_name': row.testName,
    'test_code': row.testCode,
    'status': row.status,
    'ordered_at': row.orderedAt.toIso8601String(),
    'sample_sent_at': row.sampleSentAt?.toIso8601String(),
    'result_received_at': row.resultReceivedAt?.toIso8601String(),
    'result_value': row.resultValue,
    'result_unit': row.resultUnit,
    'reference_range': row.referenceRange,
    'organism': row.organism,
    'sensitive_antibiotics': _decodedListOrEmpty(row.sensitiveAntibiotics),
    'resistant_antibiotics': _decodedListOrEmpty(row.resistantAntibiotics),
    'notes': row.notes,
    'created_at': row.createdAt.toIso8601String(),
    'updated_at': row.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _wikiPayload(WikiEntry row) => {
    'id': row.id,
    'owner_id': row.ownerId,
    'topic': row.topic,
    'markdown_content': row.markdownContent,
    'tags': row.tags,
    'department_relevance': row.departmentRelevance,
    'created_at': row.createdAt.toIso8601String(),
    'updated_at': row.updatedAt.toIso8601String(),
  };

  PatientsCompanion _patientCompanion(
    Map<String, dynamic> j,
    DateTime syncedAt,
  ) => PatientsCompanion(
    id: Value(j['id'] as String),
    ownerId: Value(j['owner_id'] as String),
    hospitalRegNo: Value(j['hospital_reg_no'] as String),
    fullName: Value(j['full_name'] as String),
    dateOfBirth: Value(_date(j['date_of_birth'])),
    sex: Value(j['sex'] as String?),
    phone: Value(j['phone'] as String?),
    diagnosis: Value(j['diagnosis'] as String?),
    currentDepartment: Value(j['current_department'] as String? ?? 'Surgery'),
    surgeryType: Value(j['surgery_type'] as String?),
    complications: Value(j['complications'] as String?),
    admissionDate: Value(_date(j['admission_date'])),
    dischargeDate: Value(_date(j['discharge_date'])),
    isActive: Value(j['is_active'] as bool? ?? true),
    metadata: Value(jsonEncode(j['metadata'] ?? <String, dynamic>{})),
    createdAt: Value(_date(j['created_at']) ?? syncedAt),
    updatedAt: Value(_date(j['updated_at']) ?? syncedAt),
    lastSyncedAt: Value(syncedAt),
  );

  ClinicalEncountersCompanion _clinicalEncounterCompanion(
    Map<String, dynamic> j,
    DateTime syncedAt,
  ) => ClinicalEncountersCompanion(
    id: Value(j['id'] as String),
    ownerId: Value(j['owner_id'] as String),
    patientId: Value(j['patient_id'] as String),
    encounterType: Value(j['encounter_type'] as String? ?? 'Ward Round'),
    occurredAt: Value(_date(j['occurred_at'] ?? j['recorded_at']) ?? syncedAt),
    sbp: Value((j['sbp'] as num?)?.toInt()),
    dbp: Value((j['dbp'] as num?)?.toInt()),
    pulse: Value((j['pulse'] as num?)?.toInt()),
    temperatureC: Value((j['temperature_c'] as num?)?.toDouble()),
    respiratoryRate: Value((j['respiratory_rate'] as num?)?.toInt()),
    spo2: Value((j['spo2'] as num?)?.toInt()),
    meanArterialPressure: Value((j['map'] as num?)?.toDouble()),
    chiefComplaint: Value(j['chief_complaint'] as String?),
    consultantAdvice: Value(j['consultant_advice'] as String?),
    note: Value(j['note'] as String?),
    dynamicData: Value(
      j['dynamic_data'] is Map
          ? Map<String, dynamic>.from(j['dynamic_data'] as Map)
          : <String, dynamic>{},
    ),
    department: Value(j['department'] as String?),
    wardName: Value(j['ward_name'] as String?),
    bedNumber: Value(j['bed_number'] as String?),
    imagePath: Value(j['image_path'] as String?),
    aiSummary: Value(j['ai_summary'] as String?),
    createdAt: Value(_date(j['created_at']) ?? syncedAt),
    updatedAt: Value(_date(j['updated_at']) ?? syncedAt),
    lastSyncedAt: Value(syncedAt),
  );

  InvestigationsCompanion _investigationCompanion(
    Map<String, dynamic> j,
    DateTime syncedAt,
  ) => InvestigationsCompanion(
    id: Value(j['id'] as String),
    ownerId: Value(j['owner_id'] as String),
    patientId: Value(j['patient_id'] as String),
    testName: Value(j['test_name'] as String),
    testCode: Value(j['test_code'] as String?),
    status: Value(j['status'] as String? ?? 'pending'),
    orderedAt: Value(_date(j['ordered_at']) ?? syncedAt),
    sampleSentAt: Value(_date(j['sample_sent_at'])),
    resultReceivedAt: Value(_date(j['result_received_at'])),
    resultValue: Value(j['result_value'] as String?),
    resultUnit: Value(j['result_unit'] as String?),
    referenceRange: Value(j['reference_range'] as String?),
    organism: Value(j['organism'] as String?),
    sensitiveAntibiotics: Value(
      jsonEncode(j['sensitive_antibiotics'] ?? <dynamic>[]),
    ),
    resistantAntibiotics: Value(
      jsonEncode(j['resistant_antibiotics'] ?? <dynamic>[]),
    ),
    notes: Value(j['notes'] as String?),
    createdAt: Value(_date(j['created_at']) ?? syncedAt),
    updatedAt: Value(_date(j['updated_at']) ?? syncedAt),
    lastSyncedAt: Value(syncedAt),
  );

  DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toUtc();

  Object _decodedOrEmpty(String value) {
    try {
      return jsonDecode(value) ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  List<Object?> _decodedListOrEmpty(String value) {
    final decoded = _decodedOrEmpty(value);
    return decoded is List ? List<Object?>.from(decoded) : <Object?>[];
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
