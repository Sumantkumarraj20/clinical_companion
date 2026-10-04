import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_extraction_result.freezed.dart';
part 'ai_extraction_result.g.dart';

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
  }) = _AiExtractionResult;

  factory AiExtractionResult.fromJson(Map<String, dynamic> json) =>
      _$AiExtractionResultFromJson(json);

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
    @JsonKey(name: 'drug_name') @Default('') String drugName,
    String? dosage,
    String? frequency,
  }) = _OrderedMedication;

  factory OrderedMedication.fromJson(Map<String, dynamic> json) =>
      _$OrderedMedicationFromJson(json);
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
