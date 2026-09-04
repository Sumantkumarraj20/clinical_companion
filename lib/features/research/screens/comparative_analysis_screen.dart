import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

class ComparativeAnalysisScreen extends ConsumerStatefulWidget {
  const ComparativeAnalysisScreen({super.key});

  @override
  ConsumerState<ComparativeAnalysisScreen> createState() =>
      _ComparativeAnalysisScreenState();
}

class _ComparativeAnalysisScreenState
    extends ConsumerState<ComparativeAnalysisScreen> {
  String? _problemId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Comparative analysis')),
    body: FutureBuilder<List<Map<String, Object?>>>(
      future: ref.read(clinicalDaoProvider).comparativeOutcomes(_problemId),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <Map<String, Object?>>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButton<String>(
              value: _problemId,
              hint: const Text('Select a problem'),
              items: [
                for (final row in rows)
                  DropdownMenuItem(
                    value: row['problem_id'] as String,
                    child: Text(row['problem_name'] as String),
                  ),
              ],
              onChanged: (value) => setState(() => _problemId = value),
            ),
            if (_problemId != null)
              DataTable(
                columns: const [
                  DataColumn(label: Text('Treatment')),
                  DataColumn(label: Text('Mean value')),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      cells: [
                        DataCell(
                          Text('${row['treatment_method'] ?? 'Unspecified'}'),
                        ),
                        DataCell(Text('${row['average_value'] ?? '-'}')),
                      ],
                    ),
                ],
              ),
          ],
        );
      },
    ),
  );
}
