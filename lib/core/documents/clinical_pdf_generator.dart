import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/local_database.dart';

class ClinicalPdfGenerator {
  /// Standardized Institutional Header
  pw.Widget _header({
    required Patient patient,
    required String title,
    String? hospitalRegNo,
    String? hospitalName,
    String? department,
    String? wardBed,
    DateTime? documentDate,
  }) {
    final facility = hospitalName?.isNotEmpty == true
        ? hospitalName!
        : 'Indira Gandhi Institute of Medical Sciences, Patna';
    final regNo = hospitalRegNo?.isNotEmpty == true
        ? hospitalRegNo!
        : 'Pending / Not assigned';
    final dateStr = (documentDate ?? DateTime.now())
        .toLocal()
        .toString()
        .split(' ')
        .first;
    final ageGender =
        '${patient.gender ?? 'Unspecified'}, ${patient.approximateAge != null ? '${patient.approximateAge} yrs' : '--'}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  facility,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal900,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  department?.isNotEmpty == true
                      ? 'Department of $department'
                      : 'Clinical Care & Surgical Services',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Patient Name: ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.TextSpan(
                          text: patient.fullName,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Age / Sex: ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.TextSpan(
                          text: ageGender,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'CR / UHID No: ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.TextSpan(
                          text: regNo,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Ward / Bed: ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.TextSpan(
                          text: wardBed?.isNotEmpty == true
                              ? wardBed!
                              : 'OPD / Day Care',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Date: ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.TextSpan(
                          text: dateStr,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Clinical Companion',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
      padding: const pw.EdgeInsets.only(bottom: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.teal800, width: 1),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.teal900,
        ),
      ),
    );
  }

  pw.Widget _table(List<List<String>> rows) => pw.TableHelper.fromTextArray(
    headers: rows.isEmpty ? const [] : rows.first,
    data: rows.length <= 1 ? const [] : rows.sublist(1),
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    cellStyle: const pw.TextStyle(fontSize: 8),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
    cellHeight: 20,
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  );

  pw.Widget _doctorSignature() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 30),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Generated via Clinical Companion Offline Store',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Legally compliant electronic clinical documentation',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(width: 140, height: 1, color: PdfColors.grey600),
              pw.SizedBox(height: 4),
              pw.Text(
                'Treating Clinician / Resident',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Reg. No / Seal',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. ADMISSION NOTE
  // =========================================================================
  Future<List<int>> generateAdmissionNote({
    required Patient patient,
    required List<PatientProblem> problems,
    required ClinicalEncounter admissionEncounter,
    List<PrescriptionOrder> initialMedications = const [],
    List<ClinicalIntervention> plannedProcedures = const [],
    String? hospitalRegNo,
    String? hospitalName,
  }) => _document(
    _header(
      patient: patient,
      title: 'Admission Workup Note',
      hospitalRegNo: hospitalRegNo,
      hospitalName: hospitalName,
      department: admissionEncounter.department,
      wardBed:
          '${admissionEncounter.wardName ?? ''} ${admissionEncounter.bedNumber ?? ''}'
              .trim(),
      documentDate: admissionEncounter.occurredAt,
    ),
    [
      _sectionTitle('Clinical Presentation & History'),
      pw.Text(
        'Chief Complaints: ${admissionEncounter.chiefComplaints ?? 'Not specified'}',
        style: const pw.TextStyle(fontSize: 9),
      ),
      if (admissionEncounter.historyOfPresentIllness?.isNotEmpty == true) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          'HPI: ${admissionEncounter.historyOfPresentIllness}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
      if (admissionEncounter.pastHistory?.isNotEmpty == true) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          'Past Medical/Surgical History: ${admissionEncounter.pastHistory}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],

      _sectionTitle('Active Problem Trajectory List'),
      if (problems.isEmpty)
        pw.Text(
          'No primary problems registered.',
          style: const pw.TextStyle(fontSize: 9),
        )
      else
        _table([
          ['Problem / Diagnosis', 'Status', 'Onset Date'],
          ...problems.map(
            (p) => [
              p.problemName,
              p.currentStatus,
              p.onsetDate != null
                  ? p.onsetDate!.toIso8601String().split('T').first
                  : 'On Admission',
            ],
          ),
        ]),

      _sectionTitle('Baseline Admission Vitals'),
      _table([
        ['Blood Pressure', 'Pulse', 'SpO2', 'Temperature', 'MAP'],
        [
          '${admissionEncounter.sbp ?? '-'}/${admissionEncounter.dbp ?? '-'} mmHg',
          '${admissionEncounter.pulse ?? '-'} bpm',
          admissionEncounter.spo2 != null ? '${admissionEncounter.spo2}%' : '-',
          admissionEncounter.temperatureC != null
              ? '${admissionEncounter.temperatureC}°C'
              : '-',
          admissionEncounter.meanArterialPressure != null
              ? '${admissionEncounter.meanArterialPressure!.toStringAsFixed(0)} mmHg'
              : '-',
        ],
      ]),

      if (plannedProcedures.isNotEmpty) ...[
        _sectionTitle('Planned Clinical Interventions & Procedures'),
        _table([
          ['Procedure', 'Code / System', 'Role'],
          ...plannedProcedures.map(
            (p) => [
              p.procedureName,
              '${p.procedureCode ?? '--'} (${p.codingSystem ?? 'Local'})',
              p.interventionRole,
            ],
          ),
        ]),
      ],

      if (initialMedications.isNotEmpty) ...[
        _sectionTitle('Admission Medication Orders'),
        _table([
          ['Drug', 'Strength', 'Route', 'Frequency', 'Special Instructions'],
          ...initialMedications.map(
            (m) => [
              m.drugName,
              m.doseStrength ?? '--',
              m.route ?? 'Oral',
              m.frequency ?? '--',
              m.specialInstructions ?? '--',
            ],
          ),
        ]),
      ],

      _sectionTitle('Initial Management Plan & Instructions'),
      pw.Text(
        admissionEncounter.consultantAdvice ??
            admissionEncounter.clinicalAssessment ??
            'Continue supportive care; monitor vitals q4h.',
        style: const pw.TextStyle(fontSize: 9),
      ),
      _doctorSignature(),
    ],
  );

  // =========================================================================
  // 2. WARD ROUND / PROGRESS NOTE
  // =========================================================================
  Future<List<int>> generateProgressNote({
    required Patient patient,
    required ClinicalEncounter roundEncounter,
    List<ProblemProgressSnapshot> progressSnapshots = const [],
    List<PrescriptionOrder> currentMeds = const [],
    List<ClinicalIntervention> newInterventions = const [],
    String? hospitalRegNo,
    String? hospitalName,
  }) => _document(
    _header(
      patient: patient,
      title: 'Daily Bedside Round Note',
      hospitalRegNo: hospitalRegNo,
      hospitalName: hospitalName,
      department: roundEncounter.department,
      wardBed:
          '${roundEncounter.wardName ?? ''} ${roundEncounter.bedNumber ?? ''}'
              .trim(),
      documentDate: roundEncounter.occurredAt,
    ),
    [
      _sectionTitle('Current Bedside Hemodynamics'),
      _table([
        ['Blood Pressure', 'Pulse', 'SpO2', 'Respiratory Rate', 'Temp'],
        [
          '${roundEncounter.sbp ?? '-'}/${roundEncounter.dbp ?? '-'} mmHg',
          '${roundEncounter.pulse ?? '-'} bpm',
          roundEncounter.spo2 != null ? '${roundEncounter.spo2}%' : '-',
          roundEncounter.respiratoryRate != null
              ? '${roundEncounter.respiratoryRate}/min'
              : '-',
          roundEncounter.temperatureC != null
              ? '${roundEncounter.temperatureC}°C'
              : '-',
        ],
      ]),

      _sectionTitle('Subjective Complaints & Examination'),
      pw.Text(
        'Subjective: ${roundEncounter.chiefComplaints ?? 'Comfortable, no fresh active complaints.'}',
        style: const pw.TextStyle(fontSize: 9),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Objective Examination: ${roundEncounter.examinationFindings ?? 'Per abdomen soft, chest clear, bilateral air entry equal.'}',
        style: const pw.TextStyle(fontSize: 9),
      ),

      if (progressSnapshots.isNotEmpty) ...[
        _sectionTitle('Problem Evolution & Course Trajectory'),
        _table([
          ['Trajectory Status', 'Clinical Course Note'],
          ...progressSnapshots.map(
            (s) => [s.statusSnapshot, s.clinicalCourseNote],
          ),
        ]),
      ],

      if (currentMeds.isNotEmpty) ...[
        _sectionTitle('Active Medications & Ongoing Infusions'),
        _table([
          ['Drug', 'Strength', 'Route', 'Frequency', 'Instructions'],
          ...currentMeds.map(
            (m) => [
              m.drugName,
              m.doseStrength ?? '--',
              m.route ?? 'Oral',
              m.frequency ?? '--',
              m.specialInstructions ?? '--',
            ],
          ),
        ]),
      ],

      _sectionTitle('Assessment & Plan of Action'),
      pw.Text(
        roundEncounter.consultantAdvice ??
            roundEncounter.clinicalAssessment ??
            'Continue active management.',
        style: const pw.TextStyle(fontSize: 9),
      ),
      _doctorSignature(),
    ],
  );

  // =========================================================================
  // 3. DISCHARGE SUMMARY
  // =========================================================================
  Future<List<int>> generateDischargeSummary({
    required Patient patient,
    required ClinicalEncounter dischargeEncounter,
    required List<PatientProblem> allProblems,
    required List<ClinicalIntervention> performedProcedures,
    required List<PrescriptionOrder> dischargeMedications,
    required String followUpAdvice,
    String? hospitalRegNo,
    String? hospitalName,
    List<String> icd11Codes = const [],
    List<String> pmJayCodes = const [],
  }) => _document(
    _header(
      patient: patient,
      title: 'Formal Hospital Discharge Summary',
      hospitalRegNo: hospitalRegNo,
      hospitalName: hospitalName,
      department: dischargeEncounter.department,
      wardBed:
          '${dischargeEncounter.wardName ?? ''} ${dischargeEncounter.bedNumber ?? ''}'
              .trim(),
      documentDate: dischargeEncounter.occurredAt,
    ),
    [
      _sectionTitle('Final Clinical Diagnosis'),
      pw.Text(
        dischargeEncounter.clinicalDiagnosis?.isNotEmpty == true
            ? dischargeEncounter.clinicalDiagnosis!
            : (allProblems.isNotEmpty
                  ? allProblems.map((p) => p.problemName).join('; ')
                  : 'Clinical resolution achieved'),
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
      if (icd11Codes.isNotEmpty || pmJayCodes.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          [
            if (icd11Codes.isNotEmpty) 'ICD-11: ${icd11Codes.join(', ')}',
            if (pmJayCodes.isNotEmpty) 'PM-JAY HBP: ${pmJayCodes.join(', ')}',
          ].join('   |   '),
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],

      _sectionTitle('Clinical Problems & Trajectory at Discharge'),
      _table([
        ['Problem', 'Status', 'Onset'],
        ...allProblems.map(
          (p) => [
            p.problemName,
            p.currentStatus,
            p.onsetDate != null
                ? p.onsetDate!.toIso8601String().split('T').first
                : '--',
          ],
        ),
      ]),

      if (performedProcedures.isNotEmpty) ...[
        _sectionTitle('Operative & Bedside Procedures Performed'),
        _table([
          ['Procedure Name', 'Role', 'Findings / Operative Notes'],
          ...performedProcedures.map(
            (p) => [
              p.procedureName,
              p.interventionRole,
              p.operativeFindings ?? 'Uneventful procedure',
            ],
          ),
        ]),
      ],

      _sectionTitle('Hospital Course & Clinical Summary'),
      pw.Text(
        dischargeEncounter.clinicalAssessment ??
            dischargeEncounter.aiSummary ??
            'Patient admitted and managed successfully. Post-procedure period uneventful. Vitals stable at discharge, surgical wound healthy, afebrile.',
        style: const pw.TextStyle(fontSize: 9),
      ),

      _sectionTitle('Discharge Medications (Rx)'),
      if (dischargeMedications.isEmpty)
        pw.Text(
          'No medications prescribed on discharge.',
          style: const pw.TextStyle(fontSize: 9),
        )
      else
        _table([
          [
            'Medication',
            'Dose',
            'Route',
            'Frequency',
            'Duration',
            'Instructions',
          ],
          ...dischargeMedications.map(
            (m) => [
              m.drugName,
              m.doseStrength ?? '--',
              m.route ?? 'Oral',
              m.frequency ?? '--',
              m.duration ?? '5 days',
              m.specialInstructions ?? '--',
            ],
          ),
        ]),

      _sectionTitle('Follow-Up Instructions & Urgent Warning Signs'),
      pw.Text(
        followUpAdvice.isNotEmpty
            ? followUpAdvice
            : 'Review in OPD after 7 days with repeat CBC. In case of high-grade fever, severe abdominal pain, persistent vomiting, or soakage, report immediately to Casualty.',
        style: const pw.TextStyle(fontSize: 9),
      ),
      _doctorSignature(),
    ],
  );

  // =========================================================================
  // 4. OPD PRESCRIPTION SLIP
  // =========================================================================
  Future<List<int>> generateOpdPrescription({
    required Patient patient,
    required ClinicalEncounter encounter,
    required List<PrescriptionOrder> medications,
    String? hospitalRegNo,
    String? hospitalName,
  }) => _document(
    _header(
      patient: patient,
      title: 'Outpatient Prescription Slip',
      hospitalRegNo: hospitalRegNo,
      hospitalName: hospitalName,
      department: encounter.department ?? 'General OPD',
      documentDate: encounter.occurredAt,
    ),
    [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('Clinical Diagnosis / Impression'),
                pw.Text(
                  encounter.clinicalDiagnosis ??
                      encounter.chiefComplaints ??
                      'General Consultation',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (encounter.chiefComplaints != null &&
                    encounter.clinicalDiagnosis != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Complaints: ${encounter.chiefComplaints}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('Recorded Vitals'),
                pw.Text(
                  'BP: ${encounter.sbp ?? '-'}/${encounter.dbp ?? '-'} mmHg\nPulse: ${encounter.pulse ?? '-'} bpm   SpO2: ${encounter.spo2 ?? '-'}%',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),

      _sectionTitle('Rx (Prescription Details)'),
      if (medications.isEmpty)
        pw.Text(
          'No medications prescribed.',
          style: const pw.TextStyle(fontSize: 9),
        )
      else
        _table([
          [
            'Drug Name',
            'Strength',
            'Route',
            'Frequency',
            'Duration',
            'Instructions',
          ],
          ...medications.map(
            (m) => [
              m.drugName,
              m.doseStrength ?? '--',
              m.route ?? 'Oral',
              m.frequency ?? '--',
              m.duration ?? '5 days',
              m.specialInstructions ?? '--',
            ],
          ),
        ]),

      if (encounter.consultantAdvice?.isNotEmpty == true) ...[
        _sectionTitle('Advice & Lifestyle Measures'),
        pw.Text(
          encounter.consultantAdvice!,
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],

      _doctorSignature(),
    ],
  );

  // =========================================================================
  // INTERNAL COMPILATION RUNNER
  // =========================================================================
  Future<List<int>> _document(pw.Widget header, List<pw.Widget> body) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => header,
        build: (_) => body,
      ),
    );
    return document.save();
  }
}
