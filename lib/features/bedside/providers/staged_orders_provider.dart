import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cds/decision_support_engine.dart';
import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/models/clinical_drug_selection.dart';

/// A staged order waiting to be committed to the encounter plan.
///
/// Beyond the label used by the CDSS banner, a [PendingOrder] carries the
/// prescription fields that the drug catalog can pre-fill. They are plain
/// mutable values (not frozen) so the clinician can correct the suggested dose
/// or route before finalizing — the catalog proposes, the clinician decides.
class PendingOrder {
  PendingOrder({
    required this.label,
    this.kind = OrderProposalKind.lab,
    this.details,
    this.source = 'cdss',
    this.dose,
    this.route,
    this.frequency,
    this.duration,
    this.dosageForm,
    this.specialInstructions,
    this.brandName,
  });

  final String label;
  final OrderProposalKind kind;
  final String? details;
  final String source;

  /// Dose/strength, pre-filled from `ClinicalDrugSelection.standardDosage`.
  String? dose;

  /// Administration route, from `ClinicalDrugSelection.route`.
  String? route;

  /// e.g. 'TID', 'q12h' — rarely known from the catalog, so usually manual.
  String? frequency;

  /// Course length, from the dosing matrix when available.
  String? duration;

  /// 'Tablet', 'Injection', …
  String? dosageForm;

  /// Free-text instructions, from
  /// `ClinicalDrugSelection.administrationGuidelines`.
  String? specialInstructions;

  /// Chosen commercial brand, when the clinician picked one.
  String? brandName;

  bool get isLab => kind == OrderProposalKind.lab;

  bool get isMedication => kind == OrderProposalKind.medication;

  /// How the drug is written on the prescription chart.
  String get prescriptionName {
    final brand = brandName?.trim();
    if (brand == null || brand.isEmpty) return label;
    return '$label ($brand)';
  }

  PendingOrder copyWith({
    String? label,
    OrderProposalKind? kind,
    String? details,
    String? source,
    String? dose,
    String? route,
    String? frequency,
    String? duration,
    String? dosageForm,
    String? specialInstructions,
    String? brandName,
  }) => PendingOrder(
    label: label ?? this.label,
    kind: kind ?? this.kind,
    details: details ?? this.details,
    source: source ?? this.source,
    dose: dose ?? this.dose,
    route: route ?? this.route,
    frequency: frequency ?? this.frequency,
    duration: duration ?? this.duration,
    dosageForm: dosageForm ?? this.dosageForm,
    specialInstructions: specialInstructions ?? this.specialInstructions,
    brandName: brandName ?? this.brandName,
  );
}

final stagedOrdersProvider =
    NotifierProvider<StagedOrdersNotifier, List<PendingOrder>>(
      StagedOrdersNotifier.new,
    );

class StagedOrdersNotifier extends Notifier<List<PendingOrder>> {
  @override
  List<PendingOrder> build() => const [];

