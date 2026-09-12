import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import 'encounter_ipd_extra.dart';

/// IPD Bedside Note mode: active problems with resolve switches.
class IpdProblemList extends ConsumerWidget {
  const IpdProblemList({required this.patientId, super.key});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Problems',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            StreamBuilder<List<PatientProblem>>(
              stream: dao.watchPatientProblems(patientId),
              builder: (context, snapshot) {
                final problems = snapshot.data ?? const [];
                if (problems.isEmpty) {
                  return const Text('No problems recorded yet.',
                      style: TextStyle(fontSize: 12, color: Colors.grey));
                }
                return Column(
                  children: [
                    for (final problem in problems)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          problem.problemName.trim().isEmpty
                              ? 'Not recorded'
                              : problem.problemName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          problem.currentStatus.trim().toLowerCase() ==
                                  'resolved'
                              ? 'Resolved'
                              : 'Active — switch to mark Resolved',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: problem.currentStatus
                                .trim()
                                .toLowerCase() ==
                            'resolved',
                        onChanged: (value) => dao.setProblemStatus(
                            problemId: problem.id, resolved: value),
                      ),
                  ],
                );
              },
            ),
            AddProblemField(patientId: patientId),
          ],
        ),
      ),
    );
  }
}
