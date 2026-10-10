import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cds/silent_brain.dart';
import '../../../core/clinical/note_formatter.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/copy_note_button.dart';
import '../../../core/widgets/silent_brain_panel.dart';
import '../data/opd_seeds.dart';

/// Rapid OPD consult: tap chips instead of typing, with suggestions that learn
/// from the clinician's own usage. The safety net observes quietly below.
class OpdEncounterScreen extends ConsumerStatefulWidget {
  const OpdEncounterScreen({super.key, required this.patient});

  final Patient patient;

  @override
  ConsumerState<OpdEncounterScreen> createState() => _OpdEncounterScreenState();
}

class _Section {
  _Section(this.title, this.category, this.hint, this.seeds);
  final String title;
  final String category;
  final String hint;
  final List<String> seeds;
  final ValueNotifier<List<String>> items = ValueNotifier(const []);
}

class _OpdEncounterScreenState extends ConsumerState<OpdEncounterScreen> {
  late final _complaints = _Section(
    'Chief complaints',
    'opd_complaint',
    'Type a complaint, or tap below',
    OpdSeeds.complaints,
  );
  late final _history = _Section(
    'History',
    'opd_history',
    'Type history, or tap below',
    OpdSeeds.history,
  );
  late final _exam = _Section(
    'Examination',
    'opd_exam',
    'Type a finding, or tap below',
    OpdSeeds.examination,
  );
  late final _labs = _Section(
    'Investigations',
    'opd_lab',
    'Type a test, or tap below',
    OpdSeeds.labs,
  );
  late final _advice = _Section(
    'Advice',
    'opd_advice',
    'Type advice, or tap below',
    OpdSeeds.advice,
  );
  late final List<_Section> _sections = [
    _complaints,
    _history,
    _exam,
    _labs,
    _advice,
  ];

  final _impression = TextEditingController();
  final _sbp = TextEditingController();
  final _dbp = TextEditingController();
  final _pulse = TextEditingController();
  final _spo2 = TextEditingController();
  final _temp = TextEditingController();
  late final Listenable _changes = Listenable.merge([
    for (final s in _sections) s.items,
    _impression,
    _sbp,
    _dbp,
    _pulse,
    _spo2,
    _temp,
  ]);
  bool _saving = false;

  @override
  void dispose() {
    for (final s in _sections) {
      s.items.dispose();
    }
    for (final c in [_impression, _sbp, _dbp, _pulse, _spo2, _temp]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _age() {
    final dob = widget.patient.dateOfBirth;
    if (dob == null) return null;
    final n = DateTime.now();
    return n.year -
        dob.year -
        ((n.month < dob.month || (n.month == dob.month && n.day < dob.day))
            ? 1
            : 0);
  }

  String _patientLine() => [
    widget.patient.fullName,
    if (_age() != null) '${_age()} y',
    if (widget.patient.gender != null) widget.patient.gender!,
  ].join(', ');

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  String _vitals() => [
    if (_int(_sbp) != null && _int(_dbp) != null)
      'BP ${_int(_sbp)}/${_int(_dbp)} mmHg',
    if (_int(_pulse) != null) 'HR ${_int(_pulse)}/min',
    if (_int(_spo2) != null) 'SpO2 ${_int(_spo2)}%',
    if (double.tryParse(_temp.text.trim()) != null)
      'Temp ${_temp.text.trim()} °C',
  ].join(', ');

  String _note() => ClinicalNoteFormatter.opdNote(
    patientLine: _patientLine(),
    when: DateTime.now(),
    complaints: _complaints.items.value,
    history: _history.items.value,
    vitals: _vitals(),
    examination: _exam.items.value,
    investigations: _labs.items.value,
    impression: _impression.text,
    advice: _advice.items.value,
  );

  BrainInput _brainInput() => BrainInput(
    complaints: _complaints.items.value.join('; '),
    history: _history.items.value.join('; '),
    examination: _exam.items.value.join('; '),
    assessment: _impression.text,
    plan: '${_labs.items.value.join('; ')}; ${_advice.items.value.join('; ')}',
    age: _age(),
    sbp: _int(_sbp),
    dbp: _int(_dbp),
    pulse: _int(_pulse),
    spo2: _int(_spo2),
    temperatureC: double.tryParse(_temp.text.trim()),
  );

  bool get _isEmpty =>
      _sections.every((s) => s.items.value.isEmpty) &&
      _impression.text.trim().isEmpty;

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add a complaint or finding first.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final dao = ref.read(clinicalDaoProvider);
      String? joined(_Section s, [String sep = '; ']) =>
          s.items.value.isEmpty ? null : s.items.value.join(sep);
      await dao.insertClinicalEncounter(
        ClinicalEncountersCompanion.insert(
          ownerId: ref.read(currentOwnerIdProvider),
          patientId: widget.patient.id,
          encounterType: const Value('OPD'),
          careSetting: const Value('OPD'),
          chiefComplaints: Value(joined(_complaints)),
          historyOfPresentIllness: Value(joined(_history)),
          examinationFindings: Value(joined(_exam)),
          consultantAdvice: Value(joined(_advice, '\n')),
          clinicalDiagnosis: Value(
            _impression.text.trim().isEmpty ? null : _impression.text.trim(),
          ),
          sbp: Value(_int(_sbp)),
          dbp: Value(_int(_dbp)),
          pulse: Value(_int(_pulse)),
          spo2: Value(_int(_spo2)),
          temperatureC: Value(double.tryParse(_temp.text.trim())),
          dynamicData: Value({'investigationsAdvised': _labs.items.value}),
        ),
      );
      // Teach the suggestions what this clinician actually uses.
      for (final s in _sections) {
        for (final term in s.items.value) {
          unawaited(
            dao
                .recordCatalogUsage(category: s.category, term: term)
                .catchError((Object e) => debugPrint('Usage not recorded: $e')),
          );
        }
      }
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Consult saved.')));
      context.go('/patients', extra: const {'opdFlow': true});
    } catch (e, st) {
      debugPrint('OPD save failed: $e\n$st');
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'We could not save this consult. Your entries are still here.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.patient.fullName, style: theme.textTheme.titleMedium),
            Text(
              ['OPD consult', if (_age() != null) '${_age()} y'].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final s in _sections.take(2)) _ChipSection(section: s),
          _VitalsRow(
            sbp: _sbp,
            dbp: _dbp,
            pulse: _pulse,
            spo2: _spo2,
            temp: _temp,
          ),
          const SizedBox(height: 8),
          for (final s in _sections.skip(2).take(2)) _ChipSection(section: s),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: _impression,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Impression',
                hintText: 'Working diagnosis',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          _ChipSection(section: _advice),
          SilentBrainPanel(inputBuilder: _brainInput, refresh: _changes),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: CopyNoteButton(textBuilder: _note, label: 'Copy note'),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: Text(_saving ? 'Saving…' : 'Save and next patient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalsRow extends StatelessWidget {
  const _VitalsRow({
    required this.sbp,
    required this.dbp,
    required this.pulse,
    required this.spo2,
    required this.temp,
  });

  final TextEditingController sbp, dbp, pulse, spo2, temp;

  Widget _f(TextEditingController c, String label, {bool decimal = false}) =>
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: c,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: const Border(),
      tilePadding: EdgeInsets.zero,
      title: const Text('Vitals (optional)'),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        Row(
          children: [
            _f(sbp, 'SBP'),
            _f(dbp, 'DBP'),
            _f(pulse, 'HR'),
            _f(spo2, 'SpO2'),
            _f(temp, '°C', decimal: true),
          ],
        ),
      ],
    );
  }
}

