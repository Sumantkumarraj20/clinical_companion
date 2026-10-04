import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';
import '../widgets/post_op_day_badge.dart';

/// The "Today" workspace — the clinician's opening screen.
///
/// Four tabs, each backed by its own stream so one slow query never blocks
/// another: Ward Rounds, Pending Results, Follow-ups, Drafts.
///
/// Design stance: everything here is a *prompt to look*, never a claim about
/// what is clinically required. Counts help triage attention; no tab asserts
/// that a patient "needs" anything. Empty states say so plainly rather than
/// manufacturing urgency.
class TodayWorkspaceScreen extends ConsumerStatefulWidget {
  const TodayWorkspaceScreen({super.key});

  @override
  ConsumerState<TodayWorkspaceScreen> createState() =>
      _TodayWorkspaceScreenState();
}

class _TodayWorkspaceScreenState extends ConsumerState<TodayWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 4,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_greeting(today.hour), style: theme.textTheme.titleMedium),
            Text(
              '${_weekday(today.weekday)}, ${today.day} '
              '${_month(today.month)} ${today.year}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _WorkspaceTabs(controller: _tabController),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _WardRoundsTab(),
                _PendingResultsTab(),
                _FollowUpsTab(),
                _DraftsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting(int hour) => hour < 12
      ? 'Good morning'
      : hour < 17
      ? 'Good afternoon'
      : 'Good evening';

  static String _weekday(int day) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][day - 1];

  static String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}

/// Tab bar with a live count per section, so the clinician can see where the
/// work sits before switching.
///
/// Each count comes from its own AsyncValue: an error in one stream shows as
/// "no count" rather than blanking the other three tabs.
class _WorkspaceTabs extends ConsumerWidget {
  const _WorkspaceTabs({required this.controller});

  /// Shared with the [TabBarView] so taps and swipes stay in sync. Without it
  /// the TabBar throws "No TabController" — there is no DefaultTabController
  /// above it in this layout.
  final TabController controller;

