import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/models/department_templates.dart';
import '../../../core/providers/app_providers.dart';

class DynamicEncounterScreen extends ConsumerStatefulWidget {
  const DynamicEncounterScreen({required this.patient, super.key});

  final Patient patient;

  @override
  ConsumerState<DynamicEncounterScreen> createState() =>
      _DynamicEncounterScreenState();
}

class _DynamicEncounterScreenState
    extends ConsumerState<DynamicEncounterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Core Clinical Controllers
  final _sbp = TextEditingController();
  final _dbp = TextEditingController();
  final _pulse = TextEditingController();
  final _spo2 = TextEditingController();
  final _temp = TextEditingController();
  final _complaint = TextEditingController();
  final _diagnosis = TextEditingController();
  final _assessment = TextEditingController();
  final _advice = TextEditingController();
  final _departmentText = TextEditingController(text: 'Surgery');
  final _wardName = TextEditingController();
  final _bedNumber = TextEditingController();

  // POMR Problem Trajectory Controllers
  String? _selectedProblemId;
  final _newProblemName = TextEditingController();
  String _problemTrajectoryStatus = 'Improving';
  final _problemCourseNote = TextEditingController();

  // Surgical / Template Controllers
  final _drainOutput = TextEditingController();
  final _postOpDay = TextEditingController();
  final _wound = TextEditingController();
  final _gcs = ValueNotifier<double>(15);
  final _mood = TextEditingController();
  final _appearance = TextEditingController();
  final _plan = TextEditingController();
  final _gravida = TextEditingController();
  final _para = TextEditingController();
  final _bishop = TextEditingController();
  final _fetalHeartRate = TextEditingController();
  final _gestationalAge = TextEditingController();
  final _thoughtProcess = TextEditingController();
  final _perception = TextEditingController();
  final _cognition = TextEditingController();
  final _insight = TextEditingController();

  bool _hallucinations = false;
  bool _suicidalIdeation = false;
  bool _homicidalIdeation = false;
  bool _saving = false;
  String _encounterType = 'Ward Round';
  String _disposition = 'Admitted';
  double? _map;

  @override
  void initState() {
    super.initState();
    _sbp.addListener(_calculateMap);
    _dbp.addListener(_calculateMap);
  }

  @override
  void dispose() {
    for (final controller in [
      _sbp,
      _dbp,
      _pulse,
      _spo2,
      _temp,
      _complaint,
      _diagnosis,
      _assessment,
      _advice,
      _departmentText,
      _wardName,
      _bedNumber,
      _newProblemName,
      _problemCourseNote,
      _drainOutput,
      _postOpDay,
      _wound,
      _mood,
      _appearance,
      _plan,
      _gravida,
      _para,
      _bishop,
      _fetalHeartRate,
      _gestationalAge,
      _thoughtProcess,
      _perception,
      _cognition,
      _insight,
    ]) {
      controller.dispose();
    }
    _gcs.dispose();
    super.dispose();
  }

  void _calculateMap() {
    final sbp = int.tryParse(_sbp.text);
    final dbp = int.tryParse(_dbp.text);
    setState(
      () => _map = sbp != null && dbp != null ? (sbp + (2 * dbp)) / 3 : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = ref.read(currentOwnerIdProvider);
    final dao = ref.read(clinicalDaoProvider);
    final now = DateTime.now().toUtc();

    setState(() => _saving = true);
    try {
      final sbpVal = int.tryParse(_sbp.text);
      final dbpVal = int.tryParse(_dbp.text);
      final pulseVal = int.tryParse(_pulse.text);
      final spo2Val = int.tryParse(_spo2.text);
      final tempVal = double.tryParse(_temp.text);
      final dynamicData = _buildTemplate().toJson();

      final newProblems = <PatientProblemsCompanion>[];
      final snapshots = <ProblemProgressSnapshotsCompanion>[];
      final interventions = <ClinicalInterventionsCompanion>[];

      String? activeProbId = _selectedProblemId;

      // Handle new problem addition
      if (_newProblemName.text.trim().isNotEmpty) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        activeProbId = newId;
        newProblems.add(
          PatientProblemsCompanion.insert(
            id: Value(newId),
            patientId: widget.patient.id,
            problemName: _newProblemName.text.trim(),
            currentStatus: Value(_problemTrajectoryStatus),
            onsetDate: Value(now),
          ),
        );
      }

      // Handle Problem Evolution Snapshot
      if (activeProbId != null && activeProbId != 'NONE') {
        final courseNote = _problemCourseNote.text.trim().isNotEmpty
            ? _problemCourseNote.text.trim()
            : 'Assessment status: $_problemTrajectoryStatus';

        snapshots.add(
          ProblemProgressSnapshotsCompanion.insert(
            problemId: activeProbId,
            encounterId: '', // Will be assigned atomically in DAO
            patientId: widget.patient.id,
            statusSnapshot: _problemTrajectoryStatus,
            clinicalCourseNote: courseNote,
            recordedAt: Value(now),
          ),
        );
      }

      // Build Encounter Entity
      final encounter = ClinicalEncountersCompanion.insert(
        ownerId: ownerId,
        patientId: widget.patient.id,
        encounterType: Value(_encounterType),
        occurredAt: Value(now),
        department: Value(_clean(_departmentText.text)),
        wardName: Value(_clean(_wardName.text)),
        bedNumber: Value(_clean(_bedNumber.text)),
        clinicalDiagnosis: Value(_clean(_diagnosis.text)),
        disposition: Value(_disposition),
        sbp: Value(sbpVal),
        dbp: Value(dbpVal),
        pulse: Value(pulseVal),
        spo2: Value(spo2Val),
        temperatureC: Value(tempVal),
        meanArterialPressure: Value(_map),
        chiefComplaints: Value(_clean(_complaint.text)),
        clinicalAssessment: Value(_clean(_assessment.text)),
        consultantAdvice: Value(_clean(_advice.text)),
        dynamicData: Value(dynamicData),
      );

      // Save via atomic POMR helper
      await dao.savePOMREncounter(
        encounter: encounter,
        newProblems: newProblems,
        progressSnapshots: snapshots,
        interventions: interventions,
      );

      if (mounted) {
        _toast(
          'Encounter & clinical trajectory saved successfully.',
          isError: false,
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) _toast('Could not save encounter: $error', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  ClinicalTemplate _buildTemplate() {
    switch (_departmentText.text.trim().toLowerCase()) {
      case 'medicine':
        return MedicineTemplate(
          systemicExamFindings: {'general': _assessment.text.trim()},
          plan: _plan.text.trim(),
        );
      case 'obgyn':
        return ObGynTemplate(
          gravida: int.tryParse(_gravida.text) ?? 0,
          para: int.tryParse(_para.text) ?? 0,
          fetalHeartRate: int.tryParse(_fetalHeartRate.text) ?? 0,
          bishopScore: int.tryParse(_bishop.text) ?? 0,
          gestationalAge: _gestationalAge.text.trim(),
          partographNotes: _assessment.text.trim(),
        );
      case 'surgery':
      case 'plastic surgery':
        return SurgeryTemplate(
          woundStatus: _wound.text.trim(),
          drainOutputMl: double.tryParse(_drainOutput.text) ?? 0,
          postOpDay: int.tryParse(_postOpDay.text) ?? 0,
        );
      case 'psychiatry':
        return PsychiatryTemplate(
          appearance: _appearance.text.trim(),
          mood: _mood.text.trim(),
          thoughtProcess: _thoughtProcess.text.trim(),
          perception: _perception.text.trim(),
          cognition: _cognition.text.trim(),
          insight: _insight.text.trim(),
          hallucinations: _hallucinations,
          suicidalIdeation: _suicidalIdeation,
          homicidalIdeation: _homicidalIdeation,
        );
      case 'emergency':
      case 'trauma':
        return GenericClinicalTemplate(
          values: {'gcs': _gcs.value.round(), 'notes': _assessment.text.trim()},
        );
      default:
        return GenericClinicalTemplate(
          values: {'notes': _assessment.text.trim()},
        );
    }
  }

  void _toast(String message, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );

  String? _clean(String val) => val.trim().isEmpty ? null : val.trim();

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);
    final department = _departmentText.text.trim().isEmpty
        ? 'Clinical'
        : _departmentText.text.trim();

    return Scaffold(
      appBar: AppBar(title: Text('$department Encounter')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // 1. LOCKED PATIENT IDENTIFIER HEADER
            _PatientBanner(patient: widget.patient),
            const SizedBox(height: 16),

            // 2. ENCOUNTER CONTEXT
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _encounterType,
                    decoration: const InputDecoration(
                      labelText: 'Encounter Type',
                      isDense: true,
                    ),
                    items: [
                      for (final type in [
                        'Ward Round',
                        'OPD',
                        'Pre-Op',
                        'Procedure',
                        'Emergency',
                        'Follow-Up',
                      ])
                        DropdownMenuItem(value: type, child: Text(type)),
                    ],
                    onChanged: (v) =>
                        setState(() => _encounterType = v ?? _encounterType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _disposition,
                    decoration: const InputDecoration(
                      labelText: 'Disposition',
                      isDense: true,
                    ),
                    items: [
                      for (final disp in [
                        'Admitted',
                        'Discharged',
                        'Transferred',
                        'ICU',
                        'OT',
                        'LAMA',
                      ])
                        DropdownMenuItem(value: disp, child: Text(disp)),
                    ],
                    onChanged: (v) =>
                        setState(() => _disposition = v ?? _disposition),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _departmentText,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _wardName,
                    decoration: const InputDecoration(
                      labelText: 'Ward',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _bedNumber,
                    decoration: const InputDecoration(
                      labelText: 'Bed No.',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. WEED'S POMR: PROBLEM TRAJECTORY TRACKING
            Text(
              'Problem-Oriented Trajectory (POMR)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<PatientProblem>>(
              stream: dao.watchPatientProblems(widget.patient.id),
              builder: (context, snapshot) {
                final existingProblems = snapshot.data ?? [];

                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProblemId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Active Patient Problem',
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('— Select Existing Problem —'),
                        ),
                        for (final prob in existingProblems)
                          DropdownMenuItem(
                            value: prob.id,
                            child: Text(
                              '${prob.problemName} (${prob.currentStatus})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedProblemId = val),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newProblemName,
                      decoration: const InputDecoration(
                        labelText: 'Or Add New Clinical Problem',
                        hintText:
                            'e.g. Acute Appendicitis with Localized Peritonitis',
                        isDense: true,
                        prefixIcon: Icon(Icons.add_circle_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: _problemTrajectoryStatus,
                            decoration: const InputDecoration(
                              labelText: 'Current Trajectory',
                              isDense: true,
                            ),
                            items: [
                              for (final status in [
                                'Active',
                                'Improving',
                                'Deteriorating',
                                'Controlled',
                                'Resolved',
                                'Recurred',
                              ])
                                DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                            ],
                            onChanged: (v) => setState(
                              () => _problemTrajectoryStatus = v ?? 'Active',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _problemCourseNote,
                            decoration: const InputDecoration(
                              labelText: 'Course / Evolution Note',
                              hintText: 'e.g. POD-2, drain 40ml serous',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // 4. BEDSIDE VITALS & MAP
            Text(
              'Bedside Hemodynamics & Vitals',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _number(_sbp, 'SBP', _validateSbp, suffix: 'mmHg'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _number(_dbp, 'DBP', _validateDbp, suffix: 'mmHg'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _number(_pulse, 'Pulse', _optional, suffix: 'bpm'),
                ),
                const SizedBox(width: 8),
                Expanded(child: _number(_spo2, 'SpO2', _optional, suffix: '%')),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Calculated Mean Arterial Pressure (MAP)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _map == null
                          ? '— mmHg'
                          : '${_map!.toStringAsFixed(1)} mmHg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 5. CLINICAL NARRATIVE
            TextFormField(
              controller: _diagnosis,
              decoration: const InputDecoration(
                labelText: 'Encounter Clinical Impression / Working Diagnosis',
                prefixIcon: Icon(Icons.psychology_outlined),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _complaint,
              minLines: 2,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Today\'s Complaints / S (Subjective)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _assessment,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Objective Examination & Assessment / O & A',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _advice,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Consultant Orders & Advice / P (Plan)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // 6. DEPARTMENT-SPECIFIC TRAJECTORY FORM
            Text(
              '$department Focused Template',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _departmentForm(department),
            const SizedBox(height: 28),

            // 7. SAVE BUTTON
            SizedBox(
              height: 54,
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
                  _saving
                      ? 'Committing POMR Ledger…'
                      : 'Save Clinical Encounter',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _departmentForm(String department) {
    switch (department.trim().toLowerCase()) {
      case 'medicine':
        return Column(
          children: [_largeText(_plan, 'Management Plan & Review Timeline')],
        );
      case 'obgyn':
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _number(_gravida, 'Gravida', _optional)),
                const SizedBox(width: 10),
                Expanded(child: _number(_para, 'Para', _optional)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _number(
                    _fetalHeartRate,
                    'Fetal Heart Rate',
                    _optional,
                    suffix: 'bpm',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _number(_bishop, 'Bishop Score', _optional)),
              ],
            ),
            _largeText(_gestationalAge, 'Gestational Age (Weeks + Days)'),
          ],
        );
      case 'surgery':
      case 'plastic surgery':
        return Column(
          children: [
            _largeText(
              _wound,
              'Surgical Site / Wound Status (e.g. Healthy, Soakage)',
            ),
            Row(
              children: [
                Expanded(
                  child: _number(
                    _drainOutput,
                    'Drain Output',
                    _optional,
                    decimal: true,
                    suffix: 'mL',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _number(_postOpDay, 'Post-Op Day (POD)', _optional),
                ),
              ],
            ),
          ],
        );
      case 'psychiatry':
        return Column(
          children: [
            _largeText(_appearance, 'Appearance / General Behavior'),
            _largeText(_mood, 'Mood / Affect'),
            _largeText(_thoughtProcess, 'Thought Process & Content'),
            _largeText(_perception, 'Perception'),
            _largeText(_cognition, 'Cognition & Orientation'),
            _largeText(_insight, 'Insight (Grade 1-6)'),
            SwitchListTile(
              title: const Text('Hallucinations Present'),
              value: _hallucinations,
              onChanged: (v) => setState(() => _hallucinations = v),
            ),
            SwitchListTile(
              title: const Text('Suicidal Ideation'),
              value: _suicidalIdeation,
              onChanged: (v) => setState(() => _suicidalIdeation = v),
            ),
            SwitchListTile(
              title: const Text('Homicidal Ideation'),
              value: _homicidalIdeation,
              onChanged: (v) => setState(() => _homicidalIdeation = v),
            ),
          ],
        );
      case 'emergency':
      case 'trauma':
        return Column(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _gcs,
              builder: (context, value, child) => ListTile(
                title: const Text('Glasgow Coma Scale (GCS)'),
                trailing: Text(
                  value.round().toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _gcs,
              builder: (context, value, child) => Slider(
                min: 3,
                max: 15,
                divisions: 12,
                value: value,
                label: value.round().toString(),
                onChanged: (next) => _gcs.value = next,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _number(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    bool decimal = false,
    String? suffix,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(decimal ? r'^\d*\.?\d*' : r'^\d*'),
      ),
    ],
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      isDense: true,
    ),
    validator: validator,
  );

  Widget _largeText(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      minLines: 2,
      maxLines: 4,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        isDense: true,
      ),
    ),
  );

  String? _validateSbp(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final sbp = int.tryParse(value);
    final dbp = int.tryParse(_dbp.text);
    if (sbp == null || sbp <= 0) return 'Invalid';
    if (dbp != null && sbp <= dbp) return '> DBP';
    return null;
  }

  String? _validateDbp(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final dbp = int.tryParse(value);
    final sbp = int.tryParse(_sbp.text);
    if (dbp == null || dbp <= 0) return 'Invalid';
    if (sbp != null && sbp <= dbp) return '< SBP';
    return null;
  }

  String? _optional(String? value) => null;
}

class _PatientBanner extends ConsumerWidget {
  const _PatientBanner({required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: Text(
              patient.fullName.trim().isNotEmpty
                  ? patient.fullName.trim()[0].toUpperCase()
                  : '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<String>(
                  future: dao.getPatientHospitalRegNo(patient.id),
                  builder: (context, snapshot) {
                    final cr = snapshot.data ?? '…';
                    return Text(
                      'CR No: $cr · ${patient.gender ?? 'Unspecified'}, ${patient.approximateAge ?? '--'} yrs',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
