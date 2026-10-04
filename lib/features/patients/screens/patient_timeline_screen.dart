import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cds/decision_support_engine.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';
import '../../ingestion/screens/adaptive_review_screen.dart';
import '../../ingestion/widgets/full_screen_image_viewer.dart';
import '../../learning/widgets/reflection_entry_sheet.dart';
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
              message: '${snapshot.error}',
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
    final entries = _filterEntries(bundle.entries, bundle.problems);

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
          if (entries.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyFeed(hasFilter: _activeProblems.isNotEmpty),
            )
          else
            SliverList.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final previous = index == 0 ? null : entries[index - 1];
                return _FeedItem(
                  entry: entry,
                  showDayHeader: previous == null || previous.day != entry.day,
                  patient: widget.patient,
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  /// Filters the feed to the selected problems.
  ///
  /// Lab results and scanned documents carry no reliable problem link, so they
  /// survive the filter — otherwise picking "Acute Appendicitis" would hide an
  /// abnormal potassium and the paper report that explains it.
  List<TimelineEntry> _filterEntries(
    List<TimelineEntry> entries,
    List<PatientProblem> problems,
  ) {
    if (_activeProblems.isEmpty) return entries;

    final problemIds = _activeProblems;
    final encountersForProblems = <String>{
      for (final problem in problems)
        if (problemIds.contains(problem.id))
          if (problem.initialEncounterId != null) problem.initialEncounterId!,
    };

    return entries.where((entry) {
      switch (entry.kind) {
        case TimelineEntryKind.encounter:
          return encountersForProblems.contains(entry.encounter?.id);
        case TimelineEntryKind.procedure:
          return problemIds.contains(entry.intervention?.problemId);
        case TimelineEntryKind.labResult:
        case TimelineEntryKind.document:
          return true;
      }
    }).toList();
  }

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

/// 24-hour clock, e.g. `09:40` — unambiguous across locales, unlike a 12-hour
/// string that would need an AM/PM suffix.
String _formatClock(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// One feed row: an optional day separator plus a kind-specific Material 3
/// card.
class _FeedItem extends StatelessWidget {
  const _FeedItem({
    required this.entry,
    required this.showDayHeader,
    required this.patient,
  });

  final TimelineEntry entry;
  final bool showDayHeader;

  /// Sprint 14.5 — forwarded to document cards so Edit Mode files corrections
  /// against the right patient.
  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(12, showDayHeader ? 14 : 4, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDayHeader) _DaySeparator(day: entry.day),
          const SizedBox(height: 6),
          switch (entry.kind) {
            TimelineEntryKind.encounter => _EncounterCard(entry: entry),
            TimelineEntryKind.labResult => _LabResultCard(entry: entry),
            TimelineEntryKind.document => _DocumentCard(
              entry: entry,
              patient: patient,
            ),
            TimelineEntryKind.procedure => _ProcedureCard(entry: entry),
          },
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _formatClock(entry.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.day});

  static const _months = [
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
  ];

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(day).inDays;
    final label = switch (difference) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => '${day.day} ${_months[day.month - 1]} ${day.year}',
    };

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
      ],
    );
  }
}

