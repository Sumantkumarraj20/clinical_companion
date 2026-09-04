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
    int? pr,
    @JsonKey(name: 'temp') double? temperatureC,
  }) = _AiVitals;

  factory AiVitals.fromJson(Map<String, dynamic> json) =>
      _$AiVitalsFromJson(json);
}

@freezed
sealed class AiExtractionResult with _$AiExtractionResult {
  const factory AiExtractionResult({
    @JsonKey(name: 'patient_identifier') String? patientIdentifier,
    required AiLocation location,
    @JsonKey(name: 'document_type') required String documentType,
    @JsonKey(name: 'vitals_extracted') required AiVitals vitalsExtracted,
    @JsonKey(name: 'clinical_summary') required String clinicalSummary,
    @JsonKey(name: 'raw_text') required String rawText,
    @JsonKey(name: 'identified_problems')
    @Default(<String>[])
    List<String> identifiedProblems,
    @JsonKey(name: 'medications_mentioned')
    @Default(<AiMedication>[])
    List<AiMedication> medicationsMentioned,
  }) = _AiExtractionResult;

  factory AiExtractionResult.fromJson(Map<String, dynamic> json) =>
      _$AiExtractionResultFromJson(json);
}

@freezed
sealed class AiMedication with _$AiMedication {
  const factory AiMedication({String? brand, String? generic, String? dose}) =
      _AiMedication;

  factory AiMedication.fromJson(Map<String, dynamic> json) =>
      _$AiMedicationFromJson(json);
}
