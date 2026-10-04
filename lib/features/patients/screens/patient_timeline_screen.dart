
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cds/decision_support_engine.dart';
import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';
import '../../ingestion/screens/adaptive_review_screen.dart';
import '../../learning/widgets/reflection_entry_sheet.dart';
import '../../learning/widgets/timeline_event_card.dart';
import '../widgets/cohort_tagger.dart';
import '../widgets/timeline_feed_model.dart';

/// Longitudinal patient view, restructured as a Material 3 feed (Sprint 11).
///
/// The layout follows the reading order of a ward round:
///
/// 1. a collapsing [SliverAppBar] with identity and — critically — CDSS /
///    allergy banners that stay pinned while scrolling;
/// 2. active POMR problems as a horizontal chip row that filters the feed;
/// 3. one merged chronological feed of encounters, labs, procedures and
///    scanned documents.
class PatientTimelineScreen extends ConsumerStatefulWidget {
  const PatientTimelineScreen({required this.patient, this.heroTag, super.key});

  final Patient patient;
  final String? heroTag;

  @override
  ConsumerState<PatientTimelineScreen> createState() =>
      _PatientTimelineScreenState();
}

class _PatientTimelineScreenState extends ConsumerState<PatientTimelineScreen> {
  late Future<PatientTimelineBundle> _bundle;

  /// Last resolved bundle, cached so a timeline card tap can look up the full
  /// [DocumentRegistry] (Edit Mode needs the row, not just its id).
  PatientTimelineBundle? _resolvedBundle;

  /// Problem ids the clinician selected; empty means "show everything".
  final Set<String> _activeProblems = {};

  @override
  void initState() {
    super.initState();
    _bundle = _load();
  }

