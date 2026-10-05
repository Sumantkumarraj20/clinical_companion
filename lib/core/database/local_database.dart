import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'local/database_executor.dart';
import 'schema/clinical_records.dart';

part 'local_database.g.dart';

final _uuid = Uuid();

// ==========================================
// TYPE CONVERTERS
// ==========================================
class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String>
    with
        JsonTypeConverter2<Map<String, dynamic>, String, Map<String, Object?>> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    try {
      final decoded = jsonDecode(fromDb);
      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);

  @override
  Map<String, dynamic> fromJson(Map<String, Object?> json) =>
      Map<String, dynamic>.from(json);

  @override
  Map<String, Object?> toJson(Map<String, dynamic> value) =>
      Map<String, Object?>.from(value);
}

class StringListConverter extends TypeConverter<List<String>, String>
    with JsonTypeConverter2<List<String>, String, List<Object?>> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    try {
      final value = jsonDecode(fromDb);
      return value is List
          ? value.map((item) => item.toString()).toList(growable: false)
          : const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);

  @override
  List<String> fromJson(List<Object?> json) =>
      json.map((item) => item.toString()).toList(growable: false);

  @override
  List<Object?> toJson(List<String> value) => List<Object?>.from(value);
}

// ==========================================
// 1. PATIENT DEMOGRAPHICS (STABLE IDENTITY)
// ==========================================
// Stable identity PLUS baseline clinical/contact data needed for rapid dose
// calculations at the point of care. Height/weight feed weight-based dosing;
// phones enable follow-up outreach. These map onto legacy SQLite columns that
// were already present in seeded files, so no migration is required.
@DataClassName('Patient')
@TableIndex(name: 'patients_full_name_idx', columns: {#fullName})
class Patients extends Table {
  @override
  String get tableName => 'patients';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get ownerId => text()();
  TextColumn get fullName => text()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get residence => text().nullable()();
  TextColumn get occupation => text().nullable()();

  // Baseline anthropometrics — used for weight-based / BSA dose calculations.
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();

  // Contact info for follow-up and outreach.
  TextColumn get phone => text().nullable()();
  TextColumn get alternatePhone => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 2. FACILITY MASTERS
// ==========================================
@DataClassName('Hospital')
class Hospitals extends Table {
  @override
  String get tableName => 'hospitals';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Ward')
class Wards extends Table {
  @override
  String get tableName => 'wards';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get hospitalId =>
      text().references(Hospitals, #id, onDelete: KeyAction.cascade)();
  TextColumn get department => text().nullable()();
  TextColumn get wardName => text()();
  IntColumn get bedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PatientHospitalIdentifier')
@TableIndex(name: 'patient_hosp_mrn_idx', columns: {#hospitalId, #mrn})
class PatientHospitalIdentifiers extends Table {
  @override
  String get tableName => 'patient_hospital_identifiers';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get hospitalId =>
      text().references(Hospitals, #id, onDelete: KeyAction.cascade)();
  // Medical Record Number assigned by the hospital for this patient.
  TextColumn get mrn => text().nullable()();
  // What kind of identifier is stored (defaults to 'MRN'; e.g. UHID, CR No).
  TextColumn get identifierType => text().withDefault(const Constant('MRN'))();
  // Kept so a patient may hold multiple historical MRNs per hospital while a
  // single one stays canonical for identity resolution.
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 3. CLINICAL ENCOUNTERS (EPISODIC CONSULTATION & ROUNDS)
// ==========================================
@DataClassName('ClinicalEncounter')
@TableIndex(
  name: 'clinical_encounters_patient_occurred_idx',
  columns: {#patientId, #occurredAt},
)
class ClinicalEncounters extends Table {
  @override
  String get tableName => 'clinical_encounters';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get ownerId => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get hospitalId => text()
      .references(Hospitals, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get encounterType => text().withDefault(
    const Constant('OPD'),
  )(); // OPD, Admission, Ward Round, Emergency, Operative
  // Sprint 3 — Dynamic Encounter & POMR. Canonical care context for the
  // encounter: 'OPD', 'IPD' or 'ER'. Derived from encounterType but stored
  // explicitly so the bedside UI can branch without parsing free text.
  TextColumn get careSetting =>
      text().withDefault(const Constant('OPD'))(); // OPD, IPD, ER
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();

  // Episodic Bedside Context
  TextColumn get department => text().nullable()();
  TextColumn get wardName => text().nullable()();
  TextColumn get bedNumber => text().nullable()();

  // Working Clinical Impression for this encounter
  TextColumn get clinicalDiagnosis => text().nullable()();
  TextColumn get icd11Code => text().nullable()();
  TextColumn get disposition =>
      text().nullable()(); // Home, Admitted, ICU, OT, Discharged, LAMA

  // Bedside Vitals
  IntColumn get sbp => integer().nullable()();
  IntColumn get dbp => integer().nullable()();
  IntColumn get pulse => integer().nullable()();
  RealColumn get temperatureC => real().nullable()();
  IntColumn get respiratoryRate => integer().nullable()();
  IntColumn get spo2 => integer().nullable()();
  RealColumn get meanArterialPressure => real().named('map').nullable()();

  // Clinical Narrative
  TextColumn get chiefComplaints => text().nullable()();
  TextColumn get historyOfPresentIllness => text().nullable()();
  TextColumn get pastHistory => text().nullable()();
  TextColumn get drugAndAllergyHistory => text().nullable()();
  TextColumn get personalAndSocialHistory => text().nullable()();
  TextColumn get examinationFindings => text().nullable()();
  TextColumn get clinicalAssessment => text().nullable()();
  TextColumn get consultantAdvice => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get aiSummary => text().nullable()();

  TextColumn get dynamicData =>
      text().map(const JsonMapConverter()).withDefault(const Constant('{}'))();

  // Sprint 3 — Structured speciality histories. Stored as JSON maps so new
  // fields can be captured without further migrations.
  // pediatricHistory: e.g. {"birthHistory": "...", "immunization": "...",
  // "developmentalMilestones": "...", "feedingHistory": "..."}
  TextColumn get pediatricHistory =>
      text().map(const JsonMapConverter()).withDefault(const Constant('{}'))();
  // obGynHistory: e.g. {"gravida": 2, "para": 1, "lmp": "...",
  // "menstrualHistory": "...", "contraception": "..."}
  TextColumn get obGynHistory =>
      text().map(const JsonMapConverter()).withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  // Sprint 14 — draft lifecycle. An encounter saved mid-consultation but not
  // yet signed off. Defaults to false so every existing row migrates to
  // "signed" and never silently appears in the pending queue.
  BoolColumn get isDraft => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

typedef DailyNote = ClinicalEncounter;
typedef DailyNotesCompanion = ClinicalEncountersCompanion;

// ==========================================
// 4. PROBLEM TRAJECTORY & EVOLUTION (POMR CORE)
// ==========================================
@DataClassName('PatientProblem')
class PatientProblems extends Table {
  @override
  String get tableName => 'patient_problems';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get initialEncounterId => text()
      .references(ClinicalEncounters, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get problemName =>
      text()(); // e.g. "Acute Appendicitis with Localized Peritonitis"
  TextColumn get icd11Code => text().nullable()();
  TextColumn get currentStatus => text().withDefault(
    const Constant('Active'),
  )(); // Active, Improving, Deteriorating, Controlled, Resolved, Recurred
  DateTimeColumn get onsetDate => dateTime().nullable()();
  DateTimeColumn get resolvedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProblemProgressSnapshot')
@TableIndex(name: 'prob_prog_patient_idx', columns: {#patientId, #problemId})
class ProblemProgressSnapshots extends Table {
  @override
  String get tableName => 'problem_progress_snapshots';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get problemId =>
      text().references(PatientProblems, #id, onDelete: KeyAction.cascade)();
  TextColumn get encounterId =>
      text().references(ClinicalEncounters, #id, onDelete: KeyAction.cascade)();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get statusSnapshot => text()(); // e.g. "Improving post-op day 3"
  TextColumn get clinicalCourseNote =>
      text()(); // e.g. "Drain serous, 30ml/24hr; flatus passed, soft abdomen"
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 5. PROBLEM-LINKED PROCEDURES & INTERVENTIONS
// ==========================================
@DataClassName('ClinicalIntervention')
@TableIndex(name: 'interventions_patient_idx', columns: {#patientId})
class ClinicalInterventions extends Table {
  @override
  String get tableName => 'clinical_interventions';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get encounterId =>
      text().references(ClinicalEncounters, #id, onDelete: KeyAction.cascade)();
  TextColumn get problemId => text()
      .references(PatientProblems, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get procedureName =>
      text()(); // e.g. "Open Appendectomy + Peritoneal Lavage"
  TextColumn get procedureCode =>
      text().nullable()(); // PM-JAY / ICD-9-CM / SNOMED code
  TextColumn get codingSystem =>
      text().nullable()(); // 'PMJAY', 'ICD11', 'LOCAL'
  TextColumn get anatomicalSite => text().nullable()();
  TextColumn get interventionRole => text().withDefault(
    const Constant('Therapeutic'),
  )(); // Diagnostic, Therapeutic, Palliative, Staging
  TextColumn get operativeFindings => text().nullable()();
  DateTimeColumn get performedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get performedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 6. OBJECTIVE OUTCOME & SERIAL MARKERS
// ==========================================
@DataClassName('ClinicalOutcomeMetric')
class ClinicalOutcomeMetrics extends Table {
  @override
  String get tableName => 'clinical_outcome_metrics';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get problemId =>
      text().references(PatientProblems, #id, onDelete: KeyAction.cascade)();
  TextColumn get encounterId => text()
      .references(ClinicalEncounters, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get metricName =>
      text()(); // e.g. "Abdominal Drain Output", "Wound Healing Score", "INR"
  RealColumn get metricValue => real()();
  TextColumn get metricUnit =>
      text().nullable()(); // "mL/24h", "Score", "Ratio"
  TextColumn get qualifyingNote => text().nullable()(); // e.g. "Serosanguinous"
  DateTimeColumn get measuredAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 7. MEDICATIONS & PHARMACOPEIA
// ==========================================
@DataClassName('PrescriptionOrder')
@TableIndex(name: 'prescriptions_patient_idx', columns: {#patientId})
class PrescriptionOrders extends Table {
  @override
  String get tableName => 'prescription_orders';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get encounterId =>
      text().references(ClinicalEncounters, #id, onDelete: KeyAction.cascade)();
  TextColumn get problemId => text()
      .references(PatientProblems, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get drugName => text()(); // Generic or Brand
  TextColumn get doseStrength => text().nullable()(); // "1 g", "500 mg"
  TextColumn get dosageForm => text().nullable()(); // "Inj", "Tab", "Syp"
  TextColumn get route => text().nullable()(); // "IV Infusion", "Oral", "SC"
  TextColumn get frequency =>
      text().nullable()(); // "TID", "q12h", "SOS", "Continuous"
  TextColumn get duration => text().nullable()(); // "5 days", "Until discharge"
  TextColumn get diluentAndRate =>
      text().nullable()(); // "in 100mL 0.9% NS over 30 mins"
  TextColumn get specialInstructions =>
      text().nullable()(); // "Post meals", "Check K+ prior"
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get orderedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Drug')
@TableIndex(name: 'drugs_brand_name_idx', columns: {#brandName})
@TableIndex(name: 'drugs_generic_name_idx', columns: {#genericName})
class Drugs extends Table {
  @override
  String get tableName => 'drug_master';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get ownerId => text()();
  TextColumn get genericName => text()();
  TextColumn get brandName => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get dosageForm => text().nullable()();
  TextColumn get route => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get substitutes => text().nullable()();
  TextColumn get sideEffects => text().nullable()();
  TextColumn get uses => text().nullable()();
  TextColumn get chemicalClass => text().nullable()();
  TextColumn get priceEstimate => text().nullable()();
  BoolColumn get isTrusted => boolean().withDefault(const Constant(false))();
  TextColumn get customNotes => text().nullable()();
  IntColumn get usageFrequency => integer().withDefault(const Constant(0))();
  TextColumn get associatedProblems =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 7b. MASTER CLINICAL DRUGS TABLE (POMR-integrated)
// ==========================================
// Hyper-optimized replacement for the bloated 3-table drug knowledge graph
// (ActiveIngredients → Formulations → Brands), which produced 222,000+
// duplicate rows. Populated offline by scripts/build_clinical_drugs.py:
//   1. Reads the legacy drug_master table (~248k rows)
//   2. Regex-strips forms/strengths from generic_name → base molecule
//   3. Keeps the top 3,000 most common molecules
//   4. Groups top 5 brands (₹) + unique forms per molecule
//   5. Enriches via gemini-1.5-flash → canonical problem arrays
//
// problemIndications & prioritizedSideEffects store JSON-encoded
// List<String> of canonical diagnosis strings (SNOMED/ICD-11 style) so they
// link directly to PatientProblems.problemName. Decoded in Dart via
// jsonDecode (see PharmacopeiaDao helpers).
// ==========================================
@DataClassName('ClinicalDrug')
class ClinicalDrugs extends Table {
  @override
  String get tableName => 'clinical_drugs';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get genericMolecule => text()();
  // JSON-encoded List<String> of standard problem names.
  TextColumn get problemIndications =>
      text().withDefault(const Constant('[]'))();
  // JSON-encoded List<String> of prioritised side-effect problem names.
  TextColumn get prioritizedSideEffects =>
      text().withDefault(const Constant('[]'))();
  TextColumn get prescribingPearls => text().nullable()();
  // Comma-separated, e.g. 'Tablet, Syrup, Injection'.
  TextColumn get availableForms => text().nullable()();
  // JSON-encoded List<String> of administration routes, e.g.
  // '["Intravenous","Intramuscular"]'. The shipped catalog asset always has
  // this column but it was previously unmapped, so route-aware prescribing had
  // no offline source at all and the only route data came from the networked
  // OTA catalog. Additive only — the column already exists on disk, so no
  // schema version bump is required.
  TextColumn get routes => text().nullable()();
  // Comma-separated, e.g. 'Augmentin (₹120), Clavam (₹110)'.
  TextColumn get topBrands => text().nullable()();
  IntColumn get usageFrequency => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 7c. OTA DRUG CATALOG (Sprint 7 — nightly Apps Script sync)
// ==========================================
// Mirrors the live Google Apps Script Web App JSON export, one table per
// sheet tab (row counts measured against the production endpoint):
//   clinical_core                  -> active_ingredients  (76 rows)
//   indications_dosing_matrix      -> indications         (77 rows)
//   formulations_administration    -> formulations        (76 rows)
//   commercial_brands_trust_layer  -> brands              (76 rows)
//
// Rows are upserted by PharmacopeiaDao.upsertOtaCatalog() using
// InsertMode.insertOrReplace keyed on the sheet's natural IDs
// ("Drug ID" / "Indication ID" / "Formulation ID" / "Brand ID"), so
// re-running a nightly sync is idempotent. Patient-owned data (drug_master
// trust flags, encounters, problems, prescriptions, notes) lives in separate
// tables and is NEVER touched by the OTA merge.
//
// Sheet IDs follow `<PREFIX>-<CODE>-<n>` (DRG-CEF-001, BRD-CEF-001); the
// middle token is derived into `moleculeCode` so the four tabs join without
// FK constraints — a malformed nightly row can never abort the transaction.
// ==========================================
@DataClassName('ActiveIngredient')
@TableIndex(name: 'active_ingredients_generic_idx', columns: {#genericName})
@TableIndex(name: 'active_ingredients_code_idx', columns: {#moleculeCode})
class ActiveIngredients extends Table {
  @override
  String get tableName => 'active_ingredients';

  // Natural key from the sheet ("Drug ID") — UUIDs would break
  // insertOrReplace idempotency.
  TextColumn get ingredientId => text()();
  // Derived molecule token shared by all four tabs, e.g. 'CEF'.
  TextColumn get moleculeCode => text().nullable()();
  TextColumn get genericName => text()();
  TextColumn get pharmacologicalClass => text().nullable()();
  TextColumn get mechanismOfAction => text().nullable()();
  TextColumn get primaryRoutes => text().nullable()();
  TextColumn get renalAdjustment => text().nullable()();
  TextColumn get hepaticRisk => text().nullable()();
  TextColumn get criticalAlerts => text().nullable()();
  TextColumn get pregnancyCategory => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {ingredientId};
}

@DataClassName('Indication')
@TableIndex(name: 'indications_code_idx', columns: {#moleculeCode})
class Indications extends Table {
  @override
  String get tableName => 'indications';

  TextColumn get indicationId => text()();
  TextColumn get moleculeCode => text().nullable()();
  TextColumn get clinicalIndication => text().nullable()();
  TextColumn get patientCohort => text().nullable()();
  TextColumn get standardRegimen => text().nullable()();
  TextColumn get routeFrequency => text().nullable()();
  TextColumn get typicalDuration => text().nullable()();
  TextColumn get maxDailyCeiling => text().nullable()();
  TextColumn get evidenceLevel => text().nullable()();
  TextColumn get clinicalProtocol => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {indicationId};
}

@DataClassName('Formulation')
@TableIndex(name: 'formulations_code_idx', columns: {#moleculeCode})
class Formulations extends Table {
  @override
  String get tableName => 'formulations';

  TextColumn get formulationId => text()();
  TextColumn get moleculeCode => text().nullable()();
  TextColumn get dosageFormStrength => text().nullable()();
  TextColumn get reconstitution => text().nullable()();
  TextColumn get administrationRoute => text().nullable()();
  TextColumn get storageStability => text().nullable()();
  TextColumn get compatibilityAlerts => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {formulationId};
}

@DataClassName('Brand')
@TableIndex(name: 'brands_code_idx', columns: {#moleculeCode})
@TableIndex(name: 'brands_name_idx', columns: {#brandName})
class Brands extends Table {
  @override
  String get tableName => 'brands';

  TextColumn get brandId => text()();
  TextColumn get moleculeCode => text().nullable()();
  TextColumn get brandName => text()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get packagingUnitStrength => text().nullable()();
  TextColumn get trustTier => text().nullable()();
  // "Approx. MRP (INR)" — arrives as number or '₹5,400.00' string.
  RealColumn get mrp => real().nullable()();
  TextColumn get trustNotes => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {brandId};
}

// ==========================================
// 8. INVESTIGATIONS & RESULTS
// ==========================================
@DataClassName('InvestigationOrder')
class InvestigationOrders extends Table {
  @override
  String get tableName => 'investigation_orders';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get encounterId => text()
      .references(ClinicalEncounters, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get problemId => text()
      .references(PatientProblems, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get testName => text()();
  TextColumn get testCode => text().nullable()();
  TextColumn get clinicalIndication => text().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('ordered'),
  )(); // ordered, sample_sent, result_received, cancelled
  DateTimeColumn get orderedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get sampleSentAt => dateTime().nullable()();
  DateTimeColumn get resultReceivedAt => dateTime().nullable()();
  TextColumn get ownerId =>
      text().withDefault(const Constant('local-practitioner'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('InvestigationResult')
class InvestigationResults extends Table {
  @override
  String get tableName => 'investigation_results';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get orderId => text().nullable()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get testName => text()();
  RealColumn get numericValue => real().nullable()();
  TextColumn get textValue => text().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get referenceRange => text().nullable()();
  BoolColumn get isAbnormal => boolean().withDefault(const Constant(false))();
  TextColumn get antibiogramJson => text().withDefault(const Constant('{}'))();

  /// Sprint 17 — provenance of this reading, used by semantic merging to decide
  /// whether an incoming value should overwrite this row.
  ///
  /// Null on pre-Sprint-17 rows, which are treated as least-authoritative so a
  /// real lab report can always supersede them.
  TextColumn get sourceAuthority => text().nullable()();
  DateTimeColumn get resultDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 9. SELF-LEARNING & CDSS
// ==========================================
@DataClassName('LearnedCatalogEntry')
@TableIndex(name: 'learned_catalog_cat_term_idx', columns: {#category, #term})
class LearnedCatalog extends Table {
  @override
  String get tableName => 'learned_catalog';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get category =>
      text()(); // investigation, procedure, advice, diagnosis
  TextColumn get term => text()();
  IntColumn get frequency => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CdssRule')
class CdssRules extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get targetProblem => text()();
  TextColumn get triggerCondition => text()();
  TextColumn get suggestedAction => text()();
  TextColumn get evidenceSource => text()();
  BoolColumn get requiresPreAuth =>
      boolean().withDefault(const Constant(false))();
  TextColumn get medicolegalAlert => text().withDefault(const Constant(''))();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// Reference Tables
@DataClassName('AyushmanPackage')
class AyushmanPackages extends Table {
  @override
  String get tableName => 'ayushman_packages';
  TextColumn get code => text()();
  TextColumn get packageName => text()();
  TextColumn get stratification => text().nullable()();
  RealColumn get rate => real().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {code};
}

@DataClassName('HbpProcedure')
class HbpProcedures extends Table {
  @override
  String get tableName => 'hbp_procedures';
  TextColumn get procedureCode => text()();
  TextColumn get packageName => text()();
  TextColumn get procedureName => text()();
  RealColumn get rate => real().nullable()();
  TextColumn get specialty => text().withDefault(const Constant(''))();
  @override
  Set<Column<Object>> get primaryKey => {procedureCode};
}

@DataClassName('HbpImplant')
class HbpImplants extends Table {
  @override
  String get tableName => 'hbp_implants';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get procedureCode => text()();
  TextColumn get implantCode => text()();
  TextColumn get implantName => text()();
  RealColumn get maximumPrice => real().nullable()();
}

@DataClassName('HbpStratification')
class HbpStratifications extends Table {
  @override
  String get tableName => 'hbp_stratifications';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get procedureCode => text()();
  TextColumn get stratificationCode => text()();
  TextColumn get stratificationName => text()();
  TextColumn get rule => text().withDefault(const Constant(''))();
}

@DataClassName('PersonalWikiEntry')
@TableIndex(name: 'personal_wiki_updated_idx', columns: {#updatedAt})
class PersonalWiki extends Table {
  @override
  String get tableName => 'personal_wiki';
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get ownerId => text()();
  TextColumn get topic => text()();
  TextColumn get markdownContent => text().withDefault(const Constant(''))();
  TextColumn get tags => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get departmentRelevance => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Sprint 15 — private clinical reflection, deliberately kept **outside** the
/// formal medical record.
///
/// A clinician's reasoning ("why did I think this was appendicitis rather than
/// a perforated ulcer, and what would have changed my mind?") is exactly what
/// makes them better over a career — but it is not part of the patient's chart,
/// must never be shown to another clinician without consent, and must not be
/// exported into audit datasets. Hence a separate table rather than a column
/// on encounters.
@DataClassName('ClinicalLearningLog')
class ClinicalLearningLogs extends Table {
  @override
  String get tableName => 'clinical_learning_logs';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  /// The encounter that prompted the reflection, when there was one. Nullable
  /// because reflections are often triggered by something seen *after* the
  /// encounter closed (a result, a readmission, a recall).
  TextColumn get encounterId => text()
      .references(ClinicalEncounters, #id, onDelete: KeyAction.setNull)
      .nullable()();

  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();

  TextColumn get ownerId =>
      text().withDefault(const Constant('local-practitioner'))();

  /// How confident the clinician felt at the time, 1–10.
  ///
  /// Captured *before* the outcome is known, which is what makes it a useful
  /// calibration signal later. Clamped in the DAO rather than by a CHECK
  /// constraint so a bad import cannot wedge the insert.
  IntColumn get diagnosisConfidenceScore =>
      integer().withDefault(const Constant(5))();

  /// Alternatives seriously considered, free text.
  TextColumn get differentialDiagnoses =>
      text().withDefault(const Constant(''))();

  /// The reasoning: what supported the leading diagnosis and what argued
  /// against it.
  TextColumn get decisionRationale => text().withDefault(const Constant(''))();

  /// What the clinician would do differently, or what they learned.
  TextColumn get clinicalTakeaway => text().withDefault(const Constant(''))();

  /// Sprint 16 — free-text `#hashtags` the clinician typed, stored as a JSON
  /// array.
  ///
  /// Kept apart from the prose so tags stay searchable and can cross-link into
  /// the wiki (`#hyponatremia` -> the hyponatremia guideline) without parsing
  /// free text on every read.
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    // One reflection per encounter; re-submitting updates rather than stacks
    // duplicates.
    {id},
  ];
}

@DataClassName('SyncQueueEntry')
class OfflineSyncQueue extends Table {
  @override
  String get tableName => 'sync_queue';
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get ownerId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get clientUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get processedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 10. DATABASE CLASS WITH COMPLETE MIGRATIONS
// ==========================================
@DriftDatabase(
  tables: [
    Patients,
    Hospitals,
    Wards,
    PatientHospitalIdentifiers,
    ClinicalEncounters,
    PatientProblems,
    ProblemProgressSnapshots,
    ClinicalInterventions,
    ClinicalOutcomeMetrics,
    PrescriptionOrders,
    InvestigationOrders,
    InvestigationResults,
    LearnedCatalog,
    Drugs,
    ClinicalDrugs,
    Indications,
    ActiveIngredients,
    Formulations,
    Brands,
    PersonalWiki,
    ClinicalLearningLogs,
    OfflineSyncQueue,
    CdssRules,
    AyushmanPackages,
    HbpProcedures,
    HbpImplants,
    HbpStratifications,
    DocumentRegistries,
    ClinicalObservations,
    MicrobiologyCultures,
    ImagingStudies,
    Admissions,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Executor is injectable so tests / smoke checks can run against an
  // in-memory NativeDatabase; production falls back to the encrypted
  // file-backed executor.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openAppDatabaseExecutor());

  @override
  int get schemaVersion => 28;

  /// Tables that must exist for the drug catalog and POMR to function.
  ///
  /// The bundled `clinical_drugs.sqlite` asset is a *different* database from
  /// the app schema: it ships the four Google-Sheets source tabs and carries
  /// `user_version = 1`. Opening it therefore runs the legacy `from == 1`
  /// upgrade path, which historically skipped the drug catalog tables
  /// entirely — so a fresh install ended up with no `drug_master`, and every
  /// `PharmacopeiaDao` query died with "no such table: drug_master".
  ///
  /// Rather than adding yet another numbered migration (which only helps users
  /// upgrading from one exact version and silently skips everyone else), the
  /// invariant is enforced on every open in [_ensureCatalogTables], which is
  /// idempotent and self-healing for any starting state.
  static const _requiredTables = <String>[
    'drug_master',
    'clinical_drugs',
    'active_ingredients',
    'indications',
    'formulations',
    'brands',
  ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1) {
        // ==========================================================
        // V1 TO LATEST: UPGRADING FROM PYTHON SEEDED DRUG DATABASE
        // ==========================================================
        // The asset database ONLY has the drugs tables.
        // We must generate all clinical app tables dynamically using their latest schemas.

        try {
          await m.createTable(patients);
        } catch (_) {}
        try {
          await m.createTable(hospitals);
        } catch (_) {}
        try {
          await m.createTable(wards);
        } catch (_) {}
        try {
          await m.createTable(patientHospitalIdentifiers);
        } catch (_) {}
        try {
          await m.createTable(clinicalEncounters);
        } catch (_) {}
        try {
          await m.createTable(patientProblems);
        } catch (_) {}
        try {
          await m.createTable(problemProgressSnapshots);
        } catch (_) {}
        try {
          await m.createTable(clinicalInterventions);
        } catch (_) {}
        try {
          await m.createTable(clinicalOutcomeMetrics);
        } catch (_) {}
        try {
          await m.createTable(prescriptionOrders);
        } catch (_) {}
        try {
          await m.createTable(investigationOrders);
        } catch (_) {}
        try {
          await m.createTable(investigationResults);
        } catch (_) {}
        try {
          await m.createTable(learnedCatalog);
        } catch (_) {}
        try {
          await m.createTable(personalWiki);
        } catch (_) {}
        try {
          await m.createTable(offlineSyncQueue);
        } catch (_) {}
        try {
          await m.createTable(cdssRules);
        } catch (_) {}
        try {
          await m.createTable(ayushmanPackages);
        } catch (_) {}
        try {
          await m.createTable(hbpProcedures);
        } catch (_) {}
        try {
          await m.createTable(hbpImplants);
        } catch (_) {}
        try {
          await m.createTable(hbpStratifications);
        } catch (_) {}
        try {
          await m.createTable(documentRegistries);
        } catch (_) {}
        try {
          await m.createTable(clinicalObservations);
        } catch (_) {}
        try {
          await m.createTable(microbiologyCultures);
        } catch (_) {}
        try {
          await m.createTable(imagingStudies);
        } catch (_) {}
        try {
          await m.createTable(admissions);
        } catch (_) {}

        // Apply fallback columns to drug_master in case Python script was old
        try {
          await m.addColumn(drugs, drugs.usageFrequency);
        } catch (_) {}
        try {
          await m.addColumn(drugs, drugs.associatedProblems);
        } catch (_) {}
        try {
          await m.addColumn(drugs, drugs.ownerId);
        } catch (_) {}
      } else {
        // ==========================================================
        // NORMAL INCREMENTAL UPGRADES FOR EXISTING USERS
        // ==========================================================
        if (from < 14) {
          try {
            await m.createTable(hospitals);
          } catch (_) {}
          try {
            await m.createTable(wards);
          } catch (_) {}
          try {
            await m.createTable(patientHospitalIdentifiers);
          } catch (_) {}
          try {
            await m.createTable(investigationOrders);
          } catch (_) {}
          try {
            await m.createTable(investigationResults);
          } catch (_) {}
          try {
            await m.createTable(learnedCatalog);
          } catch (_) {}
        }
        if (from < 15) {
          try {
            await m.addColumn(
              clinicalEncounters,
              clinicalEncounters.department,
            );
          } catch (_) {}
          try {
            await m.addColumn(clinicalEncounters, clinicalEncounters.wardName);
          } catch (_) {}
          try {
            await m.addColumn(clinicalEncounters, clinicalEncounters.bedNumber);
          } catch (_) {}
        }
        if (from < 16) {
          try {
            await m.createTable(problemProgressSnapshots);
          } catch (_) {}
          try {
            await m.createTable(clinicalInterventions);
          } catch (_) {}
          try {
            await m.createTable(clinicalOutcomeMetrics);
          } catch (_) {}
          try {
            await m.createTable(prescriptionOrders);
          } catch (_) {}

          try {
            await m.addColumn(
              clinicalEncounters,
              clinicalEncounters.clinicalDiagnosis,
            );
          } catch (_) {}
          try {
            await m.addColumn(clinicalEncounters, clinicalEncounters.icd11Code);
          } catch (_) {}
          try {
            await m.addColumn(
              clinicalEncounters,
              clinicalEncounters.clinicalAssessment,
            );
          } catch (_) {}
          try {
            await m.addColumn(patientProblems, patientProblems.icd11Code);
          } catch (_) {}
          try {
            await m.addColumn(patientProblems, patientProblems.currentStatus);
          } catch (_) {}
          try {
            await m.addColumn(patientProblems, patientProblems.resolvedDate);
          } catch (_) {}
          try {
            await m.addColumn(
              investigationOrders,
              investigationOrders.problemId,
            );
          } catch (_) {}
        }
        if (from < 17) {
          // Sprint 1 — Core Identity & Schema Integrity:
          // * New Admissions (inpatient episode) table.
          // * PatientHospitalIdentifiers gains the canonical MRN + identifierType.
          // * Patients gains `residence` (replaces the old addressOrLocation field).
          // Legacy columns are NOT dropped (no data loss); they simply fall out of
          // the schema, and existing values are backfilled into the new columns.
          try {
            await m.createTable(admissions);
          } catch (_) {}
          try {
            await m.addColumn(patients, patients.residence);
          } catch (_) {}
          try {
            await m.addColumn(
              patientHospitalIdentifiers,
              patientHospitalIdentifiers.mrn,
            );
          } catch (_) {}
          try {
            await m.addColumn(
              patientHospitalIdentifiers,
              patientHospitalIdentifiers.identifierType,
            );
          } catch (_) {}

          // Backfill canonical columns from the legacy ones so existing records
          // stay fully readable after the upgrade. Raw SQL is required because
          // the moved columns are not yet part of any query builder definition.
          try {
            await customStatement(
              'UPDATE patient_hospital_identifiers SET mrn = hospitalRegNo '
              "WHERE (mrn IS NULL OR mrn = '') AND hospitalRegNo IS NOT NULL",
            );
          } catch (_) {}
          try {
            await customStatement(
              'UPDATE patients SET residence = addressOrLocation '
              "WHERE (residence IS NULL OR residence = '') "
              'AND addressOrLocation IS NOT NULL',
            );
          } catch (_) {}
        }
        if (from < 19) {
          // POMR integration — collapse the 3-table drug knowledge graph
          // (ActiveIngredients / Formulations / Brands — 222k+ duplicate rows)
          // into the single hyper-optimized `clinical_drugs` master table.
          // Old tables are dropped; the legacy `drug_master` fallback is kept.
          try {
            await customStatement('DROP TABLE IF EXISTS brands');
          } catch (_) {}
          try {
            await customStatement('DROP TABLE IF EXISTS formulations');
          } catch (_) {}
          try {
            await customStatement('DROP TABLE IF EXISTS active_ingredients');
          } catch (_) {}
          try {
            await m.createTable(clinicalDrugs);
          } catch (_) {}
        }
        if (from < 20) {
          try {
            await m.addColumn(
              clinicalEncounters,
              clinicalEncounters.careSetting,
            );
          } catch (_) {}
          try {
            await m.addColumn(
              clinicalEncounters,
              clinicalEncounters.pediatricHistory,
            );
          } catch (_) {}
          try {
            await m.addColumn(
              clinicalEncounters,
              clinicalEncounters.obGynHistory,
            );
          } catch (_) {}

          // Backfill careSetting from the legacy free-text encounterType so
          // existing rows remain correctly classified in the bedside UI.
          try {
            await customStatement(
              "UPDATE clinical_encounters SET care_setting = 'IPD' "
              "WHERE care_setting = 'OPD' AND (encounter_type LIKE '%mission%' "
              "OR encounter_type LIKE '%Ward%' OR encounter_type LIKE '%ICU%')",
            );
            await customStatement(
              "UPDATE clinical_encounters SET care_setting = 'ER' "
              "WHERE care_setting = 'OPD' AND encounter_type LIKE '%mergen%'",
            );
          } catch (_) {}
        }
        if (from < 21) {
          // Sprint 7 (OTA Catalog Sync) — re-introduce the hierarchical
          // active_ingredients / formulations / brands tables as the nightly
          // Google Apps Script catalog target. v19 had dropped the legacy
          // copies; these are freshly created with the OTA schema and filled
          // by PharmacopeiaDao.upsertOtaCatalog(). Patient data is untouched.
          try {
            await m.createTable(activeIngredients);
          } catch (_) {}
          try {
            await m.createTable(formulations);
          } catch (_) {}
          try {
            await m.createTable(brands);
          } catch (_) {}
        }
        if (from < 22) {
          // Sprint 7.1 — align the OTA catalog with the LIVE Apps Script
          // payload (adds `indications`, reshapes the clinical_core /
          // formulations / brands columns to the real column names, and adds
          // the shared moleculeCode join key). These four tables hold ONLY
          // nightly-synced catalog rows — never patient data — so recreating
          // them is loss-free: the next sync refills them from the sheet.
          for (final table in const [
            'active_ingredients',
            'indications',
            'formulations',
            'brands',
          ]) {
            try {
              await customStatement('DROP TABLE IF EXISTS $table');
            } catch (_) {}
          }
          try {
            await m.createTable(indications);
          } catch (_) {}
          try {
            await m.createTable(activeIngredients);
          } catch (_) {}
          try {
            await m.createTable(formulations);
          } catch (_) {}
          try {
            await m.createTable(brands);
          } catch (_) {}
        }
        if (from < 23) {
          // (placeholder retained so the version chain stays readable)
        }
        if (from < 24) {
          // Sprint 14 — draft flag for the "Pending Notes" workspace tab.
          // Defaulted to false so every pre-existing encounter is treated as
          // signed; a bulk "draft = true" backfill would bury the clinician in
          // already-completed notes.
          try {
            await m.addColumn(clinicalEncounters, clinicalEncounters.isDraft);
          } catch (_) {}
        }
        if (from < 28) {
          // Sprint 17 — provenance for semantic merging. Nullable, no default,
          // so pre-existing readings are readable and treated as unknown.
          try {
            await m.addColumn(
              investigationResults,
              investigationResults.sourceAuthority,
            );
          } catch (_) {}
        }
        if (from < 27) {
          // Sprint 17 — absolute image deduplication key. Nullable with no
          // default: old rows stay NULL rather than sharing a sentinel, so a
          // NULL is never mistaken for a match by findDocumentByImageHash.
          try {
            await m.addColumn(
              documentRegistries,
              documentRegistries.imageHash,
            );
          } catch (_) {}
        }
        if (from < 26) {
          // Sprint 16 — reflection #hashtags. Additive column with an empty
          // default, so existing reflections stay readable and simply have no
          // tags until the clinician adds some.
          try {
            await m.addColumn(clinicalLearningLogs, clinicalLearningLogs.tags);
          } catch (_) {}
        }
        if (from < 25) {
          // Sprint 15 — the clinical learning log. Purely additive: a new
          // table, no ALTER on any existing one, so an interrupted upgrade can
          // never leave a clinician's patient data half-migrated. Reflections
          // are the clinician's own private notes, so they are deliberately
          // NOT enqueued for sync (see ClinicalDao.saveReflection).
          try {
            await m.createTable(clinicalLearningLogs);
          } catch (_) {}
        }
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
      await customStatement('PRAGMA busy_timeout = 5000');
      await _ensureCatalogTables();
    },
  );

  /// Creates any drug-catalog table that is missing from the opened file.
  ///
  /// Runs on every open. It is a no-op once the schema is correct, and it
  /// repairs a database seeded from an older or differently-shaped asset — the
  /// case that produced the "no such table: drug_master" crash.
  Future<void> _ensureCatalogTables() async {
    final existing = <String>{
      for (final row in await customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      ).get())
        row.read<String>('name'),
    };
    if (existing.containsAll(_requiredTables)) return;

    final migrator = Migrator(this);
    final tables = <TableInfo<Table, dynamic>>[
      drugs,
      clinicalDrugs,
      activeIngredients,
      indications,
      formulations,
      brands,
    ];
    for (final table in tables) {
      if (existing.contains(table.entityName)) continue;
      try {
        await migrator.createTable(table);
      } catch (error) {
        debugPrint(
          '[AppDatabase] Could not create ${table.entityName}: $error',
        );
      }
    }
  }
}
