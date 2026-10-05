import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:clinical_companion/core/database/daos/pharmacopeia_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/clinical_drug_selection.dart';
import 'package:clinical_companion/features/bedside/providers/staged_orders_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _syncedAt = DateTime.utc(2026, 1, 1);

/// Offline master row exactly as the bundled asset stores it: forms, routes
/// and brands are JSON, not CSV.
ClinicalDrug _master({
  String molecule = 'Modace',
  String? forms = '["tablet","capsule"]',
  String? routes = '["Oral","Intravenous"]',
  String? brands = '[{"brand":"Modace 500mg","count":6}]',
  String? pearls = 'Take after food.',
}) {
  return ClinicalDrug(
    id: 'drug_$molecule',
    genericMolecule: molecule,
    problemIndications: '[]',
    prioritizedSideEffects: '[]',
    commonIndications: '[]',
    doseAdjustments: '{}',
    commonSideEffects: '[]',
    prescribingPearls: pearls,
    availableForms: forms,
    routes: routes,
    topBrands: brands,
    usageFrequency: 6,
  );
}

Indication _indication({
  String? regimen = '500 mg PO twice daily',
  String? protocol = 'Renal dose adjustment if eGFR < 30',
  String? routeFrequency = 'Oral',
  String? duration = '5 days',
}) {
  return Indication(
    indicationId: 'IND-CEF-001',
    moleculeCode: 'CEF',
    clinicalIndication: 'Otitis Media',
    patientCohort: 'Adult',
    standardRegimen: regimen,
    routeFrequency: routeFrequency,
    typicalDuration: duration,
    maxDailyCeiling: '2 g/day',
    evidenceLevel: 'A',
    clinicalProtocol: protocol,
    syncedAt: _syncedAt,
  );
}

Formulation _formulation({
  String? strength = 'Tablet 500mg',
  String? route = 'Oral',
}) {
  return Formulation(
    formulationId: 'FMT-CEF-001',
    moleculeCode: 'CEF',
    dosageFormStrength: strength,
    reconstitution: null,
    administrationRoute: route,
    storageStability: null,
    compatibilityAlerts: null,
    syncedAt: _syncedAt,
  );
}

ActiveIngredient _ingredient({String genericName = 'Cefixime'}) {
  return ActiveIngredient(
    ingredientId: 'DRG-CEF-001',
    moleculeCode: 'CEF',
    genericName: genericName,
    pharmacologicalClass: 'Cephalosporin',
    mechanismOfAction: null,
    primaryRoutes: 'Oral',
    renalAdjustment: null,
    hepaticRisk: null,
    criticalAlerts: null,
    pregnancyCategory: null,
    syncedAt: _syncedAt,
  );
}

Brand _brand({String name = 'Suprax 100mg'}) {
  return Brand(
    brandId: 'BRD-CEF-001',
    moleculeCode: 'CEF',
    brandName: name,
    manufacturer: 'Cipla',
    packagingUnitStrength: '100 mg',
    trustTier: 'Tier 1',
    mrp: 120,
    trustNotes: null,
    syncedAt: _syncedAt,
  );
}

