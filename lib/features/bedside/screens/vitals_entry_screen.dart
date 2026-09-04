import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class VitalsEntryScreen extends ConsumerStatefulWidget {
  const VitalsEntryScreen({super.key});

  @override
  ConsumerState<VitalsEntryScreen> createState() => _VitalsEntryScreenState();
}

class _VitalsEntryScreenState extends ConsumerState<VitalsEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sbp = TextEditingController();
  final _dbp = TextEditingController();
  final _pulse = TextEditingController();
  final _complaint = TextEditingController();
  final _advice = TextEditingController();
  String? _patientId;
  double? _map;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _sbp.addListener(_updateMap);
    _dbp.addListener(_updateMap);
  }

  @override
  void dispose() {
    _sbp.dispose();
    _dbp.dispose();
    _pulse.dispose();
    _complaint.dispose();
    _advice.dispose();
    super.dispose();
  }

  void _updateMap() {
    final systolic = int.tryParse(_sbp.text);
    final diastolic = int.tryParse(_dbp.text);
    setState(() {
      _map = systolic != null && diastolic != null
          ? (systolic + (2 * diastolic)) / 3
          : null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = ref.read(currentOwnerIdProvider);
    if (_patientId == null) {
      _message('Sign in and select a patient before saving.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(clinicalDaoProvider)
          .insertDailyNote(
            DailyNotesCompanion.insert(
              ownerId: ownerId,
              patientId: _patientId!,
              sbp: Value(int.parse(_sbp.text)),
              dbp: Value(int.parse(_dbp.text)),
              pulse: Value(int.tryParse(_pulse.text)),
              meanArterialPressure: Value(_map),
              chiefComplaint: Value(
                _complaint.text.trim().isEmpty ? null : _complaint.text.trim(),
              ),
              consultantAdvice: Value(
                _advice.text.trim().isEmpty ? null : _advice.text.trim(),
              ),
            ),
          );
      if (mounted) {
        _sbp.clear();
        _dbp.clear();
        _pulse.clear();
        _complaint.clear();
        _advice.clear();
        _message('Saved locally and queued for synchronization.');
      }
    } catch (error) {
      if (mounted) _message('Could not save vitals: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(clinicalDaoProvider).watchAllPatients();
    return Scaffold(
      appBar: AppBar(title: const Text('Bedside vitals rapid entry')),
      body: StreamBuilder<List<Patient>>(
        stream: patients,
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Patient>[];
          if (_patientId != null &&
              rows.every((patient) => patient.id != _patientId)) {
            _patientId = null;
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _patientId,
                  decoration: const InputDecoration(
                    labelText: 'Patient',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: [
                    for (final patient in rows)
                      DropdownMenuItem(
                        value: patient.id,
                        child: Text(
                          '${patient.fullName} · ${patient.hospitalRegNo}',
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _patientId = value),
                  validator: (value) =>
                      value == null ? 'Select a patient' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _sbp,
                        label: 'SBP',
                        autofocus: true,
                        validator: _validateSbp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _dbp,
                        label: 'DBP',
                        validator: _validateDbp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _pulse,
                        label: 'Pulse',
                        validator: _validatePulse,
                        last: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mean arterial pressure',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _map == null
                              ? '— mmHg'
                              : '${_map!.toStringAsFixed(0)} mmHg',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _complaint,
                  textInputAction: TextInputAction.next,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Chief complaint',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _advice,
                  textInputAction: TextInputAction.done,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Consultant advice',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_saving ? 'Saving…' : 'Save vitals'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool autofocus = false,
    bool last = false,
  }) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        suffixText: label == 'Pulse' ? 'bpm' : 'mmHg',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 20,
        ),
      ),
      validator: validator,
    );
  }

  String? _validateSbp(String? value) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) return 'Required';
    final dbp = int.tryParse(_dbp.text);
    if (dbp != null && number <= dbp) return 'Must exceed DBP';
    return null;
  }

  String? _validateDbp(String? value) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) return 'Required';
    final sbp = int.tryParse(_sbp.text);
    if (sbp != null && sbp <= number) return 'SBP must exceed DBP';
    return null;
  }

  String? _validatePulse(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number <= 0 ? 'Required' : null;
  }
}
