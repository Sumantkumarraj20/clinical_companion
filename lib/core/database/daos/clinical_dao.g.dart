// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_dao.dart';

// ignore_for_file: type=lint
mixin _$ClinicalDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  $HospitalsTable get hospitals => attachedDatabase.hospitals;
  $WardsTable get wards => attachedDatabase.wards;
  $PatientHospitalIdentifiersTable get patientHospitalIdentifiers =>
      attachedDatabase.patientHospitalIdentifiers;
  $ClinicalEncountersTable get clinicalEncounters =>
      attachedDatabase.clinicalEncounters;
  $PatientProblemsTable get patientProblems => attachedDatabase.patientProblems;
  $ProblemProgressSnapshotsTable get problemProgressSnapshots =>
      attachedDatabase.problemProgressSnapshots;
  $ClinicalInterventionsTable get clinicalInterventions =>
      attachedDatabase.clinicalInterventions;
  $ClinicalOutcomeMetricsTable get clinicalOutcomeMetrics =>
      attachedDatabase.clinicalOutcomeMetrics;
  $PrescriptionOrdersTable get prescriptionOrders =>
      attachedDatabase.prescriptionOrders;
  $InvestigationOrdersTable get investigationOrders =>
      attachedDatabase.investigationOrders;
  $InvestigationResultsTable get investigationResults =>
      attachedDatabase.investigationResults;
  $LearnedCatalogTable get learnedCatalog => attachedDatabase.learnedCatalog;
  $DrugsTable get drugs => attachedDatabase.drugs;
  $PersonalWikiTable get personalWiki => attachedDatabase.personalWiki;
  $OfflineSyncQueueTable get offlineSyncQueue =>
      attachedDatabase.offlineSyncQueue;
  $AyushmanPackagesTable get ayushmanPackages =>
      attachedDatabase.ayushmanPackages;
  $HbpProceduresTable get hbpProcedures => attachedDatabase.hbpProcedures;
  $HbpImplantsTable get hbpImplants => attachedDatabase.hbpImplants;
  $HbpStratificationsTable get hbpStratifications =>
      attachedDatabase.hbpStratifications;
  $DocumentRegistriesTable get documentRegistries =>
      attachedDatabase.documentRegistries;
  $ClinicalObservationsTable get clinicalObservations =>
      attachedDatabase.clinicalObservations;
  ClinicalDaoManager get managers => ClinicalDaoManager(this);
}

class ClinicalDaoManager {
  final _$ClinicalDaoMixin _db;
  ClinicalDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
  $$HospitalsTableTableManager get hospitals =>
      $$HospitalsTableTableManager(_db.attachedDatabase, _db.hospitals);
  $$WardsTableTableManager get wards =>
      $$WardsTableTableManager(_db.attachedDatabase, _db.wards);
  $$PatientHospitalIdentifiersTableTableManager
  get patientHospitalIdentifiers =>
      $$PatientHospitalIdentifiersTableTableManager(
        _db.attachedDatabase,
        _db.patientHospitalIdentifiers,
      );
  $$ClinicalEncountersTableTableManager get clinicalEncounters =>
      $$ClinicalEncountersTableTableManager(
        _db.attachedDatabase,
        _db.clinicalEncounters,
      );
  $$PatientProblemsTableTableManager get patientProblems =>
      $$PatientProblemsTableTableManager(
        _db.attachedDatabase,
        _db.patientProblems,
      );
  $$ProblemProgressSnapshotsTableTableManager get problemProgressSnapshots =>
      $$ProblemProgressSnapshotsTableTableManager(
        _db.attachedDatabase,
        _db.problemProgressSnapshots,
      );
  $$ClinicalInterventionsTableTableManager get clinicalInterventions =>
      $$ClinicalInterventionsTableTableManager(
        _db.attachedDatabase,
        _db.clinicalInterventions,
      );
  $$ClinicalOutcomeMetricsTableTableManager get clinicalOutcomeMetrics =>
      $$ClinicalOutcomeMetricsTableTableManager(
        _db.attachedDatabase,
        _db.clinicalOutcomeMetrics,
      );
  $$PrescriptionOrdersTableTableManager get prescriptionOrders =>
      $$PrescriptionOrdersTableTableManager(
        _db.attachedDatabase,
        _db.prescriptionOrders,
      );
  $$InvestigationOrdersTableTableManager get investigationOrders =>
      $$InvestigationOrdersTableTableManager(
        _db.attachedDatabase,
        _db.investigationOrders,
      );
  $$InvestigationResultsTableTableManager get investigationResults =>
      $$InvestigationResultsTableTableManager(
        _db.attachedDatabase,
        _db.investigationResults,
      );
  $$LearnedCatalogTableTableManager get learnedCatalog =>
      $$LearnedCatalogTableTableManager(
        _db.attachedDatabase,
        _db.learnedCatalog,
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
  $$DocumentRegistriesTableTableManager get documentRegistries =>
      $$DocumentRegistriesTableTableManager(
        _db.attachedDatabase,
        _db.documentRegistries,
      );
  $$ClinicalObservationsTableTableManager get clinicalObservations =>
      $$ClinicalObservationsTableTableManager(
        _db.attachedDatabase,
        _db.clinicalObservations,
      );
}
