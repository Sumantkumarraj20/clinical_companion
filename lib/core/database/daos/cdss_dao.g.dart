// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cdss_dao.dart';

// ignore_for_file: type=lint
mixin _$CdssDaoMixin on DatabaseAccessor<AppDatabase> {
  $CdssRulesTable get cdssRules => attachedDatabase.cdssRules;
  CdssDaoManager get managers => CdssDaoManager(this);
}

class CdssDaoManager {
  final _$CdssDaoMixin _db;
  CdssDaoManager(this._db);
  $$CdssRulesTableTableManager get cdssRules =>
      $$CdssRulesTableTableManager(_db.attachedDatabase, _db.cdssRules);
}
