// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_rule_dao.dart';

// ignore_for_file: type=lint
mixin _$ClinicalRuleDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClinicalRulesTable get clinicalRules => attachedDatabase.clinicalRules;
  ClinicalRuleDaoManager get managers => ClinicalRuleDaoManager(this);
}

class ClinicalRuleDaoManager {
  final _$ClinicalRuleDaoMixin _db;
  ClinicalRuleDaoManager(this._db);
  $$ClinicalRulesTableTableManager get clinicalRules =>
      $$ClinicalRulesTableTableManager(_db.attachedDatabase, _db.clinicalRules);
}
