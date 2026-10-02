import 'package:drift/drift.dart';
import 'dart:convert';

import '../local_database.dart';

part 'pharmacopeia_dao.g.dart';

@DriftAccessor(
  tables: [
    Drugs,
    ClinicalDrugs,
    Indications,
    ActiveIngredients,
    Formulations,
    Brands,
  ],
)
class PharmacopeiaDao extends DatabaseAccessor<AppDatabase>
    with _$PharmacopeiaDaoMixin {
  PharmacopeiaDao(super.db);

  // =========================================================================
  // CLINICAL DRUGS (POMR-integrated master table)
  // =========================================================================

  /// Safely decodes a JSON-encoded `List<String>` column.
  static List<String> decodeStringList(String? json) {
    if (json == null || json.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      return decoded is List
          ? decoded.map((e) => e.toString()).toList(growable: false)
          : const [];
    } catch (_) {
      return const [];
    }
  }

  /// POMR lookup: returns every clinical drug whose JSON-encoded
  /// `problemIndications` array contains [problemName].
  ///
  /// The JSON array is stored like `["Otitis Media","Strep Throat"]`, so a
  /// quoted-LIKE match (`%"Otitis Media"%`) is both safe against partial-word
  /// collisions and indexable enough for a 3,000-row master table.
  Future<List<ClinicalDrug>> getDrugsForProblem(String problemName) {
    final term = problemName.trim();
    if (term.isEmpty) return Future.value(const []);
    final safeTerm = term
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('"', r'\"');
    final pattern = '%"$safeTerm"%';
    return (select(clinicalDrugs)
          ..where((row) => row.problemIndications.like(pattern))
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.usageFrequency,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  /// Searches the master clinical table by molecule, brand string, forms, or
  /// free-text problems (indications/side effects are JSON but LIKE-friendly).
  Future<List<ClinicalDrug>> searchClinicalDrugs(String query,
      {int limit = 50}) {
    final term = query.trim();
    if (term.isEmpty) return Future.value(const []);
    final pattern = '%${term.replaceAll('%', r'\%')}%';
    return (select(clinicalDrugs)
          ..where((row) =>
              row.genericMolecule.like(pattern) |
              row.topBrands.like(pattern) |
              row.availableForms.like(pattern) |
              row.problemIndications.like(pattern) |
              row.prioritizedSideEffects.like(pattern))
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.usageFrequency,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();
  }

  Stream<List<ClinicalDrug>> watchClinicalDrugs({int limit = 300}) {
    return (select(clinicalDrugs)
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.genericMolecule,
                  mode: OrderingMode.asc,
                ),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<List<Drug>> searchDrugsPaged({
    required String query,
    int limit = 50,
    int offset = 0,
  }) {
    final safeLimit = limit.clamp(1, 200);
    final safeOffset = offset < 0 ? 0 : offset;
    final statement = select(drugs)
      ..where((row) => row.isActive.equals(true) & row.genericName.isNotNull())
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.isTrusted, mode: OrderingMode.desc),
        (row) => OrderingTerm(
          expression: row.usageFrequency,
          mode: OrderingMode.desc,
        ),
      ]);

    final term = query.trim();
    if (term.isNotEmpty) {
      final pattern = '%${term.replaceAll('%', '\\%')}%';
      statement.where(
        (row) =>
            row.brandName.like(pattern) |
            row.genericName.like(pattern) |
            row.uses.like(pattern) |
            row.category.like(pattern) |
            row.chemicalClass.like(pattern),
      );
    }
    statement.limit(safeLimit, offset: safeOffset);
    return statement.watch();
  }

  Future<void> insertDrug(DrugsCompanion values) =>
      attachedDatabase.into(drugs).insert(values);

  // Expose the update mechanism seamlessly
  Future<void> updateDrug(Drug value) => update(drugs).replace(value);

  Future<void> deleteDrug(Drug value) => delete(drugs).delete(value);

  Future<void> markTrusted(String id, bool trusted) async {
    await (update(drugs)..where((row) => row.id.equals(id))).write(
      DrugsCompanion(
        isTrusted: Value(trusted),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> upsertLearnedDrug({
    required String? brand,
    required String? generic,
    required String? dose,
    required List<String> problemNames,
    required String ownerId,
  }) async {
    final name = (brand?.trim().isNotEmpty == true ? brand : generic)?.trim();
    if (name == null || name.isEmpty) return;

    final existing = await (select(
      drugs,
    )..where((row) => row.brandName.equals(name))).getSingleOrNull();
    final problems = problemNames.toSet().toList(growable: false);

    if (existing == null) {
      await insertDrug(
        DrugsCompanion.insert(
          ownerId: ownerId,
          genericName: generic?.trim().isNotEmpty == true
              ? generic!.trim()
              : name,
          brandName: Value(
            brand?.trim().isNotEmpty == true ? brand!.trim() : null,
          ),
          strength: Value(
            dose?.trim().isNotEmpty == true ? dose!.trim() : null,
          ),
          usageFrequency: const Value(1),
          associatedProblems: Value(jsonEncode(problems)),
        ),
      );
      return;
    }

    final oldProblems = jsonDecode(existing.associatedProblems);
    final merged = <String>{
      if (oldProblems is List) ...oldProblems.map((value) => value.toString()),
      ...problems,
    }.toList(growable: false);

    await updateDrug(
      existing.copyWith(
        usageFrequency: existing.usageFrequency + 1,
        associatedProblems: jsonEncode(merged),
        customNotes: Value('Mentioned for: ${merged.join(', ')}'),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  // =========================================================================
  // OTA CATALOG SYNC (Sprint 7)
  // =========================================================================

  /// Google Sheet tab names (plus snake_case aliases) for each OTA table.
  /// The first name of each list is what the live Apps Script payload uses.
  static const List<String> _ingredientTabs = [
    'clinical_core',
    'active_ingredients',
  ];
  static const List<String> _indicationTabs = [
    'indications_dosing_matrix',
    'indications',
  ];
  static const List<String> _formulationTabs = [
    'formulations_administration',
    'formulations',
  ];
  static const List<String> _brandTabs = [
    'commercial_brands_trust_layer',
    'brands',
  ];

  /// Live sheet IDs follow `<PREFIX>-<CODE>-<n>`: `DRG-CEF-001`,
  /// `IND-CEF-001`, `FMT-CEF-001`, `BRD-CEF-001`. The middle token is the
  /// molecule key shared by all four tabs (verified: 10/10 codes cover all
  /// four tabs in the production payload), which is why the child tables
  /// store `moleculeCode` instead of FK columns.
  static final RegExp _sheetIdPattern = RegExp(
    r'^[A-Za-z]+-([A-Za-z0-9]+)-\d+$',
  );

  /// Derives the molecule join key (`CEF`) from a sheet ID, or `null` when
  /// the ID does not follow the convention.
  static String? _moleculeCode(String? sheetId) =>
      sheetId == null ? null : _sheetIdPattern.firstMatch(sheetId)?.group(1);

  /// Bulk-merges a decoded Google Apps Script payload into the hierarchical
  /// catalog tables (`active_ingredients`, `indications`, `formulations`,
  /// `brands`).
  ///
  /// * Runs in a single [transaction] via Drift's [batch] so a partially
  ///   mapped payload is never visible — nothing is committed unless every
  ///   table maps.
  /// * Uses [InsertMode.insertOrReplace] keyed on the sheet's natural IDs
  ///   ("Drug ID" / "Indication ID" / "Formulation ID" / "Brand ID"), so
  ///   re-running a sync is idempotent and no local catalog row is deleted.
  /// * Patient data (`patients`, encounters, `drug_master` trust flags,
  ///   prescriptions, notes, ...) lives in tables this method never touches.
  /// * Missing tabs, null cells, and unknown columns degrade gracefully —
  ///   only rows without their natural ID are skipped.
  Future<void> upsertOtaCatalog(Map<String, dynamic> jsonPayload) async {
    await transaction(() async {
      await batch((bulk) {
        _upsertIngredientRows(bulk, _extractRows(jsonPayload, _ingredientTabs));
        _upsertIndicationRows(bulk, _extractRows(jsonPayload, _indicationTabs));
        _upsertFormulationRows(
          bulk,
          _extractRows(jsonPayload, _formulationTabs),
        );
        _upsertBrandRows(bulk, _extractRows(jsonPayload, _brandTabs));
      });
    });
  }

  void _upsertIngredientRows(
    Batch bulk,
    List<Map<String, dynamic>> rows,
  ) {
    bulk.insertAll(
      activeIngredients,
      [
        for (final row in rows)
          if (_readString(row, const ['Drug ID', 'drug_id', 'Ingredient_ID'])
              case final id?)
            ActiveIngredientsCompanion(
              ingredientId: Value(id),
              moleculeCode: Value(_moleculeCode(id)),
              genericName: Value(
                _readString(row, const ['Generic Name', 'generic_name']) ?? id,
              ),
              pharmacologicalClass: Value(
                _readString(row, const [
                  'Pharmacological Class',
                  'pharmacological_class',
                  'Drug_Class',
                ]),
              ),
              mechanismOfAction: Value(
                _readString(row, const [
                  'Mechanism of Action',
                  'mechanism_of_action',
                ]),
              ),
              primaryRoutes: Value(
                _readString(row, const ['Primary Routes', 'primary_routes']),
              ),
              renalAdjustment: Value(
                _readString(row, const [
                  'Renal Clearance & Adjustment',
                  'renal_adjustment',
                ]),
              ),
              hepaticRisk: Value(
                _readString(row, const [
                  'Hepatic Risk & Monitoring',
                  'hepatic_risk',
                ]),
              ),
              criticalAlerts: Value(
                _readString(row, const [
                  'Critical Alerts & Contraindications',
                  'critical_alerts',
                  'Warnings',
                ]),
              ),
              pregnancyCategory: Value(
                _readString(row, const [
                  'Pregnancy & Teratogenicity',
                  'pregnancy_category',
                ]),
              ),
              syncedAt: Value(DateTime.now().toUtc()),
            ),
      ],
      mode: InsertMode.insertOrReplace,
    );
  }

  void _upsertIndicationRows(
    Batch bulk,
    List<Map<String, dynamic>> rows,
  ) {
    bulk.insertAll(
      indications,
      [
        for (final row in rows)
          if (_readString(row, const ['Indication ID', 'indication_id'])
              case final id?)
            IndicationsCompanion(
              indicationId: Value(id),
              moleculeCode: Value(_moleculeCode(id)),
              clinicalIndication: Value(
                _readString(
                  row,
                  const ['Clinical Indication', 'clinical_indication'],
                ),
              ),
              patientCohort: Value(
                _readString(row, const ['Patient Cohort', 'patient_cohort']),
              ),
              standardRegimen: Value(
                _readString(
                  row,
                  const ['Standard Regimen / Dose', 'standard_regimen'],
                ),
              ),
              routeFrequency: Value(
                _readString(row, const ['Route & Frequency', 'route_frequency']),
              ),
              typicalDuration: Value(
                _readString(row, const ['Typical Duration', 'typical_duration']),
              ),
              maxDailyCeiling: Value(
                _readString(
                  row,
                  const ['Max Daily Ceiling', 'max_daily_ceiling'],
                ),
              ),
              evidenceLevel: Value(
                _readString(row, const ['Evidence Level', 'evidence_level']),
              ),
              clinicalProtocol: Value(
                _readString(
                  row,
                  const [
                    'Clinical Protocol & Monitoring',
                    'clinical_protocol',
                  ],
                ),
              ),
              syncedAt: Value(DateTime.now().toUtc()),
            ),
      ],
      mode: InsertMode.insertOrReplace,
    );
  }

  void _upsertFormulationRows(
    Batch bulk,
    List<Map<String, dynamic>> rows,
  ) {
    bulk.insertAll(
      formulations,
      [
        for (final row in rows)
          if (_readString(row, const ['Formulation ID', 'formulation_id'])
              case final id?)
            FormulationsCompanion(
              formulationId: Value(id),
              moleculeCode: Value(_moleculeCode(id)),
              dosageFormStrength: Value(
                _readString(
                  row,
                  const ['Dosage Form & Strength', 'dosage_form_strength'],
                ),
              ),
              reconstitution: Value(
                _readString(
                  row,
                  const [
                    'Reconstitution Diluent & Volume',
                    'reconstitution',
                  ],
                ),
              ),
              administrationRoute: Value(
                _readString(
                  row,
                  const [
                    'Administration Route & Infusion Rate',
                    'administration_route',
                  ],
                ),
              ),
              storageStability: Value(
                _readString(
                  row,
                  const [
                    'Storage & Reconstituted Stability',
                    'storage_stability',
                  ],
                ),
              ),
              compatibilityAlerts: Value(
                _readString(
                  row,
                  const [
                    'Critical Compatibility Alerts',
                    'compatibility_alerts',
                  ],
                ),
              ),
              syncedAt: Value(DateTime.now().toUtc()),
            ),
      ],
      mode: InsertMode.insertOrReplace,
    );
  }

  void _upsertBrandRows(Batch bulk, List<Map<String, dynamic>> rows) {
    bulk.insertAll(
      brands,
      [
        for (final row in rows)
          if (_readString(row, const ['Brand ID', 'brand_id']) case final id?)
            BrandsCompanion(
              brandId: Value(id),
              moleculeCode: Value(_moleculeCode(id)),
              brandName: Value(
                _readString(row, const ['Brand Trade Name', 'brand_name']) ??
                    id,
              ),
              manufacturer: Value(
                _readString(
                  row,
                  const ['Manufacturer / Marketer', 'manufacturer'],
                ),
              ),
              packagingUnitStrength: Value(
                _readString(
                  row,
                  const [
                    'Packaging & Unit Strength',
                    'packaging_unit_strength',
                  ],
                ),
              ),
              trustTier: Value(
                _readString(row, const ['Trust Tier', 'trust_tier']),
              ),
              mrp: Value(_readDouble(row, const ['Approx. MRP (INR)', 'mrp'])),
              trustNotes: Value(
                _readString(row, const [
                  'Quality Certifications & Clinical Trust Notes',
                  'trust_notes',
                ]),
              ),
              syncedAt: Value(DateTime.now().toUtc()),
            ),
      ],
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Pulls the row list for the first matching sheet tab key. Tolerates a
  /// bare JSON array under the tab key, Apps Script wrappers of the shape
  /// `{"rows": [...]}` / `{"data": [...]}`, and missing/null tabs (empty).
  static List<Map<String, dynamic>> _extractRows(
    Map<String, dynamic> payload,
    List<String> tabKeys,
  ) {
    for (final key in tabKeys) {
      final section = payload[key];
      if (section == null) continue;
      final raw = section is Map ? (section['rows'] ?? section['data']) : section;
      if (raw is! List) continue;
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((row) => row.cast<String, dynamic>())
          .toList(growable: false);
    }
    return const [];
  }

  /// First non-empty string among [keys]; `null` for absent, blank, or
  /// literal `null`/`NA` cells (Google Sheets exports empty cells as `''`).
  static String? _readString(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null' || text == 'NA') {
        continue;
      }
      return text;
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> row, List<String> keys) {
    final text = _readString(row, keys);
    if (text == null) return null;
    final direct = double.tryParse(text);
    if (direct != null) return direct;
    // Sheets formats money cells as text ('₹5,400.00', '1,250.50'). Only
    // numeric columns reach this helper, so dropping every character that
    // isn't a digit, sign or decimal point is safe and yields '5400.00'.
    final cleaned = text.replaceAll(RegExp(r'[^\d.\-]'), '');
    return cleaned.isEmpty ? null : double.tryParse(cleaned);
  }

  /// Escapes LIKE wildcards so a user query of `50%` can't match everything.
  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  // =========================================================================
  // CLOUD CATALOG QUERIES (Sprint 7 UI tab)
  // =========================================================================

  /// Streams the merged OTA ingredients ordered by generic name; [query]
  /// filters on drug ID, generic name or pharmacological class (SQLite
  /// [like] is ASCII case-insensitive, which suffices for drug names).
  Stream<List<ActiveIngredient>> watchOtaIngredients({
    String query = '',
    int limit = 300,
  }) {
    final q = query.trim();
    final pattern = q.isEmpty ? null : '%${_escapeLike(q)}%';
    return (select(activeIngredients)
          ..where((row) => pattern == null
              ? const Constant<bool>(true)
              : row.ingredientId.like(pattern) |
                  row.genericName.like(pattern) |
                  coalesce<String>([
                    row.pharmacologicalClass,
                    const Constant(''),
                  ]).like(pattern))
          ..orderBy([(row) => OrderingTerm.asc(row.genericName)])
          ..limit(limit))
        .watch();
  }

  /// All dosing-matrix rows joined to one molecule via the derived
  /// `moleculeCode` (e.g. `CEF`), ordered by indication.
  Future<List<Indication>> indicationsForMolecule(String moleculeCode) {
    return (select(indications)
          ..where((row) => row.moleculeCode.equals(moleculeCode))
          ..orderBy([
            (row) => OrderingTerm.asc(row.clinicalIndication),
          ]))
        .get();
  }

  /// Formulation/preparation rows for one molecule.
  Future<List<Formulation>> formulationsForMolecule(String moleculeCode) {
    return (select(formulations)
          ..where((row) => row.moleculeCode.equals(moleculeCode))
          ..orderBy([
            (row) => OrderingTerm.asc(row.dosageFormStrength),
          ]))
        .get();
  }

  /// Commercial brands for one molecule, cheapest first.
  Future<List<Brand>> brandsForMolecule(String moleculeCode) {
    return (select(brands)
          ..where((row) => row.moleculeCode.equals(moleculeCode))
          ..orderBy([
            (row) => OrderingTerm.asc(row.mrp, nulls: NullsOrder.last),
            (row) => OrderingTerm.asc(row.brandName),
          ]))
        .get();
  }
}
