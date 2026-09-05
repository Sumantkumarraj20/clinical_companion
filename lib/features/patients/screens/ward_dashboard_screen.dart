import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../../core/models/department_templates.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';

class WardDashboardScreen extends ConsumerStatefulWidget {
  const WardDashboardScreen({super.key});

  @override
  ConsumerState<WardDashboardScreen> createState() => _WardDashboardScreenState();
}

class _WardDashboardScreenState extends ConsumerState<WardDashboardScreen> {
  CrmiDepartment _department = CrmiDepartment.generalMedicine;
  String _ward = 'Ward 1';
  String _bed = 'Bed 1';

  @override
  Widget build(BuildContext context) {
    final encounters = ref.watch(clinicalDaoProvider).watchWardEncounters(
      department: _department.label,
      wardName: _ward,
      bedNumber: _bed,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Ward dashboard')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                DropdownButton<CrmiDepartment>(
                  value: _department,
                  items: [
                    for (final department in CrmiDepartment.values)
                      DropdownMenuItem(value: department, child: Text(department.label)),
                  ],
                  onChanged: (value) => setState(() => _department = value ?? _department),
                ),
                _selector('Ward', _ward, ['Ward 1', 'Ward 2', 'OPD'], (value) => setState(() => _ward = value)),
                _selector('Bed', _bed, [for (var i = 1; i <= 20; i++) 'Bed $i'], (value) => setState(() => _bed = value)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ClinicalEncounter>>(
              stream: encounters,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Unable to load ward data: ${snapshot.error}'));
                final rows = snapshot.data ?? const <ClinicalEncounter>[];
                if (rows.isEmpty) return const Center(child: Text('No encounters for this bed yet.'));
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final tag = 'ward-patient-${row.id}';
                    return FutureBuilder<Patient?>(
                      future: ref.read(clinicalDaoProvider).findPatient(row.patientId),
                      builder: (context, patientSnapshot) {
                        final patient = patientSnapshot.data;
                        if (patientSnapshot.connectionState != ConnectionState.done) {
                          return const SizedBox(height: 72, child: ShimmerLoading(rows: 1));
                        }
                        return Hero(
                          tag: tag,
                          child: Material(
                            color: Colors.transparent,
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(child: Text(patient?.fullName.substring(0, 1).toUpperCase() ?? '?')),
                                title: Text(patient?.fullName ?? 'Unknown patient'),
                                subtitle: Text('${row.sbp ?? '-'} / ${row.dbp ?? '-'} mmHg · PR ${row.pulse ?? '-'}\n${row.aiSummary ?? row.note ?? row.chiefComplaint ?? 'Clinical encounter'}'),
                                isThreeLine: true,
                                trailing: Text('${row.occurredAt.hour.toString().padLeft(2, '0')}:${row.occurredAt.minute.toString().padLeft(2, '0')}'),
                                onTap: patient == null ? null : () => context.go('/patients/${patient.id}', extra: {'patient': patient, 'heroTag': tag}),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _selector(String label, String value, List<String> items, ValueChanged<String> onChanged) =>
      DropdownButton<String>(
        value: value,
        hint: Text(label),
        items: [for (final item in items) DropdownMenuItem(value: item, child: Text(item))],
        onChanged: (next) { if (next != null) onChanged(next); },
      );
}
