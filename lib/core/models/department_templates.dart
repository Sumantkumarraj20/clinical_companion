import 'package:freezed_annotation/freezed_annotation.dart';

part 'department_templates.freezed.dart';
part 'department_templates.g.dart';

/// Canonical department values used by patient state and clinical templates.
enum CrmiDepartment {
  communityMedicine('Community Medicine', 12, 'Rural Health (CHC/PHC)'),
  obstetricsAndGynaecology(
    'Obstetrics & Gynaecology',
    7,
    'Wards, Labour Room, OPD, and OT',
  ),
  generalMedicine(
    'General Medicine',
    6,
    'In-patient wards, OPD, admission emergencies, ICU/HDU',
  ),
  generalSurgery('General Surgery', 6, 'Wards, OPD, Minor/Major OT, trauma'),
  pediatrics('Pediatrics', 3, 'Wards, OPD, NICU/PICU'),
  psychiatry('Psychiatry', 2, 'OPD and acute emergencies'),
  anesthesiologyAndCriticalCare(
    'Anesthesiology & Critical Care',
    2,
    'OT, ICU, Basic Life Support (BLS), Pain Clinic',
  ),
  orthopaedicsInclPmr(
    'Orthopaedics (incl. PMR)',
    2,
    'Emergencies, Minor/Major OT, Rehabilitation',
  ),
  emergencyMedicineOrCasualty(
    'Emergency Medicine / Casualty',
    2,
    'Triage, trauma, medico-legal cases',
  ),
  otorhinolaryngologyEnt(
    'Otorhinolaryngology (ENT)',
    2,
    'OPD, Minor OT, emergencies',
  ),
  ophthalmology('Ophthalmology', 2, 'OPD, Eye camps, Minor/Major OT'),
  dermatologyVenereologyLeprosy(
    'Dermatology, Venereology, Leprosy',
    2,
    'OPD, minor procedures',
  ),
  electives('Electives', 2, 'Broad specialties or AYUSH'),
  forensicMedicineAndToxicology(
    'Forensic Medicine & Toxicology',
    1,
    'Autopsies, medico-legal documentation',
  ),
  bloodBankTransfusion(
    'Blood Bank / Transfusion',
    1,
    'Blood typing, component separation, safety protocols',
  );

  const CrmiDepartment(this.label, this.durationWeeks, this.focus);

  final String label;
  final int durationWeeks;
  final String focus;

  static CrmiDepartment? tryParse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final department in values) {
      if (department.label.toLowerCase() == normalized ||
          department.name.toLowerCase() == normalized) {
        return department;
      }
    }
    switch (normalized) {
      case 'medicine':
        return generalMedicine;
      case 'surgery':
        return generalSurgery;
      case 'obgyn':
      case 'ob/gyn':
      case 'ob-gyn':
        return obstetricsAndGynaecology;
      case 'emergency':
      case 'trauma':
        return emergencyMedicineOrCasualty;
      case 'ent':
        return otorhinolaryngologyEnt;
      default:
        return null;
    }
  }

  static CrmiDepartment parse(String value) =>
      tryParse(value) ?? CrmiDepartment.generalSurgery;
}

/// The polymorphic payload stored in clinical_encounters.dynamic_data.
sealed class ClinicalTemplate {
  const ClinicalTemplate();

  String get department;
  Map<String, dynamic> toJson();

  static ClinicalTemplate fromDepartment(
    String department,
    Map<String, dynamic> json,
  ) {
    final parsed = CrmiDepartment.tryParse(department);
    if (parsed == null) return GenericClinicalTemplate.fromJson(json);
    switch (parsed) {
      case CrmiDepartment.generalMedicine:
        return MedicineTemplate.fromJson(json);
      case CrmiDepartment.obstetricsAndGynaecology:
        return ObGynTemplate.fromJson(json);
      case CrmiDepartment.generalSurgery:
        return SurgeryTemplate.fromJson(json);
      case CrmiDepartment.pediatrics:
        return PediatricsTemplate.fromJson(json);
      case CrmiDepartment.psychiatry:
        return PsychiatryTemplate.fromJson(json);
      default:
        return GenericClinicalTemplate.fromJson(json);
    }
  }

