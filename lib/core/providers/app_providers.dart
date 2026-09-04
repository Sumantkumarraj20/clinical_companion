import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_configuration.dart';
import '../database/daos/clinical_dao.dart';
import '../database/daos/pharmacopeia_dao.dart';
import '../database/daos/cdss_dao.dart';
import '../database/local_database.dart';
import '../sync/sync_service.dart';

final appConfigurationProvider = Provider<AppConfiguration>(
  (_) => AppConfiguration.fromEnvironment(),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Null means this build deliberately runs as a local-only application.
final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) => ref.watch(appConfigurationProvider).hasSupabase
      ? Supabase.instance.client
      : null,
);

final clinicalDaoProvider = Provider<ClinicalDao>(
  (ref) => ClinicalDao(ref.watch(appDatabaseProvider)),
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
  (ref) => ref.watch(clinicalDaoProvider).watchNotesForDay(DateTime.now()),
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

final wikiEntriesProvider = StreamProvider<List<WikiEntry>>(
  (ref) => ref
      .watch(clinicalDaoProvider)
      .watchWikiEntries(
        query: ref.watch(wikiSearchQueryProvider),
        ownerId: ref.watch(currentOwnerIdProvider),
      ),
);
