import 'dart:convert';
import 'dart:io';

import 'package:clinical_companion/core/database/daos/pharmacopeia_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/sync/catalog_sync_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Synthetic payload mirroring the live Apps Script column names exactly
/// (spaces, `&`, and `'₹5,400.00'`-style money cells included).
Map<String, dynamic> _nightlyPayload() => {
      'clinical_core': [
        {
          'Drug ID': 'DRG-CEF-001',
          'Generic Name': 'Ceftriaxone Sodium',
          'Pharmacological Class': '3rd-Gen Cephalosporin',
          'Mechanism of Action': null,
          'Primary Routes': 'IV, IM',
          'Renal Clearance & Adjustment': 'No adjustment',
          'Hepatic Risk & Monitoring': '',
          'Critical Alerts & Contraindications': 'Hypersensitivity',
          'Pregnancy & Teratogenicity': 'Use with caution',
        },
        // Row without its natural ID must be skipped gracefully.
        {'Generic Name': 'Orphan Molecule'},
      ],
      'indications_dosing_matrix': [
        {
          'Indication ID': 'IND-CEF-001',
          'Clinical Indication': 'Community-Acquired Pneumonia',
          'Patient Cohort': 'Adult',
          'Standard Regimen / Dose': '1-2 g IV q24h',
          'Route & Frequency': 'IV once daily',
          'Typical Duration': '7 days',
          'Max Daily Ceiling': '4 g',
          'Evidence Level': 'A',
          'Clinical Protocol & Monitoring': 'Monitor for C. difficile',
        },
      ],
      'formulations_administration': [
        {
          'Formulation ID': 'FMT-CEF-001',
          'Dosage Form & Strength': '1 g vial',
          'Reconstitution Diluent & Volume': 'Sterile water 10 mL',
          'Administration Route & Infusion Rate': 'IV over 30 min',
          'Storage & Reconstituted Stability': '6 h at room temperature',
          'Critical Compatibility Alerts': 'NA',
        },
      ],
      // Apps Script export variant wrapped in {"rows": [...]}.
      'commercial_brands_trust_layer': {
        'rows': [
          {
            'Brand ID': 'BRD-CEF-001',
            'Brand Trade Name': 'Rocephin 1g',
            'Manufacturer / Marketer': 'Roche',
            'Packaging & Unit Strength': '1 vial',
            'Trust Tier': 'Premium',
            'Approx. MRP (INR)': '1,250.50',
            'Quality Certifications & Clinical Trust Notes': 'WHO-GMP',
          },
          {
            'Brand ID': 'BRD-CEF-006',
            'Brand Trade Name': 'Zinforo 600mg',
            'Manufacturer / Marketer': 'Pfizer',
            // Real cells ship a rupee symbol + group separator.
            'Approx. MRP (INR)': '₹5,400.00',
          },
        ],
      },
    };

