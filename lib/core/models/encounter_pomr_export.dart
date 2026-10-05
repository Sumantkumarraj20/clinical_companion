import '../database/local_database.dart';

class EncounterPomrExport {
  const EncounterPomrExport({
    required this.encounter,
    required this.problems,
    required this.unlinkedPrescriptions,
    required this.unlinkedInvestigations,
    required this.unlinkedInterventions,
  });

  final ClinicalEncounter encounter;
  final List<EncounterProblemSection> problems;
  final List<PrescriptionOrder> unlinkedPrescriptions;
  final List<EncounterInvestigation> unlinkedInvestigations;
  final List<ClinicalIntervention> unlinkedInterventions;

  String toPlainText({required Patient patient}) {
    final buffer = StringBuffer()
      ..writeln('CLINICAL NOTE')
      ..writeln('Patient: ${patient.fullName}')
      ..writeln('Encounter: ${encounter.occurredAt.toLocal()}')
      ..writeln()
      ..writeln('VITALS')
      ..writeln(_vitalsText(encounter));

    _writeSection(buffer, 'Complaints', encounter.chiefComplaints);
    _writeSection(buffer, 'History', encounter.historyOfPresentIllness);
    _writeSection(buffer, 'Findings', encounter.examinationFindings);
    _writeSection(buffer, 'Assessment', encounter.clinicalAssessment);
    _writeSection(buffer, 'Advice', encounter.consultantAdvice);

    for (final section in problems) {
      buffer
        ..writeln()
        ..writeln('PROBLEM: ${section.problem.problemName}');
      if (section.problem.icd11Code?.trim().isNotEmpty == true) {
        buffer.writeln('Code: ${section.problem.icd11Code}');
      }
      for (final order in section.prescriptions) {
        buffer.writeln(
          'Medication: ${order.drugName}'
          '${_optional(", ${order.doseStrength}", order.doseStrength)}'
          '${_optional(", ${order.dosageForm}", order.dosageForm)}'
          '${_optional(", ${order.route}", order.route)}'
          '${_optional(", ${order.frequency}", order.frequency)}'
          '${_optional(", ${order.duration}", order.duration)}'
          '${_optional(", ${order.diluentAndRate}", order.diluentAndRate)}'
          '${_optional(", Instructions: ${order.specialInstructions}", order.specialInstructions)}',
        );
      }
      for (final investigation in section.investigations) {
        buffer.writeln('Investigation: ${investigation.order.testName}');
        _writeSection(
          buffer,
          'Clinical indication',
          investigation.order.clinicalIndication,
        );
        for (final result in investigation.results) {
          buffer.writeln(
            '  Result: ${result.testName}: '
            '${result.numericValue ?? result.textValue ?? '--'}'
            '${_optional(" ${result.unit}", result.unit)}'
            '${result.isAbnormal ? ' (abnormal)' : ''}',
          );
        }
      }
      for (final intervention in section.interventions) {
        buffer.writeln(
          'Procedure: ${intervention.procedureName}'
          '${_optional(" - ${intervention.operativeFindings}", intervention.operativeFindings)}',
        );
      }
    }

    if (unlinkedPrescriptions.isNotEmpty ||
        unlinkedInvestigations.isNotEmpty ||
        unlinkedInterventions.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('UNLINKED MANAGEMENT');
      for (final order in unlinkedPrescriptions) {
        buffer.writeln(
          'Medication: ${order.drugName}'
          '${_optional(", ${order.doseStrength}", order.doseStrength)}'
          '${_optional(", ${order.route}", order.route)}'
          '${_optional(", ${order.frequency}", order.frequency)}'
          '${_optional(", Instructions: ${order.specialInstructions}", order.specialInstructions)}',
        );
      }
      for (final investigation in unlinkedInvestigations) {
        buffer.writeln('Investigation: ${investigation.order.testName}');
        _writeSection(
          buffer,
          'Clinical indication',
          investigation.order.clinicalIndication,
        );
        for (final result in investigation.results) {
          buffer.writeln(
            '  Result: ${result.testName}: '
            '${result.numericValue ?? result.textValue ?? '--'}'
            '${_optional(" ${result.unit}", result.unit)}'
            '${result.isAbnormal ? ' (abnormal)' : ''}',
          );
        }
      }
      for (final intervention in unlinkedInterventions) {
        buffer.writeln('Procedure: ${intervention.procedureName}');
      }
    }
    return buffer.toString().trim();
  }
}

class EncounterProblemSection {
  const EncounterProblemSection({
    required this.problem,
    required this.prescriptions,
    required this.investigations,
    required this.interventions,
  });

  final PatientProblem problem;
  final List<PrescriptionOrder> prescriptions;
  final List<EncounterInvestigation> investigations;
  final List<ClinicalIntervention> interventions;
}

class EncounterInvestigation {
  const EncounterInvestigation({required this.order, required this.results});

  final InvestigationOrder order;
  final List<InvestigationResult> results;
}

String _vitalsText(ClinicalEncounter encounter) {
  final values = <String>[
    if (encounter.sbp != null || encounter.dbp != null)
      'BP ${encounter.sbp ?? '--'}/${encounter.dbp ?? '--'} mmHg',
    if (encounter.pulse != null) 'Pulse ${encounter.pulse} bpm',
    if (encounter.temperatureC != null) 'Temp ${encounter.temperatureC} C',
    if (encounter.respiratoryRate != null)
      'RR ${encounter.respiratoryRate}/min',
    if (encounter.spo2 != null) 'SpO2 ${encounter.spo2}%',
    if (encounter.meanArterialPressure != null)
      'MAP ${encounter.meanArterialPressure} mmHg',
  ];
  return values.isEmpty ? 'Not recorded' : values.join(' | ');
}

void _writeSection(StringBuffer buffer, String title, String? value) {
  if (value?.trim().isNotEmpty == true) {
    buffer
      ..writeln()
      ..writeln(title.toUpperCase())
      ..writeln(value!.trim());
  }
}

String _optional(String formatted, String? value) =>
    value?.trim().isNotEmpty == true ? formatted : '';
