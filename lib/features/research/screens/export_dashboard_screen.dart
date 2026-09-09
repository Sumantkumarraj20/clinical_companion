import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import 'export_sink.dart';

class ExportDashboardScreen extends ConsumerStatefulWidget {
  const ExportDashboardScreen({super.key});

  @override
  ConsumerState<ExportDashboardScreen> createState() =>
      _ExportDashboardScreenState();
}

class _ExportDashboardScreenState extends ConsumerState<ExportDashboardScreen> {
  final _searchProblem = TextEditingController();
  final _searchIntervention = TextEditingController();
  String _selectedStatus = 'ALL';
  DateTimeRange? _dateRange;
  bool _deIdentify = true;
  bool _exporting = false;

  @override
  void dispose() {
    _searchProblem.dispose();
    _searchIntervention.dispose();
    super.dispose();
  }

  Future<void> _chooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (selected != null) setState(() => _dateRange = selected);
  }

  String _generateCsv(List<List<dynamic>> rows) {
    return rows
        .map((row) {
          return row
              .map((field) {
                final val = field?.toString() ?? '';
                if (val.contains(',') ||
                    val.contains('"') ||
                    val.contains('\n')) {
                  return '"${val.replaceAll('"', '""')}"';
                }
                return val;
              })
              .join(',');
        })
        .join('\r\n');
  }

  Future<void> _exportCsv(List<_ResearchRecord> records) async {
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching records to export.')),
      );
      return;
    }

    setState(() => _exporting = true);
    try {
      final rows = <List<dynamic>>[
        [
          'Subject ID',
          if (!_deIdentify) ...['Patient Name', 'Hospital CR/UHID', 'Phone'],
          'Age (Years)',
          'Gender',
          'Primary Problem / Diagnosis',
          'Trajectory Status',
          'Encounter Type',
          'Department',
          'Ward',
          'Bed',
          'Disposition',
          'Systolic BP',
          'Diastolic BP',
          'Pulse',
          'SpO2',
          'Date of Record',
          'Clinical Summary / Notes',
        ],
        for (var i = 0; i < records.length; i++)
          [
            _deIdentify
                ? 'SUBJ-${(i + 1).toString().padLeft(5, '0')}'
                : records[i].patient.id,
            if (!_deIdentify) ...[
              records[i].patient.fullName,
              records[i].hospitalRegNo,
              records[i].patient.phone ?? '',
            ],
            records[i].patient.approximateAge ?? '',
            records[i].patient.gender ?? 'Unspecified',
            records[i].primaryProblem,
            records[i].problemStatus,
            records[i].encounter?.encounterType ?? 'OPD',
            records[i].encounter?.department ?? '',
            records[i].encounter?.wardName ?? '',
            records[i].encounter?.bedNumber ?? '',
            records[i].encounter?.disposition ?? '',
            records[i].encounter?.sbp ?? '',
            records[i].encounter?.dbp ?? '',
            records[i].encounter?.pulse ?? '',
            records[i].encounter?.spo2 ?? '',
            records[i].encounter?.occurredAt
                    .toIso8601String()
                    .split('T')
                    .first ??
                records[i].patient.createdAt.toIso8601String().split('T').first,
            records[i].encounter?.clinicalAssessment ??
                records[i].encounter?.chiefComplaints ??
                '',
          ],
      ];

      final csvContent = _generateCsv(rows);
      final filename =
          'clinical_research_cohort_${DateTime.now().toUtc().toIso8601String().substring(0, 10)}.csv';
      final path = await saveCsvFile(filename, csvContent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${records.length} records to: $path'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportJson(List<_ResearchRecord> records) async {
    if (records.isEmpty) return;
    setState(() => _exporting = true);

    try {
      final dataset = [
        for (var i = 0; i < records.length; i++)
          {
            'subject_id': _deIdentify
                ? 'SUBJ-${(i + 1).toString().padLeft(5, '0')}'
                : records[i].patient.id,
            if (!_deIdentify) ...{
              'name': records[i].patient.fullName,
              'cr_number': records[i].hospitalRegNo,
            },
            'demographics': {
              'age': records[i].patient.approximateAge,
              'gender': records[i].patient.gender,
            },
            'problem_trajectory': {
              'problem_name': records[i].primaryProblem,
              'status': records[i].problemStatus,
            },
            'encounter': {
              'type': records[i].encounter?.encounterType,
              'department': records[i].encounter?.department,
              'ward': records[i].encounter?.wardName,
              'bed': records[i].encounter?.bedNumber,
              'disposition': records[i].encounter?.disposition,
              'vitals': {
                'sbp': records[i].encounter?.sbp,
                'dbp': records[i].encounter?.dbp,
                'pulse': records[i].encounter?.pulse,
                'spo2': records[i].encounter?.spo2,
              },
              'date': records[i].encounter?.occurredAt.toIso8601String(),
            },
          },
      ];

      final jsonString = const JsonEncoder.withIndent('  ').convert(dataset);
      final filename =
          'clinical_cohort_${DateTime.now().toUtc().toIso8601String().substring(0, 10)}.json';
      final path = await saveCsvFile(filename, jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported JSON dataset to: $path'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('JSON export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Research & Dataset Export'),
        actions: [
          Switch(
            value: _deIdentify,
            onChanged: (val) => setState(() => _deIdentify = val),
            activeThumbColor: Colors.amber,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _deIdentify ? 'De-identified' : 'Identified',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Patient>>(
        stream: dao.watchAllPatients(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load research cohort:\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final patients = snapshot.data ?? [];

          return FutureBuilder<List<_ResearchRecord>>(
            future: _buildResearchDataset(dao, patients),
            builder: (context, datasetSnapshot) {
              final allRecords = datasetSnapshot.data ?? [];
              final filteredRecords = _filterDataset(allRecords);

              return Column(
                children: [
                  // Filter Control Bar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              child: TextField(
                                controller: _searchProblem,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Problem / Diagnosis',
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  isDense: true,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 170,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Trajectory Status',
                                  isDense: true,
                                ),
                                items: [
                                  for (final st in [
                                    'ALL',
                                    'Active',
                                    'Improving',
                                    'Controlled',
                                    'Resolved',
                                    'Recurred',
                                  ])
                                    DropdownMenuItem(
                                      value: st,
                                      child: Text(st),
                                    ),
                                ],
                                onChanged: (v) => setState(
                                  () => _selectedStatus = v ?? 'ALL',
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _chooseDateRange,
                              icon: const Icon(Icons.date_range, size: 18),
                              label: Text(
                                _dateRange == null
                                    ? 'Date Range'
                                    : '${_dateRange!.start.toIso8601String().substring(0, 10)} – ${_dateRange!.end.toIso8601String().substring(0, 10)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            if (_dateRange != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() => _dateRange = null),
                                tooltip: 'Reset Date Filter',
                              ),
                            FilledButton.icon(
                              onPressed: _exporting
                                  ? null
                                  : () => _exportCsv(filteredRecords),
                              icon: _exporting
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.download, size: 18),
                              label: const Text('Export CSV'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _exporting
                                  ? null
                                  : () => _exportJson(filteredRecords),
                              icon: const Icon(Icons.data_object, size: 18),
                              label: const Text('JSON'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _deIdentify
                                  ? Icons.shield_outlined
                                  : Icons.lock_open,
                              size: 16,
                              color: _deIdentify ? Colors.green : Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _deIdentify
                                  ? '${filteredRecords.length} De-identified cases ready for research'
                                  : '${filteredRecords.length} Clinical records (Contains Protected Health Info)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _deIdentify
                                    ? Colors.green.shade800
                                    : Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Paginated Data Table
                  Expanded(
                    child: filteredRecords.isEmpty
                        ? const Center(
                            child: Text(
                              'No clinical records match the specified research criteria.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : SingleChildScrollView(
                            child: PaginatedDataTable(
                              header: const Text('Filtered Cohort Ledger'),
                              columns: [
                                const DataColumn(label: Text('Subject')),
                                if (!_deIdentify)
                                  const DataColumn(label: Text('Patient Name')),
                                const DataColumn(label: Text('Age/Sex')),
                                const DataColumn(
                                  label: Text('Problem / Diagnosis'),
                                ),
                                const DataColumn(label: Text('Trajectory')),
                                const DataColumn(label: Text('Disposition')),
                                const DataColumn(label: Text('Encounter Date')),
                              ],
                              source: _ResearchDataTableSource(
                                records: filteredRecords,
                                deIdentify: _deIdentify,
                              ),
                              rowsPerPage: 10,
                              showFirstLastButtons: true,
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<List<_ResearchRecord>> _buildResearchDataset(
    ClinicalDao dao,
    List<Patient> patients,
  ) async {
    final records = <_ResearchRecord>[];

    for (final p in patients) {
      final regNo = await dao.getPatientHospitalRegNo(p.id);
      final problems = await dao.watchPatientProblems(p.id).first;
      final encounters = await dao.getEncountersForPatient(p.id);

      final latestEncounter = encounters.isNotEmpty ? encounters.first : null;
      final primaryProb = problems.isNotEmpty
          ? problems.first.problemName
          : (latestEncounter?.clinicalDiagnosis ??
                latestEncounter?.chiefComplaints ??
                'Observation');
      final probStatus = problems.isNotEmpty
          ? problems.first.currentStatus
          : 'Active';

      records.add(
        _ResearchRecord(
          patient: p,
          hospitalRegNo: regNo,
          encounter: latestEncounter,
          primaryProblem: primaryProb,
          problemStatus: probStatus,
        ),
      );
    }

    return records;
  }

  List<_ResearchRecord> _filterDataset(List<_ResearchRecord> list) {
    final queryProblem = _searchProblem.text.trim().toLowerCase();

    return list.where((item) {
      if (queryProblem.isNotEmpty) {
        final matchesProblem = item.primaryProblem.toLowerCase().contains(
          queryProblem,
        );
        final matchesDiagnosis =
            item.encounter?.clinicalDiagnosis?.toLowerCase().contains(
              queryProblem,
            ) ??
            false;
        if (!matchesProblem && !matchesDiagnosis) return false;
      }

      if (_selectedStatus != 'ALL') {
        if (item.problemStatus != _selectedStatus) return false;
      }

      if (_dateRange != null) {
        final d = item.encounter?.occurredAt ?? item.patient.createdAt;
        if (d.isBefore(_dateRange!.start) ||
            d.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

class _ResearchRecord {
  _ResearchRecord({
    required this.patient,
    required this.hospitalRegNo,
    required this.encounter,
    required this.primaryProblem,
    required this.problemStatus,
  });

  final Patient patient;
  final String hospitalRegNo;
  final ClinicalEncounter? encounter;
  final String primaryProblem;
  final String problemStatus;
}

class _ResearchDataTableSource extends DataTableSource {
  _ResearchDataTableSource({required this.records, required this.deIdentify});

  final List<_ResearchRecord> records;
  final bool deIdentify;

  @override
  DataRow? getRow(int index) {
    if (index >= records.length) return null;
    final r = records[index];
    final subjId = deIdentify
        ? 'SUBJ-${(index + 1).toString().padLeft(5, '0')}'
        : r.hospitalRegNo;
    final dateStr =
        r.encounter?.occurredAt.toIso8601String().split('T').first ??
        r.patient.createdAt.toIso8601String().split('T').first;

    return DataRow(
      cells: [
        DataCell(
          Text(subjId, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (!deIdentify) DataCell(Text(r.patient.fullName)),
        DataCell(
          Text(
            '${r.patient.approximateAge ?? '--'}y · ${r.patient.gender ?? '?'}',
          ),
        ),
        DataCell(Text(r.primaryProblem)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: r.problemStatus == 'Resolved'
                  ? Colors.green.shade50
                  : r.problemStatus == 'Improving'
                  ? Colors.teal.shade50
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: r.problemStatus == 'Resolved'
                    ? Colors.green
                    : r.problemStatus == 'Improving'
                    ? Colors.teal
                    : Colors.amber,
              ),
            ),
            child: Text(
              r.problemStatus,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: r.problemStatus == 'Resolved'
                    ? Colors.green.shade900
                    : r.problemStatus == 'Improving'
                    ? Colors.teal.shade900
                    : Colors.amber.shade900,
              ),
            ),
          ),
        ),
        DataCell(Text(r.encounter?.disposition ?? 'Admitted')),
        DataCell(Text(dateStr)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => records.length;

  @override
  int get selectedRowCount => 0;
}
