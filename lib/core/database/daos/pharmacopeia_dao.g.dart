// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmacopeia_dao.dart';

// ignore_for_file: type=lint
mixin _$PharmacopeiaDaoMixin on DatabaseAccessor<AppDatabase> {
  $DrugsTable get drugs => attachedDatabase.drugs;
  $ClinicalDrugsTable get clinicalDrugs => attachedDatabase.clinicalDrugs;
  $IndicationsTable get indications => attachedDatabase.indications;
  $ActiveIngredientsTable get activeIngredients =>
      attachedDatabase.activeIngredients;
  $FormulationsTable get formulations => attachedDatabase.formulations;
  $BrandsTable get brands => attachedDatabase.brands;
  PharmacopeiaDaoManager get managers => PharmacopeiaDaoManager(this);
}

class PharmacopeiaDaoManager {
  final _$PharmacopeiaDaoMixin _db;
  PharmacopeiaDaoManager(this._db);
  $$DrugsTableTableManager get drugs =>
      $$DrugsTableTableManager(_db.attachedDatabase, _db.drugs);
  $$ClinicalDrugsTableTableManager get clinicalDrugs =>
      $$ClinicalDrugsTableTableManager(_db.attachedDatabase, _db.clinicalDrugs);
  $$IndicationsTableTableManager get indications =>
      $$IndicationsTableTableManager(_db.attachedDatabase, _db.indications);
  $$ActiveIngredientsTableTableManager get activeIngredients =>
      $$ActiveIngredientsTableTableManager(
        _db.attachedDatabase,
        _db.activeIngredients,
      );
  $$FormulationsTableTableManager get formulations =>
      $$FormulationsTableTableManager(_db.attachedDatabase, _db.formulations);
  $$BrandsTableTableManager get brands =>
      $$BrandsTableTableManager(_db.attachedDatabase, _db.brands);
}
