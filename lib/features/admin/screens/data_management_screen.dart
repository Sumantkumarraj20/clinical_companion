import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/database/daos/clinical_dao.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
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
    final dao = ref.watch(clinicalDaoProvider);
    final stream = dao.watchAllPatients();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Data Management & Merging')),
      body: StreamBuilder<List<Patient>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load patient records:\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final query = _search.text.trim().toLowerCase();
          final allPatients = snapshot.data ?? const <Patient>[];
          final patients = allPatients
              .where((patient) {
                return query.isEmpty ||
                    patient.fullName.toLowerCase().contains(query) ||
                    (patient.phone ?? '').contains(query) ||
                    (patient.addressOrLocation ?? '').toLowerCase().contains(
                      query,
                    );
              })
              .toList(growable: false);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.merge_type_rounded,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Merge Duplicate Patient Records',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Consolidates two fragmented profiles. All encounters, problem trajectories, '
                            'lab workorders, operative notes, and prescriptions are atomically '
                            'reassigned to the target primary profile.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Filter
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'Filter Patients for Merging',
                  hintText: 'Search by patient name, phone, or location…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Step 1: Target Primary Profile
              Text(
                '1. Target Primary Profile (Profile to KEEP)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              _patientPicker(
                label: 'Select Target Primary Patient',
                value: _primaryId,
                patients: patients,
                dao: dao,
                onChanged: (value) => setState(() => _primaryId = value),
              ),
              const SizedBox(height: 18),

              // Step 2: Duplicate Profile
              Text(
                '2. Secondary Duplicate Profile (To be ABSORBED & PURGED)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 6),
              _patientPicker(
                label: 'Select Duplicate Profile',
                value: _duplicateId,
                patients: patients,
                dao: dao,
                onChanged: (value) => setState(() => _duplicateId = value),
              ),
              const SizedBox(height: 28),

              // Warning Banner
              if (_primaryId != null &&
                  _duplicateId != null &&
                  _primaryId != _duplicateId)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade600),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade900,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Irreversible clinical action: All historical episodes will be reassigned. '
                          'The duplicate identity will be purged locally and synced.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Action Button
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed:
                      _saving ||
                          _primaryId == null ||
                          _duplicateId == null ||
                          _primaryId == _duplicateId
                      ? null
                      : _confirmMerge,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.merge_type),
                  label: Text(
                    _saving
                        ? 'Executing Ledger Merge…'
                        : 'Merge Records Atomically',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    required ClinicalDao dao,
    required ValueChanged<String?> onChanged,
  }) {
    final hasValidSelection = patients.any((p) => p.id == value);

    return DropdownButtonFormField<String>(
      initialValue: hasValidSelection ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
      items: [
        for (final patient in patients)
          DropdownMenuItem(
            value: patient.id,
            child: FutureBuilder<String>(
              future: dao.getPatientHospitalRegNo(patient.id),
              builder: (context, snapshot) {
                final cr = snapshot.data ?? '…';
                return Text(
                  '${patient.fullName} (CR: $cr) · ${patient.gender ?? '?'}, ${patient.approximateAge ?? '--'}y',
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }

  Future<void> _confirmMerge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Patient Ledger Merge'),
        content: const Text(
          'Are you sure you want to proceed?\n\n'
          'All encounters, problem trajectories, lab workorders, and prescriptions '
          'belonging to the secondary profile will be moved into the primary profile. '
          'The secondary identity will then be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm & Merge'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);

    try {
      await ref
          .read(clinicalDaoProvider)
          .mergePatients(
            primaryPatientId: _primaryId!,
            duplicatePatientId: _duplicateId!,
          );

      if (mounted) {
        setState(() {
          _duplicateId = null;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Patient records merged successfully in local ledger.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merge failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