/// Selected chips, a type-ahead field, and tappable suggestions. Only this
/// section rebuilds as its text or chips change.
class _ChipSection extends ConsumerStatefulWidget {
  const _ChipSection({required this.section});
  final _Section section;

  @override
  ConsumerState<_ChipSection> createState() => _ChipSectionState();
}

class _ChipSectionState extends ConsumerState<_ChipSection> {
  final _text = TextEditingController();
  Timer? _timer;
  List<String> _learned = const [];

  _Section get _s => widget.section;

  @override
  void initState() {
    super.initState();
    _text.addListener(_onText);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onText() {
    setState(() {});
    _timer?.cancel();
    final q = _text.text.trim();
    if (q.length < 2) {
      if (_learned.isNotEmpty) setState(() => _learned = const []);
      return;
    }
    _timer = Timer(const Duration(milliseconds: 200), () async {
      try {
        final found = await ref
            .read(clinicalDaoProvider)
            .searchLearnedCatalog(category: _s.category, query: q, limit: 6);
        if (mounted && _text.text.trim() == q) setState(() => _learned = found);
      } catch (e) {
        debugPrint('Suggestion lookup failed: $e');
      }
    });
  }

  List<String> _suggestions() {
    final q = _text.text.trim().toLowerCase();
    final chosen = _s.items.value.map((e) => e.toLowerCase()).toSet();
    final seen = <String>{};
    final pool = [..._learned, ..._s.seeds];
    bool starts(String e) => e.toLowerCase().startsWith(q);
    final matches = q.isEmpty
        ? pool
        : [
            ...pool.where(starts),
            ...pool.where((e) => !starts(e) && e.toLowerCase().contains(q)),
          ];
    return matches
        .where((e) => !chosen.contains(e.toLowerCase()) && seen.add(e))
        .take(12)
        .toList();
  }

  void _add(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    if (_s.items.value.any((e) => e.toLowerCase() == v.toLowerCase())) return;
    _s.items.value = [..._s.items.value, v];
    _text.clear();
  }

  Future<void> _tap(String suggestion) async {
    if (!suggestion.contains('_')) return _add(suggestion);
    final days = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                suggestion.replaceAll(' x _ days', ''),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('For how many days?'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in const [1, 2, 3, 4, 5, 7, 10, 14, 21, 30])
                    ActionChip(
                      label: Text('$d'),
                      onPressed: () => Navigator.of(context).pop(d),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (days == null) return;
    _add(suggestion.replaceAll('_ days', days == 1 ? '1 day' : '$days days'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_s.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          ValueListenableBuilder<List<String>>(
            valueListenable: _s.items,
            builder: (context, items, _) {
              final suggestions = _suggestions();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final e in items)
                            InputChip(
                              label: Text(e),
                              onDeleted: () => _s.items.value = [
                                for (final x in items)
                                  if (x != e) x,
                              ],
                            ),
                        ],
                      ),
                    ),
                  TextField(
                    controller: _text,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: _add,
                    decoration: InputDecoration(
                      hintText: _s.hint,
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixIcon: _text.text.trim().isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Add',
                              icon: const Icon(Icons.add),
                              onPressed: () => _add(_text.text),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final sug in suggestions)
                        ActionChip(
                          label: Text(sug.replaceAll('_ ', '… ')),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _tap(sug),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
