import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  final _search = TextEditingController();
  String? _primaryId;
  String? _duplicateId;
  bool _saving = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(clinicalDaoProvider).watchAllPatients();
    return Scaffold(
      appBar: AppBar(title: const Text('Data management')),
      body: StreamBuilder<List<Patient>>(
        stream: stream,
        builder: (context, snapshot) {
          final query = _search.text.trim().toLowerCase();
          final patients = (snapshot.data ?? const <Patient>[]).where((patient) {
            return query.isEmpty ||
                patient.fullName.toLowerCase().contains(query) ||
                patient.hospitalRegNo.toLowerCase().contains(query) ||
                (patient.phoneNumber ?? '').contains(query);
          }).toList(growable: false);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Merge duplicate patient profiles', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('All encounters, investigations, problems, and actions will be reassigned to the primary profile.'),
              const SizedBox(height: 20),
              TextField(
                controller: _search,
                decoration: const InputDecoration(
                  labelText: 'Search patients',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _patientPicker(
                label: 'Primary patient',
                value: _primaryId,
                patients: patients,
                onChanged: (value) => setState(() => _primaryId = value),
              ),
              const SizedBox(height: 16),
              _patientPicker(
                label: 'Duplicate patient',
                value: _duplicateId,
                patients: patients,
                onChanged: (value) => setState(() => _duplicateId = value),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saving || _primaryId == null || _duplicateId == null || _primaryId == _duplicateId
                      ? null
                      : _confirmMerge,
                  icon: _saving
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.merge_type),
                  label: Text(_saving ? 'Merging...' : 'Merge duplicate into primary'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _patientPicker({
    required String label,
    required String? value,
    required List<Patient> patients,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: patients.any((patient) => patient.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final patient in patients)
          DropdownMenuItem(
            value: patient.id,
            child: Text('${patient.fullName} · ${patient.hospitalRegNo}', overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }

  Future<void> _confirmMerge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm patient merge'),
        content: const Text('This is a clinical data operation. The duplicate profile will be deleted after its records are reassigned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Merge records')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(clinicalDaoProvider).mergePatients(
        primaryPatientId: _primaryId!,
        duplicatePatientId: _duplicateId!,
      );
      if (mounted) {
        setState(() {
          _duplicateId = null;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient records merged locally and queued for sync.')));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Merge failed: $error')));
      }
    }
  }
}