  bool _same(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  void addProposal(OrderProposal proposal, {String source = 'cdss'}) {
    if (state.any((o) => _same(o.label, proposal.label))) return;
    state = [
      ...state,
      PendingOrder(
        label: proposal.label,
        kind: proposal.kind,
        details: proposal.details,
        source: source,
      ),
    ];
  }

  void addAllProposals(
    List<OrderProposal> proposals, {
    String source = 'cdss',
  }) {
    final existing = state.map((o) => o.label.trim().toLowerCase()).toSet();
    final fresh = <PendingOrder>[];
    for (final p in proposals) {
      if (existing.add(p.label.trim().toLowerCase())) {
        fresh.add(
          PendingOrder(
            label: p.label,
            kind: p.kind,
            details: p.details,
            source: source,
          ),
        );
      }
    }
    if (fresh.isNotEmpty) state = [...state, ...fresh];
  }

  void addManual(
    String label, {
    String source = 'manual',
    String? details,
    OrderProposalKind kind = OrderProposalKind.lab,
  }) {
    final term = label.trim();
    if (term.isEmpty || state.any((o) => _same(o.label, term))) return;
    state = [
      ...state,
      PendingOrder(label: term, kind: kind, source: source, details: details),
    ];
  }

  /// Stages a drug chosen from the catalog, pre-filling the prescription
  /// fields the database already knows:
  ///
  /// * `standardDosage`           → [PendingOrder.dose]
  /// * `administrationGuidelines` → [PendingOrder.specialInstructions]
  /// * `route`                    → [PendingOrder.route]
  ///
  /// Nothing is validated here — the clinician reviews and edits every field
  /// in the orders tray before finalizing.
  void addMedication(
    ClinicalDrugSelection selection, {
    String? brandName,
    String? frequency,
  }) {
    final label = selection.molecule.trim();
    if (label.isEmpty) return;

    final dose = selection.standardDosage;
    final route = selection.route;
    final brand = brandName?.trim();

    // De-duplicate on the full regimen rather than the drug name, so two doses
    // of the same drug stay orderable while a double tap is still absorbed.
    if (state.any(
      (o) =>
          o.isMedication &&
          _same(o.label, label) &&
          _same(o.dose ?? '', dose ?? '') &&
          _same(o.route ?? '', route ?? ''),
    )) {
      return;
    }

    state = [
      ...state,
      PendingOrder(
        label: label,
        kind: OrderProposalKind.medication,
        source: 'catalog',
        dose: dose,
        route: route,
        frequency: frequency,
        duration: selection.duration,
        dosageForm: selection.availableForms.firstOrNull,
        specialInstructions: selection.administrationGuidelines,
        brandName: (brand == null || brand.isEmpty)
            ? selection.brandNames.firstOrNull
            : brand,
        details: selection.hasClinicalDetail
            ? 'Catalog dosing applied'
            : 'Added from the offline drug catalog',
      ),
    ];
  }

  /// Replaces one staged order — used by the editable tray.
  ///
  /// Takes a mutator rather than a copyWith because the tray edits fields in
  /// place; the notifier still swaps the list so the UI rebuilds.
  void updateAt(int index, void Function(PendingOrder) mutate) {
    if (index < 0 || index >= state.length) return;
    final next = [...state];
    mutate(next[index]);
    state = next;
  }

  /// Locates a staged order by identity so an editable row can write back even
  /// after the list has been reordered or an earlier row was removed.
  ///
  /// Falls back to a label match so a row is never silently dropped when a
  /// dose edit makes the full regimen no longer match.
  int indexOf(PendingOrder target) {
    final exact = state.indexWhere(
      (o) =>
          identical(o, target) ||
          (o.label == target.label &&
              o.dose == target.dose &&
              o.route == target.route),
    );
    if (exact >= 0) return exact;
    return state.indexWhere((o) => _same(o.label, target.label));
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state..removeAt(index)];
  }

  void removeByLabel(String label) {
    state = state.where((o) => !_same(o.label, label)).toList();
  }

  void clear() => state = const [];

  int get medicationCount => state.where((o) => o.isMedication).length;

  int get investigationCount => state.where((o) => o.isLab).length;

  /// Converts every staged medication into a Drift companion for the atomic
  /// POMR write. `encounterId` is left blank because
  /// `ClinicalDao.savePOMREncounter` stamps the real id inside the same
  /// transaction.
  List<PrescriptionOrdersCompanion> toPrescriptionCompanions({
    required String patientId,
  }) {
    final now = DateTime.now().toUtc();
    return [
      for (final order in state)
        if (!order.isLab && order.label.trim().isNotEmpty)
          PrescriptionOrdersCompanion.insert(
            patientId: patientId,
            encounterId: '',
            drugName: order.prescriptionName,
            dosageForm: Value(_nullIfEmpty(order.dosageForm)),
            doseStrength: Value(_nullIfEmpty(order.dose)),
            route: Value(_nullIfEmpty(order.route)),
            frequency: Value(_nullIfEmpty(order.frequency)),
            duration: Value(_nullIfEmpty(order.duration)),
            specialInstructions: Value(_nullIfEmpty(order.specialInstructions)),
            orderedAt: Value(now),
          ),
    ];
  }

  /// Converts every staged lab into an investigation order.
  List<InvestigationOrdersCompanion> toInvestigationCompanions({
    required String patientId,
  }) {
    return [
      for (final order in state)
        if (order.isLab && order.label.trim().isNotEmpty)
          InvestigationOrdersCompanion.insert(
            patientId: patientId,
            testName: order.label.trim(),
            clinicalIndication: Value(
              _nullIfEmpty(order.details ?? order.specialInstructions),
            ),
          ),
    ];
  }

  static String? _nullIfEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Persist staged terms into the self-learning catalog so the next
  /// 2-letter search surfaces frequent items instantly.
  ///
  /// Takes the DAO rather than reaching for a provider so this notifier stays
  /// free of database wiring (and `app_providers` can re-export it).
  Future<void> finalizeOrders(
    ClinicalDao dao, {
    String category = 'medication',
  }) async {
    for (final order in state) {
      await dao.recordCatalogUsage(category: category, term: order.label);
    }
  }
}
