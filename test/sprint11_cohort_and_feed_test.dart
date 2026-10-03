import 'package:clinical_companion/core/cds/decision_support_engine.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/features/patients/widgets/cohort_tagger.dart';
import 'package:clinical_companion/features/patients/widgets/timeline_feed_model.dart';
import 'package:flutter_test/flutter_test.dart';

PatientProblem _problem({
  String name = 'Acute Appendicitis',
  String status = 'Active',
  String? encounterId,
}) {
  return PatientProblem(
    id: 'p-$name-$status',
    patientId: 'patient-1',
    initialEncounterId: encounterId,
    problemName: name,
    currentStatus: status,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

ClinicalIntervention _procedure({
  String name = 'Open Appendectomy',
  required DateTime performedAt,
  String? problemId,
}) {
  return ClinicalIntervention(
    id: 'int-$name',
    patientId: 'patient-1',
    encounterId: 'enc-1',
    problemId: problemId,
    procedureName: name,
    interventionRole: 'Therapeutic',
    performedAt: performedAt,
    createdAt: performedAt,
  );
}

Patient _patient({DateTime? dob, String gender = 'Female'}) {
  return Patient(
    id: 'patient-1',
    ownerId: 'tester',
    fullName: 'Asha Rao',
    dateOfBirth: dob,
    gender: gender,
  );
}

void main() {
  group('CohortTagger', () {
    test('turns an active problem into a diagnosis cohort', () {
      final tags = CohortTagger.tagsFor(
        problems: [_problem()],
        interventions: const [],
      );

      expect(tags.map((t) => t.display), contains('#AcuteAppendicitis'));
    });

    test('a resolved problem stops generating its cohort', () {
      final tags = CohortTagger.tagsFor(
        problems: [_problem(status: 'Resolved')],
        interventions: const [],
      );

      expect(tags, isEmpty);
    });

    test('collapses procedure names into a specialty cohort', () {
      final tags = CohortTagger.tagsFor(
        problems: const [],
        interventions: [
          _procedure(
            name: 'Craniotomy for tumour resection',
            performedAt: DateTime(2026, 1, 1),
          ),
        ],
      );

      expect(tags.map((t) => t.label), contains('Neurosurgery'));
    });

    test('generates a post-op day tag counted from the day of surgery', () {
      final surgery = DateTime(2026, 1, 10);
      final tags = CohortTagger.tagsFor(
        problems: const [],
        interventions: [_procedure(performedAt: surgery)],
        now: DateTime(2026, 1, 12),
      );

      expect(tags.map((t) => t.label), contains('PostOpDay3'));
    });

    test('stops emitting post-op tags after two weeks', () {
      final tags = CohortTagger.tagsFor(
        problems: const [],
        interventions: [_procedure(performedAt: DateTime(2026, 1, 1))],
        now: DateTime(2026, 3, 1),
      );

      expect(tags.map((t) => t.label), isNot(contains('PostOpDay1')));
    });

    test('adds demographic cohorts for paediatrics and geriatrics', () {
      final now = DateTime(2026, 1, 1);
      final child = CohortTagger.tagsFor(
        problems: const [],
        interventions: const [],
        patient: _patient(dob: DateTime(2018, 1, 1)),
        now: now,
      );
      final elderly = CohortTagger.tagsFor(
        problems: const [],
        interventions: const [],
        patient: _patient(dob: DateTime(1950, 1, 1)),
        now: now,
      );

      expect(child.map((t) => t.label), contains('Paediatric'));
      expect(elderly.map((t) => t.label), contains('Geriatric'));
    });

    test('de-duplicates tags derived from several sources', () {
      final tags = CohortTagger.tagsFor(
        problems: [_problem(name: 'Acute Appendicitis')],
        interventions: [
          _procedure(name: 'Appendectomy', performedAt: DateTime(2026, 1, 10)),
        ],
        now: DateTime(2026, 1, 10),
      );

      final generalSurgery = tags.where((t) => t.label == 'General Surgery');
      expect(
        generalSurgery,
        hasLength(1),
        reason: 'problem and procedure agree — one tag, not two',
      );
    });

    test('a patient with no problems yields no tags', () {
      final tags = CohortTagger.tagsFor(
        problems: const [],
        interventions: const [],
      );
      expect(tags, isEmpty);
    });
  });
  group('PatientTimelineBuilder', () {
    ClinicalEncounter encounter(String id, DateTime at) {
      return ClinicalEncounter(
        id: id,
        ownerId: 'tester',
        patientId: 'patient-1',
        encounterType: 'OPD Consult',
        careSetting: 'OPD',
        occurredAt: at,
        chiefComplaints: 'Abdominal pain',
        pediatricHistory: const {},
        obGynHistory: const {},
        dynamicData: const {},
        createdAt: at,
        updatedAt: at,
      );
    }

    InvestigationResult labResult(String test, DateTime at) {
      return InvestigationResult(
        id: 'res-$test',
        patientId: 'patient-1',
        testName: test,
        numericValue: 11.2,
        antibiogramJson: '{}',
        isAbnormal: true,
        resultDate: at,
        createdAt: at,
        updatedAt: at,
      );
    }

    DocumentRegistry scannedDocument(String category, DateTime at) {
      return DocumentRegistry(
        id: 'doc-$category',
        patientId: 'patient-1',
        documentCategory: category,
        imagePath: '/tmp/$category.jpg',
        rawOcrTranscript: '',
        confidenceScore: 0.9,
        documentedAt: at,
        createdAt: at,
      );
    }

    PatientTimelineBundle build({
      List<ClinicalEncounter> encounters = const [],
      List<InvestigationResult> results = const [],
      List<DocumentRegistry> documents = const [],
      List<ClinicalIntervention> interventions = const [],
      List<PrescriptionOrder> prescriptions = const [],
    }) {
      return PatientTimelineBuilder.build(
        encounters: encounters,
        results: results,
        documents: documents,
        interventions: interventions,
        prescriptions: prescriptions,
        problems: const [],
        cohortTags: const [],
      );
    }

    test('merges every record type into one newest-first feed', () {
      final base = DateTime(2026, 1, 1);
      final bundle = build(
        encounters: [encounter('enc-old', base)],
        results: [labResult('Hb', base.add(const Duration(days: 2)))],
        documents: [
          scannedDocument('lab_report', base.add(const Duration(days: 1))),
        ],
      );

      expect(bundle.entries, hasLength(3));
      expect(bundle.entries.map((e) => e.kind), [
        TimelineEntryKind.labResult,
        TimelineEntryKind.document,
        TimelineEntryKind.encounter,
      ], reason: 'newest first across all three stores');
    });

    test('keeps every record type, not just encounters', () {
      final base = DateTime(2026, 1, 1);
      final bundle = build(
        encounters: [encounter('enc-1', base)],
        results: [labResult('Hb', base)],
        documents: [scannedDocument('note', base)],
        interventions: [_procedure(performedAt: base)],
      );

      expect(bundle.entries, hasLength(4));
      expect(bundle.entries.map((e) => e.kind).toSet(), {
        TimelineEntryKind.encounter,
        TimelineEntryKind.labResult,
        TimelineEntryKind.document,
        TimelineEntryKind.procedure,
      });
    });

    test('attaches prescriptions to the encounter that ordered them', () {
      final base = DateTime(2026, 1, 1);
      final bundle = build(
        encounters: [encounter('enc-1', base)],
        prescriptions: [
          PrescriptionOrder(
            id: 'rx-1',
            patientId: 'patient-1',
            encounterId: 'enc-1',
            drugName: 'Ceftriaxone',
            doseStrength: '1 g',
            route: 'IV',
            frequency: 'OD',
            isActive: true,
            orderedAt: base,
          ),
        ],
      );

      final encounterEntry = bundle.entries.firstWhere(
        (e) => e.kind == TimelineEntryKind.encounter,
      );
      expect(encounterEntry.prescriptions.single.drugName, 'Ceftriaxone');
    });

    test('groups consecutive same-day entries under one day key', () {
      final bundle = build(
        results: [
          labResult('Hb', DateTime(2026, 1, 5, 9)),
          labResult('TLC', DateTime(2026, 1, 5, 11)),
          labResult('RBC', DateTime(2026, 1, 4, 9)),
        ],
      );

      final days = [
        for (final entry in bundle.entries)
          PatientTimelineBuilder.dayKeys([entry]).single,
      ];
      expect(days.first, days[1], reason: 'same calendar day shares a header');
      expect(days.last.isBefore(days.first), isTrue);
      expect(bundle.entries.first.kind, TimelineEntryKind.labResult);
    });
  });

  group('PatientAlertEngine', () {
    ClinicalEncounter encounterWithHistory(
      String? allergy, {
      int? sbp,
      int? pulse,
    }) {
      return ClinicalEncounter(
        id: 'enc-1',
        ownerId: 'tester',
        patientId: 'patient-1',
        encounterType: 'OPD',
        careSetting: 'OPD',
        occurredAt: DateTime(2026, 1, 1),
        pediatricHistory: const {},
        obGynHistory: const {},
        dynamicData: const {},
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        drugAndAllergyHistory: allergy,
        sbp: sbp,
        pulse: pulse,
      );
    }

    test('raises an allergy banner when allergy history is recorded', () {
      final alerts = PatientAlertEngine.fromEncounters([
        encounterWithHistory('Known allergy: Penicillin — rash'),
      ]);

      expect(alerts, hasLength(1));
      expect(alerts.single.title, 'Allergy on record');
      expect(alerts.single.description.toLowerCase(), contains('penicillin'));
    });

    test('does not invent an allergy from ordinary history text', () {
      final alerts = PatientAlertEngine.fromEncounters([
        encounterWithHistory('Hypertension, diabetes, on metformin'),
      ]);

      expect(alerts, isEmpty);
    });

    test('de-duplicates the same allergy across encounters', () {
      final alerts = PatientAlertEngine.fromEncounters([
        encounterWithHistory('Known allergy: Penicillin'),
        encounterWithHistory('Known allergy: Penicillin'),
      ]);

      expect(alerts, hasLength(1));
    });

    test('vitals alerts come from the deterministic CDSS engine', () {
      // pulse 120 / sbp 90 => shock index 1.33
      final alerts = DecisionSupportEngine.evaluateVitals(90, 120, 98);

      expect(alerts, isNotEmpty);
      expect(
        alerts.any((a) => a.description.toLowerCase().contains('shock')),
        isTrue,
      );
    });
  });
}
