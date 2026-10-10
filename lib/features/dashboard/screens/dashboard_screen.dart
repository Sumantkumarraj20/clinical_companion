import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/app_updater_service.dart';
import '../../ingestion/widgets/omni_ingestion_sheet.dart';
import '../widgets/update_download_banner.dart';

/// Sprint 8 — CI/CD & In-App Binary Updates.
///
/// Fires one silent GitHub release probe per session (plain, cached
/// `FutureProvider`). [AppUpdaterService.checkForUpdates] swallows every
/// network/parse failure and resolves `null`, so offline starts simply
/// resolve with "no update" and the dashboard never waits on the network.
final appUpdateCheckProvider = FutureProvider<AppUpdateInfo?>(
  (ref) => ref.watch(appUpdaterServiceProvider).checkForUpdateInfo(),
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appStatusProvider);
    final pending = ref.watch(pendingInvestigationsProvider);
    final notes = ref.watch(todayPatientNotesProvider);
    return Scaffold(
      // Sprint 28 — single unified entry point for ALL clinical data.
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'omni-ingestion-dashboard',
        tooltip: 'Add Clinical Data',
        onPressed: () => showOmniIngestionSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Clinical Data'),
      ),
      appBar: AppBar(
        title: const Text('Clinical dashboard'),
        actions: [
          IconButton(
            tooltip: 'Synchronize',
            onPressed: status.syncStatus == SyncStatus.syncing
                ? null
                : () => ref.read(appStatusProvider.notifier).synchronize(),
            icon: status.syncStatus == SyncStatus.syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                avatar: Icon(
                  status.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  size: 18,
                ),
                label: Text(status.isOnline ? 'Online' : 'Offline'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const _UpdateBanner(),
          const _IngestionInboxBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Good ${_dayPart()},',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  status.isOnline
                      ? 'Start the next clinical action in one tap.'
                      : 'Offline mode: local records remain safe and ready to sync.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth > 700
                        ? (constraints.maxWidth - 24) / 3
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricCard(
                          width: width,
                          label: 'Pending investigations',
                          value: pending.asData?.value.length.toString() ?? '—',
                          icon: Icons.science,
                          color: Colors.indigo,
                        ),
                        _MetricCard(
                          width: width,
                          label: 'Notes today',
                          value: notes.asData?.value.length.toString() ?? '—',
                          icon: Icons.note_alt,
                          color: Colors.teal,
                        ),
                        _MetricCard(
                          width: width,
                          label: 'Sync status',
                          value: _syncLabel(status.syncStatus),
                          icon: Icons.sync,
                          color: Colors.blue,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go(
                            '/patients',
                            extra: const {'opdFlow': true},
                          ),
                          icon: const Icon(Icons.medical_services_outlined),
                          label: const Text('Start OPD consult'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/ward-dashboard'),
                          icon: const Icon(Icons.local_hospital_outlined),
                          label: const Text('Ward round'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/research'),
                          icon: const Icon(Icons.file_download),
                          label: const Text('Research export'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/wiki'),
                          icon: const Icon(Icons.menu_book),
                          label: const Text('Second Memory'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (status.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    status.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _syncLabel(SyncStatus value) => switch (value) {
    SyncStatus.idle => 'Ready',
    SyncStatus.syncing => 'Syncing',
    SyncStatus.error => 'Error',
  };

  String _dayPart() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(30),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(label),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngestionInboxBanner extends ConsumerStatefulWidget {
  const _IngestionInboxBanner();

  @override
  ConsumerState<_IngestionInboxBanner> createState() =>
      _IngestionInboxBannerState();
}

class _IngestionInboxBannerState extends ConsumerState<_IngestionInboxBanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_restoreInbox());
    });
  }

  Future<void> _restoreInbox() async {
    try {
      await ref.read(batchExtractionProvider.notifier).restoreInbox();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not restore saved clinical data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(openIngestionInboxProvider).asData?.value;
    if (inbox == null || inbox.isEmpty) return const SizedBox.shrink();

    final readyCount = inbox
        .where((item) => item.status == 'ready_for_review')
        .length;
    final processingCount = inbox
        .where((item) => item.status == 'processing')
        .length;
    final errorCount = inbox.where((item) => item.status == 'error').length;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (processingCount > 0)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                errorCount > 0
                    ? Icons.error_outline
                    : Icons.fact_check_outlined,
                color: errorCount > 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                [
                  if (processingCount > 0)
                    '$processingCount item${processingCount == 1 ? '' : 's'} processing',
                  if (readyCount > 0 && processingCount == 0)
                    '$readyCount ready for review',
                  if (errorCount > 0 && processingCount == 0)
                    '$errorCount need${errorCount == 1 ? 's' : ''} retry',
                ].join(' · '),
              ),
            ),
            if (readyCount > 0)
              TextButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(batchExtractionProvider.notifier)
                        .restoreInbox();
                    if (context.mounted) {
                      context.push('/adaptive-review');
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not open saved clinical data: $error',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Review'),
              ),
            if (errorCount > 0)
              TextButton(
                onPressed: () async {
                  final notifier = ref.read(batchExtractionProvider.notifier);
                  try {
                    await notifier.restoreInbox();
                    for (final item in inbox.where(
                      (entry) => entry.status == 'error',
                    )) {
                      await notifier.retryTask(item.id);
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not retry saved data: $error'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sprint 8 update alert pinned to the top of the dashboard.
///
/// Watches [appUpdateCheckProvider]; while a newer release APK URL is
/// available it renders a highly visible [MaterialBanner] that can be
/// dismissed with "Later". "Update Now" opens the release asset with
/// [LaunchMode.externalApplication], letting Android's download/installer
/// flow perform an in-place upgrade over the existing SQLite sandbox —
/// same package name and signing key, so patient data is preserved.
class _UpdateBanner extends ConsumerStatefulWidget {
  const _UpdateBanner();

  @override
  ConsumerState<_UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<_UpdateBanner> {
  bool _dismissed = false;

  Future<void> _startUpdate(AppUpdateInfo update) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      final opened = await launchUrl(
        Uri.parse(update.releaseUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the release page.')),
        );
      }
      return;
    }

    // Sprint 14.5 — no modal. The download now runs in a provider-backed banner
    // so the clinician can keep working; the banner stays visible with live
    // progress until the installer launches.
    ref.read(updateDownloadProvider.notifier).start(update.apkUrl);
  }

  @override
  Widget build(BuildContext context) {
    // Resolves to null while loading, when up to date, or when the check
    // failed silently (offline) — the banner simply stays hidden. Once a
    // download is in flight this renders progress instead of the prompt, so
    // navigating away and back never loses the running transfer.
    final update = ref.watch(appUpdateCheckProvider).asData?.value;
    final downloadState = ref.watch(updateDownloadProvider);

    if (update != null &&
        (downloadState is UpdateDownloading || downloadState is UpdateFailed)) {
      return UpdateProgressBanner(apkUrl: update.apkUrl);
    }
    if (downloadState is UpdateInstalling) return const SizedBox.shrink();

    if (_dismissed) return const SizedBox.shrink();
    if (update == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return MaterialBanner(
      backgroundColor: colors.secondaryContainer,
      leading: Icon(Icons.system_update, color: colors.onSecondaryContainer),
      content: Text(
        '🚀 Update v${update.remoteVersion} Available '
        '(Current: v${update.localVersion})',
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _startUpdate(update),
          child: const Text('Update Now'),
        ),
        TextButton(
          onPressed: () => setState(() => _dismissed = true),
          child: const Text('Later'),
        ),
      ],
    );
  }
}
