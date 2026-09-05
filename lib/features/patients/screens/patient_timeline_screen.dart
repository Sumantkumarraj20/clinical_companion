import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/local_database.dart';
import '../../../core/database/daos/clinical_dao.dart';
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
  late final Future<(List<ClinicalEncounter>, List<Investigation>)>
  _timelineFuture;

  @override
  void initState() {
    super.initState();
    final dao = ref.read(clinicalDaoProvider);
    _timelineFuture =
        Future.wait([
          dao.getEncountersForPatient(widget.patient.id),
          dao.getInvestigationsForPatient(widget.patient.id),
        ]).then(
          (items) => (
            items[0] as List<ClinicalEncounter>,
            items[1] as List<Investigation>,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: widget.heroTag ?? 'patient-${widget.patient.id}',
              child: CircleAvatar(child: Text(widget.patient.fullName.substring(0, 1).toUpperCase())),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('${widget.patient.fullName} · timeline')),
          ],
        ),
        actions: [
          if ((widget.patient.phoneNumber ?? widget.patient.phone)?.isNotEmpty == true)
            IconButton(
              tooltip: 'Call patient',
              icon: const Icon(Icons.call_outlined),
              onPressed: () => launchUrl(Uri(scheme: 'tel', path: widget.patient.phoneNumber ?? widget.patient.phone)),
            ),
          IconButton(
            tooltip: 'Select PM-JAY procedure',
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
            tooltip: 'Problem-oriented record',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: () => context.push(
              '/patients/${widget.patient.id}/problems',
              extra: widget.patient,
            ),
          ),
        ],
      ),
      body: FutureBuilder<(List<ClinicalEncounter>, List<Investigation>)>(
        future: _timelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ShimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load timeline: ${snapshot.error}'),
            );
          }
          final events = _events(snapshot.data!.$1, snapshot.data!.$2);
          if (events.isEmpty) {
            return const Center(child: Text('No clinical history recorded'));
          }
          return Column(
            children: [
              if (_showFinancialAlert)
                const MaterialBanner(
                  backgroundColor: Color(0xfffff3cd),
                  leading: Icon(Icons.account_balance_wallet_outlined, color: Colors.black87),
                  content: Text(
                    'FINANCIAL ALERT: This procedure requires pre-authorization under PM-JAY. Ensure clinical photographs and baseline labs are uploaded to TMS.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  actions: [SizedBox.shrink()],
                ),
              if (_isMedicoLegal)
                const MaterialBanner(
                  backgroundColor: Color(0xffffd7d7),
                  leading: Icon(Icons.gavel_outlined, color: Colors.red),
                  content: Text(
                    'MEDICOLEGAL ALERT: Ensure MLC (Medico-Legal Case) stamp is present on the physical file and police intimation is recorded.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  actions: [SizedBox.shrink()],
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

  List<_TimelineEvent> _events(
    List<ClinicalEncounter> encounters,
    List<Investigation> investigations,
  ) {
    final events = <_TimelineEvent>[
      for (final encounter in encounters)
        _TimelineEvent(
          id: 'encounter-${encounter.id}',
          timestamp: encounter.occurredAt,
          title: encounter.encounterType,
          subtitle: encounter.chiefComplaint ?? 'Clinical encounter',
          color: encounter.encounterType == 'Procedure'
              ? Colors.green
              : Colors.blue,
          details: {
            'SBP': encounter.sbp,
            'DBP': encounter.dbp,
            'Pulse': encounter.pulse,
            'Advice': encounter.consultantAdvice,
            'Dynamic data': encounter.dynamicData,
          },
        ),
      for (final investigation in investigations)
        _TimelineEvent(
          id: 'investigation-${investigation.id}',
          timestamp: investigation.resultReceivedAt ?? investigation.orderedAt,
          title: investigation.testName,
          subtitle: investigation.status.replaceAll('_', ' '),
          color: Colors.red,
          details: {
            'Result': investigation.resultValue,
            'Unit': investigation.resultUnit,
            'Organism': investigation.organism,
            'Sensitive': _decodeList(investigation.sensitiveAntibiotics),
            'Resistant': _decodeList(investigation.resistantAntibiotics),
          },
        ),
    ];
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  List<String> _decodeList(String value) {
    try {
      final decoded = jsonDecode(value);
      return decoded is List
          ? decoded.map((item) => item.toString()).toList(growable: false)
          : const [];
    } catch (_) {
      return const [];
    }
  }

  bool get _isMedicoLegal {
    final diagnosis = widget.patient.diagnosis?.toLowerCase() ?? '';
    return diagnosis.contains('trauma') || diagnosis.contains('poison');
  }

  Future<void> _selectProcedure() async {
    final selected = await showModalBottomSheet<AyushmanPackage>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProcedureSearchSheet(dao: ref.read(clinicalDaoProvider)),
    );
    if (selected != null && mounted) {
      final rules = await ref.read(cdssDaoProvider).rulesForProblem(selected.code);
      final namedRules = await ref.read(cdssDaoProvider).rulesForProblem(selected.packageName);
      setState(() => _showFinancialAlert = [
        ...rules,
        ...namedRules,
      ].any((rule) => rule.requiresPreAuth));
    }
  }
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
  void dispose() { _query.dispose(); super.dispose(); }

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
            decoration: const InputDecoration(labelText: 'Search PM-JAY package', prefixIcon: Icon(Icons.search)),
            onChanged: (value) => setState(() => _results = widget.dao.searchAyushmanPackages(value)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: FutureBuilder<List<AyushmanPackage>>(
              future: _results,
              builder: (context, snapshot) => ListView(
                children: [
                  for (final package in snapshot.data ?? const <AyushmanPackage>[])
                    ListTile(
                      title: Text(package.packageName),
                      subtitle: Text('${package.code} · ₹${package.rate?.toStringAsFixed(2) ?? 'rate unavailable'}'),
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
    required this.color,
    required this.details,
  });
  final String id;
  final DateTime timestamp;
  final String title;
  final String subtitle;
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
                        color: event.color.withAlpha(80),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: event.color.withAlpha(100),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            _format(event.timestamp),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(event.subtitle),
                      if (expanded) ...[
                        const Divider(height: 24),
                        for (final item in event.details.entries)
                          if (item.value != null &&
                              item.value.toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${item.key}: ${item.value}'),
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

  String _format(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
