import 'dart:convert';
import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _PromptCapturingAiService extends DocumentAiService {
  _PromptCapturingAiService();

  String? prompt;

  @override
  Future<AiExtractionResult> extractDocument({
    required File? image,
    required String prompt,
  }) async {
    this.prompt = prompt;
    return const AiExtractionResult();
  }
}

Future<AppDatabase> _database() async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  return database;
}

Future<String> _patientId(AppDatabase database) async {
  final patient = await ClinicalDao(database).insertPatient(
    PatientsCompanion.insert(
      ownerId: 'local-practitioner',
      fullName: 'POMR Test Patient',
    ),
  );
  return patient.id;
}

const _pomrExtraction = AiExtractionResult(
  encounterContext: EncounterContext(
    documentType: 'Consultation',
    date: '2026-10-05T09:00:00Z',
  ),
  problems: [
    AiProblem(
      diagnosis: 'Hypertension',
      reasoning: 'Amlodipine is appropriate for documented hypertension.',
      linkedMedications: [
        OrderedMedication(
          drugName: 'Amlodipine',
          dosage: '5 mg',
          frequency: 'OD',
        ),
      ],
      linkedInvestigations: [
        AiInvestigation(testName: 'KFT', value: '1.2', unit: 'mg/dL'),
      ],
      linkedProcedures: [
        AiProcedure(procedureName: 'Blood pressure monitoring'),
      ],
    ),
    AiProblem(
      diagnosis: 'Chronic kidney disease',
      linkedInvestigations: [AiInvestigation(testName: 'Urine ACR')],
    ),
  ],
  unlinkedManagement: AiUnlinkedManagement(
    medications: [OrderedMedication(drugName: 'Unclassified tablet')],
    investigations: [AiInvestigation(testName: 'ECG')],
    procedures: [AiProcedure(procedureName: 'Unclassified procedure')],
  ),
);

