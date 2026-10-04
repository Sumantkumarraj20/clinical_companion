import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../ai/document_ai_service.dart';
import '../config/app_configuration.dart';
import '../config/secure_config_service.dart';
import '../database/daos/clinical_dao.dart';
import '../database/daos/pharmacopeia_dao.dart';
import '../database/daos/cdss_dao.dart';
import '../database/local_database.dart';
import '../models/ai_extraction_result.dart';
import '../models/document_task.dart';
import '../services/app_updater_service.dart';
import '../services/extraction_pipeline_service.dart';
import '../sync/catalog_sync_service.dart';
import '../sync/sync_service.dart';
import '../../features/billing/services/clinical_coding_service.dart';

// The staged-order tray moved to the bedside feature in Sprint 10 (it owns the
// Drift mapping for prescription/investigation orders). Re-exported so the
// many existing `app_providers.dart` importers keep resolving the symbols.
export '../../features/bedside/providers/staged_orders_provider.dart'
    show PendingOrder, StagedOrdersNotifier, stagedOrdersProvider;

final appConfigurationProvider =
    NotifierProvider<AppConfigurationNotifier, AppConfiguration>(
      AppConfigurationNotifier.new,
    );

final secureConfigServiceProvider = Provider<SecureConfigService>(
  (_) => SecureConfigService(),
);

class AppConfigurationNotifier extends Notifier<AppConfiguration> {
  AppConfigurationNotifier([this.initialConfiguration]);

  final AppConfiguration? initialConfiguration;

  @override
  AppConfiguration build() =>
      initialConfiguration ??
      const AppConfiguration(
        supabaseUrl: '',
        supabasePublishableKey: '',
        ownerId: 'local-practitioner',
      );

  void setConfiguration(AppConfiguration configuration) =>
      state = configuration;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final hasSupabase = ref.watch(
    appConfigurationProvider.select(
      (configuration) => configuration.hasSupabase,
    ),
  );
  return hasSupabase ? Supabase.instance.client : null;
});

final clinicalDaoProvider = Provider<ClinicalDao>(
  (ref) => ClinicalDao(
    ref.watch(appDatabaseProvider),
    defaultOwnerId: ref.watch(
      appConfigurationProvider.select((configuration) => configuration.ownerId),
    ),
  ),
);
final pharmacopeiaDaoProvider = Provider<PharmacopeiaDao>(
  (ref) => PharmacopeiaDao(ref.watch(appDatabaseProvider)),
);
final cdssDaoProvider = Provider<CdssDao>(
  (ref) => CdssDao(ref.watch(appDatabaseProvider)),
);

final syncServiceProvider = Provider<SyncService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  final service = SyncService(ref.watch(clinicalDaoProvider), client)
    ..startPeriodic();
  ref.onDispose(service.dispose);
  return service;
});

// ==========================================
// OTA CATALOG SYNC (Sprint 7)
// ==========================================

/// Google Apps Script Web App publishing the nightly pharmacopeia tabs.
/// Ships with the proven production endpoint; override at build time:
/// --dart-define=CATALOG_SYNC_URL=https://script...
const String catalogScriptUrl = String.fromEnvironment(
  'CATALOG_SYNC_URL',
  defaultValue: CatalogSyncService.defaultCatalogScriptUrl,
);

final catalogHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final catalogSyncProvider = Provider<CatalogSyncService>((ref) {
  return CatalogSyncService(
    pharmacopeiaDao: ref.watch(pharmacopeiaDaoProvider),
    httpClient: ref.watch(catalogHttpClientProvider),
  );
});

// ==========================================
// IN-APP BINARY UPDATES (Sprint 8)
// ==========================================

/// GitHub Release update probe behind the dashboard's MaterialBanner.
/// `checkForUpdate()` is fail-soft (never throws, resolves `null` when
/// offline), so watching it can never block or crash the dashboard.
final appUpdaterServiceProvider = Provider<AppUpdaterService>((ref) {
  final service = AppUpdaterService();
  ref.onDispose(service.dispose);
  return service;
});

// ==========================================
// AI & EXTRACTION PIPELINE PROVIDERS
// ==========================================

