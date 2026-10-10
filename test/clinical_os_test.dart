import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinical_companion/core/cds/silent_brain.dart';
import 'package:clinical_companion/core/clinical/note_formatter.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/features/rounds/screens/rounds_mode_screen.dart';

void main() {
  test('SOAP note omits empty sections and keeps order', () {
    final text = ClinicalNoteFormatter.progressNote(
      patientName: 'A B',
      location: 'Ward 1 · Bed 2',
      when: DateTime(2025, 1, 2, 3, 4),
      subjective: 'Better',
      plan: 'Continue',
    );
    expect(text, contains('02/01/2025 03:04'));
    expect(text.indexOf('S:'), lessThan(text.indexOf('P:')));
    expect(text, isNot(contains('A:')));
  });

  test('template renders only filled fields', () {
    final out = NoteTemplate.procedure.render({'procedure': 'Pleural tap'});
    expect(out, contains('PROCEDURE NOTE'));
    expect(out, contains('Pleural tap'));
    expect(out, isNot(contains('Technique')));
  });

  test('brain flags chest pain differentials and low SpO2', () {
    final items = SilentBrain.evaluate(
      const BrainInput(complaints: 'Chest pain since 1 hour', spo2: 88),
    );
    expect(items.first.urgent, isTrue);
    expect(
      items.any(
        (e) =>
            e.kind == BrainKind.differential &&
            e.rationale.contains('Acute coronary syndrome'),
      ),
      isTrue,
    );
    expect(items.any((e) => e.title == 'Allergy status'), isTrue);
  });

  testWidgets('rounds mode swipes between beds', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ClinicalDao(db);
    await tester.runAsync(() async {
      await db
          .into(db.hospitals)
          .insert(HospitalsCompanion.insert(id: const Value('h1'), name: 'H'));
      for (final (i, n) in ['Asha Rao', 'Binod Das'].indexed) {
        final p = await dao.insertPatient(
          PatientsCompanion.insert(ownerId: 'o', fullName: n),
        );
        await dao.upsertActiveAdmission(
          patientId: p.id,
          hospitalId: 'h1',
          wardName: 'W',
          bedNumber: '${i + 1}',
        );
      }
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RoundsModeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Patient 1 of 2 · swipe for next bed'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Patient 2 of 2 · swipe for next bed'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
