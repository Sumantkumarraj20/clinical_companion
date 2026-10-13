import 'dart:convert';

import 'package:clinical_companion/core/ai/interactions_api_client.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/ingestion/clinical_ingestion_mapper.dart';
import 'package:clinical_companion/core/ingestion/ingestion_orchestrator.dart';
import 'package:clinical_companion/core/ingestion/live_ingestion_controller.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/features/ingestion/screens/text_ingestion_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
{"patient_name":"Ramesh Kumar","age":58,"vitals":{"sbp":150,"dbp":95,"pulse":102,"spo2":94},
"chief_complaints":["Chest pain","Breathlessness"],"history":"K/c/o HTN, T2DM",
"diagnosis":["Acute Coronary Syndrome","Type 2 Diabetes Mellitus"],
"medications":[{"name":"Aspirin","dose":"75 mg","route":"PO","frequency":"OD"},
{"name":"Enoxaparin","dose":"60 mg","route":"SC","frequency":"BD"}]}
```
''';

Future<AppDatabase> _pump(
  WidgetTester tester,
  MockClientHandler handler,
  List<String> requests,
) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const TextIngestionScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const Scaffold(body: Text('DASHBOARD')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        ingestionOrchestratorProvider.overrideWithValue(
          IngestionOrchestrator(
            client: InteractionsApiClient(
              apiKey: 'k',
              client: MockClient((req) {
                requests.add(req.body);
                return handler(req);
              }),
            ),
            db: db,
            model: 'gemini-3.8-flash',
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

Future<void> _submit(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), _discharge);
  await tester.pump();
  await tester.tap(find.text('Prepare for review'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pasted discharge summary flows UI -> orchestrator -> Drift', (
    tester,
  ) async {
    final requests = <String>[];
    final db = await _pump(
      tester,
      (_) async => http.Response(
        jsonEncode({'id': 'int_1', 'output_text': _modelJson}),
        200,
        headers: {'content-type': 'application/json'},
      ),
      requests,
    );
    await tester.runAsync(() async {
      await _submit(tester);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(requests, hasLength(1));
    final sent = jsonDecode(requests.single) as Map<String, dynamic>;
    for (final banned in kDeprecatedGenerationParameters) {
      expect(sent.containsKey(banned), isFalse);
    }
    expect((sent['response_format'] as Map)['mime_type'], 'application/json');

    final patients = await tester.runAsync(() => db.select(db.patients).get());
    final problems = await tester.runAsync(
      () => db.select(db.patientProblems).get(),
    );
    final rx = await tester.runAsync(
      () => db.select(db.prescriptionOrders).get(),
    );
    expect(patients!.single.fullName, 'Ramesh Kumar');
    expect(problems, hasLength(2));
    expect(rx, hasLength(2));
    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text(kIngestionSuccessMessage), findsOneWidget);
    expect(find.textContaining('400'), findsNothing);
    expect(find.textContaining('INVALID_ARGUMENT'), findsNothing);
  });

  testWidgets('API failure saves a draft and shows the friendly toast', (
    tester,
  ) async {
    final db = await _pump(
      tester,
      (_) async => http.Response(
        '{"error":{"status":"INVALID_ARGUMENT","message":"bad"}}',
        400,
      ),
      <String>[],
    );
    await tester.runAsync(() async {
      await _submit(tester);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    final drafts = await tester.runAsync(
      () => db.select(db.ingestionInboxes).get(),
    );
    expect(drafts!.single.status, 'draft');
    expect(drafts.single.rawInput, _discharge);
    expect(find.text(kDraftSavedMessage), findsOneWidget);
    expect(find.textContaining('INVALID_ARGUMENT'), findsNothing);
  });
}
