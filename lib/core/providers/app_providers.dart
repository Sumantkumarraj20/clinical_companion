import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ai/document_ai_service.dart';
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
        final data = await pipeline.processDocument(task.originalFile);
        _updateTask(
          task.id,
          status: ExtractionStatus.readyForReview,
          data: data,
        );
      } catch (e) {
        _updateTask(task.id, status: ExtractionStatus.error);
      }
    }
  }

  void _updateTask(
    String id, {
    required ExtractionStatus status,
    AiExtractionResult? data,
  }) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(status: status, extractedData: data)
        else
          task,
    ];
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
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
