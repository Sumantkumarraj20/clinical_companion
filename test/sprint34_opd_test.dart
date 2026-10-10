import 'package:clinical_companion/core/cds/silent_brain.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/daos/clinical_rule_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/core/widgets/silent_brain_panel.dart';
import 'package:clinical_companion/features/opd/screens/opd_encounter_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _addRule(
  AppDatabase db, {
  required String trigger,
  bool verified = true,
  bool dismissed = false,
}) => db
    .into(db.clinicalRules)
    .insert(
      ClinicalRulesCompanion.insert(
        triggerType: 'diagnosis',
        triggerValue: trigger,
        suggestedAction: 'Quantify proteinuria',
        evidenceRationale: 'Guideline rationale text',
        differentialDiagnoses: const Value(['Minimal change disease', 'FSGS']),
        recommendedInvestigations: const Value(['24h urine protein']),
        sourceReference: const Value('KDIGO 2021'),
        isVerified: Value(verified),
        isDismissed: Value(dismissed),
      ),
    );

void main() {
  test('keyword search finds learned rules, skips dismissed ones', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _addRule(db, trigger: 'Nephrotic Syndrome');
    await _addRule(db, trigger: 'Ascites', dismissed: true);
    final dao = ClinicalRuleDao(db);

    final hit = await dao.searchByKeywords(['nephrotic']);
    expect(hit.map((r) => r.triggerValue), ['Nephrotic Syndrome']);
    expect(await dao.searchByKeywords(['ascites']), isEmpty);
    expect(await dao.searchByKeywords(['%']), isEmpty);
  });

  test('matcher: partial trigger match, generic words ignored', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _addRule(db, trigger: 'Nephrotic Syndrome');
    final rules = await db.select(db.clinicalRules).get();

    expect(LearnedRuleMatcher.isRelevant(rules.first, 'nephrotic'), isTrue);
    expect(
      LearnedRuleMatcher.isRelevant(rules.first, 'cushing syndrome'),
      isFalse,
    );
    final out = SilentBrain.evaluate(
      const BrainInput(complaints: 'puffy face, nephrotic picture'),
      learned: rules,
    );
    final card = out.firstWhere((e) => e.title.contains('Quantify'));
    expect(card.verified, isTrue);
    expect(card.source, contains('KDIGO 2021'));
    expect(out.any((e) => e.rationale.contains('FSGS')), isTrue);
  });

  test('unverified rules are labelled for the clinician to confirm', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _addRule(db, trigger: 'Ascites', verified: false);
    final rules = await db.select(db.clinicalRules).get();
    final out = SilentBrain.evaluate(
      const BrainInput(examination: 'Ascites'),
      learned: rules,
    );
    expect(
      out.firstWhere((e) => e.verified == false).source,
      contains('Awaiting your verification'),
    );
  });

  testWidgets('OPD: chips, duration, brain from local rules, copy, save', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    late Patient patient;
    await tester.runAsync(() async {
      patient = await ClinicalDao(db).insertPatient(
        PatientsCompanion.insert(ownerId: 'o', fullName: 'Ravi Kumar'),
      );
      await _addRule(db, trigger: 'Nephrotic Syndrome');
    });
    String? clip;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clip = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: OpdEncounterScreen(patient: patient)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.widgetWithText(ActionChip, 'Fever x … days'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, '3'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Fever x 3 days'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, 'Pallor'));
    await tester.pump();
    expect(find.widgetWithText(InputChip, 'Pallor'), findsOneWidget);

    // Typing a keyword surfaces the learned protocol after the debounce.
    await tester.enterText(
      find.widgetWithText(TextField, 'Type history, or tap below'),
      'nephrotic',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.scrollUntilVisible(
      find.byType(SilentBrainPanel),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Prompts for your review'), findsOneWidget);
    if (find.textContaining('Quantify proteinuria').evaluate().isEmpty) {
      await tester.tap(find.textContaining('Prompts for your review'));
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('Quantify proteinuria'), findsOneWidget);
    expect(find.textContaining('Verified protocol'), findsWidgets);

    await tester.tap(find.text('Copy note'));
    await tester.pump();
    expect(clip, contains('C/O: Fever x 3 days'));
    expect(clip, contains('O/E: Pallor'));

    await tester.tap(find.textContaining('Save and next'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final saved = await tester.runAsync(
      () => ClinicalDao(db).getEncountersForPatient(patient.id),
    );
    expect(saved, hasLength(1));
    expect(saved!.single.chiefComplaints, 'Fever x 3 days');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
