import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/documents/clinical_pdf_generator.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ClinicalDao dao;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dao = ClinicalDao(db);
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: const Value('patient-1'),
            ownerId: 'owner-1',
            fullName: 'Test Patient',
          ),
        );
    await db
        .into(db.clinicalEncounters)
        .insert(
          ClinicalEncountersCompanion.insert(
            id: const Value('encounter-1'),
            ownerId: 'owner-1',
            patientId: 'patient-1',
            chiefComplaints: const Value('Headache'),
            examinationFindings: const Value('Alert and oriented'),
            sbp: const Value(120),
            dbp: const Value(80),
          ),
        );
    await db
        .into(db.patientProblems)
        .insert(
          PatientProblemsCompanion.insert(
            id: const Value('problem-1'),
            patientId: 'patient-1',
            problemName: 'Hypertension',
            initialEncounterId: const Value('encounter-1'),
          ),
        );
    await db
        .into(db.prescriptionOrders)
        .insert(
          PrescriptionOrdersCompanion.insert(
            id: const Value('prescription-1'),
            patientId: 'patient-1',
            encounterId: 'encounter-1',
            problemId: const Value('problem-1'),
            drugName: 'Amlodipine',
            doseStrength: const Value('5 mg'),
          ),
        );
    await db
        .into(db.investigationOrders)
        .insert(
          InvestigationOrdersCompanion.insert(
            id: const Value('investigation-1'),
            patientId: 'patient-1',
            encounterId: const Value('encounter-1'),
            problemId: const Value('problem-1'),
            testName: 'KFT',
          ),
        );
    await db
        .into(db.investigationResults)
        .insert(
          InvestigationResultsCompanion.insert(
            id: const Value('result-1'),
            orderId: const Value('investigation-1'),
            patientId: 'patient-1',
            testName: 'Creatinine',
            numericValue: const Value(0.9),
            unit: const Value('mg/dL'),
          ),
        );
    await db
        .into(db.clinicalInterventions)
        .insert(
          ClinicalInterventionsCompanion.insert(
            id: const Value('intervention-1'),
            patientId: 'patient-1',
            encounterId: 'encounter-1',
            problemId: const Value('problem-1'),
            procedureName: 'ECG',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'POMR export keeps management and results under their linked problem',
    () async {
      final data = await dao.getEncounterPomrExport('encounter-1');
      final section = data.problems.single;

      expect(section.problem.problemName, 'Hypertension');
      expect(section.prescriptions.single.drugName, 'Amlodipine');
      expect(section.investigations.single.order.testName, 'KFT');
      expect(
        section.investigations.single.results.single.testName,
        'Creatinine',
      );
      expect(section.interventions.single.procedureName, 'ECG');
      expect(
        data.toPlainText(patient: (await db.select(db.patients).getSingle())),
        contains('PROBLEM: Hypertension'),
      );
    },
  );

  test('clinical PDF generator returns a structured PDF document', () async {
    final patient = await db.select(db.patients).getSingle();
    final data = await dao.getEncounterPomrExport('encounter-1');
    final bytes = await ClinicalPdfGenerator().generatePomrEncounter(
      patient: patient,
      data: data,
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(8)), startsWith('%PDF'));
  });
}
