import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_extraction_result.freezed.dart';
part 'ai_extraction_result.g.dart';

Object? _readDrugName(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['name'];

Object? _readDosage(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['dose'];

Map<String, dynamic> _normalizeUniversalExtraction(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  final demographics = json['inferredPatientDemographics'];
  if (demographics is Map) {
    normalized['patient_identity'] = <String, dynamic>{
      ...demographics,
      'hospital_reg_no': demographics['mrn'] ?? demographics['hospital_reg_no'],
    };
  }

  final details = json['encounterDetails'];
  if (details is Map) {
    normalized['encounter_context'] = <String, dynamic>{
      'document_type':
          details['type'] ?? details['document_type'] ?? 'Clinical Note',
      'date': details['date'],
      'department': details['department'],
      'ward_bed': details['ward_bed'],
    };
    final vitals = details['vitals'];
    if (vitals is Map) {
      normalized['vitals'] = <String, dynamic>{
        ...vitals,
        'pulse': vitals['pulse'] ?? vitals['pr'],
        'temp_f':
            vitals['temperature_c'] ?? vitals['temp_c'] ?? vitals['temp_f'],
      };
    }
  }

  final pomrData = json['pomr_data'];
  if (pomrData is List) {
    normalized['problems'] = pomrData;
  } else if (pomrData is Map && pomrData['problems'] is List) {
    normalized['problems'] = pomrData['problems'];
  }
  final unlinkedData = json['unlinked_data'];
  if (unlinkedData is Map) {
    normalized['unlinked_management'] = unlinkedData;
  }
  return normalized;
}

@freezed
sealed class AiLocation with _$AiLocation {
  const factory AiLocation({
    String? type,
    String? department,
    @JsonKey(name: 'ward_name') String? wardName,
    @JsonKey(name: 'bed_number') String? bedNumber,
  }) = _AiLocation;

  factory AiLocation.fromJson(Map<String, dynamic> json) =>
      _$AiLocationFromJson(json);
}

@freezed
sealed class AiVitals with _$AiVitals {
  const factory AiVitals({
    int? sbp,
    int? dbp,
    @JsonKey(name: 'pulse') int? pr,
    @JsonKey(name: 'temp_f') double? temperatureC,
    int? spo2,
    @JsonKey(name: 'respiratory_rate') int? respiratoryRate,
    @JsonKey(name: 'map') double? meanArterialPressure,
  }) = _AiVitals;

  factory AiVitals.fromJson(Map<String, dynamic> json) =>
      _$AiVitalsFromJson(json);
}

@freezed
sealed class AiExtractionResult with _$AiExtractionResult {
  const AiExtractionResult._();

  const factory AiExtractionResult({
    @JsonKey(name: 'patient_identity')
    @Default(PatientIdentity())
    PatientIdentity patientIdentity,
    @JsonKey(name: 'encounter_context')
    @Default(EncounterContext())
    EncounterContext encounterContext,
    @Default(AiVitals()) AiVitals vitals,
    @JsonKey(name: 'medications_ordered')
    @Default(<OrderedMedication>[])
    List<OrderedMedication> medicationsOrdered,
    @JsonKey(name: 'lab_results')
    @Default(<AiLabResult>[])
    List<AiLabResult> labResults,
    @Default(<AiProblem>[]) List<AiProblem> problems,
    @JsonKey(name: 'unlinked_management')
    @Default(AiUnlinkedManagement())
    AiUnlinkedManagement unlinkedManagement,
    @JsonKey(name: 'clinical_warnings')
    @Default(<AiClinicalWarning>[])
    List<AiClinicalWarning> clinicalWarnings,
    @Default('') String clinicalSummary,

    /// Verbatim narrative conclusion from the document — the "Conclusion",
    /// "Impression", "Final Remarks" or "Advice" block that pathology,
    /// radiology and discharge summaries carry at the foot of the page.
    ///
    /// This is kept separate from [clinicalSummary] because it is the part a
    /// pathologist or radiologist *wrote* for the clinician to read, and losing
    /// it is the single most damaging way OCR can truncate a report: every
    /// numeric value survives but the interpretation does not. Storing it apart
    /// also keeps it editable in review instead of being flattened into prose.
    @JsonKey(name: 'conclusion') @Default('') String conclusion,

    // ---- Sprint 17: the ClinCom semantic layer -----------------------------
    // These are emitted by the model and parsed here so the review screen can
    // render them. They default to empty so a document saved before Sprint 17
    // (or a page where ClinCom found nothing) still parses cleanly.

    /// The date the document was WRITTEN (ISO-8601), never today's date.
    /// ClinCom is instructed never to substitute the current date, so a
    /// back-dated report keeps its true clinical date.
    @JsonKey(name: 'document_date') @Default('') String documentDate,

    /// True when [documentDate] was inferred rather than read off the page.
    @JsonKey(name: 'is_date_assumed') @Default(false) bool isDateAssumed,

    /// Patient resolved from a bed/ward number via the appended active census
    /// JSON. Null when the page carried no bed number or the bed was ambiguous
    /// — ClinCom is explicitly forbidden from guessing a patient.
    @JsonKey(name: 'inferred_patient_id') String? inferredPatientId,

    @JsonKey(name: 'chief_complaints')
    @Default(<String>[])
    List<String> chiefComplaints,

    @JsonKey(name: 'diagnoses') @Default(<String>[]) List<String> diagnoses,

    @JsonKey(name: 'planned_investigations')
    @Default(<String>[])
    List<String> plannedInvestigations,

    /// Provenance of this reading. Drives Sprint 17 semantic merging: a
    /// formal 'Scanned Document' report outranks a 'Ward Round Note'.
    @JsonKey(name: 'source_authority') String? sourceAuthority,
  }) = _AiExtractionResult;

  /// True when this page carries any of the optional semantic sections, so the
  /// review screen can render a section only when the document actually has it
  /// (no empty Medications card on a bare prescription).
  bool get hasClinicalNarrative =>
      chiefComplaints.isNotEmpty ||
      diagnoses.isNotEmpty ||
      plannedInvestigations.isNotEmpty;

  factory AiExtractionResult.fromJson(Map<String, dynamic> json) =>
      _$AiExtractionResultFromJson(_normalizeUniversalExtraction(json));

  String? get patientIdentifier => patientIdentity.name;

  AiLocation get location => AiLocation(
    type: encounterContext.documentType,
    department: encounterContext.department,
    wardName: encounterContext.wardBed,
  );

  String get documentType => encounterContext.documentType;
  AiVitals get vitalsExtracted => vitals;
  String get rawText => '';
  List<String> get identifiedProblems => const [];

  List<AiMedication> get medicationsMentioned => medicationsOrdered
      .map((item) => AiMedication(generic: item.drugName, dose: item.dosage))
      .toList(growable: false);
}

@freezed
sealed class PatientIdentity with _$PatientIdentity {
  const factory PatientIdentity({
    String? name,
    int? age,
    String? gender,
    @JsonKey(name: 'hospital_reg_no') String? hospitalRegNo,

    /// Sprint 15 — the facility this document was captured at.
    ///
    /// Needed because a clinician covering several institutions can scan a
    /// report at hospital B for a patient whose identity record lives at
    /// hospital A. Without this the encounter and its observations are filed
    /// against whichever facility happened to be listed first, silently
    /// corrupting multi-hospital tracking.
    @JsonKey(name: 'hospital_id') String? hospitalId,
  }) = _PatientIdentity;

  factory PatientIdentity.fromJson(Map<String, dynamic> json) =>
      _$PatientIdentityFromJson(json);
}

@freezed
sealed class EncounterContext with _$EncounterContext {
  const factory EncounterContext({
    @JsonKey(name: 'document_type') @Default('') String documentType,
    String? date,
    String? department,
    @JsonKey(name: 'ward_bed') String? wardBed,
  }) = _EncounterContext;

  factory EncounterContext.fromJson(Map<String, dynamic> json) =>
      _$EncounterContextFromJson(json);
}

@freezed
sealed class OrderedMedication with _$OrderedMedication {
  const factory OrderedMedication({
    @JsonKey(name: 'drug_name', readValue: _readDrugName)
    @Default('')
    String drugName,
    @JsonKey(readValue: _readDosage) String? dosage,
    String? frequency,
    String? route,
    String? duration,
  }) = _OrderedMedication;

  factory OrderedMedication.fromJson(Map<String, dynamic> json) =>
      _$OrderedMedicationFromJson(json);
}

@freezed
sealed class AiProblem with _$AiProblem {
  const factory AiProblem({
    @Default('') String diagnosis,
    @JsonKey(name: 'linked_medications')
    @Default(<OrderedMedication>[])
    List<OrderedMedication> linkedMedications,
    @JsonKey(name: 'linked_investigations')
    @Default(<AiInvestigation>[])
    List<AiInvestigation> linkedInvestigations,
    @JsonKey(name: 'linked_procedures')
    @Default(<AiProcedure>[])
    List<AiProcedure> linkedProcedures,
    @Default('') String reasoning,
  }) = _AiProblem;

  factory AiProblem.fromJson(Map<String, dynamic> json) =>
      _$AiProblemFromJson(json);
}

@freezed
sealed class AiUnlinkedManagement with _$AiUnlinkedManagement {
  const factory AiUnlinkedManagement({
    @Default(<OrderedMedication>[]) List<OrderedMedication> medications,
    @Default(<AiInvestigation>[]) List<AiInvestigation> investigations,
    @Default(<AiProcedure>[]) List<AiProcedure> procedures,
  }) = _AiUnlinkedManagement;

  factory AiUnlinkedManagement.fromJson(Map<String, dynamic> json) =>
      _$AiUnlinkedManagementFromJson(json);
}

@freezed
sealed class AiClinicalWarning with _$AiClinicalWarning {
  const factory AiClinicalWarning({
    @JsonKey(name: 'medication') @Default('') String medication,
    @JsonKey(name: 'condition') @Default('') String condition,
    @JsonKey(name: 'warning') @Default('') String warning,
    @JsonKey(name: 'dose_adjustment') String? doseAdjustment,
  }) = _AiClinicalWarning;

  factory AiClinicalWarning.fromJson(Map<String, dynamic> json) =>
      _$AiClinicalWarningFromJson(json);
}

@freezed
sealed class AiInvestigation with _$AiInvestigation {
  const factory AiInvestigation({
    @JsonKey(name: 'test_name') @Default('') String testName,
    @Default('') String value,
    String? unit,
    @JsonKey(name: 'is_abnormal') @Default(false) bool isAbnormal,
  }) = _AiInvestigation;

  factory AiInvestigation.fromJson(Map<String, dynamic> json) =>
      _$AiInvestigationFromJson(json);
}

@freezed
sealed class AiProcedure with _$AiProcedure {
  const factory AiProcedure({
    @JsonKey(name: 'procedure_name') @Default('') String procedureName,
  }) = _AiProcedure;

  factory AiProcedure.fromJson(Map<String, dynamic> json) =>
      _$AiProcedureFromJson(json);
}

@freezed
sealed class AiLabResult with _$AiLabResult {
  const factory AiLabResult({
    @JsonKey(name: 'test_name') @Default('') String testName,
    @Default('') String value,
    String? unit,
    @JsonKey(name: 'is_abnormal') @Default(false) bool isAbnormal,
  }) = _AiLabResult;

  factory AiLabResult.fromJson(Map<String, dynamic> json) =>
      _$AiLabResultFromJson(json);
}

@freezed
sealed class AiMedication with _$AiMedication {
  const factory AiMedication({String? brand, String? generic, String? dose}) =
      _AiMedication;

  factory AiMedication.fromJson(Map<String, dynamic> json) =>
      _$AiMedicationFromJson(json);
}
