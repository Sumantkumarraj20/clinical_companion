import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';

class PatientTimelineScreen extends ConsumerStatefulWidget {
  const PatientTimelineScreen({required this.patient, this.heroTag, super.key});
  final Patient patient;
  final String? heroTag;

  @override
  ConsumerState<PatientTimelineScreen> createState() =>
      _PatientTimelineScreenState();
}

class _PatientTimelineScreenState extends ConsumerState<PatientTimelineScreen> {
  final _expanded = <String>{};
  bool _showFinancialAlert = false;
  bool _hasMedicolegalAlert = false;

  late final Future<_AggregatedTimelineData> _timelineFuture;

  @override
  void initState() {
    super.initState();
    final dao = ref.read(clinicalDaoProvider);
    _timelineFuture = _loadAggregatedTimeline(dao);
  }

  Future<_AggregatedTimelineData> _loadAggregatedTimeline(
    ClinicalDao dao,
  ) async {
    final results = await Future.wait([
      dao.getEncountersForPatient(widget.patient.id),
      dao.getInvestigationsForPatient(widget.patient.id),
      dao.watchPatientProblems(widget.patient.id).first,
      (dao.select(
        dao.clinicalInterventions,
      )..where((t) => t.patientId.equals(widget.patient.id))).get(),
      (dao.select(
        dao.prescriptionOrders,
      )..where((t) => t.patientId.equals(widget.patient.id))).get(),
    ]);

    final encounters = results[0] as List<ClinicalEncounter>;
    final investigations = results[1] as List<InvestigationOrder>;
    final problems = results[2] as List<PatientProblem>;
    final interventions = results[3] as List<ClinicalIntervention>;
    final prescriptions = results[4] as List<PrescriptionOrder>;

    // Check for trauma/poison/burn medicolegal keywords across problems and encounters
    final isMlCase =
        problems.any((p) {
          final name = p.problemName.toLowerCase();
          return name.contains('trauma') ||
              name.contains('poison') ||
              name.contains('assault') ||
              name.contains('rto') ||
              name.contains('rta') ||
              name.contains('burn') ||
              name.contains('stab');
        }) ||
        encounters.any((e) {
          final diag = (e.clinicalDiagnosis ?? '').toLowerCase();
          final cc = (e.chiefComplaints ?? '').toLowerCase();
          return diag.contains('trauma') ||
              diag.contains('poison') ||
              diag.contains('assault') ||
              diag.contains('rto') ||
              diag.contains('rta') ||
              cc.contains('assault') ||
              cc.contains('poison');
        });

    if (mounted && isMlCase) {
      setState(() => _hasMedicolegalAlert = true);
    }

    return _AggregatedTimelineData(
      encounters: encounters,
      investigations: investigations,
      problems: problems,
      interventions: interventions,
      prescriptions: prescriptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: widget.heroTag ?? 'patient-${widget.patient.id}',
              child: CircleAvatar(
                child: Text(
                  widget.patient.fullName.trim().isNotEmpty
                      ? widget.patient.fullName.trim()[0].toUpperCase()
                      : '?',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.patient.fullName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  FutureBuilder<String>(
                    future: dao.getPatientHospitalRegNo(widget.patient.id),
                    builder: (context, snapshot) {
                      return Text(
                        'CR: ${snapshot.data ?? '…'} · Chronological Ledger',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.patient.phone?.isNotEmpty == true)
            IconButton(
              tooltip: 'Call patient',
              icon: const Icon(Icons.call_outlined),
              onPressed: () =>
                  launchUrl(Uri(scheme: 'tel', path: widget.patient.phone)),
            ),
          IconButton(
            tooltip: 'PM-JAY Pre-Auth Check',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: _selectProcedure,
          ),
          IconButton(
            tooltip: 'Capture clinical document',
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () =>
                context.push('/smart-capture', extra: widget.patient),
          ),
          IconButton(
            tooltip: 'Problem-oriented record (POMR)',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: () => context.push(
              '/patients/${widget.patient.id}/problems',
              extra: widget.patient,
            ),
          ),
        ],
      ),
      body: FutureBuilder<_AggregatedTimelineData>(
        future: _timelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ShimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load chronological ledger:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          final events = _buildEvents(data);

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_toggle_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No Clinical History Recorded',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Encounters, bedside rounds, investigations, and procedures appear here.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_showFinancialAlert)
                MaterialBanner(
                  backgroundColor: const Color(0xfffff3cd),
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                  ),
                  content: const Text(
                    'FINANCIAL / PRE-AUTH ALERT: This procedure requires pre-authorization under PM-JAY. '
                    'Ensure baseline pre-op photographs and diagnostic reports are uploaded to TMS portal.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          setState(() => _showFinancialAlert = false),
                      child: const Text('DISMISS'),
                    ),
                  ],
                ),
              if (_hasMedicolegalAlert)
                MaterialBanner(
                  backgroundColor: const Color(0xffffd7d7),
                  leading: const Icon(Icons.gavel_outlined, color: Colors.red),
                  content: const Text(
                    'MEDICOLEGAL ALERT: High-risk presentation (Trauma/Burn/Poisoning detected). '
                    'Verify MLC registration, chain of custody, and mandatory police intimation.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          setState(() => _hasMedicolegalAlert = false),
                      child: const Text('ACKNOWLEDGE'),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
                  itemCount: events.length,
                  itemBuilder: (context, index) => _TimelineRow(
                    event: events[index],
                    isLast: index == events.length - 1,
                    expanded: _expanded.contains(events[index].id),
                    onTap: () => setState(() {
                      final id = events[index].id;
                      if (!_expanded.add(id)) _expanded.remove(id);
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_TimelineEvent> _buildEvents(_AggregatedTimelineData data) {
    final events = <_TimelineEvent>[
      // 1. Clinical Encounters
      for (final encounter in data.encounters)
        _TimelineEvent(
          id: 'encounter-${encounter.id}',
          timestamp: encounter.occurredAt,
          title: encounter.encounterType,
          subtitle:
              encounter.clinicalDiagnosis ??
              encounter.chiefComplaints ??
              'Clinical Bedside Encounter',
          category: 'Encounter',
          color: encounter.encounterType == 'Procedure'
              ? Colors.teal
              : Colors.blue.shade700,
          details: {
            'Diagnosis / Impression': encounter.clinicalDiagnosis,
            'Chief Complaints': encounter.chiefComplaints,
            'Blood Pressure': (encounter.sbp != null && encounter.dbp != null)
                ? '${encounter.sbp}/${encounter.dbp} mmHg'
                : null,
            'Pulse Rate': encounter.pulse != null
                ? '${encounter.pulse} bpm'
                : null,
            'SpO2': encounter.spo2 != null ? '${encounter.spo2}%' : null,
            'Temperature': encounter.temperatureC != null
                ? '${encounter.temperatureC}°C'
                : null,
            'Assessment & Plan': encounter.clinicalAssessment,
            'Consultant Advice': encounter.consultantAdvice,
            'Ward / Bed':
                '${encounter.wardName ?? ''} ${encounter.bedNumber ?? ''}'
                    .trim(),
          },
        ),

      // 2. Problem Trajectory Milestones
      for (final prob in data.problems)
        _TimelineEvent(
          id: 'problem-${prob.id}',
          timestamp: prob.onsetDate ?? prob.createdAt,
          title: 'Problem Registered: ${prob.problemName}',
          subtitle: 'Trajectory Status: ${prob.currentStatus}',
          category: 'POMR Problem',
          color: prob.currentStatus == 'Resolved'
              ? Colors.green.shade700
              : Colors.amber.shade800,
          details: {
            'Current Status': prob.currentStatus,
            'ICD-11 Code': prob.icd11Code,
            'Onset Date': prob.onsetDate?.toIso8601String().split('T').first,
            'Resolved Date': prob.resolvedDate
                ?.toIso8601String()
                .split('T')
                .first,
          },
        ),

      // 3. Clinical Interventions & Surgical Procedures
      for (final procedure in data.interventions)
        _TimelineEvent(
          id: 'intervention-${procedure.id}',
          timestamp: procedure.performedAt,
          title: 'Intervention: ${procedure.procedureName}',
          subtitle:
              'Role: ${procedure.interventionRole} · ${procedure.procedureCode ?? 'Local'}',
          category: 'Procedure',
          color: Colors.purple.shade700,
          details: {
            'Procedure Code': procedure.procedureCode,
            'Coding System': procedure.codingSystem,
            'Anatomical Site': procedure.anatomicalSite,
            'Operative Findings': procedure.operativeFindings,
            'Performed By': procedure.performedBy,
          },
        ),

      // 4. Laboratory Investigations
      for (final inv in data.investigations)
        _TimelineEvent(
          id: 'investigation-${inv.id}',
          timestamp: inv.resultReceivedAt ?? inv.orderedAt,
          title: 'Lab: ${inv.testName}',
          subtitle: 'Status: ${inv.status.replaceAll('_', ' ').toUpperCase()}',
          category: 'Investigation',
          color: inv.status == 'result_received'
              ? Colors.indigo.shade700
              : Colors.deepOrange.shade600,
          details: {
            'Clinical Indication': inv.clinicalIndication,
            'Workorder Status': inv.status,
            'Ordered At': inv.orderedAt.toIso8601String().split('T').first,
            'Result Received At': inv.resultReceivedAt
                ?.toIso8601String()
                .split('T')
                .first,
          },
        ),

      // 5. Prescriptions
      for (final rx in data.prescriptions)
        _TimelineEvent(
          id: 'prescription-${rx.id}',
          timestamp: rx.orderedAt,
          title: 'Rx: ${rx.drugName}',
          subtitle:
              '${rx.doseStrength ?? ''} ${rx.route ?? 'Oral'} · ${rx.frequency ?? ''}',
          category: 'Medication',
          color: Colors.cyan.shade800,
          details: {
            'Dose Strength': rx.doseStrength,
            'Dosage Form': rx.dosageForm,
            'Route': rx.route,
            'Frequency': rx.frequency,
            'Duration': rx.duration,
            'Special Instructions': rx.specialInstructions,
          },
        ),
    ];

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  Future<void> _selectProcedure() async {
    final selected = await showModalBottomSheet<AyushmanPackage>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProcedureSearchSheet(dao: ref.read(clinicalDaoProvider)),
    );
    if (selected != null && mounted) {
      final cdss = ref.read(cdssDaoProvider);
      final rules = await cdss.rulesForProblem(selected.code);
      final namedRules = await cdss.rulesForProblem(selected.packageName);
      setState(
        () => _showFinancialAlert = [
          ...rules,
          ...namedRules,
        ].any((rule) => rule.requiresPreAuth),
      );
    }
  }
}

class _AggregatedTimelineData {
  _AggregatedTimelineData({
    required this.encounters,
    required this.investigations,
    required this.problems,
    required this.interventions,
    required this.prescriptions,
  });

  final List<ClinicalEncounter> encounters;
  final List<InvestigationOrder> investigations;
  final List<PatientProblem> problems;
  final List<ClinicalIntervention> interventions;
  final List<PrescriptionOrder> prescriptions;
}

class _ProcedureSearchSheet extends StatefulWidget {
  const _ProcedureSearchSheet({required this.dao});
  final ClinicalDao dao;

  @override
  State<_ProcedureSearchSheet> createState() => _ProcedureSearchSheetState();
}

class _ProcedureSearchSheetState extends State<_ProcedureSearchSheet> {
  final _query = TextEditingController();
  Future<List<AyushmanPackage>>? _results;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _query,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search PM-JAY / TMS HBP Package',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) => setState(
              () => _results = widget.dao.searchAyushmanPackages(value),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: FutureBuilder<List<AyushmanPackage>>(
              future: _results,
              builder: (context, snapshot) => ListView(
                children: [
                  for (final package
                      in snapshot.data ?? const <AyushmanPackage>[])
                    ListTile(
                      title: Text(package.packageName),
                      subtitle: Text(
                        '${package.code} · ₹${package.rate?.toStringAsFixed(2) ?? 'Rate Unavailable'}',
                      ),
                      onTap: () => Navigator.pop(context, package),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.color,
    required this.details,
  });

  final String id;
  final DateTime timestamp;
  final String title;
  final String subtitle;
  final String category;
  final Color color;
  final Map<String, Object?> details;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isLast,
    required this.expanded,
    required this.onTap,
  });

  final _TimelineEvent event;
  final bool isLast;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: event.color.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: event.color.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: event.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: event.color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _format(event.timestamp),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (expanded) ...[
                        const Divider(height: 20),
                        for (final item in event.details.entries)
                          if (item.value != null &&
                              item.value.toString().trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.key}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${item.value}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime value) {
    final local = value.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}
