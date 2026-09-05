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
  pr: (json['pulse'] as num?)?.toInt(),
  temperatureC: (json['temp_f'] as num?)?.toDouble(),
  spo2: (json['spo2'] as num?)?.toInt(),
);

Map<String, dynamic> _$AiVitalsToJson(_AiVitals instance) => <String, dynamic>{
  'sbp': instance.sbp,
  'dbp': instance.dbp,
  'pulse': instance.pr,
  'temp_f': instance.temperatureC,
  'spo2': instance.spo2,
};

_AiExtractionResult _$AiExtractionResultFromJson(Map<String, dynamic> json) =>
    _AiExtractionResult(
      patientIdentity: json['patient_identity'] == null
          ? const PatientIdentity()
          : PatientIdentity.fromJson(
              json['patient_identity'] as Map<String, dynamic>,
            ),
      encounterContext: json['encounter_context'] == null
          ? const EncounterContext()
          : EncounterContext.fromJson(
              json['encounter_context'] as Map<String, dynamic>,
            ),
      vitals: json['vitals'] == null
          ? const AiVitals()
          : AiVitals.fromJson(json['vitals'] as Map<String, dynamic>),
      medicationsOrdered:
          (json['medications_ordered'] as List<dynamic>?)
              ?.map(
                (e) => OrderedMedication.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <OrderedMedication>[],
      labResults:
          (json['lab_results'] as List<dynamic>?)
              ?.map((e) => AiLabResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AiLabResult>[],
      clinicalSummary: json['clinicalSummary'] as String? ?? '',
    );

Map<String, dynamic> _$AiExtractionResultToJson(_AiExtractionResult instance) =>
    <String, dynamic>{
      'patient_identity': instance.patientIdentity,
      'encounter_context': instance.encounterContext,
      'vitals': instance.vitals,
      'medications_ordered': instance.medicationsOrdered,
      'lab_results': instance.labResults,
      'clinicalSummary': instance.clinicalSummary,
    };

_PatientIdentity _$PatientIdentityFromJson(Map<String, dynamic> json) =>
    _PatientIdentity(
      name: json['name'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      hospitalRegNo: json['hospital_reg_no'] as String?,
    );

Map<String, dynamic> _$PatientIdentityToJson(_PatientIdentity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'hospital_reg_no': instance.hospitalRegNo,
    };

_EncounterContext _$EncounterContextFromJson(Map<String, dynamic> json) =>
    _EncounterContext(
      documentType: json['document_type'] as String? ?? '',
      date: json['date'] as String?,
      department: json['department'] as String?,
      wardBed: json['ward_bed'] as String?,
    );

Map<String, dynamic> _$EncounterContextToJson(_EncounterContext instance) =>
    <String, dynamic>{
      'document_type': instance.documentType,
      'date': instance.date,
      'department': instance.department,
      'ward_bed': instance.wardBed,
    };

_OrderedMedication _$OrderedMedicationFromJson(Map<String, dynamic> json) =>
    _OrderedMedication(
      drugName: json['drug_name'] as String? ?? '',
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
    );

Map<String, dynamic> _$OrderedMedicationToJson(_OrderedMedication instance) =>
    <String, dynamic>{
      'drug_name': instance.drugName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
    };

_AiLabResult _$AiLabResultFromJson(Map<String, dynamic> json) => _AiLabResult(
  testName: json['test_name'] as String? ?? '',
  value: json['value'] as String? ?? '',
  unit: json['unit'] as String?,
  isAbnormal: json['is_abnormal'] as bool? ?? false,
);

Map<String, dynamic> _$AiLabResultToJson(_AiLabResult instance) =>
    <String, dynamic>{
      'test_name': instance.testName,
      'value': instance.value,
      'unit': instance.unit,
      'is_abnormal': instance.isAbnormal,
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