void main() {
  group('Sprint 19 POMR extraction contract', () {
    test('parses the requested name/dose nested management shape', () {
      final result = AiExtractionResult.fromJson({
        'problems': [
          {
            'diagnosis': 'Hypertension',
            'linked_medications': [
              {'name': 'Amlodipine', 'dose': '5 mg'},
            ],
            'linked_investigations': [
              {'test_name': 'KFT', 'value': '1.2', 'unit': 'mg/dL'},
            ],
            'linked_procedures': [
              {'procedure_name': 'Blood pressure monitoring'},
            ],
            'reasoning': 'Standard antihypertensive management.',
          },
        ],
        'unlinked_management': {
          'medications': [
            {'name': 'Unclassified tablet'},
          ],
          'investigations': [],
          'procedures': [],
        },
      });

      expect(result.problems.single.diagnosis, 'Hypertension');
      expect(
        result.problems.single.linkedMedications.single.drugName,
        'Amlodipine',
      );
      expect(result.problems.single.linkedMedications.single.dosage, '5 mg');
      expect(
        result.problems.single.linkedInvestigations.single.testName,
        'KFT',
      );
      expect(
        result.unlinkedManagement.medications.single.drugName,
        'Unclassified tablet',
      );
    });

    test(
      'ClinCom prompt mandates POMR and includes local practice patterns',
      () async {
        final ai = _PromptCapturingAiService();
        final service = ExtractionPipelineService(
          ai,
          historicalAssociationsLoader: () async => const [
            'Amlodipine:Hypertension (frequency: 4)',
          ],
        );
        addTearDown(service.close);

        await service.refineWithAi(
          File('/not-read-because-this-is-text-only.png'),
          List.filled(45, 'clinical narrative').join(' '),
        );

        expect(ai.prompt, contains('You are an expert clinical reasoner.'));
        expect(ai.prompt, contains('"pomr_data"'));
        expect(ai.prompt, contains('"unlinked_data"'));
        expect(ai.prompt, contains("CLINICIAN'S HISTORICAL PRACTICE PATTERNS"));
        expect(ai.prompt, contains('Amlodipine:Hypertension'));
        expect(ai.prompt, contains('Do not emit the legacy flat'));
      },
    );
  });

  group('Sprint 19 relational persistence and learning', () {
    test(
      'saves problem foreign keys and unlinked management as null',
      () async {
        final database = await _database();
        final dao = ClinicalDao(database);
        final patientId = await _patientId(database);
        const verified = ['Amlodipine:Hypertension'];

        await dao.processAiExtraction(
          _pomrExtraction,
          '/pomr/initial.jpg',
          patientIdOverride: patientId,
          clincomJson: jsonEncode(_pomrExtraction.toJson()),
          verifiedProblemAssociations: verified,
        );

        final problems = await database.select(database.patientProblems).get();
        final problemIds = {
          for (final problem in problems) problem.problemName: problem.id,
        };
        final prescriptions = await database
            .select(database.prescriptionOrders)
            .get();
        final amlodipine = prescriptions.singleWhere(
          (row) => row.drugName == 'Amlodipine',
        );
        final unclassifiedMedication = prescriptions.singleWhere(
          (row) => row.drugName == 'Unclassified tablet',
        );
        expect(amlodipine.problemId, problemIds['Hypertension']);
        expect(unclassifiedMedication.problemId, isNull);

        final orders = await database
            .select(database.investigationOrders)
            .get();
        final kft = orders.singleWhere((row) => row.testName == 'KFT');
        final urineAcr = orders.singleWhere(
          (row) => row.testName == 'Urine ACR',
        );
        final ecg = orders.singleWhere((row) => row.testName == 'ECG');
        expect(kft.problemId, problemIds['Hypertension']);
        expect(urineAcr.problemId, problemIds['Chronic kidney disease']);
        expect(ecg.problemId, isNull);

        final interventions = await database
            .select(database.clinicalInterventions)
            .get();
        final monitoring = interventions.singleWhere(
          (row) => row.procedureName == 'Blood pressure monitoring',
        );
        final unclassifiedProcedure = interventions.singleWhere(
          (row) => row.procedureName == 'Unclassified procedure',
        );
        expect(monitoring.problemId, problemIds['Hypertension']);
        expect(unclassifiedProcedure.problemId, isNull);
        expect(
          await dao.getTopProblemAssociations(),
          contains('Amlodipine:Hypertension (frequency: 1)'),
        );
      },
    );

    test(
      'edit hydration reads problem associations from the FK rows',
      () async {
        final database = await _database();
        final dao = ClinicalDao(database);
        final patientId = await _patientId(database);
        const imagePath = '/pomr/hydrate.jpg';
        await dao.processAiExtraction(
          _pomrExtraction,
          imagePath,
          patientIdOverride: patientId,
          clincomJson: jsonEncode(_pomrExtraction.toJson()),
        );
        final document = await dao.findDocumentByImagePath(imagePath);
        expect(document, isNotNull);

        final hydrated = await dao.hydratePomrForDocument(
          document: document!,
          extraction: const AiExtractionResult(),
        );
        final hypertension = hydrated.problems.singleWhere(
          (problem) => problem.diagnosis == 'Hypertension',
        );
        expect(hypertension.linkedMedications.single.drugName, 'Amlodipine');
        expect(hypertension.linkedInvestigations.single.testName, 'KFT');
        expect(
          hydrated.unlinkedManagement.medications.single.drugName,
          'Unclassified tablet',
        );
        expect(
          hydrated.unlinkedManagement.procedures.single.procedureName,
          'Unclassified procedure',
        );
      },
    );

    test(
      'edited links update relational rows and frequency-ranked catalog',
      () async {
        final database = await _database();
        final dao = ClinicalDao(database);
        final patientId = await _patientId(database);
        const imagePath = '/pomr/reassign.jpg';
        await dao.processAiExtraction(
          _pomrExtraction,
          imagePath,
          patientIdOverride: patientId,
          clincomJson: jsonEncode(_pomrExtraction.toJson()),
        );
        final document = await dao.findDocumentByImagePath(imagePath);
        expect(document, isNotNull);
        final edited = _pomrExtraction.copyWith(
          problems: [
            const AiProblem(diagnosis: 'Hypertension'),
            const AiProblem(
              diagnosis: 'Chronic kidney disease',
              linkedMedications: [
                OrderedMedication(
                  drugName: 'Amlodipine',
                  dosage: '5 mg',
                  frequency: 'OD',
                ),
              ],
              linkedInvestigations: [AiInvestigation(testName: 'Urine ACR')],
            ),
          ],
          unlinkedManagement: const AiUnlinkedManagement(
            medications: [OrderedMedication(drugName: 'Unclassified tablet')],
            investigations: [AiInvestigation(testName: 'ECG')],
            procedures: [AiProcedure(procedureName: 'Unclassified procedure')],
          ),
        );

        await dao.applyDocumentEdits(
          documentId: document!.id,
          documentedAt: document.documentedAt,
          extraction: edited,
          clincomJson: jsonEncode(edited.toJson()),
          verifiedProblemAssociations: const [
            'Amlodipine:Chronic kidney disease',
          ],
        );

        final ckd = (await database.select(database.patientProblems).get())
            .singleWhere(
              (problem) => problem.problemName == 'Chronic kidney disease',
            );
        final amlodipine =
            (await database.select(database.prescriptionOrders).get())
                .singleWhere((row) => row.drugName == 'Amlodipine');
        expect(amlodipine.problemId, ckd.id);
        expect(
          await dao.getTopProblemAssociations(),
          contains('Amlodipine:Chronic kidney disease (frequency: 1)'),
        );
      },
    );
  });
}
