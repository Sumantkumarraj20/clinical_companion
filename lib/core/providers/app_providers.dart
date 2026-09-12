import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ai/document_ai_service.dart';
import '../cds/decision_support_engine.dart';
import '../config/app_configuration.dart';
import '../database/daos/clinical_dao.dart';
import '../database/daos/pharmacopeia_dao.dart';
import '../database/daos/cdss_dao.dart';
import '../database/local_database.dart';
import '../models/ai_extraction_result.dart';
import '../models/document_task.dart';
import '../services/extraction_pipeline_service.dart';
import '../sync/sync_service.dart';
import '../../features/billing/services/clinical_coding_service.dart';

final appConfigurationProvider =
    NotifierProvider<AppConfigurationNotifier, AppConfiguration>(
      AppConfigurationNotifier.new,
    );

class AppConfigurationNotifier extends Notifier<AppConfiguration> {
  AppConfigurationNotifier([this.initialConfiguration]);

  final AppConfiguration? initialConfiguration;

  @override
  AppConfiguration build() =>
      initialConfiguration ?? AppConfiguration.fromEnvironment();

  void setConfiguration(AppConfiguration configuration) =>
      state = configuration;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) => ref.watch(appConfigurationProvider).hasSupabase
      ? Supabase.instance.client
      : null,
);

final clinicalDaoProvider = Provider<ClinicalDao>(
  (ref) => ClinicalDao(
    ref.watch(appDatabaseProvider),
    defaultOwnerId: ref.watch(appConfigurationProvider).ownerId,
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
// AI & EXTRACTION PIPELINE PROVIDERS
// ==========================================

final documentAiServiceProvider = Provider<DocumentAiService>((ref) {
  // Pulls API key from build environment variables or remote config
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  return DocumentAiService(apiKey: apiKey);
});

final extractionPipelineProvider = Provider<ExtractionPipelineService>((ref) {
  return ExtractionPipelineService(ref.watch(documentAiServiceProvider));
});

final batchExtractionProvider =
    NotifierProvider<BatchExtractionNotifier, List<DocumentTask>>(
      BatchExtractionNotifier.new,
    );

class BatchExtractionNotifier extends Notifier<List<DocumentTask>> {
  @override
  List<DocumentTask> build() => [];

  void addFiles(List<File> files) {
    final newTasks = files
        .map(
          (f) => DocumentTask(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            originalFile: f,
          ),
        )
        .toList();

    state = [...state, ...newTasks];
    _processQueue();
  }

  Future<void> _processQueue() async {
    final pipeline = ref.read(extractionPipelineProvider);

    for (int i = 0; i < state.length; i++) {
      final task = state[i];
      if (task.status != ExtractionStatus.pending) continue;

      _updateTask(task.id, status: ExtractionStatus.processingOcr);

      try {
        // Peek raw OCR text first so we can record whether AI fallback
        // was even needed.
        final rawText = await pipeline.recognizeRawText(task.originalFile);
        final needsAi = rawText.trim().length < 50;
        if (needsAi) {
          _updateTask(
            task.id,
            status: ExtractionStatus.processingAiFallback,
            rawOcrText: rawText,
          );
        } else {
          _updateTask(task.id, rawOcrText: rawText);
        }

        final extraction =
            await pipeline.processDocumentWithProvenance(task.originalFile);
        _updateTask(
          task.id,
          status: ExtractionStatus.readyForReview,
          data: extraction.result,
          source: extraction.taskSource,
          rawOcrText: rawText,
        );
      } catch (e) {
        _updateTask(task.id, status: ExtractionStatus.error);
      }
    }
  }

  void _updateTask(
    String id, {
    ExtractionStatus? status,
    AiExtractionResult? data,
    ExtractionSource? source,
    String? rawOcrText,
  }) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(
            status: status ?? task.status,
            extractedData: data ?? task.extractedData,
            source: source ?? task.source,
            rawOcrText: rawOcrText ?? task.rawOcrText,
          )
        else
          task,
    ];
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

// ==========================================
// STAGED ORDERS (CDSS one-tap order bundles)
// ==========================================

/// A staged order waiting to be committed to the encounter plan.
/// Deduplicated by [label] (case-insensitive) inside the notifier.
class PendingOrder {
  const PendingOrder({
    required this.label,
    this.kind = OrderProposalKind.lab,
    this.details,
    this.source = 'cdss',
  });

  final String label;
  final OrderProposalKind kind;
  final String? details;
  final String source;

  PendingOrder copyWith({
    String? label,
    OrderProposalKind? kind,
    String? details,
    String? source,
  }) => PendingOrder(
    label: label ?? this.label,
    kind: kind ?? this.kind,
    details: details ?? this.details,
    source: source ?? this.source,
  );
}

final stagedOrdersProvider =
    NotifierProvider<StagedOrdersNotifier, List<PendingOrder>>(
      StagedOrdersNotifier.new,
    );

class StagedOrdersNotifier extends Notifier<List<PendingOrder>> {
  @override
  List<PendingOrder> build() => const [];

  bool _same(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  void addProposal(OrderProposal proposal, {String source = 'cdss'}) {
    if (state.any((o) => _same(o.label, proposal.label))) return;
    state = [
      ...state,
      PendingOrder(
        label: proposal.label,
        kind: proposal.kind,
        details: proposal.details,
        source: source,
      ),
    ];
  }

  void addAllProposals(
    List<OrderProposal> proposals, {
    String source = 'cdss',
  }) {
    final existing = state.map((o) => o.label.trim().toLowerCase()).toSet();
    final fresh = <PendingOrder>[];
    for (final p in proposals) {
      if (existing.add(p.label.trim().toLowerCase())) {
        fresh.add(
          PendingOrder(
            label: p.label,
            kind: p.kind,
            details: p.details,
            source: source,
          ),
        );
      }
    }
    if (fresh.isNotEmpty) state = [...state, ...fresh];
  }

  void addManual(String label, {String source = 'manual'}) {
    final term = label.trim();
    if (term.isEmpty || state.any((o) => _same(o.label, term))) return;
    state = [...state, PendingOrder(label: term, source: source)];
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state..removeAt(index)];
  }

  void removeByLabel(String label) {
    state = state.where((o) => !_same(o.label, label)).toList();
  }

  void clear() => state = const [];

  /// Persist staged terms into the self-learning catalog so the next
  /// 2-letter search surfaces frequent items instantly.
  Future<void> finalizeOrders({String category = 'medication'}) async {
    final dao = ref.read(clinicalDaoProvider);
    for (final order in state) {
      await dao.recordCatalogUsage(category: category, term: order.label);
    }
  }
}

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
