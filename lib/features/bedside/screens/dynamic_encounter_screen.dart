import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/models/department_templates.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';
import '../providers/encounter_provider.dart';
import 'encounter_ipd_extra.dart';
import 'encounter_ipd_sections.dart';
import 'encounter_opd_sections.dart';
import 'encounter_orders_section.dart';
import 'encounter_sections.dart' show EncounterCdssBanners;
import '../../learning/widgets/reflection_entry_sheet.dart';
import '../providers/clinical_rule_guardian_provider.dart';
import '../providers/clinical_guardrail_provider.dart';
import '../widgets/subtle_guardian_banner.dart';
import '../widgets/guardrail_status_widget.dart';
import '../widgets/clinical_rule_navigator.dart';
import '../../ingestion/widgets/ambient_scribe_fab.dart';

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
  // FIX 6 — default to general medicine rather than 'Surgery'. The AppBar
  // renders "$department Encounter", so a 'Surgery' default made every
  // paediatric/psychiatric/medical consult open as "Surgery Encounter" until
  // the clinician manually overrode it.
  final _departmentText = TextEditingController(text: 'General Medicine');
  final _wardName = TextEditingController();
  final _bedNumber = TextEditingController();

  // OPD history section controllers (medically rigorous, nullable-safe).
  final _hpi = TextEditingController();
  final _pastMedical = TextEditingController();
  final _pastSurgical = TextEditingController();
  final _personalHistory = TextEditingController();
  final _socialHistory = TextEditingController();
  final _birthHistory = TextEditingController();
  final _milestones = TextEditingController();
  final _vaccination = TextEditingController();
  final _gplaa = TextEditingController();
  final _lmp = TextEditingController();
  final _menstrualHistory = TextEditingController();
  final _examination = TextEditingController();

  // IPD controllers.
  final _newProblemName = TextEditingController();
  final _navigatorProblemTrigger = ValueNotifier<String>('');
  final _navigatorSymptomTrigger = ValueNotifier<String>('');
  final _stagedManual = TextEditingController();
  final _procedureSearch = TextEditingController();
  final _medicationSearch = TextEditingController();

  bool _isOpdMode = true;

  // POMR Problem Trajectory Controllers
  String? _selectedProblemId;
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
  Timer? _guardrailDebounce;
  String _encounterType = 'Ward Round';
  String _disposition = 'Admitted';
  double? _map;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkMedicationGuardrails(ref.read(stagedOrdersProvider));
    });
    _sbp.addListener(_calculateMap);
    for (final controller in [
      _complaint,
      _hpi,
      _assessment,
      _diagnosis,
      _newProblemName,
      _sbp,
      _dbp,
      _pulse,
      _spo2,
      _temp,
    ]) {
      controller.addListener(_scheduleGuardrailRefresh);
    }
    _dbp.addListener(_calculateMap);
    // The narrative becomes an EncounterDraft as it is typed. EncounterNotifier
    // debounces internally, so one listener per field costs nothing and the
    // finalize path never has to re-derive text from controllers.
    for (final controller in [
      _complaint,
      _hpi,
      _pastMedical,
      _pastSurgical,
      _examination,
      _assessment,
      _advice,
      _plan,
    ]) {
      controller.addListener(_pushNarrativeToDraft);
    }
  }

  /// Mirrors the narrative fields into [EncounterNotifier].
  void _pushNarrativeToDraft() {
    final notifier = ref.read(encounterNotifierProvider.notifier);
    notifier.updateChiefComplaints(_complaint.text);
    notifier.updateHPI(_hpi.text);
    notifier.updatePastHistory(
      [
        _clean(_pastMedical.text),
        _clean(_pastSurgical.text),
      ].whereType<String>().join(' | '),
    );
    notifier.updateExamination(_examination.text);
    notifier.updateAssessment(_assessment.text);
    notifier.updateAdvice(_advice.text);
    notifier.updatePlan(_plan.text);
    notifier.setCareSetting(_isOpdMode ? CareSetting.opd : CareSetting.ipd);
  }

  /// FIX 6 — pediatric history is collected only for patients under 18.
  bool get _isPediatricPatient {
    final age = DateTimeUtils.ageOn(widget.patient.dateOfBirth, DateTime.now());
    return age != null && age < 18;
  }

  /// FIX 6 — OB/GYN history is collected only for female patients.
  bool get _isFemalePatient {
    final gender = widget.patient.gender?.trim().toLowerCase() ?? '';
    return gender == 'female' || gender == 'f';
  }

  @override
  void dispose() {
    _guardrailDebounce?.cancel();
    for (final controller in [
      _complaint,
      _hpi,
      _assessment,
      _diagnosis,
      _newProblemName,
      _sbp,
      _dbp,
      _pulse,
      _spo2,
      _temp,
    ]) {
      controller.removeListener(_scheduleGuardrailRefresh);
    }
    for (final controller in [
      _complaint,
      _hpi,
      _pastMedical,
      _pastSurgical,
      _examination,
      _assessment,
      _advice,
      _plan,
    ]) {
      controller.removeListener(_pushNarrativeToDraft);
    }
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
      _hpi,
      _pastMedical,
      _pastSurgical,
      _personalHistory,
      _socialHistory,
      _birthHistory,
      _milestones,
      _vaccination,
      _gplaa,
      _lmp,
      _menstrualHistory,
      _examination,
      _newProblemName,
      _stagedManual,
      _procedureSearch,
      _medicationSearch,
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
    _navigatorProblemTrigger.dispose();
    _navigatorSymptomTrigger.dispose();
    super.dispose();
  }

  void _calculateMap() {
    final sbp = int.tryParse(_sbp.text);
    final dbp = int.tryParse(_dbp.text);
    _map = sbp != null && dbp != null ? (sbp + (2 * dbp)) / 3 : null;
    if (mounted) setState(() {});
  }

  String? _clean(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _orNotRecorded(String? value) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? 'Not recorded' : trimmed;
  }

  void _checkMedicationGuardrails(List<PendingOrder> orders) {
    final medications = orders
        .where((order) => order.isMedication)
        .map((order) => order.label)
        .toList(growable: false);
    unawaited(
      ref
          .read(clinicalGuardrailProvider.notifier)
          .check(
            patientId: widget.patient.id,
            medications: medications,
            additionalSymptoms: _currentSymptoms,
            additionalVitals: _currentVitals,
          ),
    );
  }

  List<String> get _currentSymptoms => [
    _complaint.text,
    _hpi.text,
    _assessment.text,
    _diagnosis.text,
    _newProblemName.text,
  ].where((text) => text.trim().isNotEmpty).toList(growable: false);

  List<String> get _currentVitals => [
    if (_sbp.text.trim().isNotEmpty) 'SBP ${_sbp.text.trim()} mmHg',
    if (_dbp.text.trim().isNotEmpty) 'DBP ${_dbp.text.trim()} mmHg',
    if (_pulse.text.trim().isNotEmpty) 'pulse ${_pulse.text.trim()} bpm',
    if (_spo2.text.trim().isNotEmpty) 'SpO2 ${_spo2.text.trim()}%',
    if (_temp.text.trim().isNotEmpty)
      'temperature ${_temp.text.trim()} C',
  ];

  void _scheduleGuardrailRefresh() {
    final orders = ref.read(stagedOrdersProvider);
    final medications = orders
        .where((order) => order.isMedication)
        .map((order) => order.label);
    if (medications.isEmpty) return;
    ref
        .read(clinicalGuardrailProvider.notifier)
        .invalidate(patientId: widget.patient.id, medications: medications);
    _guardrailDebounce?.cancel();
    _guardrailDebounce = Timer(
      const Duration(milliseconds: 250),
      () => _checkMedicationGuardrails(ref.read(stagedOrdersProvider)),
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

      // New problems go through the DAO (Drift companion + sync enqueue).
      if (_newProblemName.text.trim().isNotEmpty) {
        final newId = await dao.addPatientProblem(
          patientId: widget.patient.id,
          problemName: _newProblemName.text.trim(),
          onsetDate: now,
        );
        activeProbId = newId;
        unawaited(
          ref
              .read(clinicalRuleGuardianProvider.notifier)
              .evaluate(
                triggerType: 'diagnosis',
                triggerValue: _newProblemName.text.trim(),
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

      // Build Encounter Entity — OPD vs IPD shapes the stored type.
      // The narrative comes from the EncounterDraft; this screen layers the
      // bedside columns (vitals, ward, diagnosis, template blob) on top.
      final draftNotifier = ref.read(encounterNotifierProvider.notifier);
      _pushNarrativeToDraft();
      // FIX 6 — persist the demographics-gated history sections. These fields
      // were rendered but never written to the draft, so growth/immunization
      // and menstrual/obstetric history were silently discarded on save.
      if (_isPediatricPatient) {
        draftNotifier.updatePediatric({
          'birthHistory': _clean(_birthHistory.text),
          'milestones': _clean(_milestones.text),
          'vaccination': _clean(_vaccination.text),
        });
      }
      if (_isFemalePatient) {
        draftNotifier.updateObGyn({
          'gplaa': _clean(_gplaa.text),
          'lmp': _clean(_lmp.text),
          'menstrualHistory': _clean(_menstrualHistory.text),
        });
      }
      draftNotifier.flush();
      final draft = ref.read(encounterNotifierProvider);

      final encounter = draft
          .toCompanion(
            ownerId: ownerId,
            patientId: widget.patient.id,
            encounterType: _isOpdMode ? 'OPD Consult' : 'IPD Bedside Note',
            occurredAt: now,
          )
          .copyWith(
            department: Value(_clean(_departmentText.text)),
            wardName: Value(_clean(_wardName.text)),
            bedNumber: Value(_clean(_bedNumber.text)),
            clinicalDiagnosis: Value(_clean(_diagnosis.text)),
            disposition: Value(_isOpdMode ? 'OPD' : _disposition),
            sbp: Value(sbpVal),
            dbp: Value(dbpVal),
            pulse: Value(pulseVal),
            spo2: Value(spo2Val),
            temperatureC: Value(tempVal),
            meanArterialPressure: Value(_map),
            personalAndSocialHistory: Value(
              [
                _clean(_personalHistory.text),
                _clean(_socialHistory.text),
              ].whereType<String>().join(' | '),
            ),
            dynamicData: Value({
              ...dynamicData,
              'encounter_mode': _isOpdMode ? 'OPD' : 'IPD',
              if ((draft.plan ?? '').trim().isNotEmpty) 'plan': draft.plan,
            }),
          );

      // Staged orders (catalog prescriptions + CDSS/banner investigations)
      // are converted to Drift companions and written in the SAME transaction
      // as the encounter, so a partially saved consult is impossible.
      final stagedNotifier = ref.read(stagedOrdersProvider.notifier);
      final staged = ref.read(stagedOrdersProvider);
      final prescriptions = stagedNotifier.toPrescriptionCompanions(
        patientId: widget.patient.id,
      );
      final investigations = stagedNotifier.toInvestigationCompanions(
        patientId: widget.patient.id,
      );

      await dao.savePOMREncounter(
        encounter: encounter,
        newProblems: newProblems,
        progressSnapshots: snapshots,
        interventions: interventions,
        prescriptions: prescriptions,
        investigations: investigations,
      );

      // Self-learning: persist staged terms, then clear both trays so the next
      // patient starts from a clean slate.
      if (staged.isNotEmpty) {
        await stagedNotifier.finalizeOrders(dao);
      }
      stagedNotifier.clear();
      draftNotifier.reset();

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
    // Null-safe display helper shared by template builders.
    String safe(String? v) => _orNotRecorded(v);
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
          values: {'notes': safe(_assessment.text)},
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

  @override
  Widget build(BuildContext context) {
    // Sprint 27 — AI failures (400/500 INVALID_ARGUMENT from a rogue legacy
    // parameter, quota, outage) reach the clinician as a non-blocking toast
    // instead of crashing or silently vanishing from the Encounter UI.
    ref.listen<String?>(aiErrorNoticeProvider, (previous, message) {
      if (message == null || !mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      ref.read(aiErrorNoticeProvider.notifier).clear();
    });
    ref.listen<List<PendingOrder>>(stagedOrdersProvider, (previous, next) {
      final priorMedicationNames = (previous ?? const <PendingOrder>[])
          .where((order) => order.isMedication)
          .map((order) => order.label.toLowerCase())
          .toSet();
      final nextMedicationNames = next
          .where((order) => order.isMedication)
          .map((order) => order.label.toLowerCase())
          .toSet();
      if (priorMedicationNames.length != nextMedicationNames.length ||
          !priorMedicationNames.containsAll(nextMedicationNames)) {
        _checkMedicationGuardrails(next);
      }
      for (final order in next) {
        if (order.isMedication &&
            !priorMedicationNames.contains(order.label.toLowerCase())) {
          unawaited(
            ref
                .read(clinicalRuleGuardianProvider.notifier)
                .evaluate(triggerType: 'medication', triggerValue: order.label),
          );
        }
      }
    });

    final dao = ref.watch(clinicalDaoProvider);
    final department = _departmentText.text.trim().isEmpty
        ? 'Clinical'
        : _departmentText.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          department.trim().isEmpty
              ? 'Clinical Encounter'
              : '$department Encounter',
        ),
      ),
      // Sprint 15 — the private learning loop. Placed at the end of the
      // consultation, which is the only moment the clinician actually knows how
      // confident they were and what they weighed.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AmbientScribeFab(patient: widget.patient),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final saved = await ReflectionEntrySheet.show(
                context,
                patientId: widget.patient.id,
              );
              if (!saved || !mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Reflection saved (private)')),
              );
            },
            icon: const Icon(Icons.psychology_alt_outlined),
            label: const Text('Log Reflection'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            const SubtleGuardianBanner(),
            // 1. LOCKED PATIENT IDENTIFIER HEADER
            _PatientBanner(patient: widget.patient),
            const SizedBox(height: 12),
            // OPD | IPD toggle.
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('OPD Consult'),
                  icon: Icon(Icons.storefront_outlined),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('IPD Bedside Note'),
                  icon: Icon(Icons.bed_outlined),
                ),
              ],
              selected: {_isOpdMode},
              onSelectionChanged: (value) =>
                  setState(() => _isOpdMode = value.first),
            ),
            const SizedBox(height: 12),
            // Live deterministic CDSS banners.
            EncounterCdssBanners(
              sbp: int.tryParse(_sbp.text),
              pulse: int.tryParse(_pulse.text),
              spo2: int.tryParse(_spo2.text),
            ),
            if (_isOpdMode) ...[
              OpdHistorySections(
                complaint: _complaint,
                hpi: _hpi,
                pastMedical: _pastMedical,
                pastSurgical: _pastSurgical,
                personalHistory: _personalHistory,
                socialHistory: _socialHistory,
                birthHistory: _birthHistory,
                milestones: _milestones,
                vaccination: _vaccination,
                gplaa: _gplaa,
                lmp: _lmp,
                menstrualHistory: _menstrualHistory,
                examination: _examination,
                // FIX 6 — demographics-aware gating. Pediatric history only for
                // patients under 18; OB/GYN history only for female patients.
                // Previously both flags were left at their default of `false`,
                // so these sections were unreachable for every patient.
                showPediatricHistory: _isPediatricPatient,
                showObGynHistory: _isFemalePatient,
              ),
              const SizedBox(height: 12),
            ] else ...[
              IpdProblemList(patientId: widget.patient.id),
              const SizedBox(height: 12),
              IpdContinuousOrders(patientId: widget.patient.id),
              const SizedBox(height: 12),
            ],
            OrdersAndPlanSection(
              medicationController: _medicationSearch,
              procedureController: _procedureSearch,
            ),

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
                      onFieldSubmitted: (value) {
                        _navigatorProblemTrigger.value = value;
                        unawaited(
                          ref
                              .read(clinicalRuleGuardianProvider.notifier)
                              .evaluate(
                                triggerType: 'diagnosis',
                                triggerValue: value,
                              ),
                        );
                      },
                      decoration: const InputDecoration(
                        labelText: 'Or Add New Clinical Problem',
                        hintText:
                            'e.g. Acute Appendicitis with Localized Peritonitis',
                        isDense: true,
                        prefixIcon: Icon(Icons.add_circle_outline, size: 20),
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _navigatorProblemTrigger,
                      builder: (context, value, child) =>
                          ClinicalRuleNavigator(
                            triggerType: 'diagnosis',
                            triggerValue: value,
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
              onFieldSubmitted: (value) {
                _navigatorProblemTrigger.value = value;
                unawaited(
                  ref
                      .read(clinicalRuleGuardianProvider.notifier)
                      .evaluate(
                        triggerType: 'diagnosis',
                        triggerValue: value,
                      ),
                );
              },
              decoration: const InputDecoration(
                labelText: 'Encounter Clinical Impression / Working Diagnosis',
                prefixIcon: Icon(Icons.psychology_outlined),
                isDense: true,
              ),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _navigatorProblemTrigger,
              builder: (context, value, child) => ClinicalRuleNavigator(
                triggerType: 'diagnosis',
                triggerValue: value,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _complaint,
              minLines: 2,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                _navigatorSymptomTrigger.value = value;
                unawaited(
                  ref
                      .read(clinicalRuleGuardianProvider.notifier)
                      .evaluate(
                        triggerType: 'symptom',
                        triggerValue: value,
                      ),
                );
              },
              decoration: const InputDecoration(
                labelText: 'Today\'s Complaints / S (Subjective)',
                alignLabelWithHint: true,
              ),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _navigatorSymptomTrigger,
              builder: (context, value, child) => ClinicalRuleNavigator(
                triggerType: 'symptom',
                triggerValue: value,
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
            GuardrailStatusWidget(patientId: widget.patient.id),
            const SizedBox(height: 8),
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
                      'CR No: $cr · ${patient.gender ?? 'Unspecified'}, ${DateTimeUtils.ageOn(patient.dateOfBirth, DateTime.now()) ?? '--'} yrs',
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
