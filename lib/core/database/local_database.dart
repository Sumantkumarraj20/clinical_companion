import 'dart:convert';

import 'package:drift/drift.dart';
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
// 1. PATIENT DEMOGRAPHICS (STRICTLY INVARIANT)
// ==========================================
@DataClassName('Patient')
@TableIndex(name: 'patients_full_name_idx', columns: {#fullName})
class Patients extends Table {
  @override
  String get tableName => 'patients';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get ownerId => text()();
  TextColumn get fullName => text()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  IntColumn get approximateAge => integer().nullable()();
  TextColumn get gender => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get addressOrLocation => text().nullable()();
  TextColumn get occupation => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get alternatePhone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

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
  TextColumn get shortName => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

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
@TableIndex(
  name: 'patient_hosp_reg_idx',
  columns: {#hospitalId, #hospitalRegNo},
)
class PatientHospitalIdentifiers extends Table {
  @override
  String get tableName => 'patient_hospital_identifiers';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get hospitalId =>
      text().references(Hospitals, #id, onDelete: KeyAction.cascade)();
  TextColumn get hospitalRegNo => text()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
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
    PersonalWiki,
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppDatabaseExecutor());

  @override
  int get schemaVersion => 16;

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
        
        try { await m.createTable(patients); } catch (_) {}
        try { await m.createTable(hospitals); } catch (_) {}
        try { await m.createTable(wards); } catch (_) {}
        try { await m.createTable(patientHospitalIdentifiers); } catch (_) {}
        try { await m.createTable(clinicalEncounters); } catch (_) {}
        try { await m.createTable(patientProblems); } catch (_) {}
        try { await m.createTable(problemProgressSnapshots); } catch (_) {}
        try { await m.createTable(clinicalInterventions); } catch (_) {}
        try { await m.createTable(clinicalOutcomeMetrics); } catch (_) {}
        try { await m.createTable(prescriptionOrders); } catch (_) {}
        try { await m.createTable(investigationOrders); } catch (_) {}
        try { await m.createTable(investigationResults); } catch (_) {}
        try { await m.createTable(learnedCatalog); } catch (_) {}
        try { await m.createTable(personalWiki); } catch (_) {}
        try { await m.createTable(offlineSyncQueue); } catch (_) {}
        try { await m.createTable(cdssRules); } catch (_) {}
        try { await m.createTable(ayushmanPackages); } catch (_) {}
        try { await m.createTable(hbpProcedures); } catch (_) {}
        try { await m.createTable(hbpImplants); } catch (_) {}
        try { await m.createTable(hbpStratifications); } catch (_) {}
        try { await m.createTable(documentRegistries); } catch (_) {}
        try { await m.createTable(clinicalObservations); } catch (_) {}
        try { await m.createTable(microbiologyCultures); } catch (_) {}
        try { await m.createTable(imagingStudies); } catch (_) {}

        // Apply fallback columns to drug_master in case Python script was old
        try { await m.addColumn(drugs, drugs.usageFrequency); } catch (_) {}
        try { await m.addColumn(drugs, drugs.associatedProblems); } catch (_) {}
        try { await m.addColumn(drugs, drugs.ownerId); } catch (_) {}

      } else {
        // ==========================================================
        // NORMAL INCREMENTAL UPGRADES FOR EXISTING USERS
        // ==========================================================
        if (from < 14) {
          try { await m.createTable(hospitals); } catch (_) {}
          try { await m.createTable(wards); } catch (_) {}
          try { await m.createTable(patientHospitalIdentifiers); } catch (_) {}
          try { await m.createTable(investigationOrders); } catch (_) {}
          try { await m.createTable(investigationResults); } catch (_) {}
          try { await m.createTable(learnedCatalog); } catch (_) {}
        }
        if (from < 15) {
          try { await m.addColumn(clinicalEncounters, clinicalEncounters.department); } catch (_) {}
          try { await m.addColumn(clinicalEncounters, clinicalEncounters.wardName); } catch (_) {}
          try { await m.addColumn(clinicalEncounters, clinicalEncounters.bedNumber); } catch (_) {}
        }
        if (from < 16) {
          try { await m.createTable(problemProgressSnapshots); } catch (_) {}
          try { await m.createTable(clinicalInterventions); } catch (_) {}
          try { await m.createTable(clinicalOutcomeMetrics); } catch (_) {}
          try { await m.createTable(prescriptionOrders); } catch (_) {}

          try { await m.addColumn(clinicalEncounters, clinicalEncounters.clinicalDiagnosis); } catch (_) {}
          try { await m.addColumn(clinicalEncounters, clinicalEncounters.icd11Code); } catch (_) {}
          try { await m.addColumn(clinicalEncounters, clinicalEncounters.clinicalAssessment); } catch (_) {}
          try { await m.addColumn(patientProblems, patientProblems.icd11Code); } catch (_) {}
          try { await m.addColumn(patientProblems, patientProblems.currentStatus); } catch (_) {}
          try { await m.addColumn(patientProblems, patientProblems.resolvedDate); } catch (_) {}
          try { await m.addColumn(investigationOrders, investigationOrders.problemId); } catch (_) {}
        }
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );
}
