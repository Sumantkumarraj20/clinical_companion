import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/models/clinical_insight.dart';
import 'package:clinical_companion/core/services/clincom_audit_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuditAi extends DocumentAiService {
  _FakeAuditAi() : super(apiKey: 'unused-in-test');

  String? summary;

  @override
  Future<List<ClinicalInsight>> generateClinicalInsights(
    String chartSummary, {
    ThinkingLevel? thinkingLevel,
  }) async {
    summary = chartSummary;
    return const [
      ClinicalInsight(
        type: 'missing_investigation',
        title: 'CSF analysis recommended',
        reasoning: 'Evaluate inflammatory causes.',
        actionableItems: ['CSF analysis'],
      ),
    ];
  }
}

void main() {
  test('audit service aggregates chart state and returns insights', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ClinicalDao(db);
    final encounter = await dao.saveUniversalClinicalPayload(
      result: const AiExtractionResult(
        patientIdentity: PatientIdentity(name: 'Audit Patient'),
        problems: [
          AiProblem(
            diagnosis: 'Transverse Myelitis',
            linkedMedications: [
              OrderedMedication(
                drugName: 'IVIG',
                dosage: '2 g/kg',
                route: 'IV',
              ),
            ],
          ),
        ],
      ),
      rawSourceText: 'Transverse Myelitis receiving IVIG.',
      isTextInput: true,
    );
    final ai = _FakeAuditAi();
    final service = ClinComAuditService(clinicalDao: dao, aiService: ai);

    final insights = await service.auditPatient(encounter.patientId);

    expect(ai.summary, contains('Transverse Myelitis'));
    expect(ai.summary, contains('IVIG'));
    expect(ai.summary, contains('ACTIVE INVESTIGATION ORDERS'));
    expect(ai.summary, contains('RECENT INVESTIGATION RESULTS'));
    expect(insights.single.title, 'CSF analysis recommended');
  });

  test(
    'audit feedback stores accepted and dismissed suggestions; hub counts accepted',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final dao = ClinicalDao(db);
      final encounter = await dao.saveUniversalClinicalPayload(
        result: const AiExtractionResult(
          patientIdentity: PatientIdentity(name: 'Feedback Patient'),
        ),
        rawSourceText: 'Clinical note.',
        isTextInput: true,
      );

      final accepted = await dao.recordClinicalAudit(
        patientId: encounter.patientId,
        suggestionType: 'missing_investigation',
        title: 'CSF analysis recommended',
        reasoning: 'Standard evaluation.',
        status: 'accepted',
      );
      await dao.recordClinicalAudit(
        patientId: encounter.patientId,
        suggestionType: 'missing_investigation',
        title: 'CSF analysis recommended',
        reasoning: 'Standard evaluation.',
        status: 'dismissed',
      );
      expect(accepted.status, 'accepted');

      final blindSpots = await dao.getFrequentAcceptedClinicalAudits();
      expect(blindSpots, hasLength(1));
      expect(blindSpots.single.acceptedCount, 1);
      expect(blindSpots.single.title, 'CSF analysis recommended');
    },
  );

  test(
    'clinical insight parser rejects invalid type and missing rationale',
    () {
      expect(
        () => ClinicalInsight.fromJson({
          'type': 'unsupported',
          'title': 'Suggestion',
          'reasoning': 'Because',
        }),
        throwsFormatException,
      );
      expect(
        () => ClinicalInsight.fromJson({
          'type': 'warning',
          'title': 'Suggestion',
          'reasoning': '',
        }),
        throwsFormatException,
      );
    },
  );
}
