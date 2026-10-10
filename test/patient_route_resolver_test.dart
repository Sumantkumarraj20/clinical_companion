import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/core/router/app_router.dart';
import 'package:clinical_companion/features/patients/screens/patient_registry_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('patient timeline route restores a patient from the local id', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final patient = await ClinicalDao(database).insertPatient(
      PatientsCompanion.insert(ownerId: 'owner-1', fullName: 'Ada Lovelace'),
    );
    final router = GoRouter(
      initialLocation: '/patients/${patient.id}',
      routes: [
        GoRoute(
          path: '/patients/:id',
          builder: (context, state) => PatientRouteResolver(
            patientId: state.pathParameters['id']!,
            title: 'Patient record',
            builder: (patient) => Scaffold(body: Text(patient.fullName)),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ada Lovelace'), findsOneWidget);
  });

  testWidgets('unknown patient id shows a safe recovery path', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final router = GoRouter(
      initialLocation: '/patients/missing',
      routes: [
        GoRoute(
          path: '/patients/:id',
          builder: (context, state) => PatientRouteResolver(
            patientId: state.pathParameters['id']!,
            title: 'Patient record',
            builder: (patient) => Scaffold(body: Text(patient.fullName)),
          ),
        ),
        GoRoute(
          path: '/patients',
          builder: (context, state) => const Scaffold(body: Text('Registry')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This patient record could not be found.'),
      findsOneWidget,
    );
    expect(find.text('Return to patients'), findsOneWidget);
  });

  testWidgets('patient registry finds records by formatted phone digits', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await ClinicalDao(database).insertPatient(
      PatientsCompanion.insert(
        ownerId: 'owner-1',
        fullName: 'Grace Hopper',
        phone: const Value('+1 (415) 555-0134'),
      ),
    );
    final router = GoRouter(
      initialLocation: '/patients',
      routes: [
        GoRoute(
          path: '/patients',
          builder: (context, state) => const PatientRegistryScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '4155550134');
    await tester.pumpAndSettle();

    expect(find.text('Grace Hopper'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