final documentAiServiceProvider = Provider<DocumentAiService>((ref) {
  // The key saved in Settings → Configuration (secure storage) is the runtime
  // source of truth; the build-time GEMINI_API_KEY define is only a fallback
  // for CI/preview builds. Reading *only* the env var meant every user who
  // configured their key in-app still hit "AI capture is not configured",
  // which is exactly the messy-document path that needs Gemini the most.
  final runtimeKey = ref
      .watch(
        appConfigurationProvider.select(
          (configuration) => configuration.geminiApiKey,
        ),
      )
      .trim();
  const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  final apiKey = runtimeKey.isNotEmpty ? runtimeKey : envKey;
  return DocumentAiService(apiKey: apiKey);
});

final extractionPipelineProvider = Provider<ExtractionPipelineService>((ref) {
  final service = ExtractionPipelineService(
    ref.watch(documentAiServiceProvider),
  );
  ref.onDispose(service.close);
  return service;
});

final batchExtractionProvider =
    NotifierProvider<BatchExtractionNotifier, List<DocumentTask>>(
      BatchExtractionNotifier.new,
    );

/// A one-shot UI event set only when a cloud extraction has been safely
/// retained locally after a network failure.
final offlineNoticeProvider = NotifierProvider<OfflineNoticeNotifier, String?>(
  OfflineNoticeNotifier.new,
);

class OfflineNoticeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) => state = message;
  void clear() => state = null;
}

/// FIFO extraction queue shared by the capture and review screens.
///
/// Adding files flips each task through `processingOcr` → (optionally)
/// `processingAiFallback` → `readyForReview`/`error`. The review screen simply
/// watches this list and renders whatever stage each document is at, so OCR
/// and cloud refinement continue in the background while the clinician
/// reviews the pages that are already done.
class BatchExtractionNotifier extends Notifier<List<DocumentTask>> {
  final _ids = const Uuid();

  /// Guards against two drains racing over the same pending task.
  bool _draining = false;
  bool _disposed = false;

  @override
  List<DocumentTask> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const [];
  }

  /// Sprint 14.5 (Edit Mode) — replaces the queue with a single pre-built
  /// task and, critically, does **not** kick the extraction pipeline.
  ///
  /// [documentedAt] is passed through so the review editor seeds its date/time
  /// pickers from the document's own timestamp rather than from "now" —
  /// otherwise simply correcting a typo would silently re-date an old report
  /// to today, which is the exact bug this whole sprint is fixing.
  void replaceWithSeed(DocumentTask task, {DateTime? documentedAt}) {
    state = [task];
    if (documentedAt != null) _seedDocumentedAt = documentedAt;
  }

  /// Date the current Edit Mode task represents, consumed once by the review
  /// screen. Null when the screen is in normal (scan queue) mode.
  DateTime? takeSeedDocumentedAt() {
    final value = _seedDocumentedAt;
    _seedDocumentedAt = null;
    return value;
  }

  DateTime? _seedDocumentedAt;

  /// Queue up one or more images. Re-adding an identical file path is a no-op
  /// so a double tap on the capture button cannot create duplicate tasks.
  void addFiles(List<File> files) {
    final seen = <String>{for (final task in state) task.originalFile.path};
    final newTasks = <DocumentTask>[];
    for (final file in files) {
      if (!seen.add(file.path)) continue;
      newTasks.add(DocumentTask(id: _ids.v4(), originalFile: file));
    }
    if (newTasks.isEmpty) return;
    state = [...state, ...newTasks];
    _kick();
  }

  /// Re-runs a task that finished in [ExtractionStatus.error].
  Future<void> retryTask(String id) async {
    final task = state.cast<DocumentTask?>().firstWhere(
      (candidate) => candidate?.id == id,
      orElse: () => null,
    );
    if (task == null || task.status != ExtractionStatus.error) return;
    _update(
      id,
      status: ExtractionStatus.pending,
      clearError: true,
      clearExtractedData: true,
    );
    await _drain();
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  /// Discards every queued document (used by "start over" affordances).
  void clear() {
    state = const [];
  }

  void _kick() {
    // Fire and forget: the queue reports progress through `state`, so callers
    // never need to await it.
    _drain();
  }

  Future<void> _drain() async {
    if (_draining || _disposed) return;
    _draining = true;
    try {
      while (true) {
        if (_disposed) return;
        final DocumentTask? next = state.cast<DocumentTask?>().firstWhere(
          (task) => task?.status == ExtractionStatus.pending,
          orElse: () => null,
        );
        if (next == null) break;
        await _runTask(next);
      }
    } finally {
      _draining = false;
    }
  }

  Future<void> _runTask(DocumentTask task) async {
    final pipeline = ref.read(extractionPipelineProvider);

    // ---- Stage 1: free on-device OCR -------------------------------------
    _update(task.id, status: ExtractionStatus.processingOcr, clearError: true);
    var rawText = '';
    try {
      rawText = await pipeline.recognizeRawText(task.originalFile);
    } catch (error) {
      _update(
        task.id,
        status: ExtractionStatus.error,
        errorMessage:
            'Local OCR could not read this image (${_short(error)}). '
            'Try re-capturing with better lighting.',
      );
      return;
    }
    _update(task.id, rawOcrText: rawText);

    // ---- Stage 2a: free regex parse --------------------------------------
    final normalizedText = await pipeline.normalizeOcrTextOffMain(rawText);
    final local = pipeline.parseLocalText(normalizedText);
    if (local != null) {
      _update(
        task.id,
        status: ExtractionStatus.readyForReview,
        data: local,
        source: ExtractionSource.local,
      );
      return;
    }

    // ---- Stage 2b: cloud refinement of a messy read ----------------------
    _update(task.id, status: ExtractionStatus.processingAiFallback);
    try {
      final extraction = await pipeline.refineWithAi(
        task.originalFile,
        rawText,
      );
      _update(
        task.id,
        status: ExtractionStatus.readyForReview,
        data: extraction.result,
        source: extraction.taskSource,
        rawOcrText: rawText,
      );
    } catch (error) {
      if (error is DocumentAiException &&
          error.type == DocumentAiErrorType.network) {
        await ref
            .read(clinicalDaoProvider)
            .enqueuePendingAiExtraction(
              taskId: task.id,
              imagePath: task.originalFile.path,
              rawOcrText: rawText,
            );
        ref
            .read(offlineNoticeProvider.notifier)
            .show('Offline: Saved locally. Will sync when connected.');
      }
      _update(
        task.id,
        status: ExtractionStatus.error,
        errorMessage: _describe(error),
      );
    }
  }

  static String _short(Object error) {
    final text = error.toString();
    return text.length > 140 ? '${text.substring(0, 140)}…' : text;
  }

  static String _describe(Object error) {
    if (error is DocumentAiException) return error.message;
    return _short(error);
  }

  void _update(
    String id, {
    ExtractionStatus? status,
    AiExtractionResult? data,
    ExtractionSource? source,
    String? rawOcrText,
    String? errorMessage,
    bool clearError = false,
    bool clearExtractedData = false,
  }) {
    if (_disposed) return;
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(
            status: status,
            extractedData: data,
            source: source,
            rawOcrText: rawOcrText,
            errorMessage: errorMessage,
            clearError: clearError,
            clearExtractedData: clearExtractedData,
          )
        else
          task,
    ];
  }
}

