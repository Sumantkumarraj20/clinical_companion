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
  respiratoryRate: (json['respiratory_rate'] as num?)?.toInt(),
  meanArterialPressure: (json['map'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AiVitalsToJson(_AiVitals instance) => <String, dynamic>{
  'sbp': instance.sbp,
  'dbp': instance.dbp,
  'pulse': instance.pr,
  'temp_f': instance.temperatureC,
  'spo2': instance.spo2,
  'respiratory_rate': instance.respiratoryRate,
  'map': instance.meanArterialPressure,
};

_AiExtractionResult _$AiExtractionResultFromJson(
  Map<String, dynamic> json,
) => _AiExtractionResult(
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
          ?.map((e) => OrderedMedication.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderedMedication>[],
  labResults:
      (json['lab_results'] as List<dynamic>?)
          ?.map((e) => AiLabResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiLabResult>[],
  problems:
      (json['problems'] as List<dynamic>?)
          ?.map((e) => AiProblem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiProblem>[],
  unlinkedManagement: json['unlinked_management'] == null
      ? const AiUnlinkedManagement()
      : AiUnlinkedManagement.fromJson(
          json['unlinked_management'] as Map<String, dynamic>,
        ),
  clinicalWarnings:
      (json['clinical_warnings'] as List<dynamic>?)
          ?.map((e) => AiClinicalWarning.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiClinicalWarning>[],
  clinicalSummary: json['clinicalSummary'] as String? ?? '',
  conclusion: json['conclusion'] as String? ?? '',
  documentDate: json['document_date'] as String? ?? '',
  isDateAssumed: json['is_date_assumed'] as bool? ?? false,
  inferredPatientId: json['inferred_patient_id'] as String?,
  chiefComplaints:
      (json['chief_complaints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  diagnoses:
      (json['diagnoses'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  plannedInvestigations:
      (json['planned_investigations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  sourceAuthority: json['source_authority'] as String?,
);

Map<String, dynamic> _$AiExtractionResultToJson(_AiExtractionResult instance) =>
    <String, dynamic>{
      'patient_identity': instance.patientIdentity,
      'encounter_context': instance.encounterContext,
      'vitals': instance.vitals,
      'medications_ordered': instance.medicationsOrdered,
      'lab_results': instance.labResults,
      'problems': instance.problems,
      'unlinked_management': instance.unlinkedManagement,
      'clinical_warnings': instance.clinicalWarnings,
      'clinicalSummary': instance.clinicalSummary,
      'conclusion': instance.conclusion,
      'document_date': instance.documentDate,
      'is_date_assumed': instance.isDateAssumed,
      'inferred_patient_id': instance.inferredPatientId,
      'chief_complaints': instance.chiefComplaints,
      'diagnoses': instance.diagnoses,
      'planned_investigations': instance.plannedInvestigations,
      'source_authority': instance.sourceAuthority,
    };

_PatientIdentity _$PatientIdentityFromJson(Map<String, dynamic> json) =>
    _PatientIdentity(
      name: json['name'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      hospitalRegNo: json['hospital_reg_no'] as String?,
      hospitalId: json['hospital_id'] as String?,
    );

Map<String, dynamic> _$PatientIdentityToJson(_PatientIdentity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'hospital_reg_no': instance.hospitalRegNo,
      'hospital_id': instance.hospitalId,
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
      drugName: _readDrugName(json, 'drug_name') as String? ?? '',
      dosage: _readDosage(json, 'dosage') as String?,
      frequency: json['frequency'] as String?,
      route: json['route'] as String?,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$OrderedMedicationToJson(_OrderedMedication instance) =>
    <String, dynamic>{
      'drug_name': instance.drugName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'route': instance.route,
      'duration': instance.duration,
    };

_AiProblem _$AiProblemFromJson(Map<String, dynamic> json) => _AiProblem(
  diagnosis: json['diagnosis'] as String? ?? '',
  linkedMedications:
      (json['linked_medications'] as List<dynamic>?)
          ?.map((e) => OrderedMedication.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderedMedication>[],
  linkedInvestigations:
      (json['linked_investigations'] as List<dynamic>?)
          ?.map((e) => AiInvestigation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiInvestigation>[],
  linkedProcedures:
      (json['linked_procedures'] as List<dynamic>?)
          ?.map((e) => AiProcedure.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiProcedure>[],
  reasoning: json['reasoning'] as String? ?? '',
);

Map<String, dynamic> _$AiProblemToJson(_AiProblem instance) =>
    <String, dynamic>{
      'diagnosis': instance.diagnosis,
      'linked_medications': instance.linkedMedications,
      'linked_investigations': instance.linkedInvestigations,
      'linked_procedures': instance.linkedProcedures,
      'reasoning': instance.reasoning,
    };

_AiUnlinkedManagement _$AiUnlinkedManagementFromJson(
  Map<String, dynamic> json,
) => _AiUnlinkedManagement(
  medications:
      (json['medications'] as List<dynamic>?)
          ?.map((e) => OrderedMedication.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderedMedication>[],
  investigations:
      (json['investigations'] as List<dynamic>?)
          ?.map((e) => AiInvestigation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiInvestigation>[],
  procedures:
      (json['procedures'] as List<dynamic>?)
          ?.map((e) => AiProcedure.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiProcedure>[],
);

Map<String, dynamic> _$AiUnlinkedManagementToJson(
  _AiUnlinkedManagement instance,
) => <String, dynamic>{
  'medications': instance.medications,
  'investigations': instance.investigations,
  'procedures': instance.procedures,
};

_AiClinicalWarning _$AiClinicalWarningFromJson(Map<String, dynamic> json) =>
    _AiClinicalWarning(
      medication: json['medication'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      warning: json['warning'] as String? ?? '',
      doseAdjustment: json['dose_adjustment'] as String?,
    );

Map<String, dynamic> _$AiClinicalWarningToJson(_AiClinicalWarning instance) =>
    <String, dynamic>{
      'medication': instance.medication,
      'condition': instance.condition,
      'warning': instance.warning,
      'dose_adjustment': instance.doseAdjustment,
    };

_AiInvestigation _$AiInvestigationFromJson(Map<String, dynamic> json) =>
    _AiInvestigation(
      testName: json['test_name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      unit: json['unit'] as String?,
      isAbnormal: json['is_abnormal'] as bool? ?? false,
    );

Map<String, dynamic> _$AiInvestigationToJson(_AiInvestigation instance) =>
    <String, dynamic>{
      'test_name': instance.testName,
      'value': instance.value,
      'unit': instance.unit,
      'is_abnormal': instance.isAbnormal,
    };

_AiProcedure _$AiProcedureFromJson(Map<String, dynamic> json) =>
    _AiProcedure(procedureName: json['procedure_name'] as String? ?? '');

Map<String, dynamic> _$AiProcedureToJson(_AiProcedure instance) =>
    <String, dynamic>{'procedure_name': instance.procedureName};

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
