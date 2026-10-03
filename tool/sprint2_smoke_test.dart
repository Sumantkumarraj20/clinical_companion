// Smoke test for the ClinicalDrugs master table (POMR-integrated drug graph).
// Run with: flutter test tool/sprint2_smoke_test.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinical_companion/core/database/daos/pharmacopeia_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';

void main() {
  test('clinicalDrugs: search + problem-oriented POMR lookup', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.clinicalDrugs)
        .insert(
          ClinicalDrugsCompanion.insert(
            genericMolecule: 'Amoxicillin + Clavulanic Acid',
            problemIndications: const Value(
              '["Community Acquired Pneumonia","Otitis Media","Animal Bite"]',
            ),
            prioritizedSideEffects:
                const Value('["Drug-Induced Hepatotoxicity","Severe Diarrhea"]'),
            prescribingPearls:
                const Value('Requires renal dose adjustment. Take with food.'),
            availableForms: const Value('Tablet, Syrup, Injection'),
            topBrands: const Value('Augmentin (₹120), Clavam (₹110)'),
            usageFrequency: const Value(12),
          ),
        );

    final dao = PharmacopeiaDao(db);

    final byMolecule = await dao.searchClinicalDrugs('amoxicillin');
    expect(byMolecule, isNotEmpty);
    expect(byMolecule.first.molecule, 'Amoxicillin + Clavulanic Acid');
    expect(
      PharmacopeiaDao.decodeStringList(byMolecule.first.master?.problemIndications),
      contains('Otitis Media'),
    );

    final byProblem = await dao.getDrugsForProblem('Otitis Media');
    expect(byProblem, isNotEmpty);
    expect(byProblem.first.usageFrequency, 12);

    // A problem the drug does not treat must return nothing (exact quoted
    // match, no partial-word collisions).
    final miss = await dao.getDrugsForProblem('Migraine');
    expect(miss, isEmpty);

    await db.close();
  });
}

