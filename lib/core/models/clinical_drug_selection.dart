import 'dart:convert';

import '../database/local_database.dart';

/// One drug as offered to the prescriber, merging the two catalogs the app
/// ships with:
///
/// * the **offline master** ([ClinicalDrug], 700+ local-curated rows bundled
///   in the app asset), and
/// * the **OTA clinical matrix** ([ActiveIngredient] / [Indication] /
///   [Formulation] / [Brand]) that arrives from the nightly Apps Script sync.
///
/// The two sets barely overlap, so a selection may legitimately carry only
/// one side of the merge. Every derived getter therefore degrades to `null`
/// rather than inventing data, and [hasClinicalDetail] lets the UI say so.
class ClinicalDrugSelection {
  const ClinicalDrugSelection({
    required this.molecule,
    this.master,
    this.ingredient,
    this.indication,
    this.formulation,
    this.brands = const [],
  });

  /// Canonical molecule / drug name shown to the clinician.
  final String molecule;

  /// Offline master row, when the drug exists in `clinical_drugs`.
  final ClinicalDrug? master;

  /// OTA active-ingredient row (safety, class, routes).
  final ActiveIngredient? ingredient;

  /// OTA dosing-matrix row (regimen, protocol, duration).
  final Indication? indication;

  /// OTA preparation row (strength, route, reconstitution).
  final Formulation? formulation;

  /// OTA commercial brands for the same molecule, cheapest first.
  final List<Brand> brands;

  /// True when the OTA clinical matrix contributed dosing/route detail.
  bool get hasClinicalDetail =>
      ingredient != null || indication != null || formulation != null;

  /// Human label for autocomplete rows: "Amoxicillin 500 mg · Tablet".
  String get displayLabel {
    final strength =
        formulation?.dosageFormStrength?.trim() ??
        brands.firstOrNull?.packagingUnitStrength?.trim();
    if (strength == null || strength.isEmpty) return molecule;
    return '$molecule · $strength';
  }

  /// Compact secondary line: forms, route and a couple of brands.
  String get subtitle {
    final parts = <String>[];
    final forms = availableForms;
    if (forms.isNotEmpty) parts.add(forms.take(3).join(', '));
    final routeValue = route;
    if (routeValue != null) parts.add(routeValue);
    final names = brandNames;
    if (names.isNotEmpty) parts.add(names.take(2).join(', '));
    return parts.join(' · ');
  }

  /// Standard regimen to pre-fill the prescription dose.
  ///
  /// Ordered by clinical authority: the dosing matrix's standard regimen
  /// first, then the preparation strength, then a brand's packaged strength.
  String? get standardDosage {
    return _firstNonEmpty([
      indication?.standardRegimen,
      indication?.maxDailyCeiling,
      formulation?.dosageFormStrength,
      brands.firstOrNull?.packagingUnitStrength,
    ]);
  }

  /// Administration guidance to pre-fill the order's special instructions.
  ///
  /// The protocol wins; the offline master supplies prescribing pearls when
  /// the OTA matrix has not been synced yet.
  String? get administrationGuidelines {
    return _firstNonEmpty([
      indication?.clinicalProtocol,
      master?.prescribingPearls,
      formulation?.reconstitution,
      formulation?.compatibilityAlerts,
      ingredient?.criticalAlerts,
    ]);
  }

  /// Administration route, preferring the most specific source available.
  String? get route {
    return _firstNonEmpty([
      formulation?.administrationRoute,
      indication?.routeFrequency,
      ingredient?.primaryRoutes,
      if (availableRoutes.isNotEmpty) availableRoutes.first,
    ]);
  }

  /// Typical course length, when the dosing matrix knows it.
  String? get duration => _firstNonEmpty([indication?.typicalDuration]);

  /// Preparation strengths available offline. `available_forms` is stored as
  /// a JSON array, not a comma-separated string.
  List<String> get availableForms => _decodeList(master?.availableForms);

  /// Routes recorded on the offline master.
  List<String> get availableRoutes => _decodeList(master?.routes);

  /// Brand names to display — OTA brands when synced, otherwise whatever the
  /// offline master knows.
  List<String> get brandNames {
    if (brands.isNotEmpty) {
      return [for (final brand in brands) brand.brandName];
    }
    return _decodeBrands(master?.topBrands);
  }

  static String? _firstNonEmpty(List<String?> candidates) {
    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  /// Tolerant list decoder: accepts a JSON array (`["Oral","IV"]`) as well as
  /// the legacy comma-separated form (`'Oral, IV'`).
  static List<String> _decodeList(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return const [];
    if (text.startsWith('[')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {
        // Fall through to the comma-separated interpretation.
      }
    }
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  /// The offline master stores brands as JSON objects
  /// (`[{"brand":"Modace 500mg","count":6}]`) rather than plain strings.
  static List<String> _decodeBrands(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return const [];
    if (text.startsWith('[')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is List) {
          return decoded
              .map(
                (entry) => entry is Map
                    ? (entry['brand'] ?? entry['name'] ?? '').toString()
                    : entry.toString(),
              )
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {
        // Fall through.
      }
    }
    return _decodeList(text);
  }
}
