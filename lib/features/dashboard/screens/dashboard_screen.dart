import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/update_download_banner.dart';

/// Sprint 8 — CI/CD & In-App Binary Updates.
///
/// Fires one silent GitHub release probe per session (plain, cached
/// `FutureProvider`). [AppUpdaterService.checkForUpdate] swallows every
/// network/parse failure and resolves `null`, so offline starts simply
/// resolve with "no update" and the dashboard never waits on the network.
final appUpdateCheckProvider = FutureProvider<String?>(
  (ref) => ref.watch(appUpdaterServiceProvider).checkForUpdate(),
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appStatusProvider);
    final pending = ref.watch(pendingInvestigationsProvider);
    final notes = ref.watch(todayPatientNotesProvider);
    return Scaffold(
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
                          onPressed: () => context.go('/smart-capture'),
                          icon: const Icon(Icons.document_scanner_outlined),
                          label: const Text('Scan clinical document'),
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

  void _startUpdate(String apkUrl) {
    // Sprint 14.5 — no modal. The download now runs in a provider-backed banner
    // so the clinician can keep working; the banner stays visible with live
    // progress until the installer launches.
    ref.read(updateDownloadProvider.notifier).start(apkUrl);
  }

  @override
  Widget build(BuildContext context) {
    // Resolves to null while loading, when up to date, or when the check
    // failed silently (offline) — the banner simply stays hidden. Once a
    // download is in flight this renders progress instead of the prompt, so
    // navigating away and back never loses the running transfer.
    final updateUrl = ref.watch(appUpdateCheckProvider).asData?.value;
    final downloading = ref.watch(updateDownloadProvider) is UpdateDownloading;

    if (downloading && updateUrl != null) {
      return UpdateProgressBanner(apkUrl: updateUrl);
    }

    if (_dismissed) return const SizedBox.shrink();
    if (updateUrl == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return MaterialBanner(
      backgroundColor: colors.secondaryContainer,
      leading: Icon(Icons.system_update, color: colors.onSecondaryContainer),
      content: Text(
        'Update Available: A new version of Clinical Companion is ready.',
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _startUpdate(updateUrl),
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
