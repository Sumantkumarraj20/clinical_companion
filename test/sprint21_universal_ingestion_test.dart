import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/models/document_task.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TextOnlyAiService extends DocumentAiService {
  _TextOnlyAiService() : super(apiKey: 'test-key');

  bool? receivedImage;
  String? receivedPrompt;

  @override
  Future<AiExtractionResult> extractDocument({
    required File? image,
    required String prompt,
    ThinkingLevel? thinkingLevel,
  }) async {
    receivedImage = image != null;
    receivedPrompt = prompt;
    return AiExtractionResult.fromJson({
      'inferredPatientDemographics': {
        'name': 'Asha Rao',
        'age': 42,
        'gender': 'Female',
        'mrn': 'MRN-42',
      },
      'encounterDetails': {
        'date': '2025-02-03',
        'type': 'OPD',
        'vitals': {
          'sbp': 138,
          'dbp': 86,
          'pulse': 78,
          'spo2': 98,
          'temperature_c': 36.8,
          'respiratory_rate': 16,
          'map': 103.3,
        },
      },
      'pomr_data': [
        {
          'diagnosis': 'Hypertension',
          'linked_medications': [
            {
              'name': 'Amlodipine',
              'dose': '5 mg',
              'frequency': 'daily',
              'route': 'oral',
              'duration': 'ongoing',
            },
          ],
          'linked_investigations': [
            {'test_name': 'Renal Function Test', 'value': '', 'unit': null},
          ],
          'linked_procedures': [
            {'procedure_name': 'ECG'},
          ],
          'reasoning': 'Ongoing blood pressure management.',
        },
      ],
      'unlinked_data': {
        'medications': [
          {'name': 'Paracetamol', 'dose': '500 mg'},
        ],
        'investigations': [],
        'procedures': [],
      },
      'chief_complaints': ['Headache'],
      'clinical_summary': 'Hypertension review with headache.',
      'conclusion': '',
      'document_date': '2025-02-03',
      'is_date_assumed': false,
      'inferred_patient_id': null,
      'source_authority': 'Typed Note',
    });
  }
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for text extraction.');
}