/// Shared shell for every card in the feed.
class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.children = const [],
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Sprint 14.5 — makes the whole card actionable (e.g. reopening a saved
  /// document). Null keeps the card inert.
  final VoidCallback? onTap;

  /// Optional long-press, used here to jump straight to the full-screen scan
  /// without entering Edit Mode.
  final VoidCallback? onLongPress;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              for (final child in children) ...[
                const SizedBox(height: 8),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Encounter card: diagnosis, HPI snippet and the drugs that were ordered.
class _EncounterCard extends StatelessWidget {
  const _EncounterCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final encounter = entry.encounter!;
    final complaint = (encounter.chiefComplaints ?? '').trim();
    final hpi = (encounter.historyOfPresentIllness ?? '').trim();
    final diagnosis = (encounter.clinicalDiagnosis ?? '').trim();
    final assessment = (encounter.clinicalAssessment ?? '').trim();

    // Prefer a short HPI snippet; fall back to the complaint so the card is
    // never blank when the note exists.
    final narrative = hpi.isNotEmpty ? hpi : complaint;
    final snippet = narrative.length > 180
        ? '${narrative.substring(0, 180)}…'
        : narrative;

    return _FeedCard(
      icon: Icons.assignment_outlined,
      iconColor: theme.colorScheme.primary,
      title: diagnosis.isNotEmpty ? diagnosis : encounter.encounterType,
      subtitle: [
        encounter.encounterType,
        if (encounter.wardName?.isNotEmpty == true) encounter.wardName,
        if (encounter.bedNumber?.isNotEmpty == true)
          'Bed ${encounter.bedNumber}',
      ].whereType<String>().join(' · '),
      children: [
        if (complaint.isNotEmpty && complaint != snippet)
          Text(
            'Presents: $complaint',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (snippet.isNotEmpty) Text(snippet, style: theme.textTheme.bodySmall),
        if (assessment.isNotEmpty)
          Text(
            assessment,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (entry.prescriptions.isNotEmpty)
          _DrugChips(prescriptions: entry.prescriptions),
      ],
    );
  }
}

/// Ordered drugs for an encounter, shown inline on the encounter card.
class _DrugChips extends StatelessWidget {
  const _DrugChips({required this.prescriptions});

  final List<PrescriptionOrder> prescriptions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final prescription in prescriptions.take(6))
          Chip(
            avatar: const Icon(Icons.medication_outlined, size: 13),
            label: Text(
              [
                prescription.drugName,
                if (prescription.doseStrength?.isNotEmpty == true)
                  prescription.doseStrength!,
                if (prescription.route?.isNotEmpty == true) prescription.route!,
              ].join(' '),
              style: const TextStyle(fontSize: 11),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        if (prescriptions.length > 6)
          Text(
            '+${prescriptions.length - 6} more',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }
}

/// Lab card. Abnormal values are the whole point of the card, so they are
/// coloured, prefixed and given a tinted container.
class _LabResultCard extends StatelessWidget {
  const _LabResultCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = entry.result!;
    final abnormal = result.isAbnormal;
    final accent = abnormal ? const Color(0xFFC62828) : const Color(0xFF2E7D32);

    final value = [
      result.textValue ?? result.numericValue?.toString() ?? '—',
      if (result.unit?.isNotEmpty == true) result.unit!,
    ].join(' ');

    return _FeedCard(
      icon: abnormal ? Icons.trending_up : Icons.science_outlined,
      iconColor: accent,
      title: result.testName,
      subtitle: result.referenceRange?.isNotEmpty == true
          ? 'Ref ${result.referenceRange}'
          : 'Investigation',
      trailing: abnormal
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ABNORMAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.4,
                ),
              ),
            )
          : null,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: abnormal ? 0.10 : 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

/// Document card for a scanned paper report.
///
/// This is the bridge between the physical and digital record: the thumbnail
/// lets a clinician recognise the page they handed over, and the confidence
/// score warns when the AI read it poorly.
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.entry, required this.patient});

  final TimelineEntry entry;

  /// Needed to file corrections against the right patient in Edit Mode.
  final Patient patient;

  /// Sprint 14.5 — tapping a saved document re-opens it for correction.
  ///
  /// The card opens the review screen in **Edit Mode**, pre-seeded with the
  /// stored timestamp, transcript and image, so a clinician can correct a
  /// mistyped detail at any time. A long-press opens the raw scan full-screen
  /// instead, for reading fine print without entering edit mode.
  void _openDocument(
    BuildContext context,
    DocumentRegistry document,
    Patient patient,
  ) {
    if (document.imagePath.trim().isEmpty) return;
    AdaptiveReviewScreen.editExisting(
      context,
      document: document,
      patient: patient,
    );
  }

  /// Opens the stored scan read-only, full-screen.
  void _viewScan(BuildContext context, DocumentRegistry document) {
    if (document.imagePath.trim().isEmpty) return;
    FullScreenImageViewer.open(
      context,
      imagePath: document.imagePath,
      title: _prettyCategory(document.documentCategory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final document = entry.document!;
    final transcript = document.rawOcrTranscript.trim();
    final lowConfidence = document.confidenceScore < 0.6;

    final summary = transcript.isEmpty
        ? 'No transcript captured.'
        : transcript.length > 200
        ? '${transcript.substring(0, 200)}…'
        : transcript;

    return _FeedCard(
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF6A1B9A),
      title: _prettyCategory(document.documentCategory),
      subtitle:
          'Scanned · ${(document.confidenceScore * 100).round()}% read confidence',
      trailing: lowConfidence
          ? Tooltip(
              message:
                  'Low extraction confidence — verify against the paper copy',
              child: Icon(
                Icons.error_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
            )
          : null,
      onTap: () => _openDocument(context, document, patient),
      onLongPress: () => _viewScan(context, document),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DocumentThumbnail(path: document.imagePath),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summary,
                style: theme.textTheme.bodySmall,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _prettyCategory(String raw) {
    final value = raw.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (value.isEmpty) return 'Clinical document';
    return value[0].toUpperCase() + value.substring(1);
  }
}

/// Small preview of the scanned page. Falls back to an icon when the file has
/// been cleaned up, so a stale path never breaks the card.
class _DocumentThumbnail extends StatelessWidget {
  const _DocumentThumbnail({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      width: 56,
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 20,
        color: theme.colorScheme.outline,
      ),
    );

    if (!File(path).existsSync()) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path),
        width: 56,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}

/// Procedure card — an operation or bedside intervention.
class _ProcedureCard extends StatelessWidget {
  const _ProcedureCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intervention = entry.intervention!;
    final findings = (intervention.operativeFindings ?? '').trim();

    return _FeedCard(
      icon: Icons.medical_services_outlined,
      iconColor: const Color(0xFF00838F),
      title: intervention.procedureName,
      subtitle: [
        intervention.interventionRole,
        if (intervention.codingSystem?.isNotEmpty == true)
          intervention.codingSystem,
      ].whereType<String>().join(' · '),
      children: [
        if (findings.isNotEmpty)
          Text(
            findings,
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

/// Placeholder shown while the bundle loads.
class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _ShimmerBar(height: 92, radius: 14),
            SizedBox(height: 14),
            _ShimmerBar(height: 30, radius: 15),
            SizedBox(height: 16),
            _ShimmerBar(height: 96, radius: 14),
            SizedBox(height: 12),
            _ShimmerBar(height: 96, radius: 14),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Load-failure state with a retry, so a transient DB error never leaves the
/// clinician staring at a blank screen.
class _TimelineError extends StatelessWidget {
  const _TimelineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Could not load this timeline.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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

/// Shown when the feed has no records — or when a filter hid them all.
class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.hasFilter});

  final bool hasFilter;

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
            hasFilter
                ? 'No records for the selected problem.'
                : 'No history recorded yet.',
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
