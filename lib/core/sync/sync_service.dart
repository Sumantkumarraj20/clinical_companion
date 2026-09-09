import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/clinical_dao.dart';
import '../database/local_database.dart';

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
        // Patients table contains invariant demographics only
        // Ignore obsolete encounter columns if older remote rows have them
        json.remove('diagnosis');
        json.remove('surgery_type');
        json.remove('complications');
        json.remove('admission_date');
        json.remove('discharge_date');
        json.remove('current_department');
        // DAO upsertRemotePatient handles conflict update
      },
    );

    // 2. Episodic Clinical Encounters
    await _pullTable(
      table: 'clinical_encounters',
      since: effectiveCursor,
      onRow: (json) async {
        // Enforce chiefComplaints mapping if coming from older cloud rows
        if (json.containsKey('chief_complaint') && !json.containsKey('chief_complaints')) {
          json['chief_complaints'] = json['chief_complaint'];
        }
      },
    );

    // 3. Problem Trajectories & Progress
    await _pullTable(
      table: 'patient_problems',
      since: effectiveCursor,
      onRow: (json) async {},
    );

    await _pullTable(
      table: 'problem_progress_snapshots',
      since: effectiveCursor,
      onRow: (json) async {},
    );

    // 4. Clinical Interventions & Procedures
    await _pullTable(
      table: 'clinical_interventions',
      since: effectiveCursor,
      onRow: (json) async {},
    );

    // 5. Objective Outcome Metrics
    await _pullTable(
      table: 'clinical_outcome_metrics',
      since: effectiveCursor,
      onRow: (json) async {},
    );

    // 6. Prescriptions
    await _pullTable(
      table: 'prescription_orders',
      since: effectiveCursor,
      onRow: (json) async {},
    );

    // 7. Investigations & Results
    await _pullTable(
      table: 'investigation_orders',
      since: effectiveCursor,
      onRow: (json) async {},
    );

    await _pullTable(
      table: 'investigation_results',
      since: effectiveCursor,
      onRow: (json) async {},
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

    // Legacy compatibility remapping
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

      // Legacy table mapping redirects
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
        // Do not retry endlessly when clearly offline
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

