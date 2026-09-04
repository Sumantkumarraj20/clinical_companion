// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmacopeia_dao.dart';

// ignore_for_file: type=lint
mixin _$PharmacopeiaDaoMixin on DatabaseAccessor<AppDatabase> {
  $DrugsTable get drugs => attachedDatabase.drugs;
  PharmacopeiaDaoManager get managers => PharmacopeiaDaoManager(this);
}

class PharmacopeiaDaoManager {
  final _$PharmacopeiaDaoMixin _db;
  PharmacopeiaDaoManager(this._db);
  $$DrugsTableTableManager get drugs =>
      $$DrugsTableTableManager(_db.attachedDatabase, _db.drugs);
}
