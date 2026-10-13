
import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
