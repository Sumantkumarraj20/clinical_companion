import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../database/daos/pharmacopeia_dao.dart';

/// Over-The-Air (OTA) nightly drug-catalog sync (Sprint 7).
///
/// Fetches the JSON published by the Google Apps Script Web App (one key per
/// Google Sheet tab: `clinical_core`, `indications_dosing_matrix`,
/// `formulations_administration`, `commercial_brands_trust_layer`) and merges
/// it into the local SQLite pharmacopeia tables through
/// [PharmacopeiaDao.upsertOtaCatalog] — an `insertOrReplace` batch that
/// never deletes or overwrites patient-owned data.
///
/// The service is intentionally fire-and-forget friendly: callers can
/// `unawaited(service.syncCatalogFromCloud(url).catchError(log))` from app
/// startup without ever blocking the UI thread (the HTTP wait and the Drift
/// batch are both fully asynchronous).
class CatalogSyncService {
  CatalogSyncService({
    required PharmacopeiaDao pharmacopeiaDao,
    http.Client? httpClient,
    this.requestTimeout = const Duration(seconds: 45),
  })  : _dao = pharmacopeiaDao,
        _client = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  /// Deployment URL of the Apps Script Web App that publishes the nightly
  /// pharmacopeia tabs. Proven live (HTTP 200, four tabs, 305 rows), so it
  /// is the default; override per environment with
  /// `--dart-define=CATALOG_SYNC_URL=https://script.google.com/...`.
  static const String defaultCatalogScriptUrl =
      'https://script.google.com/macros/s/AKfycbwPOArv0Da9ORn0B2Fl6cBjXlynTw3MLygSHTB4Azs6LefsubNPc15UYttc_OD_MeJzHQ/exec';

  /// Legacy placeholder kept so builds that still ship the un-configured
  /// dart-define bail out cleanly instead of hitting an invalid host.
  static const String urlPlaceholder = 'YOUR_GOOGLE_SCRIPT_URL_HERE';

  final PharmacopeiaDao _dao;
  final http.Client _client;
  final bool _ownsClient;
  final Duration requestTimeout;

  bool _syncInProgress = false;

  /// True while a cloud fetch/merge is running (coalesces duplicate taps).
  bool get isSyncing => _syncInProgress;

  /// Wall-clock time of the last successful merge, for debug/telemetry.
  DateTime? get lastSyncAt => _lastSyncAt;
  DateTime? _lastSyncAt;

  /// Downloads the Apps Script payload and merges it into SQLite.
  ///
  /// Throws on invalid/placeholder URLs, transport failures, malformed
  /// JSON, or a non-object payload. Concurrent calls are coalesced — a
  /// second call while one is in flight simply returns.
  Future<void> syncCatalogFromCloud(String googleScriptUrl) async {
    if (_syncInProgress) {
      debugPrint('[CatalogSync] Sync already in progress — skipped.');
      return;
    }

    final trimmedUrl = googleScriptUrl.trim();
    if (trimmedUrl.isEmpty || trimmedUrl.contains(urlPlaceholder)) {
      throw StateError(
        'Catalog sync URL not configured. Pass the Apps Script Web App '
        'deploy URL via --dart-define=CATALOG_SYNC_URL=...',
      );
    }
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null ||
        !uri.hasScheme ||
        !(uri.isScheme('https') || uri.isScheme('http')) ||
        uri.host.isEmpty) {
      throw FormatException('Invalid catalog sync URL: $googleScriptUrl');
    }

    _syncInProgress = true;
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(requestTimeout);

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Catalog fetch failed with HTTP ${response.statusCode}',
          uri: uri,
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Catalog payload must be a JSON object keyed by sheet tab name.',
        );
      }

      await _dao.upsertOtaCatalog(decoded);
      _lastSyncAt = DateTime.now();
      debugPrint('[CatalogSync] OTA catalog merged at $_lastSyncAt.');
    } finally {
      _syncInProgress = false;
    }
  }

  /// Only closes the HTTP client when this service created it itself; a
  /// client injected from Riverpod is disposed by its own provider.
  void dispose() {
    if (_ownsClient) _client.close();
  }
}
