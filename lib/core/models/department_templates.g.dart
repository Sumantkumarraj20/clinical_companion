// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_templates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicineTemplate _$MedicineTemplateFromJson(Map<String, dynamic> json) =>
    _MedicineTemplate(
      systemicExamFindings:
          (json['systemicExamFindings'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      inputOutputChart:
          (json['inputOutputChart'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as num),
          ) ??
          const <String, num>{},
      assessment: json['assessment'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
    );

Map<String, dynamic> _$MedicineTemplateToJson(_MedicineTemplate instance) =>
    <String, dynamic>{
      'systemicExamFindings': instance.systemicExamFindings,
      'inputOutputChart': instance.inputOutputChart,
      'assessment': instance.assessment,
      'plan': instance.plan,
    };

_PediatricsTemplate _$PediatricsTemplateFromJson(Map<String, dynamic> json) =>
    _PediatricsTemplate(
      apgarOneMinute: (json['apgarOneMinute'] as num?)?.toInt() ?? 0,
      apgarFiveMinute: (json['apgarFiveMinute'] as num?)?.toInt() ?? 0,
      developmentalMilestones: json['developmentalMilestones'] as String? ?? '',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      dosingNotes: json['dosingNotes'] as String? ?? '',
    );

Map<String, dynamic> _$PediatricsTemplateToJson(_PediatricsTemplate instance) =>
    <String, dynamic>{
      'apgarOneMinute': instance.apgarOneMinute,
      'apgarFiveMinute': instance.apgarFiveMinute,
      'developmentalMilestones': instance.developmentalMilestones,
      'weightKg': instance.weightKg,
      'dosingNotes': instance.dosingNotes,
    };

_ObGynTemplate _$ObGynTemplateFromJson(Map<String, dynamic> json) =>
    _ObGynTemplate(
      gravida: (json['gravida'] as num?)?.toInt() ?? 0,
      para: (json['para'] as num?)?.toInt() ?? 0,
      abortions: (json['abortions'] as num?)?.toInt() ?? 0,
      living: (json['living'] as num?)?.toInt() ?? 0,
      fetalHeartRate: (json['fetalHeartRate'] as num?)?.toInt() ?? 0,
      bishopScore: (json['bishopScore'] as num?)?.toInt() ?? 0,
      gestationalAge: json['gestationalAge'] as String? ?? '',
      partographNotes: json['partographNotes'] as String? ?? '',
    );

Map<String, dynamic> _$ObGynTemplateToJson(_ObGynTemplate instance) =>
    <String, dynamic>{
      'gravida': instance.gravida,
      'para': instance.para,
      'abortions': instance.abortions,
      'living': instance.living,
      'fetalHeartRate': instance.fetalHeartRate,
      'bishopScore': instance.bishopScore,
      'gestationalAge': instance.gestationalAge,
      'partographNotes': instance.partographNotes,
    };

_SurgeryTemplate _$SurgeryTemplateFromJson(Map<String, dynamic> json) =>
    _SurgeryTemplate(
      woundStatus: json['woundStatus'] as String? ?? '',
      drainOutputMl: (json['drainOutputMl'] as num?)?.toDouble() ?? 0,
      postOpDay: (json['postOpDay'] as num?)?.toInt() ?? 0,
      procedureName: json['procedureName'] as String? ?? '',
      flapVascularity: json['flapVascularity'] as String? ?? '',
      operationNote: json['operationNote'] as String? ?? '',
    );

Map<String, dynamic> _$SurgeryTemplateToJson(_SurgeryTemplate instance) =>
    <String, dynamic>{
      'woundStatus': instance.woundStatus,
      'drainOutputMl': instance.drainOutputMl,
      'postOpDay': instance.postOpDay,
      'procedureName': instance.procedureName,
      'flapVascularity': instance.flapVascularity,
      'operationNote': instance.operationNote,
    };

_PsychiatryTemplate _$PsychiatryTemplateFromJson(Map<String, dynamic> json) =>
    _PsychiatryTemplate(
      appearance: json['appearance'] as String? ?? '',
      behavior: json['behavior'] as String? ?? '',
      speech: json['speech'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      thoughtProcess: json['thoughtProcess'] as String? ?? '',
      perception: json['perception'] as String? ?? '',
      cognition: json['cognition'] as String? ?? '',
      insight: json['insight'] as String? ?? '',
      suicidalIdeation: json['suicidalIdeation'] as bool? ?? false,
      homicidalIdeation: json['homicidalIdeation'] as bool? ?? false,
      hallucinations: json['hallucinations'] as bool? ?? false,
    );

Map<String, dynamic> _$PsychiatryTemplateToJson(_PsychiatryTemplate instance) =>
    <String, dynamic>{
      'appearance': instance.appearance,
      'behavior': instance.behavior,
      'speech': instance.speech,
      'mood': instance.mood,
      'thoughtProcess': instance.thoughtProcess,
      'perception': instance.perception,
      'cognition': instance.cognition,
      'insight': instance.insight,
      'suicidalIdeation': instance.suicidalIdeation,
      'homicidalIdeation': instance.homicidalIdeation,
      'hallucinations': instance.hallucinations,
    };

_GenericClinicalTemplate _$GenericClinicalTemplateFromJson(
  Map<String, dynamic> json,
) => _GenericClinicalTemplate(
  values: json['values'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$GenericClinicalTemplateToJson(
  _GenericClinicalTemplate instance,
) => <String, dynamic>{'values': instance.values};
