// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_dao.dart';

// ignore_for_file: type=lint
mixin _$ClinicalDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  $ClinicalEncountersTable get clinicalEncounters =>
      attachedDatabase.clinicalEncounters;
  $InvestigationsTable get investigations => attachedDatabase.investigations;
  $DrugsTable get drugs => attachedDatabase.drugs;
  $PersonalWikiTable get personalWiki => attachedDatabase.personalWiki;
  $OfflineSyncQueueTable get offlineSyncQueue =>
      attachedDatabase.offlineSyncQueue;
  $PatientProblemsTable get patientProblems => attachedDatabase.patientProblems;
  $ClinicalActionsTable get clinicalActions => attachedDatabase.clinicalActions;
  $ClinicalOutcomesTable get clinicalOutcomes =>
      attachedDatabase.clinicalOutcomes;
  $AyushmanPackagesTable get ayushmanPackages =>
      attachedDatabase.ayushmanPackages;
  $HbpProceduresTable get hbpProcedures => attachedDatabase.hbpProcedures;
  $HbpImplantsTable get hbpImplants => attachedDatabase.hbpImplants;
  $HbpStratificationsTable get hbpStratifications =>
      attachedDatabase.hbpStratifications;
  ClinicalDaoManager get managers => ClinicalDaoManager(this);
}

class ClinicalDaoManager {
  final _$ClinicalDaoMixin _db;
  ClinicalDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
  $$ClinicalEncountersTableTableManager get clinicalEncounters =>
      $$ClinicalEncountersTableTableManager(
        _db.attachedDatabase,
        _db.clinicalEncounters,
      );
  $$InvestigationsTableTableManager get investigations =>
      $$InvestigationsTableTableManager(
        _db.attachedDatabase,
        _db.investigations,
      );
  $$DrugsTableTableManager get drugs =>
      $$DrugsTableTableManager(_db.attachedDatabase, _db.drugs);
  $$PersonalWikiTableTableManager get personalWiki =>
      $$PersonalWikiTableTableManager(_db.attachedDatabase, _db.personalWiki);
  $$OfflineSyncQueueTableTableManager get offlineSyncQueue =>
      $$OfflineSyncQueueTableTableManager(
        _db.attachedDatabase,
        _db.offlineSyncQueue,
      );
  $$PatientProblemsTableTableManager get patientProblems =>
      $$PatientProblemsTableTableManager(
        _db.attachedDatabase,
        _db.patientProblems,
      );
  $$ClinicalActionsTableTableManager get clinicalActions =>
      $$ClinicalActionsTableTableManager(
        _db.attachedDatabase,
        _db.clinicalActions,
      );
  $$ClinicalOutcomesTableTableManager get clinicalOutcomes =>
      $$ClinicalOutcomesTableTableManager(
        _db.attachedDatabase,
        _db.clinicalOutcomes,
      );
  $$AyushmanPackagesTableTableManager get ayushmanPackages =>
      $$AyushmanPackagesTableTableManager(
        _db.attachedDatabase,
        _db.ayushmanPackages,
      );
  $$HbpProceduresTableTableManager get hbpProcedures =>
      $$HbpProceduresTableTableManager(_db.attachedDatabase, _db.hbpProcedures);
  $$HbpImplantsTableTableManager get hbpImplants =>
      $$HbpImplantsTableTableManager(_db.attachedDatabase, _db.hbpImplants);
  $$HbpStratificationsTableTableManager get hbpStratifications =>
      $$HbpStratificationsTableTableManager(
        _db.attachedDatabase,
        _db.hbpStratifications,
      );
}