// ==========================================
// STAGED ORDERS (CDSS one-tap order bundles)
// ==========================================

// Definitions live in the bedside feature (Sprint 10) so the order tray owns
// its Drift mapping without `core` depending on feature code.

// ==========================================
// NETWORK & STATUS PROVIDERS
// ==========================================

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _hasConnection(await connectivity.checkConnectivity());
  await for (final change in connectivity.onConnectivityChanged) {
    yield _hasConnection(change);
  }
});

bool _hasConnection(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

enum SyncStatus { idle, syncing, error }

class AppStatusState {
  const AppStatusState({
    required this.isOnline,
    required this.syncStatus,
    this.errorMessage,
  });
  final bool isOnline;
  final SyncStatus syncStatus;
  final String? errorMessage;

  AppStatusState copyWith({
    bool? isOnline,
    SyncStatus? syncStatus,
    String? errorMessage,
    bool clearError = false,
  }) => AppStatusState(
    isOnline: isOnline ?? this.isOnline,
    syncStatus: syncStatus ?? this.syncStatus,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final appStatusProvider = NotifierProvider<AppStatus, AppStatusState>(
  AppStatus.new,
);

class AppStatus extends Notifier<AppStatusState> {
  @override
  AppStatusState build() {
    ref.watch(syncServiceProvider);
    ref.listen(connectivityProvider, (_, next) {
      state = state.copyWith(isOnline: next.asData?.value ?? false);
    });
    // Sprint 7 — OTA catalog sync: fire-and-forget the nightly Google Apps
    // Script merge as soon as the app opens and has connectivity. Runs
    // entirely off the UI isolate (async HTTP + Drift batch); failures are
    // logged silently so a broken sheet never blocks the clinician.
    unawaited(
      ref
          .read(catalogSyncProvider)
          .syncCatalogFromCloud(catalogScriptUrl)
          .catchError((Object error) {
            debugPrint('[AppStatus] OTA catalog sync skipped: $error');
          }),
    );
    return AppStatusState(
      isOnline: ref.watch(connectivityProvider).asData?.value ?? false,
      syncStatus: SyncStatus.idle,
    );
  }

  Future<void> synchronize() async {
    if (state.syncStatus == SyncStatus.syncing) return;
    final service = ref.read(syncServiceProvider);
    if (service == null) {
      state = state.copyWith(
        syncStatus: SyncStatus.error,
        errorMessage: 'Cloud sync is not configured for this build.',
      );
      return;
    }
    state = state.copyWith(syncStatus: SyncStatus.syncing, clearError: true);
    try {
      await service.sync();
      state = state.copyWith(syncStatus: SyncStatus.idle);
    } catch (error) {
      state = state.copyWith(
        syncStatus: SyncStatus.error,
        errorMessage: error.toString(),
      );
    }
  }
}

final pendingInvestigationsProvider =
    StreamProvider<List<PendingInvestigation>>(
      (ref) => ref
          .watch(clinicalDaoProvider)
          .watchPendingInvestigationsWithPatients(),
    );

final todayPatientNotesProvider = StreamProvider<List<ClinicalEncounter>>(
  (ref) =>
      ref.watch(clinicalDaoProvider).watchClinicalEncounters(DateTime.now()),
);

final wikiSearchQueryProvider = NotifierProvider<WikiSearchQuery, String>(
  WikiSearchQuery.new,
);

class WikiSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}

final currentOwnerIdProvider = Provider<String>(
  (ref) =>
      ref.watch(supabaseClientProvider)?.auth.currentUser?.id ??
      ref.watch(appConfigurationProvider).ownerId,
);

final wikiEntriesProvider = StreamProvider<List<PersonalWikiEntry>>(
  (ref) => ref
      .watch(clinicalDaoProvider)
      .watchWikiEntries(
        query: ref.watch(wikiSearchQueryProvider),
        ownerId: ref.watch(currentOwnerIdProvider),
      ),
);

final patientListProvider = StreamProvider(
  (ref) => ref.watch(clinicalDaoProvider).watchAllPatients(),
);

final clinicalCodingServiceProvider = Provider<ClinicalCodingService>((ref) {
  final service = ClinicalCodingService(ref.watch(clinicalDaoProvider));
  ref.onDispose(service.dispose);
  return service;
});

// ===========================================================================
// SPRINT 14 — "TODAY" WORKSPACE STREAMS
// ===========================================================================
// Each tab is its own StreamProvider so a slow or empty tab never blocks the
// others: the workspace renders whatever has arrived and fills in the rest.

final wardRoundsProvider = StreamProvider(
  (ref) => ref.watch(clinicalDaoProvider).watchActiveWardRounds(),
);

/// Every investigation still awaiting a result, not just today's.
///
/// The existing `pendingInvestigationsProvider` is scoped to the current
/// calendar day (it backs the lab tracker). A workspace tab has to answer
/// "what is outstanding?" across all days, so it gets its own stream rather
/// than silently showing only today's slice.
final outstandingInvestigationsProvider =
    StreamProvider<List<PendingInvestigation>>(
      (ref) => ref.watch(clinicalDaoProvider).watchOutstandingInvestigations(),
    );

final smartFollowUpsProvider = StreamProvider(
  (ref) => ref.watch(clinicalDaoProvider).watchSmartFollowUps(),
);

final pendingNotesProvider = StreamProvider(
  (ref) => ref.watch(clinicalDaoProvider).watchPendingNotes(),
);

/// Sprint 15 (Phase 2) — the universal patient timeline: five previously
/// separate stores merged into one reverse-chronological story.
final unifiedTimelineProvider =
    StreamProvider.family<List<TimelineEvent>, String>(
      (ref, patientId) =>
          ref.watch(clinicalDaoProvider).watchUnifiedTimeline(patientId),
    );

/// Post-operative day for a single patient. `autoDispose` matters here — the
/// ward-rounds list can hold dozens of cards, and each should drop its query
/// when scrolled away rather than pinning every patient's surgery record.
final postOpDayProvider = FutureProvider.autoDispose.family<int?, String>((
  ref,
  patientId,
) {
  return ref.watch(clinicalDaoProvider).getPostOpDay(patientId);
});
