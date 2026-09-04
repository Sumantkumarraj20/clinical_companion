// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_extraction_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiLocation _$AiLocationFromJson(Map<String, dynamic> json) => _AiLocation(
  type: json['type'] as String?,
  department: json['department'] as String?,
  wardName: json['ward_name'] as String?,
  bedNumber: json['bed_number'] as String?,
);

Map<String, dynamic> _$AiLocationToJson(_AiLocation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'department': instance.department,
      'ward_name': instance.wardName,
      'bed_number': instance.bedNumber,
    };

_AiVitals _$AiVitalsFromJson(Map<String, dynamic> json) => _AiVitals(
  sbp: (json['sbp'] as num?)?.toInt(),
  dbp: (json['dbp'] as num?)?.toInt(),
  pr: (json['pr'] as num?)?.toInt(),
  temperatureC: (json['temp'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AiVitalsToJson(_AiVitals instance) => <String, dynamic>{
  'sbp': instance.sbp,
  'dbp': instance.dbp,
  'pr': instance.pr,
  'temp': instance.temperatureC,
};

_AiExtractionResult _$AiExtractionResultFromJson(Map<String, dynamic> json) =>
    _AiExtractionResult(
      patientIdentifier: json['patient_identifier'] as String?,
      location: AiLocation.fromJson(json['location'] as Map<String, dynamic>),
      documentType: json['document_type'] as String,
      vitalsExtracted: AiVitals.fromJson(
        json['vitals_extracted'] as Map<String, dynamic>,
      ),
      clinicalSummary: json['clinical_summary'] as String,
      rawText: json['raw_text'] as String,
      identifiedProblems:
          (json['identified_problems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      medicationsMentioned:
          (json['medications_mentioned'] as List<dynamic>?)
              ?.map((e) => AiMedication.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AiMedication>[],
    );

Map<String, dynamic> _$AiExtractionResultToJson(_AiExtractionResult instance) =>
    <String, dynamic>{
      'patient_identifier': instance.patientIdentifier,
      'location': instance.location,
      'document_type': instance.documentType,
      'vitals_extracted': instance.vitalsExtracted,
      'clinical_summary': instance.clinicalSummary,
      'raw_text': instance.rawText,
      'identified_problems': instance.identifiedProblems,
      'medications_mentioned': instance.medicationsMentioned,
    };

_AiMedication _$AiMedicationFromJson(Map<String, dynamic> json) =>
    _AiMedication(
      brand: json['brand'] as String?,
      generic: json['generic'] as String?,
      dose: json['dose'] as String?,
    );

Map<String, dynamic> _$AiMedicationToJson(_AiMedication instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'generic': instance.generic,
      'dose': instance.dose,
    };
