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
      for (final medication in widget.extraction.medicationsOrdered)
        _EditableMedication.from(medication),
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
    for (final medication in _medications) {
      medication.dispose();
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
      labResults: [
        for (final lab in _labs)
          AiLabResult(
            testName: lab.testName.text.trim(),
            value: lab.value.text.trim(),
            unit: lab.unit.text.trim().isEmpty ? null : lab.unit.text.trim(),
            isAbnormal: lab.isAbnormal,
          ),
      ],
      medicationsOrdered: [
        for (final medication in _medications)
          OrderedMedication(
            drugName: medication.drugName.text.trim(),
            dosage: medication.dosage.text.trim().isEmpty
                ? null
                : medication.dosage.text.trim(),
            frequency: medication.frequency.text.trim().isEmpty
                ? null
                : medication.frequency.text.trim(),
          ),
      ],
      clinicalSummary: _summary.text.trim(),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(clinicalDaoProvider).processAiExtraction(
            _editedExtraction(),
            widget.imagePath,
            patientIdOverride: _selectedPatientId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document saved to the clinical record')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save document: $error')),
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
      prefixIcon: missing ? const Icon(Icons.warning_amber_rounded) : null,
      filled: missing,
      fillColor: missing ? Colors.amber.withValues(alpha: 0.08) : null,
      enabledBorder: missing
          ? const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(clinicalDaoProvider).watchAllPatients();
    return Scaffold(
      appBar: AppBar(title: const Text('Review extracted document')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final image = SizedBox(
              height: constraints.maxHeight > 700
                  ? constraints.maxHeight * 0.46
                  : 300,
              child: PhotoView(
                imageProvider: FileImage(File(widget.imagePath)),
                backgroundDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                minScale: PhotoViewComputedScale.contained,
              ),
            );
            final form = SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Patient identity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    decoration: _decoration('Name', missing: _name.text.isEmpty),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          decoration: _decoration('Age', missing: _age.text.isEmpty),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _gender,
                          decoration: _decoration('Gender', missing: _gender.text.isEmpty),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _registration,
                    decoration: _decoration(
                      'Hospital registration number',
                      missing: _registration.text.isEmpty,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  Text('Patient link', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  FutureBuilder<Patient?>(
                    future: _matchedPatient,
                    builder: (context, matchSnapshot) {
                      final matched = matchSnapshot.data;
                      return StreamBuilder<List<Patient>>(
                        stream: patients,
                        builder: (context, snapshot) {
                      final values = snapshot.data ?? const <Patient>[];
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedPatientId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _selectedPatientId != null || matched != null
                              ? 'Existing patient'
                              : 'New Patient Profile (AUTO generated on save)',
                        ),
                        items: values
                            .map(
                              (patient) => DropdownMenuItem(
                                value: patient.id,
                                child: Text(
                                  '${patient.fullName} | ${patient.hospitalRegNo}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _selectedPatientId = value),
                      );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<Patient?>(
                    future: _matchedPatient,
                    builder: (context, snapshot) => Text(
                      _selectedPatientId != null
                          ? 'Manual patient override selected. New findings will be added to that history.'
                          : snapshot.data == null
                              ? 'A new patient profile will be created if no exact or fuzzy match is found.'
                              : 'Matched existing patient: ${snapshot.data!.fullName} · ${snapshot.data!.hospitalRegNo}',
                    ),
                  ),
                  if (_selectedPatientId != null)
                    FutureBuilder<List<ClinicalEncounter>>(
                      future: ref.read(clinicalDaoProvider).getEncountersForPatient(
                            _selectedPatientId!,
                          ),
                      builder: (context, snapshot) => Text(
                        'History: ${snapshot.data?.length ?? 0} prior encounters',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text('Vitals', style: Theme.of(context).textTheme.titleLarge),
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
                      Expanded(child: _numberField('Temp F', _tempF, decimal: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_labs.isNotEmpty) ...[
                    Text('Laboratory results', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final lab in _labs) _labEditor(lab),
                    const SizedBox(height: 8),
                  ],
                  if (_medications.isNotEmpty) ...[
                    Text('Medications ordered', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final medication in _medications) _medicationEditor(medication),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: _documentType,
                    decoration: _decoration('Document type', missing: _documentType.text.isEmpty),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _summary,
                    minLines: 3,
                    maxLines: 6,
                    decoration: _decoration('Clinical summary', missing: _summary.text.isEmpty),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 64,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_outlined),
                      label: Text(
                        _saving ? 'Saving...' : 'Confirm & Save to Record',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
            return constraints.maxWidth >= 900
                ? Row(children: [Expanded(child: image), Expanded(child: form)])
                : Column(children: [image, Expanded(child: form)]);
          },
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller, {bool decimal = false}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: _decoration(label, missing: controller.text.isEmpty),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _labEditor(_EditableLab lab) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: lab.testName, decoration: _decoration('Test name', missing: lab.testName.text.isEmpty), onChanged: (_) => setState(() {}))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: lab.value, decoration: _decoration('Value', missing: lab.value.text.isEmpty), onChanged: (_) => setState(() {}))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: lab.unit, decoration: const InputDecoration(labelText: 'Unit'))),
              Checkbox(value: lab.isAbnormal, onChanged: (value) => setState(() => lab.isAbnormal = value ?? false)),
              const Text('Abnormal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _medicationEditor(_EditableMedication medication) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: TextField(controller: medication.drugName, decoration: _decoration('Drug', missing: medication.drugName.text.isEmpty), onChanged: (_) => setState(() {}))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: medication.dosage, decoration: const InputDecoration(labelText: 'Dosage'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: medication.frequency, decoration: const InputDecoration(labelText: 'Frequency'))),
        ],
      ),
    );
  }
}

class _EditableLab {
  _EditableLab({required this.testName, required this.value, required this.unit, required this.isAbnormal});

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
  _EditableMedication({required this.drugName, required this.dosage, required this.frequency});

  factory _EditableMedication.from(OrderedMedication medication) => _EditableMedication(
    drugName: TextEditingController(text: medication.drugName),
    dosage: TextEditingController(text: medication.dosage ?? ''),
    frequency: TextEditingController(text: medication.frequency ?? ''),
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