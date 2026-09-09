import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  int _step = 0;
  String? _patientId;
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _gender = TextEditingController();
  final _phone = TextEditingController();
  final _sbp = TextEditingController();
  final _dbp = TextEditingController();
  final _pulse = TextEditingController();
  final _spo2 = TextEditingController();
  final _complaint = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_name, _age, _gender, _phone, _sbp, _dbp, _pulse, _spo2, _complaint, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(clinicalDaoProvider).saveManualEncounter(
        ownerId: ref.read(currentOwnerIdProvider),
        patientId: _patientId,
        patientName: _name.text,
        patientAge: int.tryParse(_age.text),
        patientGender: _gender.text,
        patientPhone: _phone.text,
        sbp: int.tryParse(_sbp.text),
        dbp: int.tryParse(_dbp.text),
        pulse: int.tryParse(_pulse.text),
        spo2: int.tryParse(_spo2.text),
        chiefComplaint: _complaint.text,
        note: _notes.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quick entry saved locally and queued for sync.')));
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save entry: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Manual quick entry')),
    body: SafeArea(
      child: Stepper(
        currentStep: _step,
        onStepTapped: (step) => setState(() => _step = step),
        onStepContinue: () {
          if (_step < 2) {
            setState(() => _step++);
          } else {
            _save();
          }
        },
        onStepCancel: _step == 0 ? null : () => setState(() => _step--),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              FilledButton(onPressed: _saving ? null : details.onStepContinue, child: Text(_step == 2 ? 'Save to record' : 'Continue')),
              if (_step > 0) ...[const SizedBox(width: 12), TextButton(onPressed: details.onStepCancel, child: const Text('Back'))],
            ],
          ),
        ),
        steps: [
          Step(title: const Text('Patient link'), isActive: _step >= 0, content: _patientFields()),
          Step(title: const Text('Vitals & complaint'), isActive: _step >= 1, content: _vitalFields()),
          Step(title: const Text('Clinical notes'), isActive: _step >= 2, content: _notesFields()),
        ],
      ),
    ),
  );

  Widget _patientFields() {
    final patients = ref.watch(clinicalDaoProvider).watchAllPatients();
    return Column(
      children: [
        StreamBuilder<List<Patient>>(
          stream: patients,
          builder: (context, snapshot) => Autocomplete<Patient>(
            displayStringForOption: (patient) => '${patient.fullName} · ${patient.id}',
            optionsBuilder: (value) {
              final query = value.text.toLowerCase().trim();
              return (snapshot.data ?? const <Patient>[]).where((patient) => query.isEmpty || patient.fullName.toLowerCase().contains(query) || patient.id.toLowerCase().contains(query));
            },
            onSelected: (patient) {
              _patientId = patient.id;
              _name.text = patient.fullName;
              _gender.text = patient.gender ?? '';
              _phone.text = patient.phone ?? '';
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'Search existing patient or enter a new name')),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name'))), const SizedBox(width: 8), Expanded(child: TextField(controller: _age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age')))]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: TextField(controller: _gender, decoration: const InputDecoration(labelText: 'Gender'))), const SizedBox(width: 8), Expanded(child: TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')))]),
      ],
    );
  }

  Widget _vitalFields() => Column(children: [
    Row(children: [Expanded(child: _number('SBP', _sbp)), const SizedBox(width: 8), Expanded(child: _number('DBP', _dbp))]),
    const SizedBox(height: 12),
    Row(children: [Expanded(child: _number('Pulse', _pulse)), const SizedBox(width: 8), Expanded(child: _number('SpO2', _spo2))]),
    const SizedBox(height: 12),
    TextField(controller: _complaint, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Chief complaint')),
  ]);

  Widget _notesFields() => TextField(controller: _notes, minLines: 8, maxLines: 14, decoration: const InputDecoration(labelText: 'Progress notes or orders', alignLabelWithHint: true));

  Widget _number(String label, TextEditingController controller) => TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label));
}