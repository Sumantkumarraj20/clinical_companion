import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../../core/database/local_database.dart';
import '../../../core/database/services/identity_resolution_service.dart';
import '../../../core/models/ai_extraction_result.dart';
import '../../../core/providers/app_providers.dart';

class ExtractionReviewScreen extends ConsumerStatefulWidget {
  const ExtractionReviewScreen({
    required this.extraction,
    required this.imagePath,
    super.key,
  });

  final AiExtractionResult extraction;
  final String imagePath;

  @override
  ConsumerState<ExtractionReviewScreen> createState() =>
      _ExtractionReviewScreenState();
}

class _ExtractionReviewScreenState
    extends ConsumerState<ExtractionReviewScreen> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _registration;
  late final TextEditingController _gender;
  late final TextEditingController _summary;
  late final TextEditingController _documentType;

  late final TextEditingController _sbp;
  late final TextEditingController _dbp;
  late final TextEditingController _pulse;
  late final TextEditingController _spo2;
  late final TextEditingController _tempF;

  late final Future<Patient?> _matchedPatient;
  late final List<_EditableLab> _labs;
  late final List<_EditableMedication> _medications;

  String? _selectedPatientId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final identity = widget.extraction.patientIdentity;
    _name = TextEditingController(text: identity.name ?? '');
    _age = TextEditingController(text: identity.age?.toString() ?? '');
    _registration = TextEditingController(text: identity.hospitalRegNo ?? '');
    _gender = TextEditingController(text: identity.gender ?? '');

    _summary = TextEditingController(text: widget.extraction.clinicalSummary);
    _documentType = TextEditingController(
      text: widget.extraction.encounterContext.documentType,
    );

    final vitals = widget.extraction.vitals;
    _sbp = TextEditingController(text: vitals.sbp?.toString() ?? '');
    _dbp = TextEditingController(text: vitals.dbp?.toString() ?? '');
    _pulse = TextEditingController(text: vitals.pr?.toString() ?? '');
    _spo2 = TextEditingController(text: vitals.spo2?.toString() ?? '');
    _tempF = TextEditingController(text: vitals.temperatureC?.toString() ?? '');

    _matchedPatient = IdentityResolutionService(
      database: ref.read(appDatabaseProvider),
      ownerId: ref.read(currentOwnerIdProvider),
    ).findExistingPatient(identity);

    _labs = [
      for (final lab in widget.extraction.labResults) _EditableLab.from(lab),
    ];
    _medications = [
      for (final med in widget.extraction.medicationsOrdered)
        _EditableMedication.from(med),
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _registration.dispose();
    _gender.dispose();
    _summary.dispose();
    _documentType.dispose();
    _sbp.dispose();
    _dbp.dispose();
    _pulse.dispose();
    _spo2.dispose();
    _tempF.dispose();
    for (final lab in _labs) {
      lab.dispose();
    }
    for (final med in _medications) {
      med.dispose();
    }
    super.dispose();
  }

  AiExtractionResult _editedExtraction() {
    return widget.extraction.copyWith(
      patientIdentity: widget.extraction.patientIdentity.copyWith(
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
        age: int.tryParse(_age.text.trim()),
        gender: _gender.text.trim().isEmpty ? null : _gender.text.trim(),
        hospitalRegNo: _registration.text.trim().isEmpty
            ? null
            : _registration.text.trim(),
      ),
      encounterContext: widget.extraction.encounterContext.copyWith(
        documentType: _documentType.text.trim(),
      ),
      vitals: widget.extraction.vitals.copyWith(
        sbp: int.tryParse(_sbp.text.trim()),
        dbp: int.tryParse(_dbp.text.trim()),
        pr: int.tryParse(_pulse.text.trim()),
        spo2: int.tryParse(_spo2.text.trim()),
        temperatureC: double.tryParse(_tempF.text.trim()),
      ),
      labResults: _labs
          .map(
            (lab) => AiLabResult(
              testName: lab.testName.text.trim(),
              value: lab.value.text.trim(),
              unit: lab.unit.text.trim().isEmpty ? null : lab.unit.text.trim(),
              isAbnormal: lab.isAbnormal,
            ),
          )
          .toList(),
      medicationsOrdered: _medications
          .map(
            (med) => OrderedMedication(
              drugName: med.drugName.text.trim(),
              dosage: med.dosage.text.trim().isEmpty
                  ? null
                  : med.dosage.text.trim(),
              frequency: med.frequency.text.trim().isEmpty
                  ? null
                  : med.frequency.text.trim(),
            ),
          )
          .toList(),
      clinicalSummary: _summary.text.trim(),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(clinicalDaoProvider)
          .processAiExtraction(
            _editedExtraction(),
            widget.imagePath,
            patientIdOverride: _selectedPatientId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document successfully saved to clinical record'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save document: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, {required bool missing}) {
    return InputDecoration(
      labelText: label,
      helperText: missing ? 'Missing or not confidently identified' : null,
      prefixIcon: missing
          ? const Icon(Icons.warning_amber_rounded, size: 20)
          : null,
      filled: missing,
      fillColor: missing ? Colors.amber.withValues(alpha: 0.08) : null,
      enabledBorder: missing
          ? const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            )
          : const OutlineInputBorder(),
      border: const OutlineInputBorder(),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientsStream = ref.watch(clinicalDaoProvider).watchAllPatients();

    return Scaffold(
      appBar: AppBar(title: const Text('Review AI Extraction')),
      bottomNavigationBar: BottomAppBar(
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(
            _saving ? 'Processing & Saving...' : 'Confirm & Save Record',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageViewer = Container(
              height: constraints.maxWidth > 900 ? double.infinity : 250,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: PhotoView(
                imageProvider: FileImage(File(widget.imagePath)),
                backgroundDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                minScale: PhotoViewComputedScale.contained,
              ),
            );

            final formContent = SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Patient Link',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<Patient?>(
                    future: _matchedPatient,
                    builder: (context, matchSnapshot) {
                      final matched = matchSnapshot.data;

                      return StreamBuilder<List<Patient>>(
                        stream: patientsStream,
                        builder: (context, snapshot) {
                          final patientsList = snapshot.data ?? const [];

                          if (_selectedPatientId != null &&
                              !patientsList.any(
                                (p) => p.id == _selectedPatientId,
                              )) {
                            _selectedPatientId = null;
                          }

                          return DropdownButtonFormField<String>(
                            initialValue: _selectedPatientId ?? matched?.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Attach to Patient Record',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  '✨ Create New Patient Profile (AUTO-GEN)',
                                ),
                              ),
                              ...patientsList.map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(
                                    '${p.fullName} | ${p.hospitalRegNo}',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedPatientId = val),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Extracted Identity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    decoration: _decoration(
                      'Patient Name',
                      missing: _name.text.isEmpty,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          decoration: _decoration(
                            'Age',
                            missing: _age.text.isEmpty,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _gender,
                          decoration: _decoration(
                            'Gender',
                            missing: _gender.text.isEmpty,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _registration,
                    decoration: _decoration(
                      'Hospital Reg Number (CR No.)',
                      missing: _registration.text.isEmpty,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Vitals & Context',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _documentType,
                    decoration: _decoration(
                      'Document Type (e.g. CBC, Progress Note)',
                      missing: _documentType.text.isEmpty,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _numberField('SBP', _sbp)),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField('DBP', _dbp)),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField('Pulse', _pulse)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _numberField('SpO2', _spo2)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _numberField(
                          'Temp (°C/F)',
                          _tempF,
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_labs.isNotEmpty) ...[
                    Text(
                      'Labs Extracted',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ..._labs.map((lab) => _labEditor(lab)),
                    const SizedBox(height: 12),
                  ],
                  if (_medications.isNotEmpty) ...[
                    Text(
                      'Medications Ordered',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ..._medications.map((med) => _medicationEditor(med)),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    'AI Clinical Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _summary,
                    minLines: 3,
                    maxLines: 6,
                    decoration: _decoration(
                      'Summary of findings',
                      missing: _summary.text.isEmpty,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );

            if (constraints.maxWidth >= 900) {
              return Row(
                children: [
                  Expanded(child: imageViewer),
                  Expanded(child: formContent),
                ],
              );
            } else {
              return Column(
                children: [
                  imageViewer,
                  Expanded(child: formContent),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: _decoration(label, missing: controller.text.isEmpty),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _labEditor(_EditableLab lab) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: lab.testName,
                decoration: const InputDecoration(
                  labelText: 'Test Name',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: lab.value,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: lab.unit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicationEditor(_EditableMedication med) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: med.drugName,
                decoration: const InputDecoration(
                  labelText: 'Drug',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: med.dosage,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableLab {
  _EditableLab({
    required this.testName,
    required this.value,
    required this.unit,
    required this.isAbnormal,
  });

  factory _EditableLab.from(AiLabResult lab) => _EditableLab(
    testName: TextEditingController(text: lab.testName),
    value: TextEditingController(text: lab.value),
    unit: TextEditingController(text: lab.unit ?? ''),
    isAbnormal: lab.isAbnormal,
  );

  final TextEditingController testName;
  final TextEditingController value;
  final TextEditingController unit;
  bool isAbnormal;

  void dispose() {
    testName.dispose();
    value.dispose();
    unit.dispose();
  }
}

class _EditableMedication {
  _EditableMedication({
    required this.drugName,
    required this.dosage,
    required this.frequency,
  });

  factory _EditableMedication.from(OrderedMedication med) =>
      _EditableMedication(
        drugName: TextEditingController(text: med.drugName),
        dosage: TextEditingController(text: med.dosage ?? ''),
        frequency: TextEditingController(text: med.frequency ?? ''),
      );

  final TextEditingController drugName;
  final TextEditingController dosage;
  final TextEditingController frequency;

  void dispose() {
    drugName.dispose();
    dosage.dispose();
    frequency.dispose();
  }
}