void main() {
  late AppDatabase db;
  late PharmacopeiaDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = PharmacopeiaDao(db);
  });

  tearDown(() async => db.close());

  test('upsertOtaCatalog maps live sheet columns into all four tables',
      () async {
    await dao.upsertOtaCatalog(_nightlyPayload());

    final ingredients = await dao.select(dao.activeIngredients).get();
    expect(ingredients, hasLength(1)); // ID-less row skipped
    final ceftriaxone = ingredients.single;
    expect(ceftriaxone.genericName, 'Ceftriaxone Sodium');
    expect(ceftriaxone.pharmacologicalClass, '3rd-Gen Cephalosporin');
    expect(ceftriaxone.renalAdjustment, 'No adjustment');
    expect(ceftriaxone.hepaticRisk, isNull); // '' cell -> null
    expect(ceftriaxone.mechanismOfAction, isNull); // null cell -> null
    expect(ceftriaxone.criticalAlerts, 'Hypersensitivity');
    expect(ceftriaxone.moleculeCode, 'CEF'); // derived from DRG-CEF-001

    final indications = await dao.select(dao.indications).get();
    expect(indications, hasLength(1));
    expect(indications.single.clinicalIndication,
        'Community-Acquired Pneumonia');
    expect(indications.single.standardRegimen, '1-2 g IV q24h');
    expect(indications.single.moleculeCode, 'CEF');

    final formulations = await dao.select(dao.formulations).get();
    expect(formulations, hasLength(1));
    expect(formulations.single.dosageFormStrength, '1 g vial');
    expect(formulations.single.compatibilityAlerts, isNull); // 'NA' -> null

    final brands = await dao.select(dao.brands).get();
    expect(brands, hasLength(2));
    expect(brands.firstWhere((b) => b.brandId == 'BRD-CEF-001').mrp, 1250.50);
    // Rupee-symbol string: '₹5,400.00' parses to 5400.0.
    expect(
        brands.firstWhere((b) => b.brandId == 'BRD-CEF-006').mrp, 5400.0);
    expect(brands.first.brandName, 'Rocephin 1g');
  });
  test('upsertOtaCatalog replaces catalog rows but keeps absent tabs',
      () async {
    await dao.upsertOtaCatalog(_nightlyPayload());
    await dao.upsertOtaCatalog({
      'clinical_core': [
        {'Drug ID': 'DRG-CEF-001', 'Generic Name': 'Ceftriaxone (updated)'},
        {'Drug ID': 'DRG-MAC-001', 'Generic Name': 'Azithromycin'},
      ],
      // Omitted tabs must not delete anything.
    });

    final ingredients = await dao.select(dao.activeIngredients).get();
    expect(ingredients, hasLength(2));
    final ceftriaxone =
        ingredients.firstWhere((i) => i.ingredientId == 'DRG-CEF-001');
    expect(ceftriaxone.genericName, 'Ceftriaxone (updated)');
    // insertOrReplace wiped the optional column from the fresh payload.
    expect(ceftriaxone.criticalAlerts, isNull);
    expect(ceftriaxone.moleculeCode, 'CEF');

    // Indications / formulations / brands from the previous night survive
    // because their tabs were absent from the payload.
    expect(await dao.select(dao.indications).get(), hasLength(1));
    expect(await dao.select(dao.formulations).get(), hasLength(1));
    expect(await dao.select(dao.brands).get(), hasLength(2));
  });

  test('upsertOtaCatalog never touches patient-owned data', () async {
    await db.into(db.patients).insert(
          PatientsCompanion.insert(
            ownerId: 'local-practitioner',
            fullName: 'Test Patient',
          ),
        );
    await db.into(db.drugs).insert(
          DrugsCompanion.insert(
            ownerId: 'local-practitioner',
            genericName: 'Paracetamol',
            brandName: const Value('My Trusted Brand'),
            isTrusted: const Value(true),
          ),
        );

    await dao.upsertOtaCatalog(_nightlyPayload());

    expect(await dao.select(db.patients).get(), hasLength(1));
    final drug = (await dao.select(db.drugs).get()).single;
    expect(drug.isTrusted, isTrue); // trust flag preserved
    expect(drug.brandName, 'My Trusted Brand');
  });
  test('CatalogSyncService fetches Apps Script JSON and merges it', () async {
    final requests = <Uri>[];
    final client = MockClient((request) async {
      requests.add(request.url);
      return http.Response(jsonEncode(_nightlyPayload()), 200,
          headers: {'content-type': 'application/json'});
    });
    final service = CatalogSyncService(
      pharmacopeiaDao: dao,
      httpClient: client,
    );

    await service.syncCatalogFromCloud(
      'https://script.google.com/macros/s/TEST_DEPLOYMENT/exec',
    );

    expect(requests, hasLength(1));
    expect(service.lastSyncAt, isNotNull);
    expect(await dao.select(dao.activeIngredients).get(), hasLength(1));
    expect(await dao.select(dao.indications).get(), hasLength(1));
    expect(await dao.select(dao.brands).get(), hasLength(2));
  });

  test('CatalogSyncService surfaces transport and schema failures', () async {
    final failing = CatalogSyncService(
      pharmacopeiaDao: dao,
      httpClient: MockClient((_) async => http.Response('boom', 500)),
    );
    expect(
      failing.syncCatalogFromCloud('https://script.google.com/macros/x/exec'),
      throwsA(isA<Exception>()),
    );

    final notConfigured = CatalogSyncService(pharmacopeiaDao: dao);
    expect(
      notConfigured.syncCatalogFromCloud(
        CatalogSyncService.urlPlaceholder,
      ),
      throwsStateError,
    );
  });
  test('merges the production Apps Script snapshot end-to-end', () async {
    final file = File('test/fixtures/ota_payload.json');
    final payload =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    await dao.upsertOtaCatalog(payload);

    // Exact row counts of the captured production export (4 sheet tabs).
    expect(await dao.select(dao.activeIngredients).get(), hasLength(76));
    expect(await dao.select(dao.indications).get(), hasLength(77));
    expect(await dao.select(dao.formulations).get(), hasLength(76));
    expect(await dao.select(dao.brands).get(), hasLength(76));

    // Every sheet ID yields the shared molecule join key (10 molecules).
    final ingredients = await dao.select(dao.activeIngredients).get();
    expect(ingredients.every((row) => row.moleculeCode != null), isTrue);
    final codes =
        ingredients.map((row) => row.moleculeCode).toSet();
    expect(codes, hasLength(10));

    final ceftriaxone =
        ingredients.firstWhere((row) => row.ingredientId == 'DRG-CEF-001');
    expect(ceftriaxone.genericName, 'Ceftriaxone Sodium');
    expect(ceftriaxone.moleculeCode, 'CEF');
    expect(ceftriaxone.renalAdjustment, isNotNull);

    // Every child-table row joins back to a known molecule code.
    final indications = await dao.select(dao.indications).get();
    final formulations = await dao.select(dao.formulations).get();
    expect(indications.every((row) => codes.contains(row.moleculeCode)),
        isTrue);
    expect(formulations.every((row) => codes.contains(row.moleculeCode)),
        isTrue);

    // Mixed-type MRP column: all 76 cells (number or '₹5,400.00' text)
    // parse to non-null doubles, including the rupee-symbol strings.
    final brands = await dao.select(dao.brands).get();
    expect(brands.every((row) => row.mrp != null && row.mrp! > 0), isTrue);
    expect(
      brands.firstWhere((row) => row.brandId == 'BRD-CEF-006').mrp,
      5400.0,
    );

    // Molecule-keyed lookups power the Cloud Catalog detail sheet
    // (snapshot counts: CEF → 7 indications, 6 formulations, 6 brands).
    expect(await dao.indicationsForMolecule('CEF'), hasLength(7));
    expect(await dao.formulationsForMolecule('CEF'), hasLength(6));
    expect(await dao.brandsForMolecule('CEF'), hasLength(6));

    // Re-running the same snapshot is idempotent (insertOrReplace by ID).
    await dao.upsertOtaCatalog(payload);
    expect(await dao.select(dao.activeIngredients).get(), hasLength(76));
    expect(await dao.select(dao.brands).get(), hasLength(76));
  });
}