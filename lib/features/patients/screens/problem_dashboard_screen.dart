import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/local_database.dart';
import '../../../core/documents/clinical_pdf_generator.dart';
import '../../../core/providers/app_providers.dart';

class ProblemDashboardScreen extends ConsumerWidget {
  const ProblemDashboardScreen({required this.patient, super.key});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.fullName} · Problems'),
        actions: [
          FutureBuilder<String>(
            future: dao.getPatientHospitalRegNo(patient.id),
            builder: (context, snapshot) {
              final cr = snapshot.data ?? '…';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Chip(
                    label: Text(
                      'CR: $cr',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _export(context, ref),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Generate Document'),
      ),
      body: StreamBuilder<List<PatientProblem>>(
        stream: dao.watchPatientProblems(patient.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load problems:\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final problems = snapshot.data ?? const <PatientProblem>[];
          if (problems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Problems Recorded',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Problems added during clinical rounds appear here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
            itemCount: problems.length,
            itemBuilder: (context, index) {
              return _ProblemTile(problem: problems[index], number: index + 1);
            },
          );
        },
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final value in [
              'Admission Note',
              'Progress Note',
              'Discharge Summary',
              'OPD Prescription',
            ])
              ListTile(
                leading: Icon(
                  value.contains('Prescription')
                      ? Icons.medication_outlined
                      : Icons.description_outlined,
                ),
                title: Text(value),
                onTap: () => Navigator.pop(sheetContext, value),
              ),
          ],
        ),
      ),
    );

    if (type == null || !context.mounted) return;
    final dao = ref.read(clinicalDaoProvider);
    final problems = await dao.watchPatientProblems(patient.id).first;
    final encounters = await dao.getEncountersForPatient(patient.id);

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

    final latestEncounter = encounters.first;
    final hospitalRegNo = await dao.getPatientHospitalRegNo(patient.id);

    // Fetch interventions associated with the first problem if available
    final actions = problems.isEmpty
        ? <ClinicalIntervention>[]
        : await dao.watchActionsForProblem(problems.first.id).first;

    // Fetch active prescriptions for the patient
    final prescriptions = await (dao.select(
      dao.prescriptionOrders,
    )..where((p) => p.patientId.equals(patient.id))).get();

    final icd11Codes = <String>{};
    final pmJayCodes = <String>{};
    for (final enc in encounters) {
      final icd = enc.dynamicData['icd11_code'];
      final pmJay = enc.dynamicData['pmjay_code'];
      if (icd is String && icd.trim().isNotEmpty) icd11Codes.add(icd.trim());
      if (pmJay is String && pmJay.trim().isNotEmpty) {
        pmJayCodes.add(pmJay.trim());
      }
    }

    final generator = ClinicalPdfGenerator();
    final List<int> bytes;

    switch (type) {
      case 'Admission Note':
        bytes = await generator.generateAdmissionNote(
          patient: patient,
          problems: problems,
          admissionEncounter: latestEncounter,
          plannedProcedures: actions,
          initialMedications: prescriptions,
          hospitalRegNo: hospitalRegNo,
        );
        break;

      case 'Progress Note':
        bytes = await generator.generateProgressNote(
          patient: patient,
          roundEncounter: latestEncounter,
          currentMeds: prescriptions,
          newInterventions: actions,
          hospitalRegNo: hospitalRegNo,
        );
        break;

      case 'Discharge Summary':
        bytes = await generator.generateDischargeSummary(
          patient: patient,
          dischargeEncounter: latestEncounter,
          allProblems: problems,
          performedProcedures: actions,
          dischargeMedications: prescriptions,
          followUpAdvice:
              'Review in OPD after 7 days with repeat investigation reports.',
          hospitalRegNo: hospitalRegNo,
          icd11Codes: icd11Codes.toList(growable: false),
          pmJayCodes: pmJayCodes.toList(growable: false),
        );
        break;

      case 'OPD Prescription':
      default:
        bytes = await generator.generateOpdPrescription(
          patient: patient,
          encounter: latestEncounter,
          medications: prescriptions,
          hospitalRegNo: hospitalRegNo,
        );
        break;
    }

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(type),
        content: const Text(
          'Clinical document generated successfully. Select an action:',
        ),
        actions: [
          IconButton(
            tooltip: 'Share PDF',
            onPressed: () => Share.shareXFiles([
              XFile.fromData(
                Uint8List.fromList(bytes),
                mimeType: 'application/pdf',
                name: '${patient.fullName.replaceAll(' ', '_')}_$type.pdf',
              ),
            ]),
            icon: const Icon(Icons.share),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (_) async => Uint8List.fromList(bytes),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Document'),
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
    final isResolved = problem.currentStatus == 'Resolved';

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isResolved
              ? Colors.green.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          '$number. ${problem.problemName}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isResolved ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${problem.currentStatus} · Onset: ${problem.onsetDate?.toIso8601String().split('T').first ?? 'Noted on admission'}',
          style: TextStyle(
            color: isResolved ? Colors.green.shade800 : Colors.black87,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isResolved ? Colors.green.shade50 : Colors.teal.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isResolved ? Colors.green : Colors.teal),
          ),
          child: Text(
            problem.currentStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isResolved ? Colors.green.shade900 : Colors.teal.shade900,
            ),
          ),
        ),
        children: [
          StreamBuilder<List<ClinicalIntervention>>(
            stream: dao.watchActionsForProblem(problem.id),
            builder: (context, snapshot) {
              final actions = snapshot.data ?? const <ClinicalIntervention>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  if (actions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'No specific procedures or clinical interventions linked yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  else
                    for (final action in actions)
                      ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                        ),
                        title: Text(action.procedureName),
                        subtitle: Text(
                          'Role: ${action.interventionRole} · ${action.performedAt.toIso8601String().split('T').first}',
                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: OverflowBar(
                      spacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: () => _updateProblemStatus(context, ref),
                          icon: const Icon(Icons.sync_alt, size: 16),
                          label: const Text('Update Status'),
                        ),
                        TextButton.icon(
                          onPressed: () => _addAction(context, ref),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Intervention'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              _consultationMode(context, problem, actions),
                          icon: const Icon(Icons.history_edu, size: 16),
                          label: const Text('Trajectory View'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateProblemStatus(BuildContext context, WidgetRef ref) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Update Trajectory Status'),
        children: [
          for (final st in [
            'Active',
            'Improving',
            'Deteriorating',
            'Controlled',
            'Resolved',
            'Recurred',
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, st),
              child: Text(st),
            ),
        ],
      ),
    );

    if (newStatus == null) return;
    final dao = ref.read(clinicalDaoProvider);
    final now = DateTime.now().toUtc();

    await dao
        .into(dao.patientProblems)
        .insertOnConflictUpdate(
          problem.copyWith(
            currentStatus: newStatus,
            resolvedDate: Value(newStatus == 'Resolved' ? now : null),
            updatedAt: now,
          ),
        );
  }

  Future<void> _addAction(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final roleController = TextEditingController(text: 'Therapeutic');

    final description = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Clinical Intervention / Procedure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Procedure / Intervention Name',
                hintText: 'e.g. Incision and Drainage, Chest Tube Placement',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role',
                hintText: 'Therapeutic, Diagnostic, or Palliative',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Record Action'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (description == null || description.isEmpty) return;

    final dao = ref.read(clinicalDaoProvider);
    final encounters = await dao.getEncountersForPatient(problem.patientId);
    final encounterId = encounters.isNotEmpty ? encounters.first.id : '';

    await dao.insertClinicalIntervention(
      ClinicalInterventionsCompanion.insert(
        patientId: problem.patientId,
        encounterId: encounterId,
        problemId: Value(problem.id),
        procedureName: description,
        interventionRole: Value(
          roleController.text.trim().isEmpty
              ? 'Therapeutic'
              : roleController.text.trim(),
        ),
        performedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  void _consultationMode(
    BuildContext context,
    PatientProblem problem,
    List<ClinicalIntervention> actions,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(problem.problemName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Current Trajectory: ${problem.currentStatus}'),
              const SizedBox(height: 4),
              Text(
                '• Onset Date: ${problem.onsetDate?.toIso8601String().split('T').first ?? 'Noted on admission'}',
              ),
              if (problem.resolvedDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  '• Resolved Date: ${problem.resolvedDate!.toIso8601String().split('T').first}',
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                'Linked Interventions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (actions.isEmpty)
                const Text('No procedural actions linked.')
              else
                ...actions.map(
                  (a) => Text('• ${a.procedureName} (${a.interventionRole})'),
                ),
            ],
          ),
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
