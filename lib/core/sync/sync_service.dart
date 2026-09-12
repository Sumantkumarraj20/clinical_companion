import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/clinical_dao.dart';
import '../database/local_database.dart';

import '../utils/datetime_utils.dart';

enum SyncStatus { idle, syncing, offline, error }

/// Coordinates the local outbox with Supabase without ever making a UI write
/// wait for the network. Calling [sync] is safe from multiple lifecycle hooks;
/// concurrent calls are coalesced by [_syncInProgress].
class SyncService {
  SyncService(this._dao, this._client);

  final ClinicalDao _dao;
  final SupabaseClient _client;
  bool _syncInProgress = false;
  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastPullAt;
  Timer? _periodicSync;

  bool get isSyncing => _syncInProgress;
  SyncStatus get status => _status;

  void startPeriodic({Duration interval = const Duration(minutes: 5)}) {
    _periodicSync ??= Timer.periodic(
      interval,
      (_) => unawaited(_syncSilently()),
    );
  }

  void dispose() => _periodicSync?.cancel();

  Future<void> _syncSilently() async {
    try {
      await sync();
    } catch (e) {
      debugPrint('[SyncService] Silent sync skipped: $e');
    }
  }

  Future<void> sync() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    _status = SyncStatus.syncing;

    try {
      await pushLocalChanges();
      await pullRemoteChanges();
      _status = SyncStatus.idle;
    } on SocketException catch (e) {
      debugPrint('[SyncService] Network offline: $e');
      _status = SyncStatus.offline;
    } catch (error, stack) {
      debugPrint('[SyncService] Sync error: $error\n$stack');
      _status = SyncStatus.error;
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> pushLocalChanges() async {
    final entries = await _dao.pendingQueue();
    for (final entry in entries) {
      try {
        await _retry(() => _send(entry));
        await _dao.removeQueueEntry(entry.id);
      } catch (error) {
        await _dao.markQueueFailure(entry, error);
      }
    }
  }

  Future<void> pullRemoteChanges({DateTime? since}) async {
    final cursor = since ?? _lastPullAt;
    final effectiveCursor =
        cursor ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final syncStartedAt = DateTime.now().toUtc();

    // 1. Core Invariant Demographics & Multi-Hospital IDs
    await _pullTable(
      table: 'patients',
      since: effectiveCursor,
      onRow: (json) async {
        json.remove('diagnosis');
        json.remove('surgery_type');
        json.remove('complications');
        json.remove('admission_date');
        json.remove('discharge_date');
        json.remove('current_department');
        await _dao.upsertRemotePatient(json, syncStartedAt);
      },
    );

    // 2. Episodic Clinical Encounters
    await _pullTable(
      table: 'clinical_encounters',
      since: effectiveCursor,
      onRow: (json) async {
        if (json.containsKey('chief_complaint') &&
            !json.containsKey('chief_complaints')) {
          json['chief_complaints'] = json['chief_complaint'];
        }
        await _dao.upsertRemoteEncounter(json, syncStartedAt);
      },
    );

    // 3. Problem Trajectories & Progress
    await _pullTable(
      table: 'patient_problems',
      since: effectiveCursor,
      onRow: (json) async {
        final id = json['id'] as String;
        final patientId = json['patient_id'] as String;
        final problemName =
            json['problem_name'] as String? ?? 'Clinical Finding';
        final status = json['current_status'] as String? ?? 'Active';
        final onset = DateTimeUtils.parseToUtc(json['onset_date']);

        await _dao
            .into(_dao.patientProblems)
            .insertOnConflictUpdate(
              PatientProblemsCompanion(
                id: Value(id),
                patientId: Value(patientId),
                problemName: Value(problemName),
                currentStatus: Value(status),
                onsetDate: Value(onset?.toUtc()),
                updatedAt: Value(syncStartedAt),
              ),
            );
      },
    );

    await _pullTable(
      table: 'problem_progress_snapshots',
      since: effectiveCursor,
      onRow: (json) async {
        final id = json['id'] as String;
        final problemId = json['problem_id'] as String;
        final patientId = json['patient_id'] as String;
        // FIX 1: Enforce non-null String for encounterId
        final encounterId = json['encounter_id'] as String? ?? '';
        final status = json['status_snapshot'] as String? ?? 'Active';
        final note = json['clinical_course_note'] as String? ?? '';

        await _dao
            .into(_dao.problemProgressSnapshots)
            .insertOnConflictUpdate(
              ProblemProgressSnapshotsCompanion(
                id: Value(id),
                problemId: Value(problemId),
                patientId: Value(patientId),
                encounterId: Value(encounterId),
                statusSnapshot: Value(status),
                clinicalCourseNote: Value(note),
              ),
            );
      },
    );

    // 4. Clinical Interventions & Procedures
    await _pullTable(
      table: 'clinical_interventions',
      since: effectiveCursor,
      onRow: (json) async {
        final id = json['id'] as String;
        final patientId = json['patient_id'] as String;
        // FIX 2: Enforce non-null String for encounterId
        final encounterId = json['encounter_id'] as String? ?? '';
        final problemId = json['problem_id'] as String?;
        final procName = json['procedure_name'] as String? ?? 'Procedure';
        final role = json['intervention_role'] as String? ?? 'Therapeutic';

        await _dao
            .into(_dao.clinicalInterventions)
            .insertOnConflictUpdate(
              ClinicalInterventionsCompanion(
                id: Value(id),
                patientId: Value(patientId),
                encounterId: Value(encounterId),
                problemId: Value(problemId),
                procedureName: Value(procName),
                interventionRole: Value(role),
                performedAt: Value(
                  DateTimeUtils.parseToUtc(json['performed_at']) ??
                      syncStartedAt,
                ),
              ),
            );
      },
    );

    // 5. Objective Outcome Metrics
    await _pullTable(
      table: 'clinical_outcome_metrics',
      since: effectiveCursor,
      onRow: (json) async {
        final id = json['id'] as String;
        final patientId = json['patient_id'] as String;
        final metricName = json['metric_name'] as String? ?? 'Metric';
        // FIX 3: Map to metric_value instead of numeric_value
        final numVal = (json['metric_value'] ?? json['value'] as num?)
            ?.toDouble();

        await _dao
            .into(_dao.clinicalOutcomeMetrics)
            .insertOnConflictUpdate(
              ClinicalOutcomeMetricsCompanion(
                id: Value(id),
                patientId: Value(patientId),
                metricName: Value(metricName),
                metricValue: Value(numVal), // Updated to metricValue
                measuredAt: Value(
                  DateTimeUtils.parseToUtc(json['measured_at']) ??
                      syncStartedAt,
                ),
              ),
            );
      },
    );

    // 6. Prescriptions
    await _pullTable(
      table: 'prescription_orders',
      since: effectiveCursor,
      onRow: (json) async {
        final id = json['id'] as String;
        final patientId = json['patient_id'] as String;
        final drugName = json['drug_name'] as String? ?? 'Medication';
        final encId = json['encounter_id'] as String?;

        await _dao
            .into(_dao.prescriptionOrders)
            .insertOnConflictUpdate(
              PrescriptionOrdersCompanion(
                id: Value(id),
                patientId: Value(patientId),
                encounterId: Value(encId ?? ''),
                drugName: Value(drugName),
                doseStrength: Value(json['dose_strength'] as String?),
                frequency: Value(json['frequency'] as String?),
                route: Value(json['route'] as String?),
                orderedAt: Value(
                  DateTimeUtils.parseToUtc(json['ordered_at']) ??
                      syncStartedAt,
                ),
              ),
            );
      },
    );

    // 7. Investigations & Results
    await _pullTable(
      table: 'investigation_orders',
      since: effectiveCursor,
      onRow: (json) async {
        await _dao.upsertRemoteInvestigation(json, syncStartedAt);
      },
    );

    await _pullTable(
      table: 'investigation_results',
      since: effectiveCursor,
      onRow: (json) async {
        final id = json['id'] as String;
        final orderId = json['order_id'] as String?;
        final patientId = json['patient_id'] as String;
        final testName = json['test_name'] as String? ?? 'Test';
        final numVal = (json['numeric_value'] as num?)?.toDouble();

        await _dao
            .into(_dao.investigationResults)
            .insertOnConflictUpdate(
              InvestigationResultsCompanion(
                id: Value(id),
                orderId: Value(orderId),
                patientId: Value(patientId),
                testName: Value(testName),
                numericValue: Value(numVal),
                textValue: Value(json['text_value'] as String?),
                unit: Value(json['unit'] as String?),
                isAbnormal: Value(json['is_abnormal'] as bool? ?? false),
                resultDate: Value(
                  DateTimeUtils.parseToUtc(json['result_date']) ??
                      syncStartedAt,
                ),
              ),
            );
      },
    );

    // 8. Personal Knowledge Base Wiki
    await _pullTable(
      table: 'personal_wiki',
      since: effectiveCursor,
      onRow: (json) => _dao.upsertRemoteWiki(json, syncStartedAt),
    );

    _lastPullAt = syncStartedAt;
  }

  Future<void> _pullTable({
    required String table,
    required DateTime since,
    required Future<void> Function(Map<String, dynamic>) onRow,
  }) async {
    final result = await _retry(() async {
      return _client
          .from(table)
          .select()
          .gt('updated_at', since.toIso8601String())
          .order('updated_at');
    });
    for (final raw in result) {
      await onRow(Map<String, dynamic>.from(raw));
    }
  }

  Future<void> _send(SyncQueueEntry entry) async {
    final decoded = jsonDecode(entry.payload);
    if (decoded is! Map) {
      throw const FormatException('Sync queue payload must be a JSON object');
    }
    final payload = Map<String, dynamic>.from(decoded);
    final table = _tableName(entry.entityType);

    if (entry.entityType == 'daily_vitals_notes') {
      payload['occurred_at'] ??= payload.remove('recorded_at');
      payload['encounter_type'] ??= 'Ward Round';
      payload['dynamic_data'] ??= <String, dynamic>{};
    }

    if (entry.operation == 'delete') {
      await _client.from(table).delete().eq('id', entry.entityId);
      return;
    }

    await _client.from(table).upsert(payload, onConflict: 'id');
  }

  String _tableName(String entityType) {
    switch (entityType) {
      case 'patients':
      case 'patient_hospital_identifiers':
      case 'clinical_encounters':
      case 'patient_problems':
      case 'problem_progress_snapshots':
      case 'clinical_interventions':
      case 'clinical_outcome_metrics':
      case 'prescription_orders':
      case 'investigation_orders':
      case 'investigation_results':
      case 'personal_wiki':
      case 'cdss_rules':
        return entityType;

      case 'daily_vitals_notes':
        return 'clinical_encounters';
      case 'investigation_tracker':
        return 'investigation_orders';

      default:
        throw ArgumentError.value(
          entityType,
          'entityType',
          'Unknown or non-syncable entity type',
        );
    }
  }

  Future<T> _retry<T>(Future<T> Function() action) async {
    Object? lastError;
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        return await action();
      } on SocketException {
        rethrow;
      } catch (error) {
        lastError = error;
        if (attempt == 3) break;
        final delay = Duration(milliseconds: 250 * (1 << attempt));
        await Future<void>.delayed(delay);
      }
    }
    throw lastError ?? StateError('Network operation failed');
  }
}