ProviderContainer _ordersContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ClinicalDrugSelection', () {
    test('decodes the JSON columns the offline master actually stores', () {
      final selection = ClinicalDrugSelection(
        molecule: 'Modace',
        master: _master(),
      );

      expect(selection.availableForms, ['tablet', 'capsule']);
      expect(selection.availableRoutes, ['Oral', 'Intravenous']);
      expect(selection.brandNames, ['Modace 500mg']);
      expect(selection.route, 'Oral', reason: 'first recorded route');
      expect(selection.administrationGuidelines, 'Take after food.');
      expect(selection.hasClinicalDetail, isFalse);
    });

    test('still understands the legacy comma-separated columns', () {
      final selection = ClinicalDrugSelection(
        molecule: 'Modace',
        master: _master(forms: 'Tablet, Syrup', brands: 'Augmentin, Clavam'),
      );

      expect(selection.availableForms, ['Tablet', 'Syrup']);
      expect(selection.brandNames, ['Augmentin', 'Clavam']);
    });

    test('the OTA dosing matrix outranks the offline master', () {
      final selection = ClinicalDrugSelection(
        molecule: 'Cefixime',
        master: _master(molecule: 'Cefixime'),
        ingredient: _ingredient(),
        indication: _indication(),
        formulation: _formulation(),
        brands: [_brand()],
      );

      expect(selection.hasClinicalDetail, isTrue);
      expect(selection.standardDosage, '500 mg PO twice daily');
      expect(
        selection.administrationGuidelines,
        'Renal dose adjustment if eGFR < 30',
      );
      expect(selection.route, 'Oral');
      expect(selection.duration, '5 days');
      expect(selection.brandNames, ['Suprax 100mg']);
      expect(selection.displayLabel, 'Cefixime · Tablet 500mg');
    });

    test('never invents data the catalog does not hold', () {
      final selection = ClinicalDrugSelection(
        molecule: 'Unknown',
        master: _master(
          molecule: 'Unknown',
          forms: null,
          routes: null,
          brands: null,
          pearls: null,
        ),
      );

      expect(selection.standardDosage, isNull);
      expect(selection.administrationGuidelines, isNull);
      expect(selection.route, isNull);
      expect(selection.subtitle, isEmpty);
    });

    test(
      'searchClinicalDrugs returns offline hits before any catalog sync',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final dao = PharmacopeiaDao(db);
        await db.into(db.clinicalDrugs).insert(_master(molecule: 'Modace'));

        final results = await dao.searchClinicalDrugs('mod');

        expect(results, hasLength(1));
        expect(results.single.molecule, 'Modace');
        expect(results.single.route, 'Oral');
        expect(results.single.master, isNotNull);
      },
    );

    test(
      'searchClinicalDrugs merges the OTA matrix onto an offline hit',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final dao = PharmacopeiaDao(db);
        await db.into(db.clinicalDrugs).insert(_master(molecule: 'Cefixime'));
        await db.into(db.activeIngredients).insert(_ingredient());
        await db.into(db.indications).insert(_indication());
        await db.into(db.formulations).insert(_formulation());
        await db.into(db.brands).insert(_brand());

        final results = await dao.searchClinicalDrugs('cefix');

        expect(
          results,
          hasLength(1),
          reason: 'the two rows must merge, not dup',
        );
        final selection = results.single;
        expect(selection.molecule, 'Cefixime');
        expect(selection.master, isNotNull, reason: 'offline half is present');
        expect(selection.indication, isNotNull, reason: 'OTA half is present');
        expect(selection.standardDosage, '500 mg PO twice daily');
        expect(selection.brands.single.brandName, 'Suprax 100mg');
      },
    );

    test('searchClinicalDrugs surfaces OTA-only molecules', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final dao = PharmacopeiaDao(db);
      await db.into(db.activeIngredients).insert(_ingredient());
      await db.into(db.indications).insert(_indication());

      final results = await dao.searchClinicalDrugs('cef');

      expect(results, hasLength(1));
      expect(results.single.master, isNull);
      expect(results.single.hasClinicalDetail, isTrue);
    });

    test('a search that matches nothing returns an empty list', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      expect(await PharmacopeiaDao(db).searchClinicalDrugs('zzz'), isEmpty);
      expect(await PharmacopeiaDao(db).searchClinicalDrugs('  '), isEmpty);
    });
  });

  group('StagedOrdersNotifier', () {
    test('addMedication maps dose, route and guidelines from the catalog', () {
      final container = _ordersContainer();
      final notifier = container.read(stagedOrdersProvider.notifier);

      notifier.addMedication(
        ClinicalDrugSelection(
          molecule: 'Cefixime',
          ingredient: _ingredient(),
          indication: _indication(),
          formulation: _formulation(),
          brands: [_brand()],
        ),
        frequency: 'BD',
      );

      final order = container.read(stagedOrdersProvider).single;
      expect(order.isMedication, isTrue);
      expect(order.label, 'Cefixime');
      expect(
        order.dose,
        '500 mg PO twice daily',
        reason: 'standardDosage -> dose',
      );
      expect(order.route, 'Oral', reason: 'route -> route');
      expect(
        order.specialInstructions,
        'Renal dose adjustment if eGFR < 30',
        reason: 'administrationGuidelines -> special instructions',
      );
      expect(order.duration, '5 days');
      expect(order.frequency, 'BD');
      expect(order.brandName, 'Suprax 100mg');
      expect(order.source, 'catalog');
    });

    test('a double tap is absorbed but a different dose is allowed', () {
      final container = _ordersContainer();
      final notifier = container.read(stagedOrdersProvider.notifier);
      final selection = ClinicalDrugSelection(
        molecule: 'Cefixime',
        master: _master(molecule: 'Cefixime'),
      );

      notifier.addMedication(selection);
      notifier.addMedication(selection);
      expect(
        container.read(stagedOrdersProvider),
        hasLength(1),
        reason: 'double tap must not duplicate the order',
      );

      notifier.updateAt(0, (o) => o.dose = '200 mg OD');
      notifier.addMedication(selection);
      expect(
        container.read(stagedOrdersProvider),
        hasLength(2),
        reason: 'a genuinely different regimen is a separate order',
      );
    });

    test('the clinician can edit the suggested dose before saving', () {
      final container = _ordersContainer();
      final notifier = container.read(stagedOrdersProvider.notifier);
      notifier.addMedication(
        ClinicalDrugSelection(
          molecule: 'Cefixime',
          master: _master(molecule: 'Cefixime', routes: '["Oral"]'),
        ),
      );

      notifier.updateAt(0, (o) {
        o.dose = '250 mg OD for 3 days';
        o.route = 'IV';
        o.specialInstructions = 'Renal adjustment applied';
      });

      final order = container.read(stagedOrdersProvider).single;
      expect(order.dose, '250 mg OD for 3 days');
      expect(order.route, 'IV');
      expect(order.specialInstructions, 'Renal adjustment applied');
    });

    test('staged orders become prescription and investigation companions', () {
      final container = _ordersContainer();
      final notifier = container.read(stagedOrdersProvider.notifier);
      notifier.addMedication(
        ClinicalDrugSelection(
          molecule: 'Cefixime',
          ingredient: _ingredient(),
          indication: _indication(),
          formulation: _formulation(),
          brands: [_brand()],
        ),
        frequency: 'BD',
      );
      notifier.addManual('Serum creatinine', source: 'cdss');

      expect(container.read(stagedOrdersProvider), hasLength(2));
      expect(notifier.medicationCount, 1);
      expect(notifier.investigationCount, 1);

      final prescriptions = notifier.toPrescriptionCompanions(patientId: 'p1');
      expect(prescriptions, hasLength(1));
      expect(prescriptions.single.drugName.value, 'Cefixime (Suprax 100mg)');
      expect(prescriptions.single.doseStrength.value, '500 mg PO twice daily');
      expect(prescriptions.single.route.value, 'Oral');
      expect(prescriptions.single.frequency.value, 'BD');
      expect(
        prescriptions.single.specialInstructions.value,
        'Renal dose adjustment if eGFR < 30',
      );
      expect(prescriptions.single.patientId.value, 'p1');

      final investigations = notifier.toInvestigationCompanions(
        patientId: 'p1',
      );
      expect(investigations, hasLength(1));
      expect(investigations.single.testName.value, 'Serum creatinine');
      expect(investigations.single.patientId.value, 'p1');
    });

    test('blank catalog suggestions become null, not empty strings', () {
      final container = _ordersContainer();
      final notifier = container.read(stagedOrdersProvider.notifier);
      notifier.addMedication(
        ClinicalDrugSelection(
          molecule: 'Modace',
          master: _master(forms: null, brands: null, pearls: null),
        ),
      );

      final prescription = notifier
          .toPrescriptionCompanions(patientId: 'p1')
          .single;
      expect(prescription.doseStrength.value, isNull);
      expect(prescription.specialInstructions.value, isNull);
    });
  });

  group('savePOMREncounter', () {
    test(
      'writes the encounter, prescriptions and investigations together',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final dao = ClinicalDao(db, defaultOwnerId: 'tester');

        const patientId = 'patient-1';
        await db
            .into(db.patients)
            .insert(
              PatientsCompanion.insert(
                id: const Value(patientId),
                ownerId: 'tester',
                fullName: 'Asha Rao',
              ),
            );

        final container = _ordersContainer();
        final notifier = container.read(stagedOrdersProvider.notifier);
        notifier.addMedication(
          ClinicalDrugSelection(
            molecule: 'Cefixime',
            indication: _indication(),
            formulation: _formulation(),
          ),
          frequency: 'BD',
        );
        notifier.addManual('CBC', source: 'cdss');

        await dao.savePOMREncounter(
          encounter: ClinicalEncountersCompanion.insert(
            ownerId: 'tester',
            patientId: patientId,
            encounterType: const Value('OPD Consult'),
          ),
          prescriptions: notifier.toPrescriptionCompanions(
            patientId: patientId,
          ),
          investigations: notifier.toInvestigationCompanions(
            patientId: patientId,
          ),
        );

        final encounter = await db.select(db.clinicalEncounters).getSingle();
        final prescriptions = await db.select(db.prescriptionOrders).get();
        final investigations = await db.select(db.investigationOrders).get();

        expect(prescriptions, hasLength(1));
        expect(investigations, hasLength(1));
        expect(
          prescriptions.single.encounterId,
          encounter.id,
          reason: 'orders must be stamped with the real encounter id',
        );
        expect(investigations.single.encounterId, encounter.id);
        expect(prescriptions.single.doseStrength, '500 mg PO twice daily');
        expect(prescriptions.single.route, 'Oral');
      },
    );

    test('a failing child order rolls the whole encounter back', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final dao = ClinicalDao(db, defaultOwnerId: 'tester');

      const patientId = 'patient-1';
      await db
          .into(db.patients)
          .insert(
            PatientsCompanion.insert(
              id: const Value(patientId),
              ownerId: 'tester',
              fullName: 'Asha Rao',
            ),
          );

      await expectLater(
        dao.savePOMREncounter(
          encounter: ClinicalEncountersCompanion.insert(
            ownerId: 'tester',
            patientId: patientId,
          ),
          // Unknown patient violates the foreign key on prescription_orders.
          prescriptions: [
            PrescriptionOrdersCompanion.insert(
              patientId: 'does-not-exist',
              encounterId: '',
              drugName: 'Cefixime',
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );

      expect(
        await db.select(db.clinicalEncounters).get(),
        isEmpty,
        reason: 'no orphan encounter may survive a failed child write',
      );
      expect(await db.select(db.prescriptionOrders).get(), isEmpty);
    });
  });
}
