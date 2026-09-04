import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class PatientRegistryScreen extends ConsumerWidget {
  const PatientRegistryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Patient registry')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showPatientEditor(context, ref),
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Add patient'),
    ),
    body: StreamBuilder<List<Patient>>(
      stream: ref.watch(clinicalDaoProvider).watchAllPatients(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Unable to load patients: ${snapshot.error}'),
          );
        }
        final patients = snapshot.data ?? const <Patient>[];
        if (patients.isEmpty) {
          return const Center(
            child: Text('Add a patient to begin recording care.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
          itemCount: patients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final patient = patients[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(patient.fullName.substring(0, 1).toUpperCase()),
                ),
                title: Text(patient.fullName),
                subtitle: Text(
                  '${patient.hospitalRegNo} · ${patient.currentDepartment}${patient.diagnosis == null ? '' : '\n${patient.diagnosis}'}',
                ),
                isThreeLine: patient.diagnosis != null,
                onTap: () =>
                    context.go('/patients/${patient.id}', extra: patient),
                trailing: IconButton(
                  tooltip: 'Edit patient',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () =>
                      _showPatientEditor(context, ref, patient: patient),
                ),
              ),
            );
          },
        );
      },
    ),
  );

  Future<void> _showPatientEditor(
    BuildContext context,
    WidgetRef ref, {
    Patient? patient,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _PatientEditor(patient: patient),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            patient == null
                ? 'Patient saved locally.'
                : 'Patient updated locally.',
          ),
        ),
      );
    }
  }
}

class _PatientEditor extends ConsumerStatefulWidget {
  const _PatientEditor({this.patient});
  final Patient? patient;
  @override
  ConsumerState<_PatientEditor> createState() => _PatientEditorState();
}

class _PatientEditorState extends ConsumerState<_PatientEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.patient?.fullName ?? '',
  );
  late final _registration = TextEditingController(
    text: widget.patient?.hospitalRegNo ?? '',
  );
  late final _diagnosis = TextEditingController(
    text: widget.patient?.diagnosis ?? '',
  );
  late final _surgery = TextEditingController(
    text: widget.patient?.surgeryType ?? '',
  );
  String _department = 'Surgery';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _department = widget.patient?.currentDepartment ?? _department;
  }

  @override
  void dispose() {
    _name.dispose();
    _registration.dispose();
    _diagnosis.dispose();
    _surgery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.patient == null ? 'Add patient' : 'Edit patient'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registration,
                decoration: const InputDecoration(
                  labelText: 'Hospital registration number',
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _department,
                decoration: const InputDecoration(labelText: 'Department'),
                items: [
                  for (final item in const [
                    'Medicine',
                    'OBGYN',
                    'Surgery',
                    'Plastic Surgery',
                    'Psychiatry',
                    'Emergency',
                  ])
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) =>
                    setState(() => _department = value ?? _department),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosis,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _surgery,
                decoration: const InputDecoration(
                  labelText: 'Surgery / procedure',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving…' : 'Save'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final dao = ref.read(clinicalDaoProvider);
      final existing = widget.patient;
      if (existing == null) {
        await dao.insertPatient(
          PatientsCompanion.insert(
            ownerId: ref.read(currentOwnerIdProvider),
            hospitalRegNo: _registration.text.trim(),
            fullName: _name.text.trim(),
            currentDepartment: Value(_department),
            diagnosis: Value(_emptyToNull(_diagnosis.text)),
            surgeryType: Value(_emptyToNull(_surgery.text)),
          ),
        );
      } else {
        await dao.updatePatient(
          existing.copyWith(
            hospitalRegNo: _registration.text.trim(),
            fullName: _name.text.trim(),
            currentDepartment: _department,
            diagnosis: Value(_emptyToNull(_diagnosis.text)),
            surgeryType: Value(_emptyToNull(_surgery.text)),
          ),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save patient: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
