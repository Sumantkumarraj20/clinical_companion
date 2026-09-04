import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/models/department_templates.dart';
import '../../../core/providers/app_providers.dart';

class DynamicEncounterScreen extends ConsumerStatefulWidget {
  const DynamicEncounterScreen({required this.patient, super.key});

  final Patient patient;

  @override
  ConsumerState<DynamicEncounterScreen> createState() =>
      _DynamicEncounterScreenState();
}

class _DynamicEncounterScreenState
    extends ConsumerState<DynamicEncounterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sbp = TextEditingController();
  final _dbp = TextEditingController();
  final _pulse = TextEditingController();
  final _complaint = TextEditingController();
  final _advice = TextEditingController();
  final _gcs = ValueNotifier<double>(15);
  final _departmentText = TextEditingController();
  final _drainOutput = TextEditingController();
  final _postOpDay = TextEditingController();
  final _wound = TextEditingController();
  final _mood = TextEditingController();
  final _appearance = TextEditingController();
  final _plan = TextEditingController();
  final _gravida = TextEditingController();
  final _para = TextEditingController();
  final _bishop = TextEditingController();
  final _fetalHeartRate = TextEditingController();
  final _gestationalAge = TextEditingController();
  final _thoughtProcess = TextEditingController();
  final _perception = TextEditingController();
  final _cognition = TextEditingController();
  final _insight = TextEditingController();
  bool _hallucinations = false;
  bool _suicidalIdeation = false;
  bool _homicidalIdeation = false;
  bool _saving = false;
  String _encounterType = 'Ward Round';
  double? _map;

  @override
  void initState() {
    super.initState();
    _sbp.addListener(_calculateMap);
    _dbp.addListener(_calculateMap);
  }

  @override
  void dispose() {
    for (final controller in [
      _sbp,
      _dbp,
      _pulse,
      _complaint,
      _advice,
      _departmentText,
      _drainOutput,
      _postOpDay,
      _wound,
      _mood,
      _appearance,
      _plan,
      _gravida,
      _para,
      _bishop,
      _fetalHeartRate,
      _gestationalAge,
      _thoughtProcess,
      _perception,
      _cognition,
      _insight,
    ]) {
      controller.dispose();
    }
    _gcs.dispose();
    super.dispose();
  }

  void _calculateMap() {
    final sbp = int.tryParse(_sbp.text);
    final dbp = int.tryParse(_dbp.text);
    setState(
      () => _map = sbp != null && dbp != null ? (sbp + (2 * dbp)) / 3 : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = ref.read(currentOwnerIdProvider);
    setState(() => _saving = true);
    try {
      final dynamicData = _buildTemplate().toJson();
      await ref
          .read(clinicalDaoProvider)
          .insertClinicalEncounter(
            ClinicalEncountersCompanion.insert(
              ownerId: ownerId,
              patientId: widget.patient.id,
              encounterType: Value(_encounterType),
              sbp: Value(int.parse(_sbp.text)),
              dbp: Value(int.parse(_dbp.text)),
              pulse: Value(int.tryParse(_pulse.text)),
              meanArterialPressure: Value(_map),
              chiefComplaint: Value(_complaint.text.trim()),
              consultantAdvice: Value(
                _advice.text.trim().isEmpty ? null : _advice.text.trim(),
              ),
              dynamicData: Value(dynamicData),
            ),
          );
      if (mounted) {
        _toast('Encounter saved offline and queued for sync.');
        _formKey.currentState!.reset();
        for (final controller in [
          _sbp,
          _dbp,
          _pulse,
          _complaint,
          _advice,
          _departmentText,
          _drainOutput,
          _postOpDay,
          _wound,
          _mood,
          _appearance,
          _plan,
          _gravida,
          _para,
          _bishop,
          _fetalHeartRate,
          _gestationalAge,
          _thoughtProcess,
          _perception,
          _cognition,
          _insight,
        ]) {
          controller.clear();
        }
        _map = null;
      }
    } catch (error) {
      if (mounted) _toast('Could not save encounter: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  ClinicalTemplate _buildTemplate() {
    switch (widget.patient.currentDepartment.toLowerCase()) {
      case 'medicine':
        return MedicineTemplate(
          systemicExamFindings: {'general': _departmentText.text.trim()},
          plan: _plan.text.trim(),
        );
      case 'obgyn':
        return ObGynTemplate(
          gravida: int.tryParse(_gravida.text) ?? 0,
          para: int.tryParse(_para.text) ?? 0,
          fetalHeartRate: int.tryParse(_fetalHeartRate.text) ?? 0,
          bishopScore: int.tryParse(_bishop.text) ?? 0,
          gestationalAge: _gestationalAge.text.trim(),
          partographNotes: _departmentText.text.trim(),
        );
      case 'surgery':
      case 'plastic surgery':
        return SurgeryTemplate(
          woundStatus: _wound.text.trim(),
          drainOutputMl: double.tryParse(_drainOutput.text) ?? 0,
          postOpDay: int.tryParse(_postOpDay.text) ?? 0,
        );
      case 'psychiatry':
        return PsychiatryTemplate(
          appearance: _appearance.text.trim(),
          mood: _mood.text.trim(),
          thoughtProcess: _thoughtProcess.text.trim(),
          perception: _perception.text.trim(),
          cognition: _cognition.text.trim(),
          insight: _insight.text.trim(),
          hallucinations: _hallucinations,
          suicidalIdeation: _suicidalIdeation,
          homicidalIdeation: _homicidalIdeation,
        );
      case 'emergency':
      case 'trauma':
        return GenericClinicalTemplate(
          values: {
            'gcs': _gcs.value.round(),
            'notes': _departmentText.text.trim(),
          },
        );
      default:
        return GenericClinicalTemplate(
          values: {'notes': _departmentText.text.trim()},
        );
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final department = widget.patient.currentDepartment;
    return Scaffold(
      appBar: AppBar(
        title: Text('$department encounter'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Chip(label: Text(widget.patient.fullName))),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          children: [
            Text(
              'Universal observations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _encounterType,
              decoration: const InputDecoration(labelText: 'Encounter type'),
              items: [
                for (final type in [
                  'Ward Round',
                  'OPD',
                  'Pre-Op',
                  'Procedure',
                  'Emergency',
                  'Follow-Up',
                ])
                  DropdownMenuItem(value: type, child: Text(type)),
              ],
              onChanged: (value) =>
                  setState(() => _encounterType = value ?? _encounterType),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _number(_sbp, 'SBP', _validateSbp)),
                const SizedBox(width: 10),
                Expanded(child: _number(_dbp, 'DBP', _validateDbp)),
                const SizedBox(width: 10),
                Expanded(child: _number(_pulse, 'Pulse', _required)),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('Mean arterial pressure'),
                trailing: Text(
                  _map == null ? '—' : '${_map!.toStringAsFixed(0)} mmHg',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            TextFormField(
              controller: _complaint,
              minLines: 2,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Chief complaint',
                alignLabelWithHint: true,
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _advice,
              minLines: 2,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Consultant advice',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Department-specific template',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _departmentForm(department),
            const SizedBox(height: 24),
            SizedBox(
              height: 60,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Saving…' : 'Save encounter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _departmentForm(String department) {
    switch (department.trim().toLowerCase()) {
      case 'medicine':
        return Column(
          children: [
            _largeText(_departmentText, 'Systemic examination findings'),
            _largeText(_plan, 'Assessment and plan'),
          ],
        );
      case 'obgyn':
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _number(_gravida, 'Gravida', _optional)),
                const SizedBox(width: 10),
                Expanded(child: _number(_para, 'Para', _optional)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _number(
                    _fetalHeartRate,
                    'Fetal heart rate',
                    _optional,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _number(_bishop, 'Bishop score', _optional)),
              ],
            ),
            _largeText(_gestationalAge, 'Gestational age'),
            _largeText(_departmentText, 'Partograph / obstetric notes'),
          ],
        );
      case 'surgery':
      case 'plastic surgery':
        return Column(
          children: [
            _largeText(_wound, 'Wound status'),
            Row(
              children: [
                Expanded(
                  child: _number(
                    _drainOutput,
                    'Drain output (mL)',
                    _optional,
                    decimal: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _number(_postOpDay, 'Post-op day', _optional)),
              ],
            ),
          ],
        );
      case 'psychiatry':
        return Column(
          children: [
            _largeText(_appearance, 'Appearance / behavior'),
            _largeText(_mood, 'Mood / affect'),
            _largeText(_thoughtProcess, 'Thought process'),
            _largeText(_perception, 'Perception'),
            _largeText(_cognition, 'Cognition'),
            _largeText(_insight, 'Insight'),
            SwitchListTile(
              title: const Text('Hallucinations'),
              value: _hallucinations,
              onChanged: (value) => setState(() => _hallucinations = value),
            ),
            SwitchListTile(
              title: const Text('Suicidal ideation'),
              value: _suicidalIdeation,
              onChanged: (value) => setState(() => _suicidalIdeation = value),
            ),
            SwitchListTile(
              title: const Text('Homicidal ideation'),
              value: _homicidalIdeation,
              onChanged: (value) => setState(() => _homicidalIdeation = value),
            ),
          ],
        );
      case 'emergency':
      case 'trauma':
        return Column(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _gcs,
              builder: (context, value, child) => ListTile(
                title: const Text('Glasgow Coma Scale'),
                trailing: Text(
                  value.round().toString(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _gcs,
              builder: (context, value, child) => Slider(
                min: 3,
                max: 15,
                divisions: 12,
                value: value,
                label: value.round().toString(),
                onChanged: (next) => _gcs.value = next,
              ),
            ),
            _largeText(_departmentText, 'Trauma notes'),
          ],
        );
      default:
        return _largeText(_departmentText, 'Department notes');
    }
  }

  Widget _number(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    bool decimal = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.]' : r'[0-9]')),
    ],
    textInputAction: TextInputAction.next,
    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
    ),
    validator: validator,
  );

  Widget _largeText(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      minLines: 2,
      maxLines: 4,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  String? _validateSbp(String? value) {
    final sbp = int.tryParse(value ?? '');
    final dbp = int.tryParse(_dbp.text);
    if (sbp == null || sbp <= 0) return 'Required';
    if (dbp != null && sbp <= dbp) return 'Must exceed DBP';
    return null;
  }

  String? _validateDbp(String? value) {
    final dbp = int.tryParse(value ?? '');
    final sbp = int.tryParse(_sbp.text);
    if (dbp == null || dbp <= 0) return 'Required';
    if (sbp != null && sbp <= dbp) return 'SBP must exceed DBP';
    return null;
  }

  String? _optional(String? value) => value == null || value.trim().isEmpty
      ? null
      : (double.tryParse(value) == null ? 'Enter a number' : null);
}
