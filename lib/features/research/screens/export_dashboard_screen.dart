import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _diagnosis = TextEditingController();
  final _surgery = TextEditingController();
  final _complications = TextEditingController();
  DateTimeRange? _dateRange;
  bool _exporting = false;

  @override
  void dispose() {
    _diagnosis.dispose();
    _surgery.dispose();
    _complications.dispose();
    super.dispose();
  }

  List<Patient> _filter(List<Patient> rows) {
    final diagnosis = _diagnosis.text.trim().toLowerCase();
    final surgery = _surgery.text.trim().toLowerCase();
    final complications = _complications.text.trim().toLowerCase();
    return rows
        .where((patient) {
          final date = patient.admissionDate;
          return (diagnosis.isEmpty ||
                  (patient.diagnosis ?? '').toLowerCase().contains(
                    diagnosis,
                  )) &&
              (surgery.isEmpty ||
                  (patient.surgeryType ?? '').toLowerCase().contains(
                    surgery,
                  )) &&
              (complications.isEmpty ||
                  (patient.complications ?? '').toLowerCase().contains(
                    complications,
                  )) &&
              (_dateRange == null ||
                  (date != null &&
                      !date.isBefore(_dateRange!.start) &&
                      !date.isAfter(
                        _dateRange!.end.add(const Duration(days: 1)),
                      )));
        })
        .toList(growable: false);
  }

  Future<void> _chooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (selected != null) setState(() => _dateRange = selected);
  }

  Future<void> _export(List<Patient> rows) async {
    setState(() => _exporting = true);
    try {
      final csv = Csv(lineDelimiter: '\n').encode([
        [
          'record_number',
          'diagnosis',
          'surgery_type',
          'admission_date',
          'discharge_date',
          'complications',
        ],
        for (var index = 0; index < rows.length; index++)
          [
            'CASE-${(index + 1).toString().padLeft(5, '0')}',
            rows[index].diagnosis ?? '',
            rows[index].surgeryType ?? '',
            rows[index].admissionDate?.toIso8601String() ?? '',
            rows[index].dischargeDate?.toIso8601String() ?? '',
            rows[index].complications ?? '',
          ],
      ]);
      final filename =
          'medassit_registry_${DateTime.now().toUtc().toIso8601String().substring(0, 10)}.csv';
      final destination = await saveCsvFile(filename, csv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${rows.length} records to $destination'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(clinicalDaoProvider).watchAllPatients();
    return Scaffold(
      appBar: AppBar(title: const Text('Research export')),
      body: StreamBuilder<List<Patient>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load registry: ${snapshot.error}'),
            );
          }
          final rows = _filter(snapshot.data ?? const <Patient>[]);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 210,
                      child: TextField(
                        controller: _diagnosis,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Diagnosis',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 210,
                      child: TextField(
                        controller: _surgery,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Surgery type',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 210,
                      child: TextField(
                        controller: _complications,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Complications',
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _chooseDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _dateRange == null
                            ? 'Date range'
                            : '${_dateRange!.start.toIso8601String().substring(0, 10)} – ${_dateRange!.end.toIso8601String().substring(0, 10)}',
                      ),
                    ),
                    if (_dateRange != null)
                      IconButton(
                        tooltip: 'Clear date filter',
                        onPressed: () => setState(() => _dateRange = null),
                        icon: const Icon(Icons.clear),
                      ),
                    FilledButton.icon(
                      onPressed: _exporting ? null : () => _export(rows),
                      icon: _exporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text('Export to CSV'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${rows.length} de-identified records'),
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const Center(
                        child: Text('No records match the selected filters.'),
                      )
                    : SingleChildScrollView(
                        child: PaginatedDataTable(
                          columns: const [
                            DataColumn(label: Text('Patient')),
                            DataColumn(label: Text('Registration')),
                            DataColumn(label: Text('Diagnosis')),
                            DataColumn(label: Text('Surgery')),
                            DataColumn(label: Text('Admission')),
                            DataColumn(label: Text('Complications')),
                          ],
                          source: _PatientDataSource(rows),
                          rowsPerPage: 10,
                          showFirstLastButtons: true,
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

class _PatientDataSource extends DataTableSource {
  _PatientDataSource(this.rows);

  final List<Patient> rows;

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final patient = rows[index];
    return DataRow(
      cells: [
        DataCell(Text(patient.fullName)),
        DataCell(Text(patient.hospitalRegNo)),
        DataCell(Text(patient.diagnosis ?? '—')),
        DataCell(Text(patient.surgeryType ?? '—')),
        DataCell(
          Text(
            patient.admissionDate?.toIso8601String().substring(0, 10) ?? '—',
          ),
        ),
        DataCell(Text(patient.complications ?? '—')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}
