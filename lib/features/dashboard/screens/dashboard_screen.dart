import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Good ${_dayPart()},',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Keep your round notes current and synchronized.',
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
                    onPressed: () => context.go('/vitals'),
                    icon: const Icon(Icons.monitor_heart),
                    label: const Text('Record bedside vitals'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/patients'),
                    icon: const Icon(Icons.people_outline),
                    label: const Text('Patient registry'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/labs'),
                    icon: const Icon(Icons.science),
                    label: const Text('Open lab tracker'),
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
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
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
