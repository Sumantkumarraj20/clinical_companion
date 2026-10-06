import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/clinical_rule_engine.dart';

final clinicalGuardrailProvider =
    NotifierProvider<ClinicalGuardrailNotifier, GuardrailAssessment>(
      ClinicalGuardrailNotifier.new,
    );

class GuardrailAssessment {
  const GuardrailAssessment({
    this.patientId = '',
    this.medications = const [],
    this.additionalSymptoms = const [],
    this.additionalVitals = const [],
    this.isChecking = false,
    this.completed = true,
    this.rulesChecked = 0,
    this.conflicts = const [],
    this.requiredMonitoring = const [],
    this.acknowledged = false,
    this.error,
  });

  final String patientId;
  final List<String> medications;
  final List<String> additionalSymptoms;
  final List<String> additionalVitals;
  final bool isChecking;
  final bool completed;
  final int rulesChecked;
  final List<ClinicalRuleConflict> conflicts;
  final List<String> requiredMonitoring;
  final bool acknowledged;
  final String? error;

  bool get canSave =>
      completed && !isChecking && (conflicts.isEmpty || acknowledged);

  GuardrailAssessment copyWith({
    String? patientId,
    List<String>? medications,
    List<String>? additionalSymptoms,
    List<String>? additionalVitals,
    bool? isChecking,
    bool? completed,
    int? rulesChecked,
    List<ClinicalRuleConflict>? conflicts,
    List<String>? requiredMonitoring,
    bool? acknowledged,
    String? error,
    bool clearError = false,
  }) => GuardrailAssessment(
    patientId: patientId ?? this.patientId,
    medications: medications ?? this.medications,
    additionalSymptoms: additionalSymptoms ?? this.additionalSymptoms,
    additionalVitals: additionalVitals ?? this.additionalVitals,
    isChecking: isChecking ?? this.isChecking,
    completed: completed ?? this.completed,
    rulesChecked: rulesChecked ?? this.rulesChecked,
    conflicts: conflicts ?? this.conflicts,
    requiredMonitoring: requiredMonitoring ?? this.requiredMonitoring,
    acknowledged: acknowledged ?? this.acknowledged,
    error: clearError ? null : error ?? this.error,
  );
}

class ClinicalGuardrailNotifier extends Notifier<GuardrailAssessment> {
  int _request = 0;

  @override
  GuardrailAssessment build() => const GuardrailAssessment();

  void invalidate({
    required String patientId,
    required Iterable<String> medications,
  }) {
    final medicationNames = medications
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (medicationNames.isEmpty) return;
    _request++;
    state = GuardrailAssessment(
      patientId: patientId,
      medications: medicationNames,
      isChecking: true,
      completed: false,
    );
  }

  Future<void> check({
    required String patientId,
    required Iterable<String> medications,
    List<String> additionalSymptoms = const [],
    List<String> additionalVitals = const [],
  }) async {
    final medicationNames = medications
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final request = ++_request;
    if (medicationNames.isEmpty) {
      state = GuardrailAssessment(patientId: patientId);
      return;
    }

    final previous = state;
    state = GuardrailAssessment(
      patientId: patientId,
      medications: medicationNames,
      additionalSymptoms: additionalSymptoms,
      additionalVitals: additionalVitals,
      isChecking: true,
      completed: false,
    );
    try {
      final clinicalDao = ref.read(clinicalDaoProvider);
      final storedContext = await clinicalDao.getCurrentPatientContext(
        patientId,
      );
      final context = storedContext.copyWith(
        recentSymptoms: [
          ...storedContext.recentSymptoms,
          ...additionalSymptoms.where((value) => value.trim().isNotEmpty),
        ],
        recentVitals: [
          ...storedContext.recentVitals,
          ...additionalVitals.where((value) => value.trim().isNotEmpty),
        ],
      );
      final ruleDao = ref.read(clinicalRuleDaoProvider);
      final results = await Future.wait(
        medicationNames.map(
          (medication) => ruleDao.rulesForTrigger(
            triggerType: 'medication',
            triggerValue: medication,
          ),
        ),
      );
      final allRules = results.expand((rules) => rules).toList(growable: false);
      final conflicts = ClinicalRuleEngine.findConflicts(
        rules: allRules,
        context: context,
      );
      final verifiedRules = allRules
          .where((rule) => rule.isVerified)
          .toList(growable: false);
      if (request != _request) return;
      final sameWarnings =
          previous.patientId == patientId &&
          setEquals(
            previous.medications.map((value) => value.toLowerCase()).toSet(),
            medicationNames.map((value) => value.toLowerCase()).toSet(),
          ) &&
          _conflictKeys(
            previous.conflicts,
          ).toSet().difference(_conflictKeys(conflicts).toSet()).isEmpty &&
          _conflictKeys(conflicts)
              .toSet()
              .difference(_conflictKeys(previous.conflicts).toSet())
              .isEmpty;
      state = GuardrailAssessment(
        patientId: patientId,
        medications: medicationNames,
        additionalSymptoms: additionalSymptoms,
        additionalVitals: additionalVitals,
        completed: true,
        rulesChecked: verifiedRules.length,
        conflicts: conflicts,
        acknowledged: sameWarnings && previous.acknowledged,
        requiredMonitoring: verifiedRules
            .expand((rule) => rule.requiredMonitoring)
            .toSet()
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      if (request != _request) return;
      debugPrint(
        '[ClinicalGuardrail] Context check failed: $error\n$stackTrace',
      );
      state = GuardrailAssessment(
        patientId: patientId,
        medications: medicationNames,
        additionalSymptoms: additionalSymptoms,
        additionalVitals: additionalVitals,
        completed: false,
        error: error.toString(),
      );
    }
  }

  void acknowledge() {
    if (state.conflicts.isNotEmpty && state.completed && !state.isChecking) {
      state = state.copyWith(acknowledged: true);
    }
  }

  Future<void> recheckCurrent() async {
    if (state.patientId.isEmpty || state.medications.isEmpty) return;
    await check(
      patientId: state.patientId,
      medications: state.medications,
      additionalSymptoms: state.additionalSymptoms,
      additionalVitals: state.additionalVitals,
    );
  }

  static List<String> _conflictKeys(List<ClinicalRuleConflict> conflicts) => [
    for (final conflict in conflicts)
      '${conflict.rule.id}:${conflict.condition}:${conflict.evidence}',
  ];
}
