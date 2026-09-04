import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'local/database_executor.dart';

part 'local_database.g.dart';

final _uuid = Uuid();

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

@DataClassName('Patient')
@TableIndex(name: 'patients_hospital_reg_no_idx', columns: {#hospitalRegNo})
@TableIndex(name: 'patients_admission_date_idx', columns: {#admissionDate})
class Patients extends Table {
  @override
  String get tableName => 'patients';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get ownerId => text()();
  TextColumn get hospitalRegNo => text()();
  TextColumn get fullName => text()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get sex => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get currentDepartment =>
      text().withDefault(const Constant('Surgery'))();
  TextColumn get surgeryType => text().nullable()();
  TextColumn get complications => text().nullable()();
  DateTimeColumn get admissionDate => dateTime().nullable()();
  DateTimeColumn get dischargeDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {ownerId, hospitalRegNo},
  ];
}

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
  TextColumn get encounterType =>
      text().withDefault(const Constant('Ward Round'))();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get sbp => integer().nullable()();
  IntColumn get dbp => integer().nullable()();
  IntColumn get pulse => integer().nullable()();
  RealColumn get temperatureC => real().nullable()();
  IntColumn get respiratoryRate => integer().nullable()();
  IntColumn get spo2 => integer().nullable()();

  /// Kept as the `map` database column for compatibility with existing data.
  /// The Dart name avoids colliding with Drift's generated `map` method.
  RealColumn get meanArterialPressure => real().named('map').nullable()();
  TextColumn get chiefComplaint => text().nullable()();
  TextColumn get consultantAdvice => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get dynamicData =>
      text().map(const JsonMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get department => text().nullable()();
  TextColumn get wardName => text().nullable()();
  TextColumn get bedNumber => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get aiSummary => text().nullable()();
  TextColumn get problemId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

typedef DailyNote = ClinicalEncounter;
typedef DailyNotesCompanion = ClinicalEncountersCompanion;

@DataClassName('Investigation')
@TableIndex(name: 'investigations_status_idx', columns: {#status})
@TableIndex(name: 'investigations_test_name_idx', columns: {#testName})
class Investigations extends Table {
  @override
  String get tableName => 'investigation_tracker';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get ownerId => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get testName => text()();
  TextColumn get testCode => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get orderedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get sampleSentAt => dateTime().nullable()();
  DateTimeColumn get resultReceivedAt => dateTime().nullable()();
  TextColumn get resultValue => text().nullable()();
  TextColumn get resultUnit => text().nullable()();
  TextColumn get referenceRange => text().nullable()();
  TextColumn get organism => text().nullable()();
  TextColumn get sensitiveAntibiotics =>
      text().withDefault(const Constant('[]'))();
  TextColumn get resistantAntibiotics =>
      text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  TextColumn get problemId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Drug')
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
  TextColumn get substitutes => text().withDefault(const Constant(''))();
  TextColumn get sideEffects => text().withDefault(const Constant(''))();
  TextColumn get uses => text().withDefault(const Constant(''))();
  TextColumn get chemicalClass => text().withDefault(const Constant(''))();
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

@DataClassName('WikiEntry')
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

@DataClassName('PatientProblem')
class PatientProblems extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get problemName => text()();
  TextColumn get status => text().withDefault(const Constant('Active'))();
  DateTimeColumn get onsetDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ClinicalAction')
class ClinicalActions extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get problemId =>
      text().references(PatientProblems, #id, onDelete: KeyAction.cascade)();
  TextColumn get actionType => text()();
  TextColumn get description => text()();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ClinicalOutcome')
class ClinicalOutcomes extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get problemId =>
      text().references(PatientProblems, #id, onDelete: KeyAction.cascade)();
  TextColumn get metricName => text()();
  RealColumn get metricValue => real()();
  TextColumn get metricUnit => text().nullable()();
  TextColumn get treatmentMethod => text().nullable()();
  DateTimeColumn get measuredAt => dateTime().withDefault(currentDateAndTime)();

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
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
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

@DriftDatabase(
  tables: [
    Patients,
    ClinicalEncounters,
    Investigations,
    Drugs,
    PersonalWiki,
    OfflineSyncQueue,
    PatientProblems,
    ClinicalActions,
    ClinicalOutcomes,
    CdssRules,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Uses NativeDatabase.createInBackground on Android/desktop and the
  /// platform-equivalent drift_flutter executor on web.
  AppDatabase() : super(openAppDatabaseExecutor());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(patients, patients.complications);
      }
      if (from < 3) {
        await m.addColumn(patients, patients.currentDepartment);
        await m.createTable(clinicalEncounters);
        await customStatement('''
              INSERT OR IGNORE INTO clinical_encounters
                (id, owner_id, patient_id, encounter_type, occurred_at, sbp, dbp, pulse,
                 temperature_c, respiratory_rate, spo2, map, chief_complaint,
                 consultant_advice, note, dynamic_data, created_at, updated_at, last_synced_at)
              SELECT id, owner_id, patient_id, 'Ward Round', recorded_at, sbp, dbp, pulse,
                     temperature_c, respiratory_rate, spo2, map, chief_complaint,
                     consultant_advice, note, '{}', created_at, updated_at, last_synced_at
              FROM daily_vitals_notes
            ''');
      }
      if (from < 4) {
        await m.createTable(personalWiki);
      }
      if (from < 5) {
        await m.addColumn(clinicalEncounters, clinicalEncounters.department);
        await m.addColumn(clinicalEncounters, clinicalEncounters.wardName);
        await m.addColumn(clinicalEncounters, clinicalEncounters.bedNumber);
        await m.addColumn(clinicalEncounters, clinicalEncounters.imagePath);
        await m.addColumn(clinicalEncounters, clinicalEncounters.aiSummary);
      }
      if (from < 6) {
        await m.addColumn(drugs, drugs.substitutes);
        await m.addColumn(drugs, drugs.sideEffects);
        await m.addColumn(drugs, drugs.uses);
        await m.addColumn(drugs, drugs.chemicalClass);
        await m.addColumn(drugs, drugs.priceEstimate);
        await m.addColumn(drugs, drugs.isTrusted);
        await m.addColumn(drugs, drugs.customNotes);
      }
      if (from < 7) {
        await m.addColumn(clinicalEncounters, clinicalEncounters.problemId);
        await m.addColumn(investigations, investigations.problemId);
        await m.addColumn(drugs, drugs.usageFrequency);
        await m.addColumn(drugs, drugs.associatedProblems);
        await m.createTable(patientProblems);
        await m.createTable(clinicalActions);
        await m.createTable(clinicalOutcomes);
      }
      if (from < 8) await m.createTable(cdssRules);
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
