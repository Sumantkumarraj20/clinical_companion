import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../../core/database/local_database.dart';
import '../../../core/database/services/identity_resolution_service.dart';
import '../../../core/models/ai_extraction_result.dart';
import '../../../core/models/document_task.dart';
import '../../../core/providers/app_providers.dart';

class ExtractionReviewScreen extends ConsumerStatefulWidget {
  const ExtractionReviewScreen({
    required this.extraction,
    required this.imagePath,
    this.source = ExtractionSource.unknown,
    this.rawOcrText,
    super.key,
  });

  final AiExtractionResult extraction;
  final String imagePath;
  final ExtractionSource source;
  final String? rawOcrText;

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
  late final TextEditingController _temp;

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
    _gender = TextEditingController(text: identity.gender ?? 'Unspecified');

    _summary = TextEditingController(text: widget.extraction.clinicalSummary);
    _documentType = TextEditingController(
      text: widget.extraction.encounterContext.documentType.isEmpty
          ? 'Clinical Document'
          : widget.extraction.encounterContext.documentType,
    );

    final vitals = widget.extraction.vitals;
    _sbp = TextEditingController(text: vitals.sbp?.toString() ?? '');
    _dbp = TextEditingController(text: vitals.dbp?.toString() ?? '');
    _pulse = TextEditingController(text: vitals.pr?.toString() ?? '');
    _spo2 = TextEditingController(text: vitals.spo2?.toString() ?? '');
    _temp = TextEditingController(text: vitals.temperatureC?.toString() ?? '');

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
    _temp.dispose();
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
        documentType: _documentType.text.trim().isEmpty
            ? 'Clinical Document'
            : _documentType.text.trim(),
      ),
      vitals: widget.extraction.vitals.copyWith(
        sbp: int.tryParse(_sbp.text.trim()),
        dbp: int.tryParse(_dbp.text.trim()),
        pr: int.tryParse(_pulse.text.trim()),
        spo2: int.tryParse(_spo2.text.trim()),
        temperatureC: double.tryParse(_temp.text.trim()),
      ),
      labResults: _labs
          .where((l) => l.testName.text.trim().isNotEmpty)
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
          .where((m) => m.drugName.text.trim().isNotEmpty)
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
          content: Text('Document successfully committed to clinical ledger'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not commit extraction: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(
    String label, {
    required bool missing,
    String? hintText,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      suffixText: suffixText,
      helperText: missing ? 'Not detected on document' : null,
      prefixIcon: missing
          ? const Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: Colors.amber,
            )
          : null,
      filled: missing,
      fillColor: missing ? Colors.amber.withValues(alpha: 0.06) : null,
      enabledBorder: missing
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.amber),
            )
          : OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review AI Extraction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_outlined),
            tooltip: 'Add Lab Item',
            onPressed: () {
              setState(() {
                _labs.add(_EditableLab.empty());
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.medication_outlined),
            tooltip: 'Add Medication Item',
            onPressed: () {
              setState(() {
                _medications.add(_EditableMedication.empty());
              });
            },
          ),
        ],
      ),
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
              : const Icon(Icons.check_circle_outline),
          label: Text(
            _saving ? 'Committing to Database…' : 'Confirm & Save Record',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ExtractionSourceBanner(source: widget.source),
            Expanded(
              child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            final imageViewer = Container(
              height: isDesktop ? double.infinity : 260,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.3),
                  ),
                  right: isDesktop
                      ? BorderSide(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.3),
                        )
                      : BorderSide.none,
                ),
              ),
              child: Stack(
                children: [
                  PhotoView(
                    imageProvider: FileImage(File(widget.imagePath)),
                    backgroundDecoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4.0,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pinch / Scroll to Zoom',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            );

            final formContent = SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. PATIENT LINKING & IDENTITY SECTION
                  Text(
                    'Patient Association',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<Patient?>(
                    future: _matchedPatient,
                    builder: (context, matchSnapshot) {
                      final matched = matchSnapshot.data;

                      return StreamBuilder<List<Patient>>(
                        stream: dao.watchAllPatients(),
                        builder: (context, snapshot) {
                          final patientsList = snapshot.data ?? const [];

                          final effectiveSelectedId =
                              _selectedPatientId ?? matched?.id;

                          return DropdownButtonFormField<String?>(
                            initialValue:
                                patientsList.any(
                                  (p) => p.id == effectiveSelectedId,
                                )
                                ? effectiveSelectedId
                                : null,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Attach To Patient',
                              prefixIcon: const Icon(Icons.link_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  '✨ Create New Profile (Auto-Assign CR)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...patientsList.map(
                                (p) => DropdownMenuItem<String?>(
                                  value: p.id,
                                  child: FutureBuilder<String>(
                                    future: dao.getPatientHospitalRegNo(p.id),
                                    builder: (context, regSnap) {
                                      final reg = regSnap.data ?? '…';
                                      return Text(
                                        '${p.fullName} (CR: $reg) · ${p.gender ?? '?'}, ${p.approximateAge ?? '--'}y',
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
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
                  const SizedBox(height: 16),

                  // 2. EXTRACTED DEMOGRAPHICS
                  Text(
                    'Extracted Demographics',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    decoration: _decoration(
                      'Patient Full Name',
                      missing: _name.text.isEmpty,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          decoration: _decoration(
                            'Age (Years)',
                            missing: _age.text.isEmpty,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _gender,
                          decoration: _decoration(
                            'Gender (M/F/O)',
                            missing: _gender.text.isEmpty,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _registration,
                    decoration: _decoration(
                      'Hospital Reg Number (CR / OPD No.)',
                      missing: _registration.text.isEmpty,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // 3. ENCOUNTER CONTEXT & VITALS
                  Text(
                    'Encounter Context & Vitals',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _documentType,
                    decoration: _decoration(
                      'Document Type / Classification',
                      missing: _documentType.text.isEmpty,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          'Systolic BP',
                          _sbp,
                          suffix: 'mmHg',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _numberField(
                          'Diastolic BP',
                          _dbp,
                          suffix: 'mmHg',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _numberField('Pulse', _pulse, suffix: 'bpm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _numberField('SpO2', _spo2, suffix: '%')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _numberField(
                          'Temp (°C)',
                          _temp,
                          decimal: true,
                          suffix: '°C',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. EXTRACTED LAB RESULTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Extracted Lab Panels (${_labs.length})',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Test'),
                        onPressed: () =>
                            setState(() => _labs.add(_EditableLab.empty())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_labs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No laboratory tests parsed from this page.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    )
                  else
                    ..._labs.asMap().entries.map(
                      (entry) => _labEditor(entry.key, entry.value),
                    ),
                  const SizedBox(height: 20),

                  // 5. EXTRACTED MEDICATIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medications Prescribed (${_medications.length})',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Drug'),
                        onPressed: () => setState(
                          () => _medications.add(_EditableMedication.empty()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_medications.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No medications detected on this document.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    )
                  else
                    ..._medications.asMap().entries.map(
                      (entry) => _medicationEditor(entry.key, entry.value),
                    ),
                  const SizedBox(height: 20),

                  // 6. CLINICAL SUMMARY
                  Text(
                    'AI Clinical Summary & Findings',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _summary,
                    minLines: 3,
                    maxLines: 6,
                    decoration: _decoration(
                      'Narrative Summary',
                      missing: _summary.text.isEmpty,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(flex: 5, child: imageViewer),
                  Expanded(flex: 6, child: formContent),
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
          ],
        ),
      ),
    );
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    bool decimal = false,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: _decoration(
        label,
        missing: controller.text.isEmpty,
        suffixText: suffix,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _labEditor(int index, _EditableLab lab) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: lab.isAbnormal
              ? Colors.red.withValues(alpha: 0.5)
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: lab.testName,
                decoration: const InputDecoration(
                  labelText: 'Test Name',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: lab.value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: lab.isAbnormal ? Colors.red : null,
                ),
                decoration: const InputDecoration(
                  labelText: 'Value',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: lab.unit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                lab.isAbnormal ? Icons.flag : Icons.outlined_flag,
                color: lab.isAbnormal ? Colors.red : Colors.grey,
                size: 20,
              ),
              tooltip: lab.isAbnormal ? 'Flagged Abnormal' : 'Mark Abnormal',
              onPressed: () => setState(() => lab.isAbnormal = !lab.isAbnormal),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              tooltip: 'Delete Item',
              onPressed: () {
                setState(() {
                  _labs.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicationEditor(int index, _EditableMedication med) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: med.drugName,
                decoration: const InputDecoration(
                  labelText: 'Drug Name',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: med.dosage,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  hintText: '500mg',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: med.frequency,
                decoration: const InputDecoration(
                  labelText: 'Freq',
                  hintText: 'TID / BD',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              tooltip: 'Delete Item',
              onPressed: () {
                setState(() {
                  _medications.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtractionSourceBanner extends StatelessWidget {
  const _ExtractionSourceBanner({required this.source});

  final ExtractionSource source;

  @override
  Widget build(BuildContext context) {
    final (label, icon, bg, fg, border) = switch (source) {
      ExtractionSource.local => (
          'Locally Extracted (Free) — on-device OCR matched labs/demographics.',
          Icons.offline_bolt_outlined,
          Colors.green.shade50,
          Colors.green.shade900,
          Colors.green.shade700,
        ),
      ExtractionSource.ai => (
          'AI Extracted — escalated to Gemini after local OCR was insufficient.',
          Icons.auto_awesome_outlined,
          Colors.purple.shade50,
          Colors.purple.shade900,
          Colors.purple.shade700,
        ),
      ExtractionSource.unknown => (
          'Extraction source unknown — verify fields before saving.',
          Icons.help_outline,
          Colors.grey.shade200,
          Colors.grey.shade800,
          Colors.grey.shade500,
        ),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, semanticLabel: 'Extraction source badge'),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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

  factory _EditableLab.empty() => _EditableLab(
    testName: TextEditingController(),
    value: TextEditingController(),
    unit: TextEditingController(),
    isAbnormal: false,
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

  factory _EditableMedication.empty() => _EditableMedication(
    drugName: TextEditingController(),
    dosage: TextEditingController(),
    frequency: TextEditingController(),
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
