import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ai/document_ai_service.dart';
import '../config/app_configuration.dart';
import '../config/secure_config_service.dart';
import '../database/daos/clinical_dao.dart';
import '../database/daos/clinical_rule_dao.dart';
import '../database/daos/ingestion_inbox_dao.dart';
import '../database/daos/pharmacopeia_dao.dart';
import '../database/daos/cdss_dao.dart';
import '../database/local_database.dart';
import '../models/ai_extraction_result.dart';
import '../models/document_task.dart';
import '../services/clincom_audit_service.dart';
import '../services/app_updater_service.dart';
import '../services/extraction_pipeline_service.dart';
import '../services/omni_ingestion_service.dart';
import '../services/ambient_scribe_service.dart';
import '../sync/catalog_sync_service.dart';
import '../services/storage_retention_service.dart';
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
final patientByIdProvider = FutureProvider.family<Patient?, String>(
  (ref, patientId) => ref.watch(clinicalDaoProvider).findPatient(patientId),
);
final clinicalRuleDaoProvider = Provider<ClinicalRuleDao>(
  (ref) => ClinicalRuleDao(ref.watch(appDatabaseProvider)),
);
final ingestionInboxDaoProvider = Provider<IngestionInboxDao>(
  (ref) => IngestionInboxDao(ref.watch(appDatabaseProvider)),
);
final openIngestionInboxProvider = StreamProvider((ref) {
  return ref.watch(ingestionInboxDaoProvider).watchOpenItems();
});
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
  // configured their key in-app still hit "ClinCom capture is not configured",
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