  static int _count(AsyncValue<List<Object>> value) =>
      value.maybeWhen(data: (rows) => rows.length, orElse: () => -1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wards = _count(ref.watch(wardRoundsProvider));
    final results = _count(ref.watch(outstandingInvestigationsProvider));
    final followUps = _count(ref.watch(smartFollowUpsProvider));
    final drafts = _count(ref.watch(pendingNotesProvider));

    Widget tab(String label, int n) {
      return Tab(
        height: 52,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (n > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$n',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        tab('Ward Rounds', wards),
        tab('Pending Results', results),
        tab('Follow-ups', followUps),
        tab('Drafts', drafts),
      ],
    );
  }
}

/// Shared loading/error/empty scaffolding so all four tabs behave identically.
class _TabScaffold extends StatelessWidget {
  const _TabScaffold({
    required this.value,
    required this.itemBuilder,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final AsyncValue<List<Object>> value;
  final Widget Function(BuildContext, int) itemBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyBody;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load',
        body: '$error',
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return _EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            body: emptyBody,
          );
        }
        return ListView.builder(
          // AlwaysScrollable keeps scrolling alive even on short lists; the
          // large bottom padding clears the nav bar so the final card is
          // never trapped underneath it.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: rows.length,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Patient card with an optional live Post-Op Day badge.
class _PatientCard extends ConsumerWidget {
  const _PatientCard({
    required this.patientId,
    required this.name,
    this.patient,
    this.subtitle,
    this.trailing,
  });

  final String patientId;
  final String name;

  /// Passed as route `extra` because `/patients/:id` resolves the timeline from
  /// the object, not the path id. Null means the card cannot deep-link.
  final Patient? patient;

  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pod = ref.watch(postOpDayProvider(patientId)).value;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: patient == null
            ? null
            : () => context.go(
                '/patients/${Uri.encodeComponent(patientId)}',
                extra: patient,
              ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    // Null while loading, which collapses the badge to zero
                    // size instead of flashing a layout jump.
                    if (pod != null) ...[
                      const SizedBox(height: 8),
                      PostOpDayBadge(postOpDay: pod),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _WardRoundsTab extends ConsumerWidget {
  const _WardRoundsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wards = ref.watch(wardRoundsProvider);
    return _TabScaffold(
      value: wards,
      itemBuilder: (context, index) {
        final row = wards.value![index];
        final location = [
          row.wardName,
          if (row.bedNumber != null && row.bedNumber!.trim().isNotEmpty)
            'Bed ${row.bedNumber}',
        ].whereType<String>().join(' · ');
        final age = DateTimeUtils.ageOn(
          row.patient.dateOfBirth,
          DateTime.now(),
        );

        return _PatientCard(
          patientId: row.patient.id,
          patient: row.patient,
          name: row.patient.fullName,
          subtitle: [
            if (location.isNotEmpty) location,
            if (row.mrn != null && row.mrn!.trim().isNotEmpty) 'MRN ${row.mrn}',
            if (age != null) '$age yrs',
            if (row.patient.gender != null) row.patient.gender!,
          ].join(' · '),
        );
      },
      emptyIcon: Icons.bed_outlined,
      emptyTitle: 'No admitted patients',
      emptyBody:
          'Patients marked "currently admitted" in their demographics appear '
          'here as a bed board.',
    );
  }
}

class _PendingResultsTab extends ConsumerWidget {
  const _PendingResultsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(outstandingInvestigationsProvider);

    return _TabScaffold(
      value: results,
      itemBuilder: (context, index) {
        final row = results.value![index];
        final days = DateTime.now()
            .difference(row.investigation.orderedAt.toLocal())
            .inDays;

        return _PatientCard(
          patientId: row.patient.id,
          patient: row.patient,
          name: row.patient.fullName,
          subtitle: row.investigation.testName,
          // Age is informational only — it helps a clinician prioritise which
          // pending result to chase. It is not a clinical threshold.
          trailing: days > 0
              ? Tooltip(
                  message: 'Ordered $days day${days == 1 ? '' : 's'} ago',
                  child: Chip(
                    label: Text('${days}d'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                )
              : null,
        );
      },
      emptyIcon: Icons.task_alt_outlined,
      emptyTitle: 'Nothing pending',
      emptyBody: 'Investigations appear here until a result is recorded.',
    );
  }
}

class _FollowUpsTab extends ConsumerWidget {
  const _FollowUpsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followUps = ref.watch(smartFollowUpsProvider);

    return _TabScaffold(
      value: followUps,
      itemBuilder: (context, index) {
        final row = followUps.value![index];
        return _PatientCard(
          patientId: row.patient.id,
          patient: row.patient,
          name: row.patient.fullName,
          subtitle: row.lastSeenAt == null
              ? 'No prior encounter recorded'
              : 'Last seen ${DateTimeUtils.relative(row.lastSeenAt!)}',
        );
      },
      emptyIcon: Icons.event_available_outlined,
      emptyTitle: 'No follow-up candidates',
      emptyBody:
          'Patients with a recent procedure or an unresolved problem are '
          'surfaced here for your review.',
    );
  }
}

class _DraftsTab extends ConsumerWidget {
  const _DraftsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(pendingNotesProvider);
    final theme = Theme.of(context);

    return _TabScaffold(
      value: drafts,
      itemBuilder: (context, index) {
        final row = drafts.value![index];
        final summary = row.encounter.chiefComplaints?.trim();

        return _PatientCard(
          patientId: row.patient.id,
          patient: row.patient,
          name: row.patient.fullName,
          subtitle: (summary == null || summary.isEmpty)
              ? row.encounter.encounterType
              : summary,
          trailing: Chip(
            label: Text(
              DateTimeUtils.relative(row.encounter.updatedAt),
              style: theme.textTheme.labelSmall,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        );
      },
      emptyIcon: Icons.edit_note_outlined,
      emptyTitle: 'No unsaved drafts',
      emptyBody: 'Encounters you save without signing off appear here.',
    );
  }
}
