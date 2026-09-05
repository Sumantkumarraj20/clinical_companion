import 'dart:io';

import 'local_database.dart';

class DatabaseSideloadService {
  Future<void> mergePmjayCatalog({
    required File pmjayDatabase,
    required AppDatabase database,
  }) async {
    final sourcePath = pmjayDatabase.path.replaceAll("'", "''");
    await database.customStatement("ATTACH DATABASE '$sourcePath' AS pmjay_source");
    try {
      await database.customStatement('''
        CREATE TABLE IF NOT EXISTS hbp_procedures (
          procedure_code TEXT PRIMARY KEY NOT NULL,
          package_name TEXT NOT NULL,
          procedure_name TEXT NOT NULL,
          rate REAL,
          specialty TEXT NOT NULL DEFAULT ''
        )
      ''');
      await database.customStatement('''
        CREATE TABLE IF NOT EXISTS hbp_implants (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          procedure_code TEXT NOT NULL,
          implant_code TEXT NOT NULL,
          implant_name TEXT NOT NULL,
          maximum_price REAL
        )
      ''');
      await database.customStatement('''
        CREATE TABLE IF NOT EXISTS hbp_stratifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          procedure_code TEXT NOT NULL,
          stratification_code TEXT NOT NULL,
          stratification_name TEXT NOT NULL,
          rule TEXT NOT NULL DEFAULT ''
        )
      ''');
      await database.customStatement('''
        INSERT OR REPLACE INTO hbp_procedures
          (procedure_code, package_name, procedure_name, rate, specialty)
        SELECT procedure_code, package_name, procedure_name, rate, specialty
        FROM pmjay_source.hbp_procedures
      ''');
      await database.customStatement('''
        INSERT INTO hbp_implants
          (procedure_code, implant_code, implant_name, maximum_price)
        SELECT procedure_code, implant_code, implant_name, maximum_price
        FROM pmjay_source.hbp_implants
      ''');
      await database.customStatement('''
        INSERT INTO hbp_stratifications
          (procedure_code, stratification_code, stratification_name, rule)
        SELECT procedure_code, stratification_code, stratification_name, rule
        FROM pmjay_source.hbp_stratifications
      ''');
      await database.customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS hbp_fts USING fts5(
          package_name, procedure_name, specialty,
          content='hbp_procedures', content_rowid='rowid'
        )
      ''');
      await database.customStatement('DELETE FROM hbp_fts');
      await database.customStatement('''
        INSERT INTO hbp_fts(rowid, package_name, procedure_name, specialty)
        SELECT rowid, package_name, procedure_name, specialty FROM hbp_procedures
      ''');
    } finally {
      await database.customStatement('DETACH DATABASE pmjay_source');
    }
  }

}