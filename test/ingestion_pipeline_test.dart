import 'dart:convert';

import 'package:clinical_companion/core/ai/interactions_api_client.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/ingestion/clinical_ingestion_mapper.dart';
import 'package:clinical_companion/core/ingestion/ingestion_orchestrator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _discharge = '''
DISCHARGE SUMMARY - Ramesh Kumar, 58 yr M. Presented with chest pain x2 days
and breathlessness. BP 150/95, PR 102, T 99.1, SpO2 94% RA. K/c/o HTN, T2DM.
Dx: Acute Coronary Syndrome; Type 2 Diabetes Mellitus.
Rx: Tab Aspirin 75 mg PO OD x 30 days, Inj Enoxaparin 60 mg SC BD.
''';

const _modelJson = '''
```json
{"patient_name":"Ramesh Kumar","age":"58","vitals":{"sbp":150,"dbp":95,"pulse":102,
"temperature_c":"37.3","spo2":94,"respiratory_rate":null},
"chief_complaints":["Chest pain","Breathlessness"],"history":"K/c/o HTN, T2DM",
"diagnosis":["Acute Coronary Syndrome","Type 2 Diabetes Mellitus"],
"medications":[{"name":"Aspirin","dose":"75 mg","route":"PO","frequency":"OD","duration":"30 days"},
{"name":"Enoxaparin","dose":"60 mg","route":"SC","frequency":"BD"},{"dose":"orphan"}]}
```
''';

http.Response _ok(String text) => http.Response(
  jsonEncode({'id': 'int_1', 'output_text': text}),
  200,
  headers: {'content-type': 'application/json'},
);

void main() {
  test('mock 200 request carries no legacy params and forces JSON', () async {
    late Map<String, dynamic> sent;
    final client = InteractionsApiClient(
      apiKey: 'k',
      client: MockClient((req) async {
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return _ok('{}');
      }),
    );
    final result = await client.create(model: 'gemini-3.8-flash', prompt: 'hi');
    expect(result.text, '{}');
    for (final banned in kDeprecatedGenerationParameters) {
      expect(sent.containsKey(banned), isFalse);
      expect((sent['generation_config'] ?? {}) as Map, isNot(contains(banned)));
    }
    expect((sent['response_format'] as Map)['mime_type'], 'application/json');
  });

  test('discharge summary maps into distinct SQLite rows', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final orchestrator = IngestionOrchestrator(
      client: InteractionsApiClient(
        apiKey: 'k',
        client: MockClient((_) async => _ok(_modelJson)),
      ),
      db: db,
      model: 'gemini-3.8-flash',
    );
    final outcome = await orchestrator.ingestText(_discharge);
    expect(outcome.savedAsDraft, isFalse);

    final patients = await db.select(db.patients).get();
    final encounters = await db.select(db.clinicalEncounters).get();
    final problems = await db.select(db.patientProblems).get();
    final rx = await db.select(db.prescriptionOrders).get();
    // ignore: avoid_print
    print(
      '[LOG] patients=${patients.length} encounters=${encounters.length} '
      'problems=${problems.map((p) => p.problemName).toList()} '
      'rx=${rx.map((r) => '${r.drugName} ${r.doseStrength} ${r.route} ${r.frequency}').toList()} '
      'vitals=${encounters.single.sbp}/${encounters.single.dbp} '
      'pr=${encounters.single.pulse} t=${encounters.single.temperatureC}',
    );
    expect(patients.single.fullName, 'Ramesh Kumar');
    expect(patients.single.dateOfBirth, isNotNull);
    expect(encounters.single.sbp, 150);
    expect(encounters.single.temperatureC, 37.3);
    expect(encounters.single.chiefComplaints, 'Chest pain; Breathlessness');
    expect(problems, hasLength(2));
    expect(rx, hasLength(2));
    expect(rx.first.encounterId, encounters.single.id);
  });

  test('null/garbage fields never crash the mapping', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final r = await ClinicalIngestionMapper(db).persistRaw(
      '{"patient_name":null,"age":"unknown","vitals":"n/a",'
      '"diagnosis":"Sepsis","medications":null}',
    );
    expect(r.problemCount, 1);
    expect(r.medicationCount, 0);
  });

  test('failures preserve raw input as a draft', () async {
    for (final handler in <MockClientHandler>[
      (_) async => http.Response('{"error":{"status":"INVALID_ARGUMENT"}}', 400),
      (_) async => _ok('not json at all'),
    ]) {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final outcome = await IngestionOrchestrator(
        client: InteractionsApiClient(apiKey: 'k', client: MockClient(handler)),
        db: db,
        model: 'm',
      ).ingestText(_discharge);
      expect(outcome.savedAsDraft, isTrue);
      expect(outcome.isError, isTrue);
      expect(outcome.userMessage, isNot(kDraftSavedMessage));
      expect(outcome.userMessage, contains('Stack trace'));
      final drafts = await db.select(db.ingestionInboxes).get();
      expect(drafts.single.status, 'draft');
      expect(drafts.single.rawInput, _discharge);
      expect(await db.select(db.patients).get(), isEmpty);
    }
  });

  test('same patient ingested twice merges into one chart', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final mapper = ClinicalIngestionMapper(db);
    final first = await mapper.persistRaw(_modelJson);
    final second = await mapper.persistRaw(
      '{"patient_name":"Mr. RAMESH  kumar","age":58,"gender":"male",'
      '"diagnosis":["Unstable Angina"],"medications":[{"name":"Atorvastatin"}]}',
    );
    // ignore: avoid_print
    print('[LOG] first=$first second=$second');
    expect(await db.select(db.patients).get(), hasLength(1));
    expect(await db.select(db.clinicalEncounters).get(), hasLength(2));
    expect(second.patientId, first.patientId);
    expect(second.matchedExistingPatient, isTrue);
    final problems = await db.select(db.patientProblems).get();
    expect(problems, hasLength(3));
    expect(problems.every((p) => p.patientId == first.patientId), isTrue);
    expect(await db.select(db.prescriptionOrders).get(), hasLength(3));
  });

  test('different age or gender is NOT merged', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final mapper = ClinicalIngestionMapper(db);
    await mapper.persist({
      'patient_name': 'Ramesh Kumar',
      'age': 58,
      'gender': 'Male',
    });
    await mapper.persist({'patient_name': 'Ramesh Kumar', 'age': 25});
    await mapper.persist({
      'patient_name': 'Ramesh Kumar',
      'age': 58,
      'gender': 'Female',
    });
    await mapper.persist({'patient_name': null});
    await mapper.persist({'patient_name': null});
    expect(await db.select(db.patients).get(), hasLength(5));
  });

  test('census prompt is injected and Bed reference resolves to the patient',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final seeded = await ClinicalIngestionMapper(
      db,
    ).persist({'patient_name': 'Sita Devi', 'age': 40});
    final census = jsonEncode([
      {
        'patient_id': seeded.patientId,
        'name': 'Sita Devi',
        'bed': '827',
        'ward': 'Medicine',
      },
    ]);
    late String prompt;
    final orchestrator = IngestionOrchestrator(
      client: InteractionsApiClient(
        apiKey: 'k',
        client: MockClient((req) async {
          prompt = (jsonDecode(req.body) as Map)['input'] as String;
          return _ok(
            jsonEncode({
              'patient_id': seeded.patientId,
              'patient_name': null,
              'bed_number': '827',
              'diagnosis': ['Pneumonia'],
            }),
          );
        }),
      ),
      db: db,
      model: 'm',
    );
    final outcome = await orchestrator.ingestText(
      'Bed 827 - fever, start antibiotics',
      activeCensusJson: census,
    );
    expect(prompt, contains('ACTIVE WARD CENSUS'));
    expect(prompt, contains(seeded.patientId));
    expect(outcome.mapping!.patientId, seeded.patientId);
    expect(await db.select(db.patients).get(), hasLength(1));
    final enc = (await db.select(db.clinicalEncounters).get()).last;
    expect(enc.bedNumber, '827');

    // A hallucinated id that is not in the census is ignored.
    final r = await ClinicalIngestionMapper(db).persist({
      'patient_id': 'not-in-census',
      'patient_name': 'Other Person',
    }, censusIds: censusPatientIds(census));
    expect(r.matchedExistingPatient, isFalse);
  });
}
