import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/clinical_dao.dart';
import '../database/local_database.dart';

/// Coordinates the local outbox with Supabase without ever making a UI write
/// wait for the network. Calling [sync] is safe from multiple lifecycle hooks;
/// concurrent calls are coalesced by [_syncInProgress].
class SyncService {
  SyncService(this._dao, this._client);

  final ClinicalDao _dao;
  final SupabaseClient _client;
  bool _syncInProgress = false;
  DateTime? _lastPullAt;
  Timer? _periodicSync;

  bool get isSyncing => _syncInProgress;

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
    } catch (_) {
      // The outbox retains failed work and applies its own retry schedule.
    }
  }

  Future<void> sync() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    try {
      await pushLocalChanges();
      await pullRemoteChanges();
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
    final cursor = since ?? _lastPullAt ?? await _dao.latestRemoteSync();
    final effectiveCursor =
        cursor ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final syncStartedAt = DateTime.now().toUtc();

    await _pullTable(
      table: 'patients',
      since: effectiveCursor,
      onRow: (json) => _dao.upsertRemotePatient(json, syncStartedAt),
    );
    await _pullTable(
      table: 'clinical_encounters',
      since: effectiveCursor,
      onRow: (json) => _dao.upsertRemoteEncounter(json, syncStartedAt),
    );
    await _pullTable(
      table: 'investigation_tracker',
      since: effectiveCursor,
      onRow: (json) => _dao.upsertRemoteInvestigation(json, syncStartedAt),
    );
    await _pullTable(
      table: 'drug_master',
      since: effectiveCursor,
      onRow: (json) => _dao.upsertRemoteDrug(json, syncStartedAt),
    );
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
        return 'patients';
      case 'clinical_encounters':
      case 'daily_vitals_notes': // legacy queue rows created before migration
        return 'clinical_encounters';
      case 'investigation_tracker':
      case 'drug_master':
      case 'personal_wiki':
        return entityType;
      default:
        throw ArgumentError.value(
          entityType,
          'entityType',
          'Unknown sync entity',
        );
    }
  }

  Future<T> _retry<T>(Future<T> Function() action) async {
    Object? lastError;
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        return await action();
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
