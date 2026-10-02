import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local_database.dart';

final _uuid = Uuid();

class DocumentRegistries extends Table {
  TextColumn get id => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get documentCategory => text()();
  TextColumn get imagePath => text()();
  TextColumn get rawOcrTranscript => text().withDefault(const Constant(''))();
  RealColumn get confidenceScore => real().withDefault(const Constant(0.0))();
  DateTimeColumn get documentedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ClinicalObservations extends Table {
  TextColumn get id => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get documentId =>
      text().references(DocumentRegistries, #id, onDelete: KeyAction.cascade)();
  TextColumn get observationCategory => text()();
  TextColumn get code => text()();
  TextColumn get displayName => text()();
  RealColumn get numericValue => real().nullable()();
  TextColumn get textValue => text().nullable()();
  TextColumn get unit => text().nullable()();
  RealColumn get referenceLow => real().nullable()();
  RealColumn get referenceHigh => real().nullable()();
  BoolColumn get isAbnormal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get corroborationNote => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PrescriptionOrders extends Table {
  TextColumn get id => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get documentId =>
      text().references(DocumentRegistries, #id, onDelete: KeyAction.cascade)();
  TextColumn get drugName => text()();
  TextColumn get strength => text().nullable()();
  TextColumn get dosageForm => text().nullable()();
  TextColumn get route => text()();
  TextColumn get frequency => text()();
  TextColumn get diluentAndRate => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get orderedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MicrobiologyCultures extends Table {
  TextColumn get id => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get documentId =>
      text().references(DocumentRegistries, #id, onDelete: KeyAction.cascade)();
  TextColumn get sampleType => text()();
  TextColumn get organismIdentified => text().nullable()();
  TextColumn get colonyCount => text().nullable()();
  TextColumn get antibiogramJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get reportedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ImagingStudies extends Table {
  TextColumn get id => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get documentId =>
      text().references(DocumentRegistries, #id, onDelete: KeyAction.cascade)();
  TextColumn get modality => text()();
  TextColumn get anatomicalRegion => text()();
  TextColumn get findings => text()();
  TextColumn get impression => text()();
  DateTimeColumn get performedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ==========================================
// 4. ADMISSIONS — INPATIENT EPISODES
// ==========================================
// Episode/event model. A patient can have many admissions across hospitals;
// this table deliberately lives apart from the stable-identity tables.
@DataClassName('Admission')
@TableIndex(
  name: 'admissions_hospital_status_idx',
  columns: {#hospitalId, #status},
)
class Admissions extends Table {
  @override
  String get tableName => 'admissions';

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get hospitalId =>
      text().references(Hospitals, #id, onDelete: KeyAction.cascade)();
  TextColumn get wardName => text().nullable()();
  TextColumn get bedNumber => text().nullable()();
  DateTimeColumn get admissionTime =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dischargeTime => dateTime().nullable()();
  // 'active' while inpatient, 'discharged' once the episode is closed.
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}