  static ClinicalTemplate fromJsonForDepartment({
    required String currentDepartment,
    required Map<String, dynamic> json,
  }) => fromDepartment(currentDepartment, json);
}

@freezed
sealed class MedicineTemplate
    with _$MedicineTemplate
    implements ClinicalTemplate {
  const MedicineTemplate._();
  const factory MedicineTemplate({
    @Default(<String, String>{}) Map<String, String> systemicExamFindings,
    @Default(<String, num>{}) Map<String, num> inputOutputChart,
    @Default('') String assessment,
    @Default('') String plan,
  }) = _MedicineTemplate;

  factory MedicineTemplate.fromJson(Map<String, dynamic> json) =>
      _$MedicineTemplateFromJson(json);

  @override
  String get department => 'Medicine';
}

@freezed
sealed class PediatricsTemplate
    with _$PediatricsTemplate
    implements ClinicalTemplate {
  const PediatricsTemplate._();
  const factory PediatricsTemplate({
    @Default(0) int apgarOneMinute,
    @Default(0) int apgarFiveMinute,
    @Default('') String developmentalMilestones,
    @Default(0) double weightKg,
    @Default('') String dosingNotes,
  }) = _PediatricsTemplate;

  factory PediatricsTemplate.fromJson(Map<String, dynamic> json) =>
      _$PediatricsTemplateFromJson(json);

  @override
  String get department => 'Pediatrics';
}

@freezed
sealed class ObGynTemplate with _$ObGynTemplate implements ClinicalTemplate {
  const ObGynTemplate._();
  const factory ObGynTemplate({
    @Default(0) int gravida,
    @Default(0) int para,
    @Default(0) int abortions,
    @Default(0) int living,
    @Default(0) int fetalHeartRate,
    @Default(0) int bishopScore,
    @Default('') String gestationalAge,
    @Default('') String partographNotes,
  }) = _ObGynTemplate;

  factory ObGynTemplate.fromJson(Map<String, dynamic> json) =>
      _$ObGynTemplateFromJson(json);

  @override
  String get department => 'OBGYN';
}

@freezed
sealed class SurgeryTemplate
    with _$SurgeryTemplate
    implements ClinicalTemplate {
  const SurgeryTemplate._();
  const factory SurgeryTemplate({
    @Default('') String woundStatus,
    @Default(0) double drainOutputMl,
    @Default(0) int postOpDay,
    @Default('') String procedureName,
    @Default('') String flapVascularity,
    @Default('') String operationNote,
  }) = _SurgeryTemplate;

  factory SurgeryTemplate.fromJson(Map<String, dynamic> json) =>
      _$SurgeryTemplateFromJson(json);

  @override
  String get department => 'Surgery';
}

@freezed
sealed class PsychiatryTemplate
    with _$PsychiatryTemplate
    implements ClinicalTemplate {
  const PsychiatryTemplate._();
  const factory PsychiatryTemplate({
    @Default('') String appearance,
    @Default('') String behavior,
    @Default('') String speech,
    @Default('') String mood,
    @Default('') String thoughtProcess,
    @Default('') String perception,
    @Default('') String cognition,
    @Default('') String insight,
    @Default(false) bool suicidalIdeation,
    @Default(false) bool homicidalIdeation,
    @Default(false) bool hallucinations,
  }) = _PsychiatryTemplate;

  factory PsychiatryTemplate.fromJson(Map<String, dynamic> json) =>
      _$PsychiatryTemplateFromJson(json);

  @override
  String get department => 'Psychiatry';
}

@freezed
sealed class GenericClinicalTemplate
    with _$GenericClinicalTemplate
    implements ClinicalTemplate {
  const GenericClinicalTemplate._();
  const factory GenericClinicalTemplate({
    @Default(<String, dynamic>{}) Map<String, dynamic> values,
  }) = _GenericClinicalTemplate;

  factory GenericClinicalTemplate.fromJson(Map<String, dynamic> json) =>
      _$GenericClinicalTemplateFromJson(json);

  @override
  String get department => 'Other';
}