void main() {
  test('Smart Paste queue calls ClinCom text-only without image OCR', () async {
    final ai = _TextOnlyAiService();
    final container = ProviderContainer(
      overrides: [
        extractionPipelineProvider.overrideWith(
          (ref) => ExtractionPipelineService(ai),
        ),
      ],
    );
    addTearDown(container.dispose);

    const originalText = 'Asha Rao, OPD review. BP 138/86. Pipzo continued.';
    container.read(batchExtractionProvider.notifier).addText(originalText);
    await _waitUntil(
      () => container
          .read(batchExtractionProvider)
          .any((task) => task.status == ExtractionStatus.readyForReview),
    );

    final task = container.read(batchExtractionProvider).single;
    expect(task.isTextInput, isTrue);
    expect(task.originalFile, isNull);
    expect(task.rawOcrText, originalText);
    expect(task.source, ExtractionSource.text);
    expect(task.extractedData?.patientIdentity.name, 'Asha Rao');
    expect(task.extractedData?.problems.single.diagnosis, 'Hypertension');
    expect(ai.receivedImage, isFalse);
    expect(ai.receivedPrompt, contains(originalText));
    expect(ai.receivedPrompt, contains('elite Medical Informatician'));
    expect(ai.receivedPrompt, contains('pomr_data'));
  });

  test('ambient transcript uses the Omni-Schema scribe context', () async {
    final ai = _TextOnlyAiService();
    final container = ProviderContainer(
      overrides: [
        extractionPipelineProvider.overrideWith(
          (ref) => ExtractionPipelineService(ai),
        ),
      ],
    );
    addTearDown(container.dispose);

    const transcript = 'Doctor: BP is 138 over 86. Start amlodipine 5 mg.';
    container
        .read(batchExtractionProvider.notifier)
        .addText(transcript, isAmbientAudio: true);
    await _waitUntil(
      () => container
          .read(batchExtractionProvider)
          .any((task) => task.status == ExtractionStatus.readyForReview),
    );

    final task = container.read(batchExtractionProvider).single;
    expect(task.isAmbientAudio, isTrue);
    expect(task.rawOcrText, transcript);
    expect(
      ai.receivedPrompt,
      contains('raw, ambient audio transcription from an Indian hospital ward'),
    );
    expect(ai.receivedPrompt, contains('Hindi/Hinglish into standard English'));
    expect(ai.receivedPrompt, contains('saans phool rahi hai'));
    expect(ai.receivedPrompt, contains('Ignore conversational filler'));
    expect(task.extractedData?.problems.single.diagnosis, 'Hypertension');
  });

  test('universal DAO transaction files text and linked POMR rows', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ClinicalDao(db);
    const originalText =
        'Asha Rao, MRN MRN-42. OPD review: headache; BP 138/86.';
    final result = AiExtractionResult(
      patientIdentity: const PatientIdentity(
        name: 'Asha Rao',
        age: 42,
        gender: 'Female',
        hospitalRegNo: 'MRN-42',
      ),
      encounterContext: const EncounterContext(
        documentType: 'OPD',
        date: '2025-02-03',
      ),
      vitals: const AiVitals(
        sbp: 138,
        dbp: 86,
        pr: 78,
        spo2: 98,
        respiratoryRate: 16,
        meanArterialPressure: 103.3,
      ),
      chiefComplaints: const ['Headache'],
      clinicalSummary: 'Hypertension review with headache.',
      problems: const [
        AiProblem(
          diagnosis: 'Hypertension',
          linkedMedications: [
            OrderedMedication(
              drugName: 'Amlodipine',
              dosage: '5 mg',
              frequency: 'daily',
              route: 'oral',
              duration: 'ongoing',
            ),
          ],
          linkedInvestigations: [
            AiInvestigation(testName: 'Renal Function Test'),
          ],
          linkedProcedures: [AiProcedure(procedureName: 'ECG')],
        ),
      ],
      unlinkedManagement: const AiUnlinkedManagement(
        medications: [OrderedMedication(drugName: 'Paracetamol')],
      ),
    );

    final encounter = await dao.saveUniversalClinicalPayload(
      result: result,
      rawSourceText: originalText,
      isTextInput: true,
      clincomJson: '{"source":"smart-paste"}',
    );

    final patients = await db.select(db.patients).get();
    final registry = await db.select(db.documentRegistries).getSingle();
    final problem = await db.select(db.patientProblems).getSingle();
    final prescriptions = await db.select(db.prescriptionOrders).get();
    final investigation = await db.select(db.investigationOrders).getSingle();
    final intervention = await db.select(db.clinicalInterventions).getSingle();

    expect(patients, hasLength(1));
    expect(patients.single.fullName, 'Asha Rao');
    expect(registry.patientId, patients.single.id);
    expect(registry.documentCategory, 'Text Note');
    expect(registry.imagePath, isEmpty);
    expect(registry.rawOcrTranscript, originalText);
    expect(registry.clincomJson, '{"source":"smart-paste"}');
    expect(encounter.patientId, patients.single.id);
    expect(encounter.imagePath, isNull);
    expect(encounter.respiratoryRate, 16);
    expect(encounter.meanArterialPressure, 103.3);
    expect(problem.problemName, 'Hypertension');
    expect(prescriptions, hasLength(2));
    expect(
      prescriptions.firstWhere((row) => row.drugName == 'Amlodipine').problemId,
      problem.id,
    );
    expect(
      prescriptions.firstWhere((row) => row.drugName == 'Amlodipine').route,
      'oral',
    );
    expect(
      prescriptions.firstWhere((row) => row.drugName == 'Amlodipine').duration,
      'ongoing',
    );
    expect(
      prescriptions
          .firstWhere((row) => row.drugName == 'Paracetamol')
          .problemId,
      isNull,
    );
    expect(investigation.problemId, problem.id);
    expect(intervention.problemId, problem.id);
  });
}
