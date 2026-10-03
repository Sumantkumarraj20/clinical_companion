import 'dart:io';

import 'package:clinical_companion/core/database/daos/pharmacopeia_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Simulates a *real* fresh install: the shipped asset is copied into the app
/// directory and opened. The asset is not an app-schema database (it carries
/// the four Google-Sheets source tabs at `user_version = 1`), which is exactly
/// the state that produced "no such table: drug_master" in the field.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const required = [
    'drug_master',
    'clinical_drugs',
    'active_ingredients',
    'indications',
    'formulations',
    'brands',
  ];

  test('shipped asset cannot itself supply the app catalog tables', () async {
    final asset = File('assets/clinical_drugs.sqlite');
    expect(asset.existsSync(), isTrue, reason: 'asset must exist to seed from');

    // Read the asset raw (no beforeOpen self-heal) to document its real shape.
    final raw = sqlite3.open(asset.path);
    addTearDown(raw.close);

    final userVersion =
        raw.select('PRAGMA user_version').first.values.first as int;
    final names = raw
        .select("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r.values.first as String)
        .toSet();

    // Documents *why* the self-heal is required.
    expect(userVersion, lessThan(23));
    expect(names.contains('drug_master'), isFalse);
    expect(names.contains('active_ingredients'), isFalse);
  });

  test(
    'opening an asset-shaped database heals the missing catalog tables',
    () async {
      final tmp = await Directory.systemTemp.createTemp('catalog_heal');
      addTearDown(() => tmp.delete(recursive: true));
      final seed = File(
        'assets/clinical_drugs.sqlite',
      ).copySync('${tmp.path}/seed.sqlite');

      // Before the fix this file had no drug_master and the DAO threw.
      final db = AppDatabase(NativeDatabase(File(seed.path)));
      addTearDown(db.close);
      await db.customSelect('SELECT 1').get(); // triggers beforeOpen

      for (final table in required) {
        final found = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
              variables: [Variable<String>(table)],
            )
            .get();
        expect(found, isNotEmpty, reason: '$table must exist after open');
      }

      // The original crash, now proven fixed against the real DAO.
      final dao = PharmacopeiaDao(db);
      expect(await dao.searchClinicalDrugs('amox'), isA<List>());
      expect(await dao.indicationsForMolecule('TEST'), isA<List>());
    },
  );

  test('catalog healing is idempotent across repeated opens', () async {
    final tmp = await Directory.systemTemp.createTemp('catalog_idem');
    addTearDown(() => tmp.delete(recursive: true));
    final seed = File(
      'assets/clinical_drugs.sqlite',
    ).copySync('${tmp.path}/seed.sqlite');

    for (var pass = 0; pass < 3; pass++) {
      final db = AppDatabase(NativeDatabase(File(seed.path)));
      await db.customSelect('SELECT 1').get();
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name='drug_master'",
          )
          .get();
      expect(rows.length, 1, reason: 'pass $pass must not duplicate the table');
      await db.close();
    }
  });
}