  @override
  void didUpdateWidget(covariant PatientTimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient.id != widget.patient.id) {
      _activeProblems.clear();
      _bundle = _load();
    }
  }

  Future<PatientTimelineBundle> _load() async {
    final dao = ref.read(clinicalDaoProvider);
    final patient = widget.patient;
    final loaded = await Future.wait([
      dao.getEncountersForPatient(patient.id),
      dao.getResultsForPatient(patient.id),
      dao.getDocumentsForPatient(patient.id),
      dao.getInterventionsForPatient(patient.id),
      dao.getPrescriptionsForPatient(patient.id),
      dao.watchPatientProblems(patient.id).first,
    ]);

    final encounters = loaded[0] as List<ClinicalEncounter>;
    final results = loaded[1] as List<InvestigationResult>;
    final documents = loaded[2] as List<DocumentRegistry>;
    final interventions = loaded[3] as List<ClinicalIntervention>;
    final prescriptions = loaded[4] as List<PrescriptionOrder>;
    final problems = loaded[5] as List<PatientProblem>;

    // Most recent vitals drive the shock-index / hypoxia banners, so only the
    // latest encounter is evaluated — an old hypotensive reading must not
    // haunt the header forever.
    final alerts = <CdssAlert>[
      ...PatientAlertEngine.fromEncounters(encounters),
      if (encounters.isNotEmpty)
        ...DecisionSupportEngine.evaluateVitals(
          encounters.first.sbp,
          encounters.first.pulse,
          encounters.first.spo2,
        ),
    ];

    return PatientTimelineBuilder.build(
      encounters: encounters,
      results: results,
      documents: documents,
      interventions: interventions,
      prescriptions: prescriptions,
      problems: problems,
      alerts: alerts,
      cohortTags: CohortTagger.tagsFor(
        problems: problems,
        interventions: interventions,
        patient: patient,
      ),
    );
  }

  void _toggleProblem(String problemId) {
    setState(() {
      if (!_activeProblems.remove(problemId)) _activeProblems.add(problemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PatientTimelineBundle>(
        future: _bundle,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _TimelineSkeleton();
          }
          if (snapshot.hasError) {
            return _TimelineError(
              error: snapshot.error!,
              onRetry: () => setState(() => _bundle = _load()),
            );
          }
          final bundle = snapshot.data ?? PatientTimelineBundle.empty;
          return _buildContent(bundle);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'timeline-encounter-fab',
        onPressed: () => context.push('/encounter', extra: widget.patient),
        icon: const Icon(Icons.edit_note),
        label: const Text('Consult'),
      ),
    );
  }

  Widget _buildContent(PatientTimelineBundle bundle) {
    // Cached so a card tap can resolve the full DocumentRegistry (Edit Mode
    // needs the row, not just the id the timeline event carries).
    _resolvedBundle = bundle;
    // Sprint 16 — the feed is now the unified five-source timeline (Sprint 15
    // data layer): admissions, encounters, lab results, prescriptions and
    // scanned documents merged reverse-chronologically.
    final events = ref.watch(unifiedTimelineProvider(widget.patient.id));

    return RefreshIndicator(
      onRefresh: () async => setState(() => _bundle = _load()),
      child: CustomScrollView(
        slivers: [
          _headerSliver(bundle),
          SliverToBoxAdapter(
            child: _ProblemFilterRow(
              problems: bundle.problems,
              selected: _activeProblems,
              onToggle: _toggleProblem,
              onClear: () => setState(_activeProblems.clear),
            ),
          ),
          events.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, _) => SliverToBoxAdapter(
              child: _EmptyFeed(
                hasFilter: _activeProblems.isNotEmpty,
                message: 'Could not load the timeline.',
              ),
            ),
            data: (rows) {
              if (rows.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyFeed(hasFilter: _activeProblems.isNotEmpty),
                );
              }
              return SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final event = rows[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TimelineEventCard(
                      event: event,
                      onTap: () => _openEvent(event),
                    ),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  /// Routes a timeline card to the right destination.
  ///
  /// Scanned documents open in Edit Mode so a mistyped timestamp or a lost
  /// conclusion can be corrected at any time. The other kinds have no dedicated
  /// detail screen yet, so those cards stay informative rather than navigating
  /// somewhere unhelpful.
  void _openEvent(TimelineEvent event) {
    if (event.kind != TimelineEventKind.document) return;
    final id = event.id.split(':').last;
    // Resolve the full row from the bundle so Edit Mode receives the real
    // DocumentRegistry (timestamp, transcript, image path), not just an id.
    for (final entry in _resolvedBundle?.entries ?? const <TimelineEntry>[]) {
      final document = entry.document;
      if (document == null || document.id != id) continue;
      AdaptiveReviewScreen.editExisting(
        context,
        document: document,
        patient: widget.patient,
      );
      return;
    }
  }

  /// Filters the feed to the selected problems.
  ///
  /// Lab results and scanned documents carry no reliable problem link, so they
  /// survive the filter — otherwise picking "Acute Appendicitis" would hide an
  /// abnormal potassium and the paper report that explains it.
  

  SliverAppBar _headerSliver(PatientTimelineBundle bundle) {
    final theme = Theme.of(context);
    final dao = ref.watch(clinicalDaoProvider);
    final alerts = bundle.alerts;

    return SliverAppBar(
      pinned: true,
      expandedHeight: alerts.isEmpty ? 170.0 : 170.0 + alerts.length * 76.0,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 14),
        title: _IdentityLine(patient: widget.patient),
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    FutureBuilder<String>(
                      future: dao.getPatientHospitalRegNo(widget.patient.id),
                      builder: (context, snapshot) => Text(
                        'MRN ${snapshot.data ?? '…'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (bundle.problems.isNotEmpty)
                      Text(
                        '${bundle.problems.length} active problem'
                        '${bundle.problems.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                CohortTagStrip(tags: bundle.cohortTags),
                const SizedBox(height: 6),
                // Pinned inside the flexible space so an alert scrolls away
                // only with the header, never in the middle of the feed.
                for (final alert in alerts) _AlertBanner(alert: alert),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Sprint 15 — the private learning loop, surfaced here as well as on
        // the encounter screen. A reflection is often triggered by reviewing a
        // patient's whole history, not just the encounter in front of you.
        IconButton(
          tooltip: 'Log reflection',
          icon: const Icon(Icons.psychology_alt_outlined),
          onPressed: () async {
            // Captured before the await: using `context` after an async gap is
            // exactly what the use_build_context_synchronously lint guards.
            final messenger = ScaffoldMessenger.of(context);
            final saved = await ReflectionEntrySheet.show(
              context,
              patientId: widget.patient.id,
            );
            if (!saved || !mounted) return;
            messenger.showSnackBar(
              const SnackBar(content: Text('Reflection saved (private)')),
            );
          },
        ),
        IconButton(
          tooltip: 'Problem record',
          icon: const Icon(Icons.assignment_outlined),
          onPressed: () => context.push(
            '/patients/${widget.patient.id}/problems',
            extra: widget.patient,
          ),
        ),
      ],
    );
  }
}

/// Name · age · gender, shown in the pinned app bar.
class _IdentityLine extends StatelessWidget {
  const _IdentityLine({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final age = DateTimeUtils.ageOn(patient.dateOfBirth, DateTime.now());
    final gender = patient.gender?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          patient.fullName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          [
            if (age != null) '$age y',
            if (gender != null && gender.isNotEmpty) gender,
          ].join(' · '),
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

/// A single CDSS / allergy banner.
///
/// Colour comes from the alert itself so a clinician learns to trust the
/// colour: red always means "check before you prescribe".
class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.alert});

  final CdssAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: alert.severityColor.withValues(alpha: 0.9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: alert.severityColor,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  alert.description,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrollable active-problem chips that filter the feed.
class _ProblemFilterRow extends StatelessWidget {
  const _ProblemFilterRow({
    required this.problems,
    required this.selected,
    required this.onToggle,
    required this.onClear,
  });

  final List<PatientProblem> problems;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final active = problems
        .where((p) => p.currentStatus.toLowerCase() != 'resolved')
        .toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: active.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ActionChip(
                avatar: const Icon(Icons.filter_alt_off, size: 15),
                label: const Text('All'),
                visualDensity: VisualDensity.compact,
                backgroundColor: selected.isEmpty
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                onPressed: selected.isEmpty ? null : onClear,
              );
            }
            final problem = active[index - 1];
            final isSelected = selected.contains(problem.id);
            return FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: Icon(
                isSelected ? Icons.check : Icons.circle_outlined,
                size: 14,
              ),
              label: Text(
                problem.problemName,
                style: const TextStyle(fontSize: 12),
              ),
              tooltip: 'Status: ${problem.currentStatus}',
              visualDensity: VisualDensity.compact,
              onSelected: (_) => onToggle(problem.id),
            );
          },
        ),
      ),
    );
  }
}

/// Loading placeholder for the timeline while the bundle resolves.
class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: 5,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Error state for the timeline bundle with a retry affordance.
class _TimelineError extends StatelessWidget {
  const _TimelineError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 44,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load this patient\'s timeline.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.hasFilter, this.message});

  final bool hasFilter;

  /// Overrides the default copy, e.g. when the timeline stream itself failed.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Icon(
            hasFilter ? Icons.filter_alt_off : Icons.timeline,
            size: 44,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            message ??
                (hasFilter
                    ? 'No records for the selected problem.'
                    : 'No history recorded yet.'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            hasFilter
                ? 'Tap "All" to see the full timeline.'
                : 'Encounters, labs and scanned reports appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