final ambientScribeServiceProvider = Provider<AmbientScribeService>((ref) {
  final service = AmbientScribeService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final clinComAuditServiceProvider = Provider<ClinComAuditService>(
  (ref) => ClinComAuditService(
    clinicalDao: ref.watch(clinicalDaoProvider),
    aiService: ref.watch(documentAiServiceProvider),
  ),
);

final extractionPipelineProvider = Provider<ExtractionPipelineService>((ref) {
  final service = ExtractionPipelineService(
    ref.watch(documentAiServiceProvider),
    historicalAssociationsLoader: () =>
        ref.read(clinicalDaoProvider).getTopProblemAssociations(limit: 50),
  );
  ref.onDispose(service.close);
  return service;
});

/// Sprint 28 — the unified omni-ingestion engine. All capture entry points
/// (scribe, scan, PDF, paste) route through here for local-first POMR
/// normalization before hitting the review queue.
final omniIngestionServiceProvider = Provider<OmniIngestionService>((ref) {
  return OmniIngestionService(
    aiService: ref.watch(documentAiServiceProvider),
    pipeline: ref.watch(extractionPipelineProvider),
    ruleDao: ref.watch(clinicalRuleDaoProvider),
    cdssDao: ref.watch(cdssDaoProvider),
    database: ref.watch(appDatabaseProvider),
  );
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

/// Sprint 27 — one-shot AI failure notice for the Encounter UI.
///
/// Mirrors [offlineNoticeProvider]: services that cannot show UI themselves
/// (e.g. the clinical rule guardian's async AI calls) publish here, and the
/// Encounter screen listens and raises a non-blocking SnackBar. A rogue
/// legacy parameter that slips through as a 400/500 must degrade to a toast,
/// never a crash of the Encounter UI.
final aiErrorNoticeProvider = NotifierProvider<AiErrorNoticeNotifier, String?>(
  AiErrorNoticeNotifier.new,
);

class AiErrorNoticeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) => state = message;
  void clear() => state = null;
}

/// Task holder for the review / Edit Mode screen.
///
/// Extraction itself now runs through `liveIngestionProvider` →
/// `IngestionOrchestrator`; this notifier only holds saved records opened for
/// editing and legacy inbox items awaiting review or retry.
class BatchExtractionNotifier extends Notifier<List<DocumentTask>> {
  bool _disposed = false;
  bool _inboxRestored = false;

  @override
  List<DocumentTask> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const [];
  }

  Future<void> restoreInbox() async {
    if (_inboxRestored || _disposed) return;
    await _restoreInbox();
    _inboxRestored = true;
  }

  Future<void> _restoreInbox() async {
    try {
      final items = await ref.read(ingestionInboxDaoProvider).getOpenItems();
      if (_disposed) return;
      final restored = <DocumentTask>[];
      final currentTasks = {for (final task in state) task.id: task};
      for (final item in items) {
        if (item.status == 'processing' &&
            currentTasks[item.id]?.isInProgress == true) {
          continue;
        }
        final text = item.payloadType == 'text' || item.payloadType == 'audio';
        AiExtractionResult? extraction;
        if (item.status == 'ready_for_review' && item.extractedJson != null) {
          final decoded = jsonDecode(item.extractedJson!);
          if (decoded is! Map) {
            throw FormatException('Invalid saved extraction for ${item.id}.');
          }
          extraction = AiExtractionResult.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
        final file = item.filePath == null ? null : File(item.filePath!);
        final stillProcessing = item.status == 'processing';
        restored.add(
          DocumentTask(
            id: item.id,
            originalFile: file,
            isTextInput: text,
            isAmbientAudio: item.payloadType == 'audio',
            useOmniIngestion: true,
            status: item.status == 'ready_for_review'
                ? ExtractionStatus.readyForReview
                : ExtractionStatus.error,
            extractedData: extraction,
            source: text ? ExtractionSource.text : ExtractionSource.unknown,
            rawOcrText: item.rawInput,
            errorMessage: item.errorMessage,
          ),
        );
        if (stillProcessing) {
          await ref
              .read(ingestionInboxDaoProvider)
              .markError(
                item.id,
                'Processing was interrupted. Retry this item to continue.',
              );
          restored[restored.length - 1] = restored.last.copyWith(
            status: ExtractionStatus.error,
            errorMessage:
                'Processing was interrupted. Retry this item to continue.',
          );
        }
      }
      if (_disposed) return;
      final knownIds = {for (final task in state) task.id};
      state = [
        ...state,
        for (final task in restored)
          if (!knownIds.contains(task.id)) task,
      ];
    } catch (error, stackTrace) {
      debugPrint(
        '[ClinCom] Could not restore ingestion inbox: $error\n$stackTrace',
      );
      rethrow;
    }
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

  /// Returns a document already saved from these EXACT image bytes, if any.
  ///
  /// Sprint 17 — absolute deduplication. Returning a duplicate means the
  /// pipeline never runs OCR and never spends an API call; the caller routes
  /// the clinician straight into Edit Mode for the record that already exists.
  ///
  /// A hash failure is swallowed: proceeding may create one duplicate record,
  /// which is strictly better than refusing to open a document at the bedside.
  Future<DocumentRegistry?> findDuplicate(File file) async {
    try {
      final hash = await ClinicalDao.hashFile(file);
      return await ref.read(clinicalDaoProvider).findDocumentByImageHash(hash);
    } catch (error) {
      debugPrint('[ClinCom] Deduplication check skipped: $error');
      return null;
    }
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  /// Discards every queued document (used by "start over" affordances).
  void clear() {
    state = const [];
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
    // Sprint 16 — Smart data retention. Fire-and-forget on startup so a sweep of
    // years-old scans never delays the clinician reaching the dashboard. Only
    // image *files* are touched: no database row is deleted and nothing is
    // enqueued, so this cannot interfere with the offline sync queue.
    unawaited(() async {
      try {
        final pruned = await StorageRetentionService(
          ref.read(appDatabaseProvider),
        ).pruneOldImages();
        if (pruned > 0) {
          debugPrint('[AppStatus] Pruned $pruned old document image(s).');
        }
      } catch (error) {
        debugPrint('[AppStatus] Image retention sweep skipped: $error');
      }
    }());
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
