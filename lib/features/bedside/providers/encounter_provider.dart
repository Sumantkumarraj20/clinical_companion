import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';

/// Canonical care contexts for a bedside encounter.
enum CareSetting { opd, ipd, er }

/// Immutable snapshot of the in-progress encounter narrative.
///
/// The [DynamicEncounterScreen] pushes throttled text edits into this
/// notifier (via [EncounterNotifier]) instead of calling setState on every
/// keystroke, keeping the form jank-free on low-end devices.
class EncounterDraft {
  const EncounterDraft({
    this.careSetting = CareSetting.opd,
    this.chiefComplaints,
    this.hpi,
    this.pastHistory,
    this.pediatricHistory = const <String, dynamic>{},
    this.obGynHistory = const <String, dynamic>{},
    this.examination,
    this.clinicalAssessment,
    this.consultantAdvice,
    this.plan,
  });

  final CareSetting careSetting;
  final String? chiefComplaints;
  final String? hpi;
  final String? pastHistory;
  final Map<String, dynamic> pediatricHistory;
  final Map<String, dynamic> obGynHistory;
  final String? examination;
  final String? clinicalAssessment;
  final String? consultantAdvice;
  final String? plan;

  EncounterDraft copyWith({
    CareSetting? careSetting,
    String? Function()? chiefComplaints,
    String? Function()? hpi,
    String? Function()? pastHistory,
    Map<String, dynamic>? pediatricHistory,
    Map<String, dynamic>? obGynHistory,
    String? Function()? examination,
    String? Function()? clinicalAssessment,
    String? Function()? consultantAdvice,
    String? Function()? plan,
  }) {
    return EncounterDraft(
      careSetting: careSetting ?? this.careSetting,
      chiefComplaints:
          chiefComplaints != null ? chiefComplaints() : this.chiefComplaints,
      hpi: hpi != null ? hpi() : this.hpi,
      pastHistory: pastHistory != null ? pastHistory() : this.pastHistory,
      pediatricHistory: pediatricHistory ?? this.pediatricHistory,
      obGynHistory: obGynHistory ?? this.obGynHistory,
      examination: examination != null ? examination() : this.examination,
      clinicalAssessment: clinicalAssessment != null
          ? clinicalAssessment()
          : this.clinicalAssessment,
      consultantAdvice: consultantAdvice != null
          ? consultantAdvice()
          : this.consultantAdvice,
      plan: plan != null ? plan() : this.plan,
    );
  }

  /// Merges this draft into a Drift insert companion.
  ClinicalEncountersCompanion toCompanion({
    required String ownerId,
    required String patientId,
    required String encounterType,
    required DateTime occurredAt,
  }) {
    return ClinicalEncountersCompanion.insert(
      ownerId: ownerId,
      patientId: patientId,
      encounterType: Value(encounterType),
      careSetting: Value(
        switch (careSetting) {
          CareSetting.opd => 'OPD',
          CareSetting.ipd => 'IPD',
          CareSetting.er => 'ER',
        },
      ),
      occurredAt: Value(occurredAt),
      chiefComplaints: Value(chiefComplaints),
      historyOfPresentIllness: Value(hpi),
      pastHistory: Value(pastHistory),
      pediatricHistory: Value(pediatricHistory),
      obGynHistory: Value(obGynHistory),
      examinationFindings: Value(examination),
      clinicalAssessment: Value(clinicalAssessment),
      consultantAdvice: Value(consultantAdvice),
    );
  }
}

/// Holds the working [EncounterDraft] for the active bedside session.
///
/// Text-field updates are debounced internally ([commitBuffer]) so callers can
/// push every keystroke without thrashing the provider graph.
class EncounterNotifier extends Notifier<EncounterDraft> {
  Timer? _debounce;
  EncounterDraft _pending = const EncounterDraft();

  static const Duration commitBuffer = Duration(milliseconds: 400);

  @override
  EncounterDraft build() => const EncounterDraft();

  void _scheduleCommit(EncounterDraft next) {
    _pending = next;
    _debounce?.cancel();
    _debounce = Timer(commitBuffer, () {
      state = _pending;
    });
  }

  void setCareSetting(CareSetting setting) {
    state = state.copyWith(careSetting: setting);
  }

  void updateChiefComplaints(String text) =>
      _scheduleCommit(state.copyWith(chiefComplaints: () => text));

  void updateHPI(String text) =>
      _scheduleCommit(state.copyWith(hpi: () => text));

  void updatePastHistory(String text) =>
      _scheduleCommit(state.copyWith(pastHistory: () => text));

  void updatePediatric(Map<String, dynamic> data) =>
      _scheduleCommit(
        state.copyWith(pediatricHistory: {...state.pediatricHistory, ...data}),
      );

  void updateObGyn(Map<String, dynamic> data) => _scheduleCommit(
    state.copyWith(obGynHistory: {...state.obGynHistory, ...data}),
  );

  void updateExamination(String text) =>
      _scheduleCommit(state.copyWith(examination: () => text));

  void updateAssessment(String text) =>
      _scheduleCommit(state.copyWith(clinicalAssessment: () => text));

  void updateAdvice(String text) =>
      _scheduleCommit(state.copyWith(consultantAdvice: () => text));

  void updatePlan(String text) =>
      _scheduleCommit(state.copyWith(plan: () => text));

  /// Flushes any debounced edits immediately (call before persisting).
  void flush() {
    _debounce?.cancel();
    if (_pending != state) state = _pending;
  }

  void reset() {
    _debounce?.cancel();
    _pending = const EncounterDraft();
    state = _pending;
  }
}

final encounterNotifierProvider =
    NotifierProvider<EncounterNotifier, EncounterDraft>(
      EncounterNotifier.new,
    );
