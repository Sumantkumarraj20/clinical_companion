import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/models/clinical_drug_selection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drug semantic metadata and safety warnings decode', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.clinicalDrugs)
        .insert(
          ClinicalDrugsCompanion.insert(
            genericMolecule: 'Example medicine',
            problemIndications: const Value('["Chronic Kidney Disease"]'),
            prioritizedSideEffects: const Value('["Rash","Nausea"]'),
            commonIndications: const Value('["Chronic Kidney Disease"]'),
            doseAdjustments: const Value(
              '{"Renal":"Reduce dose when eGFR is low."}',
            ),
            commonSideEffects: const Value('["Rash","Nausea"]'),
          ),
        );
    final master = await db.select(db.clinicalDrugs).getSingle();
    final ingredient = ActiveIngredient(
      ingredientId: 'DRG-ABC-001',
      moleculeCode: 'ABC',
      genericName: 'Example medicine',
      pharmacologicalClass: null,
      mechanismOfAction: null,
      primaryRoutes: '["Oral"]',
      renalAdjustment: 'Reduce dose when eGFR is low.',
      hepaticRisk: null,
      criticalAlerts: null,
      pregnancyCategory: null,
      syncedAt: DateTime.utc(2026),
    );
    final selection = ClinicalDrugSelection(
      molecule: ingredient.genericName,
      ingredient: ingredient,
      master: master,
    );
    final extraction = AiExtractionResult.fromJson({
      'clinical_warnings': [
        {
          'medication': 'Example medicine',
          'condition': 'CKD',
          'warning': 'Review dose',
          'dose_adjustment': 'Reduce dose',
        },
      ],
    });

    expect(selection.commonIndications, contains('Chronic Kidney Disease'));
    expect(selection.doseAdjustments['Renal'], 'Reduce dose when eGFR is low.');
    expect(selection.commonSideEffects, containsAll(['Rash', 'Nausea']));
    expect(extraction.clinicalWarnings.single.warning, 'Review dose');
  });

  test(
    'recording ADR creates POMR problem and discontinues prescription atomically',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final dao = ClinicalDao(db);
      final encounter = await dao.saveUniversalClinicalPayload(
        result: const AiExtractionResult(
          patientIdentity: PatientIdentity(name: 'Test Patient'),
          problems: [
            AiProblem(
              diagnosis: 'Hypertension',
              linkedMedications: [
                OrderedMedication(drugName: 'Amlodipine', dosage: '5 mg'),
              ],
            ),
          ],
        ),
        rawSourceText: 'Hypertension; Amlodipine 5 mg.',
        isTextInput: true,
      );
      final prescription =
          (await db.select(db.prescriptionOrders).get()).single;

      final problemId = await dao.recordAdverseDrugReaction(
        prescriptionId: prescription.id,
        reaction: 'Ankle oedema',
      );

      final updatedPrescription = await dao.getPrescriptionOrder(
        prescription.id,
      );
      final problem = await dao.getPatientProblem(problemId);
      expect(updatedPrescription!.isActive, isFalse);
      expect(
        updatedPrescription.specialInstructions,
        'Discontinued due to suspected ADR: Ankle oedema',
      );
      expect(problem!.patientId, encounter.patientId);
      expect(problem.initialEncounterId, encounter.id);
      expect(problem.problemName, 'Amlodipine-associated Ankle oedema');
      expect(problem.currentStatus, 'Active');
    },
  );
}
