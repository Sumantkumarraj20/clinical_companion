import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cds/silent_brain.dart';
import '../../../core/clinical/note_formatter.dart';
import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/copy_note_button.dart';
import '../../../core/widgets/silent_brain_panel.dart';
import '../../ingestion/widgets/omni_ingestion_sheet.dart';

final _roundHistoryProvider = FutureProvider.autoDispose
    .family<List<ClinicalEncounter>, String>(
      (ref, patientId) =>
          ref.watch(clinicalDaoProvider).getEncountersForPatient(patientId),
    );

enum RoundSort { bed, name, longestStay }

/// Rounds Mode: one admitted patient per page. Swipe to the next bed.
class RoundsModeScreen extends ConsumerStatefulWidget {
  const RoundsModeScreen({super.key});

  @override
  ConsumerState<RoundsModeScreen> createState() => _RoundsModeScreenState();
}

class _RoundsModeScreenState extends ConsumerState<RoundsModeScreen> {
  final _pages = PageController();
  RoundSort _sort = RoundSort.bed;
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  List<WardRoundPatient> _sorted(List<WardRoundPatient> rows) {
    final list = [...rows];
    int bed(WardRoundPatient r) =>
        int.tryParse((r.bedNumber ?? '').replaceAll(RegExp(r'\D'), '')) ??
        1 << 30;
    switch (_sort) {
      case RoundSort.bed:
        list.sort((a, b) {
          final w = (a.wardName ?? '').compareTo(b.wardName ?? '');
          return w != 0 ? w : bed(a).compareTo(bed(b));
        });
      case RoundSort.name:
        list.sort((a, b) => a.patient.fullName.compareTo(b.patient.fullName));
      case RoundSort.longestStay:
        list.sort(
          (a, b) =>
              a.admission.admissionTime.compareTo(b.admission.admissionTime),
        );
    }
    return list;
  }

  void _go(int i, int count) {
    if (i < 0 || i >= count) return;
    _pages.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wards = ref.watch(wardRoundsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rounds'),
        actions: [
          PopupMenuButton<RoundSort>(
            tooltip: 'Order patients',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (s) => setState(() {
              _sort = s;
              _index = 0;
              if (_pages.hasClients) _pages.jumpToPage(0);
            }),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: RoundSort.bed,
                child: Text('By ward and bed'),
              ),
              PopupMenuItem(value: RoundSort.name, child: Text('By name')),
              PopupMenuItem(
                value: RoundSort.longestStay,
                child: Text('Longest stay first'),
              ),
            ],
          ),
        ],
      ),
      body: wards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('We could not load your ward list.'),
              TextButton(
                onPressed: () => ref.invalidate(wardRoundsProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bed_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'No admitted patients yet.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.go('/patients'),
                      child: const Text('Open patients'),
                    ),
                  ],
                ),
              ),
            );
          }
          final list = _sorted(rows);
          final count = list.length;
          final current = _index.clamp(0, count - 1);
          return Column(
            children: [
              _QueueStrip(
                list: list,
                current: current,
                onTap: (i) => _go(i, count),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: count,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _RoundPage(
                    key: ValueKey(list[i].admission.id),
                    row: list[i],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous bed',
                        onPressed: current > 0
                            ? () => _go(current - 1, count)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          'Patient ${current + 1} of $count · swipe for next bed',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next bed',
                        onPressed: current < count - 1
                            ? () => _go(current + 1, count)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QueueStrip extends StatelessWidget {
  const _QueueStrip({
    required this.list,
    required this.current,
    required this.onTap,
  });

  final List<WardRoundPatient> list;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final r = list[i];
          final bed = (r.bedNumber ?? '').trim();
          return ChoiceChip(
            selected: i == current,
            onSelected: (_) => onTap(i),
            label: Text(
              bed.isEmpty
                  ? r.patient.fullName.split(' ').first
                  : '$bed · ${r.patient.fullName.split(' ').first}',
            ),
          );
        },
      ),
    );
  }
}

class _RoundPage extends ConsumerStatefulWidget {
  const _RoundPage({super.key, required this.row});
  final WardRoundPatient row;

  @override
  ConsumerState<_RoundPage> createState() => _RoundPageState();
}

