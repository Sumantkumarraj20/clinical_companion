// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingestion_inbox_dao.dart';

// ignore_for_file: type=lint
mixin _$IngestionInboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  $HospitalsTable get hospitals => attachedDatabase.hospitals;
  $ClinicalEncountersTable get clinicalEncounters =>
      attachedDatabase.clinicalEncounters;
  $IngestionInboxesTable get ingestionInboxes =>
      attachedDatabase.ingestionInboxes;
  IngestionInboxDaoManager get managers => IngestionInboxDaoManager(this);
}

class IngestionInboxDaoManager {
  final _$IngestionInboxDaoMixin _db;
  IngestionInboxDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
  $$HospitalsTableTableManager get hospitals =>
      $$HospitalsTableTableManager(_db.attachedDatabase, _db.hospitals);
  $$ClinicalEncountersTableTableManager get clinicalEncounters =>
      $$ClinicalEncountersTableTableManager(
        _db.attachedDatabase,
        _db.clinicalEncounters,
      );
  $$IngestionInboxesTableTableManager get ingestionInboxes =>
      $$IngestionInboxesTableTableManager(
        _db.attachedDatabase,
        _db.ingestionInboxes,
      );
}
