import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/clinical_rule_dao.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/clinical_rule_suggestion.dart';
import 'package:clinical_companion/core/models/patient_clinical_context.dart';
import 'package:clinical_companion/core/services/clinical_rule_engine.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

class _FakeRuleAi extends DocumentAiService {
  _FakeRuleAi() : super(apiKey: 'unused-in-test');

  int calls = 0;

  @override
  Future<ClinicalRuleSuggestion> generateClinicalRule({
    required String triggerType,
    required String triggerValue,
  }) async {
    calls++;
    return ClinicalRuleSuggestion(
      triggerType: triggerType,
      triggerValue: triggerValue,
      suggestedAction: 'Review standard evaluation',
      evidenceRationale: 'Supported by standard-of-care guidance.',
      contraindicatingConditions: const ['anuria'],
      requiredMonitoring: const ['electrolytes'],
      differentialDiagnoses: const ['Alternative diagnosis'],
      recommendedInvestigations: const ['Targeted laboratory test'],
      recommendedManagement: const ['Initial management option'],
    );
  }
}

void main() {
  test(
    'schema 32 upgrades rule columns and context index without data loss',
    () async {
      final database = AppDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute('''
            CREATE TABLE clinical_rules (
              id TEXT NOT NULL PRIMARY KEY,
              trigger_type TEXT NOT NULL,
              trigger_value TEXT NOT NULL,
              suggested_action TEXT NOT NULL,
              evidence_rationale TEXT NOT NULL,
              is_verified INTEGER NOT NULL DEFAULT 0,
              is_dismissed INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL DEFAULT '2026-01-01T00:00:00.000'
            )
          ''');
            sqlite.execute('''
            INSERT INTO clinical_rules (
              id, trigger_type, trigger_value, suggested_action,
              evidence_rationale, created_at
            ) VALUES (
              'legacy-rule', 'medication', 'Drug X', 'Review', 'Reason',
              '2026-01-01T00:00:00.000'
            )
          ''');
            sqlite.execute('''
            CREATE TABLE patient_problems (
              id TEXT NOT NULL PRIMARY KEY,
              patient_id TEXT NOT NULL,
              current_status TEXT NOT NULL DEFAULT 'Active'
            )
          ''');
            sqlite.execute('PRAGMA user_version = 32');
          },
        ),
      );
      addTearDown(database.close);

      final columns = await database
          .customSelect('PRAGMA table_info(clinical_rules)')
          .get();
      final names = columns.map((row) => row.read<String>('name')).toSet();
      expect(
        names,
        containsAll([
          'contraindicating_conditions',
          'required_monitoring',
          'source_reference',
          'differential_diagnoses',
          'recommended_investigations',
          'recommended_management',
        ]),
      );
      final legacyRule = await (database.select(
        database.clinicalRules,
      )..where((rule) => rule.id.equals('legacy-rule'))).getSingle();
      expect(legacyRule.triggerValue, 'Drug X');
      expect(legacyRule.contraindicatingConditions, isEmpty);
      expect(legacyRule.requiredMonitoring, isEmpty);
      expect(legacyRule.differentialDiagnoses, isEmpty);
      expect(legacyRule.recommendedInvestigations, isEmpty);
      expect(legacyRule.recommendedManagement, isEmpty);
    },
  );

  test('schema 31 creates the current clinical rules table safely', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute('''
            CREATE TABLE patient_problems (
              id TEXT NOT NULL PRIMARY KEY,
              patient_id TEXT NOT NULL,
              current_status TEXT NOT NULL DEFAULT 'Active'
            )
          ''');
          sqlite.execute('PRAGMA user_version = 31');
        },
      ),
    );
    addTearDown(database.close);

    final columns = await database
        .customSelect('PRAGMA table_info(clinical_rules)')
        .get();
    final names = columns.map((row) => row.read<String>('name')).toSet();
    expect(
      names,
      containsAll([
        'contraindicating_conditions',
        'required_monitoring',
        'source_reference',
        'differential_diagnoses',
        'recommended_investigations',
        'recommended_management',
      ]),
    );
  });

  test(
    'cache miss generates an unverified rule, then cache hit is local',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final dao = ClinicalRuleDao(database);
      final ai = _FakeRuleAi();
      final engine = ClinicalRuleEngine(ruleDao: dao, aiService: ai);

      final generated = await engine.evaluate(
        triggerType: 'diagnosis',
        triggerValue: 'Transverse Myelitis',
      );
      expect(generated, isNotNull);
      expect(generated!.isVerified, isFalse);
      expect(generated.triggerValue, 'Transverse Myelitis');
      expect(ai.calls, 1);

      final cached = await engine.evaluate(
        triggerType: 'diagnosis',
        triggerValue: 'transverse myelitis',
      );
      expect(cached?.id, generated.id);
      expect(ai.calls, 1);

      final verified = await dao.verifyRule(generated.id);
      expect(verified.isVerified, isTrue);
      expect(
        (await engine.evaluate(
          triggerType: 'diagnosis',
          triggerValue: 'TRANSVERSE MYELITIS',
        ))?.isVerified,
        isTrue,
      );
      expect(ai.calls, 1);
    },
  );

  test('dismissed rule is not generated again or surfaced', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final dao = ClinicalRuleDao(database);
    final ai = _FakeRuleAi();
    final engine = ClinicalRuleEngine(ruleDao: dao, aiService: ai);

    final generated = (await engine.evaluate(
      triggerType: 'medication',
      triggerValue: 'Medication X',
    ))!;
    await dao.dismissRule(generated.id);

    expect(
      await engine.evaluate(
        triggerType: 'medication',
        triggerValue: 'Medication X',
      ),
      isNull,
    );
    expect(ai.calls, 1);
  });

  test('invalid or empty triggers do not call the AI', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final ai = _FakeRuleAi();
    final engine = ClinicalRuleEngine(
      ruleDao: ClinicalRuleDao(database),
      aiService: ai,
    );

    expect(
      await engine.evaluate(triggerType: 'procedure', triggerValue: 'CT'),
      isNull,
    );
    expect(
      await engine.evaluate(triggerType: 'diagnosis', triggerValue: '  '),
      isNull,
    );
    expect(ai.calls, 0);
  });

  test(
    'guideline rules persist structured fields and match whole chart context',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final dao = ClinicalRuleDao(database);
      final import = await dao.saveGuidelineRules([
        const ClinicalRuleSuggestion(
          triggerType: 'medication',
          triggerValue: 'Furosemide',
          suggestedAction: 'Review before prescribing',
          evidenceRationale: 'The source describes specific contraindications.',
          contraindicatingConditions: [
            'anuria',
            'allergy: furosemide',
            'SBP < 90',
          ],
          requiredMonitoring: ['electrolytes', 'urine output'],
          differentialDiagnoses: ['Heart failure'],
          recommendedInvestigations: ['Electrolytes'],
          recommendedManagement: ['Review diuretic therapy'],
          sourceReference: 'Local Clinical Guideline',
        ),
      ]);
      expect(import.insertedCount, 1);

      const patientId = 'context-test-patient';
      await database
          .into(database.patients)
          .insert(
            PatientsCompanion.insert(
              id: const Value(patientId),
              ownerId: 'test',
              fullName: 'Test Patient',
            ),
          );
      final now = DateTime.now().toUtc();
      await database
          .into(database.clinicalEncounters)
          .insert(
            ClinicalEncountersCompanion.insert(
              ownerId: 'test',
              patientId: patientId,
              chiefComplaints: const Value('Anuria for two days'),
              drugAndAllergyHistory: const Value('Sulfa/Furosemide allergy'),
              sbp: const Value(82),
              occurredAt: Value(now),
            ),
          );

      final clinicalDao = ClinicalDao(database);
      await clinicalDao.getCurrentPatientContext(patientId, now: now);
      final stopwatch = Stopwatch()..start();
      final context = await clinicalDao.getCurrentPatientContext(
        patientId,
        now: now,
      );
      stopwatch.stop();
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 50)));
      final rules = await dao.rulesForTrigger(
        triggerType: 'medication',
        triggerValue: 'furosemide',
      );
      expect(rules.single.isVerified, isFalse);
      expect(rules.single.contraindicatingConditions, [
        'anuria',
        'allergy: furosemide',
        'SBP < 90',
      ]);
      expect(rules.single.requiredMonitoring, ['electrolytes', 'urine output']);
      expect(rules.single.differentialDiagnoses, ['Heart failure']);
      expect(rules.single.recommendedInvestigations, ['Electrolytes']);
      expect(rules.single.recommendedManagement, ['Review diuretic therapy']);
      expect(rules.single.sourceReference, 'Local Clinical Guideline');
      expect((await dao.watchPendingPathways().first).map((rule) => rule.id), [
        rules.single.id,
      ]);

      final verified = await dao.verifyRule(rules.single.id);
      final conflicts = ClinicalRuleEngine.findConflicts(
        rules: [verified],
        context: context,
      );
      expect(conflicts.map((conflict) => conflict.condition), [
        'anuria',
        'allergy: furosemide',
        'SBP < 90',
      ]);
      final verifiedPathway = await dao.updatePathwayAndVerify(
        id: verified.id,
        differentialDiagnoses: ['Edited diagnosis'],
        recommendedInvestigations: ['Edited investigation'],
        recommendedManagement: ['Edited management'],
        evidenceRationale: 'Clinician-reviewed rationale.',
      );
      expect(verifiedPathway.isVerified, isTrue);
      expect(verifiedPathway.differentialDiagnoses, ['Edited diagnosis']);
      expect(verifiedPathway.recommendedInvestigations, [
        'Edited investigation',
      ]);
      expect(verifiedPathway.recommendedManagement, ['Edited management']);
      expect(
        verifiedPathway.evidenceRationale,
        'Clinician-reviewed rationale.',
      );
    },
  );

  test('negative symptom statement does not trigger the symptom guardrail', () {
    final rule = CachedClinicalRule(
      id: 'rule-1',
      triggerType: 'medication',
      triggerValue: 'Furosemide',
      suggestedAction: 'Review',
      evidenceRationale: 'Rationale',
      contraindicatingConditions: ['anuria'],
      requiredMonitoring: [],
      differentialDiagnoses: [],
      recommendedInvestigations: [],
      recommendedManagement: [],
      sourceReference: '',
      isVerified: true,
      isDismissed: false,
      createdAt: DateTime.now(),
    );
    const context = PatientClinicalContext(
      allergyHistory: '',
      activeProblems: [],
      recentVitals: [],
      recentSymptoms: ['No anuria reported'],
    );

    expect(
      ClinicalRuleEngine.findConflicts(rules: [rule], context: context),
      isEmpty,
    );
    const positiveContext = PatientClinicalContext(
      allergyHistory: '',
      activeProblems: [],
      recentVitals: [],
      recentSymptoms: ['No anuria reported', 'Anuria for two days'],
    );
    final conflict = ClinicalRuleEngine.findConflicts(
      rules: [rule],
      context: positiveContext,
    );
    expect(conflict, hasLength(1));
    expect(conflict.single.evidence, 'Anuria for two days');
  });
}
