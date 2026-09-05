import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/documents/clinical_pdf_generator.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class ProblemDashboardScreen extends ConsumerWidget {
  const ProblemDashboardScreen({required this.patient, super.key});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text('${patient.fullName} · problems')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _export(context, ref),
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('Generate Document'),
    ),
    body: StreamBuilder<List<PatientProblem>>(
      stream: ref.watch(clinicalDaoProvider).watchPatientProblems(patient.id),
      builder: (context, snapshot) {
        final problems = snapshot.data ?? const <PatientProblem>[];
        final active = problems
            .where((problem) => problem.status != 'Resolved')
            .toList(growable: false);
        if (active.isEmpty) {
          return const Center(child: Text('No active problems recorded.'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (var index = 0; index < active.length; index++)
              _ProblemTile(problem: active[index], number: index + 1),
          ],
        );
      },
    ),
  );

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in [
            'Admission Note',
            'Progress Note',
            'Discharge Summary',
            'OPD Prescription',
          ])
            ListTile(
              title: Text(value),
              onTap: () => Navigator.pop(sheetContext, value),
            ),
        ],
      ),
    );
    if (type == null || !context.mounted) return;
    final dao = ref.read(clinicalDaoProvider);
    final problems = await dao.watchPatientProblems(patient.id).first;
    final actions = problems.isEmpty
        ? <ClinicalAction>[]
        : await dao.watchActionsForProblem(problems.first.id).first;
    final encounters = await dao.getEncountersForPatient(patient.id);
    final icd11Codes = <String>{};
    final pmJayCodes = <String>{};
    for (final encounter in encounters) {
      final icd = encounter.dynamicData['icd11_code'];
      final pmJay = encounter.dynamicData['pmjay_code'];
      if (icd is String && icd.trim().isNotEmpty) icd11Codes.add(icd.trim());
      if (pmJay is String && pmJay.trim().isNotEmpty) pmJayCodes.add(pmJay.trim());
    }
    if (encounters.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record an encounter before generating a document.'),
          ),
        );
      }
      return;
    }
    if (problems.isEmpty && type == 'OPD Prescription') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Add a problem before generating an OPD prescription.',
            ),
          ),
        );
      }
      return;
    }
    final generator = ClinicalPdfGenerator();
    final bytes = switch (type) {
      'Admission Note' => await generator.generateAdmissionNote(
        patient,
        problems,
        encounters,
        actions,
      ),
      'Progress Note' => await generator.generateProgressNote(
        patient,
        encounters.first,
        encounters.first.aiSummary ?? '',
        actions,
      ),
      'Discharge Summary' => await generator.generateDischargeSummary(
        patient,
        problems.where((p) => p.status == 'Resolved').toList(),
        actions,
        'Follow-up as advised.',
        icd11Codes: icd11Codes.toList(growable: false),
        pmJayCodes: pmJayCodes.toList(growable: false),
      ),
      _ => await generator.generateOpdPrescription(
        patient,
        problems.first,
        actions,
      ),
    };
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(type),
        actions: [
          FilledButton.icon(
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (_) async => Uint8List.fromList(bytes),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
          IconButton(
            tooltip: 'Share PDF',
            onPressed: () => Share.shareXFiles([
              XFile.fromData(
                Uint8List.fromList(bytes),
                mimeType: 'application/pdf',
                name: 'clinical-document.pdf',
              ),
            ]),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}

class _ProblemTile extends ConsumerWidget {
  const _ProblemTile({required this.problem, required this.number});
  final PatientProblem problem;
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);
    return Card(
      child: ExpansionTile(
        title: Text('$number. ${problem.problemName}'),
        subtitle: Text(
          '${problem.status} · onset ${problem.onsetDate?.toIso8601String().split('T').first ?? 'unknown'}',
        ),
        children: [
          StreamBuilder<List<ClinicalAction>>(
            stream: dao.watchActionsForProblem(problem.id),
            builder: (context, snapshot) {
              final actions = snapshot.data ?? const <ClinicalAction>[];
              return Column(
                children: [
                  for (final action in actions)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.arrow_right),
                      title: Text(action.description),
                      subtitle: Text(action.actionType),
                    ),
                  OverflowBar(
                    children: [
                      TextButton.icon(
                        onPressed: () => _addAction(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Action'),
                      ),
                      FilledButton.tonal(
                        onPressed: () =>
                            _consultationMode(context, problem, actions),
                        child: const Text('Consultation Mode'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addAction(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final description = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add clinical action'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (description == null || description.isEmpty) return;
    await ref
        .read(clinicalDaoProvider)
        .insertClinicalAction(
          ClinicalActionsCompanion.insert(
            patientId: problem.patientId,
            problemId: problem.id,
            actionType: 'Consultation',
            description: description,
          ),
        );
  }

  void _consultationMode(
    BuildContext context,
    PatientProblem problem,
    List<ClinicalAction> actions,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(problem.problemName),
        content: Text(
          '• Status: ${problem.status}\n'
          '• Onset: ${problem.onsetDate?.toIso8601String().split('T').first ?? 'unknown'}\n'
          '• Current actions: ${actions.isEmpty ? 'none recorded' : actions.map((action) => action.description).join('; ')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