class _RoundPageState extends ConsumerState<_RoundPage>
    with AutomaticKeepAliveClientMixin {
  final _s = TextEditingController();
  final _o = TextEditingController();
  final _a = TextEditingController();
  final _p = TextEditingController();
  bool _saving = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    for (final c in [_s, _o, _a, _p]) {
      c.dispose();
    }
    super.dispose();
  }

  String _location() => [
    widget.row.wardName,
    if ((widget.row.bedNumber ?? '').trim().isNotEmpty)
      'Bed ${widget.row.bedNumber}',
  ].whereType<String>().join(' · ');

  String _note(ClinicalEncounter? last) => ClinicalNoteFormatter.progressNote(
    patientName: widget.row.patient.fullName,
    location: _location(),
    when: DateTime.now(),
    subjective: _s.text,
    objective: _o.text,
    assessment: _a.text,
    plan: _p.text,
    vitals: ClinicalNoteFormatter.vitalsLine(last),
  );

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if ([_s, _o, _a, _p].every((c) => c.text.trim().isEmpty)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add a few words first.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final dao = ref.read(clinicalDaoProvider);
      await dao.insertClinicalEncounter(
        ClinicalEncountersCompanion.insert(
          ownerId: ref.read(currentOwnerIdProvider),
          patientId: widget.row.patient.id,
          encounterType: const Value('Ward Round'),
          careSetting: const Value('IPD'),
          wardName: Value(widget.row.wardName),
          bedNumber: Value(widget.row.bedNumber),
          historyOfPresentIllness: Value(_nullIfEmpty(_s.text)),
          examinationFindings: Value(_nullIfEmpty(_o.text)),
          clinicalAssessment: Value(_nullIfEmpty(_a.text)),
          consultantAdvice: Value(_nullIfEmpty(_p.text)),
        ),
      );
      for (final c in [_s, _o, _a, _p]) {
        c.clear();
      }
      ref.invalidate(_roundHistoryProvider(widget.row.patient.id));
      messenger.showSnackBar(const SnackBar(content: Text('Note saved.')));
    } catch (e, st) {
      debugPrint('Round note save failed: $e\n$st');
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'We could not save this note. Your text is still here.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final patient = widget.row.patient;
    final history = ref.watch(_roundHistoryProvider(patient.id));
    final past = history.value ?? const <ClinicalEncounter>[];
    final last = past.isEmpty ? null : past.first;
    final days = DateTime.now()
        .difference(widget.row.admission.admissionTime)
        .inDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.fullName, style: theme.textTheme.titleLarge),
                  Text(
                    [
                      _location(),
                      'Day ${days + 1} of admission',
                      if (widget.row.mrn != null) 'MRN ${widget.row.mrn}',
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.push('/patients/${patient.id}', extra: patient),
              child: const Text('Full chart'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (last != null && ClinicalNoteFormatter.vitalsLine(last).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Last vitals: ${ClinicalNoteFormatter.vitalsLine(last)}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        SilentBrainPanel(
          input: BrainInput(
            complaints: last?.chiefComplaints ?? '',
            history: last?.historyOfPresentIllness ?? '',
            examination: '${last?.examinationFindings ?? ''} ${_o.text}',
            assessment: '${last?.clinicalAssessment ?? ''} ${_a.text}',
            plan: '${last?.consultantAdvice ?? ''} ${_p.text}',
            sbp: last?.sbp,
            dbp: last?.dbp,
            pulse: last?.pulse,
            spo2: last?.spo2,
            temperatureC: last?.temperatureC,
            respiratoryRate: last?.respiratoryRate,
            hasAllergyRecord: (last?.drugAndAllergyHistory ?? '').isNotEmpty,
            hasMedicationRecord: (last?.drugAndAllergyHistory ?? '').isNotEmpty,
          ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          shape: const Border(),
          tilePadding: EdgeInsets.zero,
          title: Text('Recent history (${past.length})'),
          children: [
            if (history.isLoading)
              const LinearProgressIndicator()
            else if (past.isEmpty)
              const ListTile(title: Text('No earlier notes for this patient.'))
            else
              for (final e in past.take(5))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    ClinicalNoteFormatter.encounterDigest(e).isEmpty
                        ? 'Note without details'
                        : ClinicalNoteFormatter.encounterDigest(e),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${e.occurredAt.day}/${e.occurredAt.month}/${e.occurredAt.year}',
                  ),
                ),
          ],
        ),
        const SizedBox(height: 8),
        _field(_s, 'Subjective', 'How is the patient today?'),
        _field(_o, 'Objective', 'Examination, results'),
        _field(_a, 'Assessment', 'Impression'),
        _field(_p, 'Plan', 'Orders and next steps'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_saving ? 'Saving…' : 'Save note'),
            ),
            CopyNoteButton(textBuilder: () => _note(last)),
            OutlinedButton.icon(
              onPressed: () => showOmniIngestionSheet(context),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add record'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        minLines: 2,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
