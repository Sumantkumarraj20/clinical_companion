// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_extraction_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiLocation {

 String? get type; String? get department;@JsonKey(name: 'ward_name') String? get wardName;@JsonKey(name: 'bed_number') String? get bedNumber;
/// Create a copy of AiLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiLocationCopyWith<AiLocation> get copyWith => _$AiLocationCopyWithImpl<AiLocation>(this as AiLocation, _$identity);

  /// Serializes this AiLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiLocation&&(identical(other.type, type) || other.type == type)&&(identical(other.department, department) || other.department == department)&&(identical(other.wardName, wardName) || other.wardName == wardName)&&(identical(other.bedNumber, bedNumber) || other.bedNumber == bedNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,department,wardName,bedNumber);

@override
String toString() {
  return 'AiLocation(type: $type, department: $department, wardName: $wardName, bedNumber: $bedNumber)';
}


}

/// @nodoc
abstract mixin class $AiLocationCopyWith<$Res>  {
  factory $AiLocationCopyWith(AiLocation value, $Res Function(AiLocation) _then) = _$AiLocationCopyWithImpl;
@useResult
$Res call({
 String? type, String? department,@JsonKey(name: 'ward_name') String? wardName,@JsonKey(name: 'bed_number') String? bedNumber
});




}
/// @nodoc
class _$AiLocationCopyWithImpl<$Res>
    implements $AiLocationCopyWith<$Res> {
  _$AiLocationCopyWithImpl(this._self, this._then);

  final AiLocation _self;
  final $Res Function(AiLocation) _then;

/// Create a copy of AiLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? department = freezed,Object? wardName = freezed,Object? bedNumber = freezed,}) {
  return _then(AiLocation(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,wardName: freezed == wardName ? _self.wardName : wardName // ignore: cast_nullable_to_non_nullable
as String?,bedNumber: freezed == bedNumber ? _self.bedNumber : bedNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiLocation].
extension AiLocationPatterns on AiLocation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiLocation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiLocation value)  $default,){
final _that = this;
switch (_that) {
case _AiLocation():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiLocation value)?  $default,){
final _that = this;
switch (_that) {
case _AiLocation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? department, @JsonKey(name: 'ward_name')  String? wardName, @JsonKey(name: 'bed_number')  String? bedNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiLocation() when $default != null:
return $default(_that.type,_that.department,_that.wardName,_that.bedNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? department, @JsonKey(name: 'ward_name')  String? wardName, @JsonKey(name: 'bed_number')  String? bedNumber)  $default,) {final _that = this;
switch (_that) {
case _AiLocation():
return $default(_that.type,_that.department,_that.wardName,_that.bedNumber);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? department, @JsonKey(name: 'ward_name')  String? wardName, @JsonKey(name: 'bed_number')  String? bedNumber)?  $default,) {final _that = this;
switch (_that) {
case _AiLocation() when $default != null:
return $default(_that.type,_that.department,_that.wardName,_that.bedNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiLocation implements AiLocation {
  const _AiLocation({this.type, this.department, @JsonKey(name: 'ward_name') this.wardName, @JsonKey(name: 'bed_number') this.bedNumber});
  factory _AiLocation.fromJson(Map<String, dynamic> json) => _$AiLocationFromJson(json);

@override final  String? type;
@override final  String? department;
@override@JsonKey(name: 'ward_name') final  String? wardName;
@override@JsonKey(name: 'bed_number') final  String? bedNumber;

/// Create a copy of AiLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiLocationCopyWith<_AiLocation> get copyWith => __$AiLocationCopyWithImpl<_AiLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiLocation&&(identical(other.type, type) || other.type == type)&&(identical(other.department, department) || other.department == department)&&(identical(other.wardName, wardName) || other.wardName == wardName)&&(identical(other.bedNumber, bedNumber) || other.bedNumber == bedNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,department,wardName,bedNumber);

@override
String toString() {
  return 'AiLocation(type: $type, department: $department, wardName: $wardName, bedNumber: $bedNumber)';
}


}

/// @nodoc
abstract mixin class _$AiLocationCopyWith<$Res> implements $AiLocationCopyWith<$Res> {
  factory _$AiLocationCopyWith(_AiLocation value, $Res Function(_AiLocation) _then) = __$AiLocationCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? department,@JsonKey(name: 'ward_name') String? wardName,@JsonKey(name: 'bed_number') String? bedNumber
});




}
/// @nodoc
class __$AiLocationCopyWithImpl<$Res>
    implements _$AiLocationCopyWith<$Res> {
  __$AiLocationCopyWithImpl(this._self, this._then);

  final _AiLocation _self;
  final $Res Function(_AiLocation) _then;

/// Create a copy of AiLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? department = freezed,Object? wardName = freezed,Object? bedNumber = freezed,}) {
  return _then(_AiLocation(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,wardName: freezed == wardName ? _self.wardName : wardName // ignore: cast_nullable_to_non_nullable
as String?,bedNumber: freezed == bedNumber ? _self.bedNumber : bedNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AiVitals {

 int? get sbp; int? get dbp;@JsonKey(name: 'pulse') int? get pr;@JsonKey(name: 'temp_f') double? get temperatureC; int? get spo2;@JsonKey(name: 'respiratory_rate') int? get respiratoryRate;@JsonKey(name: 'map') double? get meanArterialPressure;
/// Create a copy of AiVitals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiVitalsCopyWith<AiVitals> get copyWith => _$AiVitalsCopyWithImpl<AiVitals>(this as AiVitals, _$identity);

  /// Serializes this AiVitals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiVitals&&(identical(other.sbp, sbp) || other.sbp == sbp)&&(identical(other.dbp, dbp) || other.dbp == dbp)&&(identical(other.pr, pr) || other.pr == pr)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.spo2, spo2) || other.spo2 == spo2)&&(identical(other.respiratoryRate, respiratoryRate) || other.respiratoryRate == respiratoryRate)&&(identical(other.meanArterialPressure, meanArterialPressure) || other.meanArterialPressure == meanArterialPressure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sbp,dbp,pr,temperatureC,spo2,respiratoryRate,meanArterialPressure);

@override
String toString() {
  return 'AiVitals(sbp: $sbp, dbp: $dbp, pr: $pr, temperatureC: $temperatureC, spo2: $spo2, respiratoryRate: $respiratoryRate, meanArterialPressure: $meanArterialPressure)';
}


}

/// @nodoc
abstract mixin class $AiVitalsCopyWith<$Res>  {
  factory $AiVitalsCopyWith(AiVitals value, $Res Function(AiVitals) _then) = _$AiVitalsCopyWithImpl;
@useResult
$Res call({
 int? sbp, int? dbp,@JsonKey(name: 'pulse') int? pr,@JsonKey(name: 'temp_f') double? temperatureC, int? spo2,@JsonKey(name: 'respiratory_rate') int? respiratoryRate,@JsonKey(name: 'map') double? meanArterialPressure
});




}
/// @nodoc
class _$AiVitalsCopyWithImpl<$Res>
    implements $AiVitalsCopyWith<$Res> {
  _$AiVitalsCopyWithImpl(this._self, this._then);

  final AiVitals _self;
  final $Res Function(AiVitals) _then;

/// Create a copy of AiVitals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sbp = freezed,Object? dbp = freezed,Object? pr = freezed,Object? temperatureC = freezed,Object? spo2 = freezed,Object? respiratoryRate = freezed,Object? meanArterialPressure = freezed,}) {
  return _then(AiVitals(
sbp: freezed == sbp ? _self.sbp : sbp // ignore: cast_nullable_to_non_nullable
as int?,dbp: freezed == dbp ? _self.dbp : dbp // ignore: cast_nullable_to_non_nullable
as int?,pr: freezed == pr ? _self.pr : pr // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,spo2: freezed == spo2 ? _self.spo2 : spo2 // ignore: cast_nullable_to_non_nullable
as int?,respiratoryRate: freezed == respiratoryRate ? _self.respiratoryRate : respiratoryRate // ignore: cast_nullable_to_non_nullable
as int?,meanArterialPressure: freezed == meanArterialPressure ? _self.meanArterialPressure : meanArterialPressure // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiVitals].
extension AiVitalsPatterns on AiVitals {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiVitals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiVitals value)  $default,){
final _that = this;
switch (_that) {
case _AiVitals():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiVitals value)?  $default,){
final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? sbp,  int? dbp, @JsonKey(name: 'pulse')  int? pr, @JsonKey(name: 'temp_f')  double? temperatureC,  int? spo2, @JsonKey(name: 'respiratory_rate')  int? respiratoryRate, @JsonKey(name: 'map')  double? meanArterialPressure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC,_that.spo2,_that.respiratoryRate,_that.meanArterialPressure);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? sbp,  int? dbp, @JsonKey(name: 'pulse')  int? pr, @JsonKey(name: 'temp_f')  double? temperatureC,  int? spo2, @JsonKey(name: 'respiratory_rate')  int? respiratoryRate, @JsonKey(name: 'map')  double? meanArterialPressure)  $default,) {final _that = this;
switch (_that) {
case _AiVitals():
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC,_that.spo2,_that.respiratoryRate,_that.meanArterialPressure);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? sbp,  int? dbp, @JsonKey(name: 'pulse')  int? pr, @JsonKey(name: 'temp_f')  double? temperatureC,  int? spo2, @JsonKey(name: 'respiratory_rate')  int? respiratoryRate, @JsonKey(name: 'map')  double? meanArterialPressure)?  $default,) {final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC,_that.spo2,_that.respiratoryRate,_that.meanArterialPressure);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiVitals implements AiVitals {
  const _AiVitals({this.sbp, this.dbp, @JsonKey(name: 'pulse') this.pr, @JsonKey(name: 'temp_f') this.temperatureC, this.spo2, @JsonKey(name: 'respiratory_rate') this.respiratoryRate, @JsonKey(name: 'map') this.meanArterialPressure});
  factory _AiVitals.fromJson(Map<String, dynamic> json) => _$AiVitalsFromJson(json);

@override final  int? sbp;
@override final  int? dbp;
@override@JsonKey(name: 'pulse') final  int? pr;
@override@JsonKey(name: 'temp_f') final  double? temperatureC;
@override final  int? spo2;
@override@JsonKey(name: 'respiratory_rate') final  int? respiratoryRate;
@override@JsonKey(name: 'map') final  double? meanArterialPressure;

/// Create a copy of AiVitals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiVitalsCopyWith<_AiVitals> get copyWith => __$AiVitalsCopyWithImpl<_AiVitals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiVitalsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiVitals&&(identical(other.sbp, sbp) || other.sbp == sbp)&&(identical(other.dbp, dbp) || other.dbp == dbp)&&(identical(other.pr, pr) || other.pr == pr)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.spo2, spo2) || other.spo2 == spo2)&&(identical(other.respiratoryRate, respiratoryRate) || other.respiratoryRate == respiratoryRate)&&(identical(other.meanArterialPressure, meanArterialPressure) || other.meanArterialPressure == meanArterialPressure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sbp,dbp,pr,temperatureC,spo2,respiratoryRate,meanArterialPressure);

@override
String toString() {
  return 'AiVitals(sbp: $sbp, dbp: $dbp, pr: $pr, temperatureC: $temperatureC, spo2: $spo2, respiratoryRate: $respiratoryRate, meanArterialPressure: $meanArterialPressure)';
}


}

/// @nodoc
abstract mixin class _$AiVitalsCopyWith<$Res> implements $AiVitalsCopyWith<$Res> {
  factory _$AiVitalsCopyWith(_AiVitals value, $Res Function(_AiVitals) _then) = __$AiVitalsCopyWithImpl;
@override @useResult
$Res call({
 int? sbp, int? dbp,@JsonKey(name: 'pulse') int? pr,@JsonKey(name: 'temp_f') double? temperatureC, int? spo2,@JsonKey(name: 'respiratory_rate') int? respiratoryRate,@JsonKey(name: 'map') double? meanArterialPressure
});




}
/// @nodoc
class __$AiVitalsCopyWithImpl<$Res>
    implements _$AiVitalsCopyWith<$Res> {
  __$AiVitalsCopyWithImpl(this._self, this._then);

  final _AiVitals _self;
  final $Res Function(_AiVitals) _then;

/// Create a copy of AiVitals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sbp = freezed,Object? dbp = freezed,Object? pr = freezed,Object? temperatureC = freezed,Object? spo2 = freezed,Object? respiratoryRate = freezed,Object? meanArterialPressure = freezed,}) {
  return _then(_AiVitals(
sbp: freezed == sbp ? _self.sbp : sbp // ignore: cast_nullable_to_non_nullable
as int?,dbp: freezed == dbp ? _self.dbp : dbp // ignore: cast_nullable_to_non_nullable
as int?,pr: freezed == pr ? _self.pr : pr // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,spo2: freezed == spo2 ? _self.spo2 : spo2 // ignore: cast_nullable_to_non_nullable
as int?,respiratoryRate: freezed == respiratoryRate ? _self.respiratoryRate : respiratoryRate // ignore: cast_nullable_to_non_nullable
as int?,meanArterialPressure: freezed == meanArterialPressure ? _self.meanArterialPressure : meanArterialPressure // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$AiExtractionResult {

@JsonKey(name: 'patient_identity') PatientIdentity get patientIdentity;@JsonKey(name: 'encounter_context') EncounterContext get encounterContext; AiVitals get vitals;@JsonKey(name: 'medications_ordered') List<OrderedMedication> get medicationsOrdered;@JsonKey(name: 'lab_results') List<AiLabResult> get labResults; List<AiProblem> get problems;@JsonKey(name: 'unlinked_management') AiUnlinkedManagement get unlinkedManagement;@JsonKey(name: 'clinical_warnings') List<AiClinicalWarning> get clinicalWarnings; String get clinicalSummary;/// Verbatim narrative conclusion from the document — the "Conclusion",
/// "Impression", "Final Remarks" or "Advice" block that pathology,
/// radiology and discharge summaries carry at the foot of the page.
///
/// This is kept separate from [clinicalSummary] because it is the part a
/// pathologist or radiologist *wrote* for the clinician to read, and losing
/// it is the single most damaging way OCR can truncate a report: every
/// numeric value survives but the interpretation does not. Storing it apart
/// also keeps it editable in review instead of being flattened into prose.
@JsonKey(name: 'conclusion') String get conclusion;/// The date the document was WRITTEN (ISO-8601), never today's date.
/// ClinCom is instructed never to substitute the current date, so a
/// back-dated report keeps its true clinical date.
@JsonKey(name: 'document_date') String get documentDate;/// True when [documentDate] was inferred rather than read off the page.
@JsonKey(name: 'is_date_assumed') bool get isDateAssumed;/// Patient resolved from a bed/ward number via the appended active census
/// JSON. Null when the page carried no bed number or the bed was ambiguous
/// — ClinCom is explicitly forbidden from guessing a patient.
@JsonKey(name: 'inferred_patient_id') String? get inferredPatientId;@JsonKey(name: 'chief_complaints') List<String> get chiefComplaints;@JsonKey(name: 'diagnoses') List<String> get diagnoses;@JsonKey(name: 'planned_investigations') List<String> get plannedInvestigations;/// Provenance of this reading. Drives Sprint 17 semantic merging: a
/// formal 'Scanned Document' report outranks a 'Ward Round Note'.
@JsonKey(name: 'source_authority') String? get sourceAuthority;
/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiExtractionResultCopyWith<AiExtractionResult> get copyWith => _$AiExtractionResultCopyWithImpl<AiExtractionResult>(this as AiExtractionResult, _$identity);

  /// Serializes this AiExtractionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiExtractionResult&&(identical(other.patientIdentity, patientIdentity) || other.patientIdentity == patientIdentity)&&(identical(other.encounterContext, encounterContext) || other.encounterContext == encounterContext)&&(identical(other.vitals, vitals) || other.vitals == vitals)&&const DeepCollectionEquality().equals(other.medicationsOrdered, medicationsOrdered)&&const DeepCollectionEquality().equals(other.labResults, labResults)&&const DeepCollectionEquality().equals(other.problems, problems)&&(identical(other.unlinkedManagement, unlinkedManagement) || other.unlinkedManagement == unlinkedManagement)&&const DeepCollectionEquality().equals(other.clinicalWarnings, clinicalWarnings)&&(identical(other.clinicalSummary, clinicalSummary) || other.clinicalSummary == clinicalSummary)&&(identical(other.conclusion, conclusion) || other.conclusion == conclusion)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.isDateAssumed, isDateAssumed) || other.isDateAssumed == isDateAssumed)&&(identical(other.inferredPatientId, inferredPatientId) || other.inferredPatientId == inferredPatientId)&&const DeepCollectionEquality().equals(other.chiefComplaints, chiefComplaints)&&const DeepCollectionEquality().equals(other.diagnoses, diagnoses)&&const DeepCollectionEquality().equals(other.plannedInvestigations, plannedInvestigations)&&(identical(other.sourceAuthority, sourceAuthority) || other.sourceAuthority == sourceAuthority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientIdentity,encounterContext,vitals,const DeepCollectionEquality().hash(medicationsOrdered),const DeepCollectionEquality().hash(labResults),const DeepCollectionEquality().hash(problems),unlinkedManagement,const DeepCollectionEquality().hash(clinicalWarnings),clinicalSummary,conclusion,documentDate,isDateAssumed,inferredPatientId,const DeepCollectionEquality().hash(chiefComplaints),const DeepCollectionEquality().hash(diagnoses),const DeepCollectionEquality().hash(plannedInvestigations),sourceAuthority);

@override
String toString() {
  return 'AiExtractionResult(patientIdentity: $patientIdentity, encounterContext: $encounterContext, vitals: $vitals, medicationsOrdered: $medicationsOrdered, labResults: $labResults, problems: $problems, unlinkedManagement: $unlinkedManagement, clinicalWarnings: $clinicalWarnings, clinicalSummary: $clinicalSummary, conclusion: $conclusion, documentDate: $documentDate, isDateAssumed: $isDateAssumed, inferredPatientId: $inferredPatientId, chiefComplaints: $chiefComplaints, diagnoses: $diagnoses, plannedInvestigations: $plannedInvestigations, sourceAuthority: $sourceAuthority)';
}


}

/// @nodoc
abstract mixin class $AiExtractionResultCopyWith<$Res>  {
  factory $AiExtractionResultCopyWith(AiExtractionResult value, $Res Function(AiExtractionResult) _then) = _$AiExtractionResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'patient_identity') PatientIdentity patientIdentity,@JsonKey(name: 'encounter_context') EncounterContext encounterContext, AiVitals vitals,@JsonKey(name: 'medications_ordered') List<OrderedMedication> medicationsOrdered,@JsonKey(name: 'lab_results') List<AiLabResult> labResults, List<AiProblem> problems,@JsonKey(name: 'unlinked_management') AiUnlinkedManagement unlinkedManagement,@JsonKey(name: 'clinical_warnings') List<AiClinicalWarning> clinicalWarnings, String clinicalSummary,@JsonKey(name: 'conclusion') String conclusion,@JsonKey(name: 'document_date') String documentDate,@JsonKey(name: 'is_date_assumed') bool isDateAssumed,@JsonKey(name: 'inferred_patient_id') String? inferredPatientId,@JsonKey(name: 'chief_complaints') List<String> chiefComplaints,@JsonKey(name: 'diagnoses') List<String> diagnoses,@JsonKey(name: 'planned_investigations') List<String> plannedInvestigations,@JsonKey(name: 'source_authority') String? sourceAuthority
});


$PatientIdentityCopyWith<$Res> get patientIdentity;$EncounterContextCopyWith<$Res> get encounterContext;$AiVitalsCopyWith<$Res> get vitals;$AiUnlinkedManagementCopyWith<$Res> get unlinkedManagement;

}
/// @nodoc
class _$AiExtractionResultCopyWithImpl<$Res>
    implements $AiExtractionResultCopyWith<$Res> {
  _$AiExtractionResultCopyWithImpl(this._self, this._then);

  final AiExtractionResult _self;
  final $Res Function(AiExtractionResult) _then;

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patientIdentity = null,Object? encounterContext = null,Object? vitals = null,Object? medicationsOrdered = null,Object? labResults = null,Object? problems = null,Object? unlinkedManagement = null,Object? clinicalWarnings = null,Object? clinicalSummary = null,Object? conclusion = null,Object? documentDate = null,Object? isDateAssumed = null,Object? inferredPatientId = freezed,Object? chiefComplaints = null,Object? diagnoses = null,Object? plannedInvestigations = null,Object? sourceAuthority = freezed,}) {
  return _then(AiExtractionResult(
patientIdentity: null == patientIdentity ? _self.patientIdentity : patientIdentity // ignore: cast_nullable_to_non_nullable
as PatientIdentity,encounterContext: null == encounterContext ? _self.encounterContext : encounterContext // ignore: cast_nullable_to_non_nullable
as EncounterContext,vitals: null == vitals ? _self.vitals : vitals // ignore: cast_nullable_to_non_nullable
as AiVitals,medicationsOrdered: null == medicationsOrdered ? _self.medicationsOrdered : medicationsOrdered // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,labResults: null == labResults ? _self.labResults : labResults // ignore: cast_nullable_to_non_nullable
as List<AiLabResult>,problems: null == problems ? _self.problems : problems // ignore: cast_nullable_to_non_nullable
as List<AiProblem>,unlinkedManagement: null == unlinkedManagement ? _self.unlinkedManagement : unlinkedManagement // ignore: cast_nullable_to_non_nullable
as AiUnlinkedManagement,clinicalWarnings: null == clinicalWarnings ? _self.clinicalWarnings : clinicalWarnings // ignore: cast_nullable_to_non_nullable
as List<AiClinicalWarning>,clinicalSummary: null == clinicalSummary ? _self.clinicalSummary : clinicalSummary // ignore: cast_nullable_to_non_nullable
as String,conclusion: null == conclusion ? _self.conclusion : conclusion // ignore: cast_nullable_to_non_nullable
as String,documentDate: null == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String,isDateAssumed: null == isDateAssumed ? _self.isDateAssumed : isDateAssumed // ignore: cast_nullable_to_non_nullable
as bool,inferredPatientId: freezed == inferredPatientId ? _self.inferredPatientId : inferredPatientId // ignore: cast_nullable_to_non_nullable
as String?,chiefComplaints: null == chiefComplaints ? _self.chiefComplaints : chiefComplaints // ignore: cast_nullable_to_non_nullable
as List<String>,diagnoses: null == diagnoses ? _self.diagnoses : diagnoses // ignore: cast_nullable_to_non_nullable
as List<String>,plannedInvestigations: null == plannedInvestigations ? _self.plannedInvestigations : plannedInvestigations // ignore: cast_nullable_to_non_nullable
as List<String>,sourceAuthority: freezed == sourceAuthority ? _self.sourceAuthority : sourceAuthority // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientIdentityCopyWith<$Res> get patientIdentity {
  
  return $PatientIdentityCopyWith<$Res>(_self.patientIdentity, (value) {
    return _then(_self.copyWith(patientIdentity: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncounterContextCopyWith<$Res> get encounterContext {
  
  return $EncounterContextCopyWith<$Res>(_self.encounterContext, (value) {
    return _then(_self.copyWith(encounterContext: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiVitalsCopyWith<$Res> get vitals {
  
  return $AiVitalsCopyWith<$Res>(_self.vitals, (value) {
    return _then(_self.copyWith(vitals: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiUnlinkedManagementCopyWith<$Res> get unlinkedManagement {

  return $AiUnlinkedManagementCopyWith<$Res>(_self.unlinkedManagement, (value) {
    return _then(_self.copyWith(unlinkedManagement: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiExtractionResult].
extension AiExtractionResultPatterns on AiExtractionResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiExtractionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiExtractionResult value)  $default,){
final _that = this;
switch (_that) {
case _AiExtractionResult():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiExtractionResult value)?  $default,){
final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'patient_identity')  PatientIdentity patientIdentity, @JsonKey(name: 'encounter_context')  EncounterContext encounterContext,  AiVitals vitals, @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered, @JsonKey(name: 'lab_results')  List<AiLabResult> labResults,  List<AiProblem> problems, @JsonKey(name: 'unlinked_management')  AiUnlinkedManagement unlinkedManagement, @JsonKey(name: 'clinical_warnings')  List<AiClinicalWarning> clinicalWarnings,  String clinicalSummary, @JsonKey(name: 'conclusion')  String conclusion, @JsonKey(name: 'document_date')  String documentDate, @JsonKey(name: 'is_date_assumed')  bool isDateAssumed, @JsonKey(name: 'inferred_patient_id')  String? inferredPatientId, @JsonKey(name: 'chief_complaints')  List<String> chiefComplaints, @JsonKey(name: 'diagnoses')  List<String> diagnoses, @JsonKey(name: 'planned_investigations')  List<String> plannedInvestigations, @JsonKey(name: 'source_authority')  String? sourceAuthority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that.patientIdentity,_that.encounterContext,_that.vitals,_that.medicationsOrdered,_that.labResults,_that.problems,_that.unlinkedManagement,_that.clinicalWarnings,_that.clinicalSummary,_that.conclusion,_that.documentDate,_that.isDateAssumed,_that.inferredPatientId,_that.chiefComplaints,_that.diagnoses,_that.plannedInvestigations,_that.sourceAuthority);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'patient_identity')  PatientIdentity patientIdentity, @JsonKey(name: 'encounter_context')  EncounterContext encounterContext,  AiVitals vitals, @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered, @JsonKey(name: 'lab_results')  List<AiLabResult> labResults,  List<AiProblem> problems, @JsonKey(name: 'unlinked_management')  AiUnlinkedManagement unlinkedManagement, @JsonKey(name: 'clinical_warnings')  List<AiClinicalWarning> clinicalWarnings,  String clinicalSummary, @JsonKey(name: 'conclusion')  String conclusion, @JsonKey(name: 'document_date')  String documentDate, @JsonKey(name: 'is_date_assumed')  bool isDateAssumed, @JsonKey(name: 'inferred_patient_id')  String? inferredPatientId, @JsonKey(name: 'chief_complaints')  List<String> chiefComplaints, @JsonKey(name: 'diagnoses')  List<String> diagnoses, @JsonKey(name: 'planned_investigations')  List<String> plannedInvestigations, @JsonKey(name: 'source_authority')  String? sourceAuthority)  $default,) {final _that = this;
switch (_that) {
case _AiExtractionResult():
return $default(_that.patientIdentity,_that.encounterContext,_that.vitals,_that.medicationsOrdered,_that.labResults,_that.problems,_that.unlinkedManagement,_that.clinicalWarnings,_that.clinicalSummary,_that.conclusion,_that.documentDate,_that.isDateAssumed,_that.inferredPatientId,_that.chiefComplaints,_that.diagnoses,_that.plannedInvestigations,_that.sourceAuthority);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'patient_identity')  PatientIdentity patientIdentity, @JsonKey(name: 'encounter_context')  EncounterContext encounterContext,  AiVitals vitals, @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered, @JsonKey(name: 'lab_results')  List<AiLabResult> labResults,  List<AiProblem> problems, @JsonKey(name: 'unlinked_management')  AiUnlinkedManagement unlinkedManagement, @JsonKey(name: 'clinical_warnings')  List<AiClinicalWarning> clinicalWarnings,  String clinicalSummary, @JsonKey(name: 'conclusion')  String conclusion, @JsonKey(name: 'document_date')  String documentDate, @JsonKey(name: 'is_date_assumed')  bool isDateAssumed, @JsonKey(name: 'inferred_patient_id')  String? inferredPatientId, @JsonKey(name: 'chief_complaints')  List<String> chiefComplaints, @JsonKey(name: 'diagnoses')  List<String> diagnoses, @JsonKey(name: 'planned_investigations')  List<String> plannedInvestigations, @JsonKey(name: 'source_authority')  String? sourceAuthority)?  $default,) {final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that.patientIdentity,_that.encounterContext,_that.vitals,_that.medicationsOrdered,_that.labResults,_that.problems,_that.unlinkedManagement,_that.clinicalWarnings,_that.clinicalSummary,_that.conclusion,_that.documentDate,_that.isDateAssumed,_that.inferredPatientId,_that.chiefComplaints,_that.diagnoses,_that.plannedInvestigations,_that.sourceAuthority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiExtractionResult extends AiExtractionResult {
  const _AiExtractionResult({@JsonKey(name: 'patient_identity') this.patientIdentity = const PatientIdentity(), @JsonKey(name: 'encounter_context') this.encounterContext = const EncounterContext(), this.vitals = const AiVitals(), @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered = const <OrderedMedication>[], @JsonKey(name: 'lab_results')  List<AiLabResult> labResults = const <AiLabResult>[],  List<AiProblem> problems = const <AiProblem>[], @JsonKey(name: 'unlinked_management') this.unlinkedManagement = const AiUnlinkedManagement(), @JsonKey(name: 'clinical_warnings')  List<AiClinicalWarning> clinicalWarnings = const <AiClinicalWarning>[], this.clinicalSummary = '', @JsonKey(name: 'conclusion') this.conclusion = '', @JsonKey(name: 'document_date') this.documentDate = '', @JsonKey(name: 'is_date_assumed') this.isDateAssumed = false, @JsonKey(name: 'inferred_patient_id') this.inferredPatientId, @JsonKey(name: 'chief_complaints')  List<String> chiefComplaints = const <String>[], @JsonKey(name: 'diagnoses')  List<String> diagnoses = const <String>[], @JsonKey(name: 'planned_investigations')  List<String> plannedInvestigations = const <String>[], @JsonKey(name: 'source_authority') this.sourceAuthority}): _medicationsOrdered = medicationsOrdered,_labResults = labResults,_problems = problems,_clinicalWarnings = clinicalWarnings,_chiefComplaints = chiefComplaints,_diagnoses = diagnoses,_plannedInvestigations = plannedInvestigations,super._();
  factory _AiExtractionResult.fromJson(Map<String, dynamic> json) => _$AiExtractionResultFromJson(json);

@override@JsonKey(name: 'patient_identity') final  PatientIdentity patientIdentity;
@override@JsonKey(name: 'encounter_context') final  EncounterContext encounterContext;
@override@JsonKey() final  AiVitals vitals;
 final  List<OrderedMedication> _medicationsOrdered;
@override@JsonKey(name: 'medications_ordered') List<OrderedMedication> get medicationsOrdered {
  if (_medicationsOrdered is EqualUnmodifiableListView) return _medicationsOrdered;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medicationsOrdered);
}

 final  List<AiLabResult> _labResults;
@override@JsonKey(name: 'lab_results') List<AiLabResult> get labResults {
  if (_labResults is EqualUnmodifiableListView) return _labResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labResults);
}

 final  List<AiProblem> _problems;
@override@JsonKey() List<AiProblem> get problems {
  if (_problems is EqualUnmodifiableListView) return _problems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_problems);
}

@override@JsonKey(name: 'unlinked_management') final  AiUnlinkedManagement unlinkedManagement;
 final  List<AiClinicalWarning> _clinicalWarnings;
@override@JsonKey(name: 'clinical_warnings') List<AiClinicalWarning> get clinicalWarnings {
  if (_clinicalWarnings is EqualUnmodifiableListView) return _clinicalWarnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinicalWarnings);
}

@override@JsonKey() final  String clinicalSummary;
/// Verbatim narrative conclusion from the document — the "Conclusion",
/// "Impression", "Final Remarks" or "Advice" block that pathology,
/// radiology and discharge summaries carry at the foot of the page.
///
/// This is kept separate from [clinicalSummary] because it is the part a
/// pathologist or radiologist *wrote* for the clinician to read, and losing
/// it is the single most damaging way OCR can truncate a report: every
/// numeric value survives but the interpretation does not. Storing it apart
/// also keeps it editable in review instead of being flattened into prose.
@override@JsonKey(name: 'conclusion') final  String conclusion;
/// The date the document was WRITTEN (ISO-8601), never today's date.
/// ClinCom is instructed never to substitute the current date, so a
/// back-dated report keeps its true clinical date.
@override@JsonKey(name: 'document_date') final  String documentDate;
/// True when [documentDate] was inferred rather than read off the page.
@override@JsonKey(name: 'is_date_assumed') final  bool isDateAssumed;
/// Patient resolved from a bed/ward number via the appended active census
/// JSON. Null when the page carried no bed number or the bed was ambiguous
/// — ClinCom is explicitly forbidden from guessing a patient.
@override@JsonKey(name: 'inferred_patient_id') final  String? inferredPatientId;
 final  List<String> _chiefComplaints;
@override@JsonKey(name: 'chief_complaints') List<String> get chiefComplaints {
  if (_chiefComplaints is EqualUnmodifiableListView) return _chiefComplaints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chiefComplaints);
}

 final  List<String> _diagnoses;
@override@JsonKey(name: 'diagnoses') List<String> get diagnoses {
  if (_diagnoses is EqualUnmodifiableListView) return _diagnoses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_diagnoses);
}

 final  List<String> _plannedInvestigations;
@override@JsonKey(name: 'planned_investigations') List<String> get plannedInvestigations {
  if (_plannedInvestigations is EqualUnmodifiableListView) return _plannedInvestigations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plannedInvestigations);
}

/// Provenance of this reading. Drives Sprint 17 semantic merging: a
/// formal 'Scanned Document' report outranks a 'Ward Round Note'.
@override@JsonKey(name: 'source_authority') final  String? sourceAuthority;

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiExtractionResultCopyWith<_AiExtractionResult> get copyWith => __$AiExtractionResultCopyWithImpl<_AiExtractionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiExtractionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiExtractionResult&&(identical(other.patientIdentity, patientIdentity) || other.patientIdentity == patientIdentity)&&(identical(other.encounterContext, encounterContext) || other.encounterContext == encounterContext)&&(identical(other.vitals, vitals) || other.vitals == vitals)&&const DeepCollectionEquality().equals(other._medicationsOrdered, _medicationsOrdered)&&const DeepCollectionEquality().equals(other._labResults, _labResults)&&const DeepCollectionEquality().equals(other._problems, _problems)&&(identical(other.unlinkedManagement, unlinkedManagement) || other.unlinkedManagement == unlinkedManagement)&&const DeepCollectionEquality().equals(other._clinicalWarnings, _clinicalWarnings)&&(identical(other.clinicalSummary, clinicalSummary) || other.clinicalSummary == clinicalSummary)&&(identical(other.conclusion, conclusion) || other.conclusion == conclusion)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.isDateAssumed, isDateAssumed) || other.isDateAssumed == isDateAssumed)&&(identical(other.inferredPatientId, inferredPatientId) || other.inferredPatientId == inferredPatientId)&&const DeepCollectionEquality().equals(other._chiefComplaints, _chiefComplaints)&&const DeepCollectionEquality().equals(other._diagnoses, _diagnoses)&&const DeepCollectionEquality().equals(other._plannedInvestigations, _plannedInvestigations)&&(identical(other.sourceAuthority, sourceAuthority) || other.sourceAuthority == sourceAuthority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientIdentity,encounterContext,vitals,const DeepCollectionEquality().hash(_medicationsOrdered),const DeepCollectionEquality().hash(_labResults),const DeepCollectionEquality().hash(_problems),unlinkedManagement,const DeepCollectionEquality().hash(_clinicalWarnings),clinicalSummary,conclusion,documentDate,isDateAssumed,inferredPatientId,const DeepCollectionEquality().hash(_chiefComplaints),const DeepCollectionEquality().hash(_diagnoses),const DeepCollectionEquality().hash(_plannedInvestigations),sourceAuthority);

@override
String toString() {
  return 'AiExtractionResult(patientIdentity: $patientIdentity, encounterContext: $encounterContext, vitals: $vitals, medicationsOrdered: $medicationsOrdered, labResults: $labResults, problems: $problems, unlinkedManagement: $unlinkedManagement, clinicalWarnings: $clinicalWarnings, clinicalSummary: $clinicalSummary, conclusion: $conclusion, documentDate: $documentDate, isDateAssumed: $isDateAssumed, inferredPatientId: $inferredPatientId, chiefComplaints: $chiefComplaints, diagnoses: $diagnoses, plannedInvestigations: $plannedInvestigations, sourceAuthority: $sourceAuthority)';
}


}

/// @nodoc
abstract mixin class _$AiExtractionResultCopyWith<$Res> implements $AiExtractionResultCopyWith<$Res> {
  factory _$AiExtractionResultCopyWith(_AiExtractionResult value, $Res Function(_AiExtractionResult) _then) = __$AiExtractionResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'patient_identity') PatientIdentity patientIdentity,@JsonKey(name: 'encounter_context') EncounterContext encounterContext, AiVitals vitals,@JsonKey(name: 'medications_ordered') List<OrderedMedication> medicationsOrdered,@JsonKey(name: 'lab_results') List<AiLabResult> labResults, List<AiProblem> problems,@JsonKey(name: 'unlinked_management') AiUnlinkedManagement unlinkedManagement,@JsonKey(name: 'clinical_warnings') List<AiClinicalWarning> clinicalWarnings, String clinicalSummary,@JsonKey(name: 'conclusion') String conclusion,@JsonKey(name: 'document_date') String documentDate,@JsonKey(name: 'is_date_assumed') bool isDateAssumed,@JsonKey(name: 'inferred_patient_id') String? inferredPatientId,@JsonKey(name: 'chief_complaints') List<String> chiefComplaints,@JsonKey(name: 'diagnoses') List<String> diagnoses,@JsonKey(name: 'planned_investigations') List<String> plannedInvestigations,@JsonKey(name: 'source_authority') String? sourceAuthority
});


@override $PatientIdentityCopyWith<$Res> get patientIdentity;@override $EncounterContextCopyWith<$Res> get encounterContext;@override $AiVitalsCopyWith<$Res> get vitals;@override $AiUnlinkedManagementCopyWith<$Res> get unlinkedManagement;

}
/// @nodoc
class __$AiExtractionResultCopyWithImpl<$Res>
    implements _$AiExtractionResultCopyWith<$Res> {
  __$AiExtractionResultCopyWithImpl(this._self, this._then);

  final _AiExtractionResult _self;
  final $Res Function(_AiExtractionResult) _then;

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patientIdentity = null,Object? encounterContext = null,Object? vitals = null,Object? medicationsOrdered = null,Object? labResults = null,Object? problems = null,Object? unlinkedManagement = null,Object? clinicalWarnings = null,Object? clinicalSummary = null,Object? conclusion = null,Object? documentDate = null,Object? isDateAssumed = null,Object? inferredPatientId = freezed,Object? chiefComplaints = null,Object? diagnoses = null,Object? plannedInvestigations = null,Object? sourceAuthority = freezed,}) {
  return _then(_AiExtractionResult(
patientIdentity: null == patientIdentity ? _self.patientIdentity : patientIdentity // ignore: cast_nullable_to_non_nullable
as PatientIdentity,encounterContext: null == encounterContext ? _self.encounterContext : encounterContext // ignore: cast_nullable_to_non_nullable
as EncounterContext,vitals: null == vitals ? _self.vitals : vitals // ignore: cast_nullable_to_non_nullable
as AiVitals,medicationsOrdered: null == medicationsOrdered ? _self._medicationsOrdered : medicationsOrdered // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,labResults: null == labResults ? _self._labResults : labResults // ignore: cast_nullable_to_non_nullable
as List<AiLabResult>,problems: null == problems ? _self._problems : problems // ignore: cast_nullable_to_non_nullable
as List<AiProblem>,unlinkedManagement: null == unlinkedManagement ? _self.unlinkedManagement : unlinkedManagement // ignore: cast_nullable_to_non_nullable
as AiUnlinkedManagement,clinicalWarnings: null == clinicalWarnings ? _self._clinicalWarnings : clinicalWarnings // ignore: cast_nullable_to_non_nullable
as List<AiClinicalWarning>,clinicalSummary: null == clinicalSummary ? _self.clinicalSummary : clinicalSummary // ignore: cast_nullable_to_non_nullable
as String,conclusion: null == conclusion ? _self.conclusion : conclusion // ignore: cast_nullable_to_non_nullable
as String,documentDate: null == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String,isDateAssumed: null == isDateAssumed ? _self.isDateAssumed : isDateAssumed // ignore: cast_nullable_to_non_nullable
as bool,inferredPatientId: freezed == inferredPatientId ? _self.inferredPatientId : inferredPatientId // ignore: cast_nullable_to_non_nullable
as String?,chiefComplaints: null == chiefComplaints ? _self._chiefComplaints : chiefComplaints // ignore: cast_nullable_to_non_nullable
as List<String>,diagnoses: null == diagnoses ? _self._diagnoses : diagnoses // ignore: cast_nullable_to_non_nullable
as List<String>,plannedInvestigations: null == plannedInvestigations ? _self._plannedInvestigations : plannedInvestigations // ignore: cast_nullable_to_non_nullable
as List<String>,sourceAuthority: freezed == sourceAuthority ? _self.sourceAuthority : sourceAuthority // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientIdentityCopyWith<$Res> get patientIdentity {
  
  return $PatientIdentityCopyWith<$Res>(_self.patientIdentity, (value) {
    return _then(_self.copyWith(patientIdentity: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncounterContextCopyWith<$Res> get encounterContext {
  
  return $EncounterContextCopyWith<$Res>(_self.encounterContext, (value) {
    return _then(_self.copyWith(encounterContext: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiVitalsCopyWith<$Res> get vitals {
  
  return $AiVitalsCopyWith<$Res>(_self.vitals, (value) {
    return _then(_self.copyWith(vitals: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiUnlinkedManagementCopyWith<$Res> get unlinkedManagement {

  return $AiUnlinkedManagementCopyWith<$Res>(_self.unlinkedManagement, (value) {
    return _then(_self.copyWith(unlinkedManagement: value));
  });
}
}


/// @nodoc
mixin _$PatientIdentity {

 String? get name; int? get age; String? get gender;@JsonKey(name: 'hospital_reg_no') String? get hospitalRegNo;/// Sprint 15 — the facility this document was captured at.
///
/// Needed because a clinician covering several institutions can scan a
/// report at hospital B for a patient whose identity record lives at
/// hospital A. Without this the encounter and its observations are filed
/// against whichever facility happened to be listed first, silently
/// corrupting multi-hospital tracking.
@JsonKey(name: 'hospital_id') String? get hospitalId;
/// Create a copy of PatientIdentity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientIdentityCopyWith<PatientIdentity> get copyWith => _$PatientIdentityCopyWithImpl<PatientIdentity>(this as PatientIdentity, _$identity);

  /// Serializes this PatientIdentity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientIdentity&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.hospitalRegNo, hospitalRegNo) || other.hospitalRegNo == hospitalRegNo)&&(identical(other.hospitalId, hospitalId) || other.hospitalId == hospitalId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,gender,hospitalRegNo,hospitalId);

@override
String toString() {
  return 'PatientIdentity(name: $name, age: $age, gender: $gender, hospitalRegNo: $hospitalRegNo, hospitalId: $hospitalId)';
}


}

/// @nodoc
abstract mixin class $PatientIdentityCopyWith<$Res>  {
  factory $PatientIdentityCopyWith(PatientIdentity value, $Res Function(PatientIdentity) _then) = _$PatientIdentityCopyWithImpl;
@useResult
$Res call({
 String? name, int? age, String? gender,@JsonKey(name: 'hospital_reg_no') String? hospitalRegNo,@JsonKey(name: 'hospital_id') String? hospitalId
});




}
/// @nodoc
class _$PatientIdentityCopyWithImpl<$Res>
    implements $PatientIdentityCopyWith<$Res> {
  _$PatientIdentityCopyWithImpl(this._self, this._then);

  final PatientIdentity _self;
  final $Res Function(PatientIdentity) _then;

/// Create a copy of PatientIdentity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? age = freezed,Object? gender = freezed,Object? hospitalRegNo = freezed,Object? hospitalId = freezed,}) {
  return _then(PatientIdentity(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,hospitalRegNo: freezed == hospitalRegNo ? _self.hospitalRegNo : hospitalRegNo // ignore: cast_nullable_to_non_nullable
as String?,hospitalId: freezed == hospitalId ? _self.hospitalId : hospitalId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientIdentity].
extension PatientIdentityPatterns on PatientIdentity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientIdentity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientIdentity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientIdentity value)  $default,){
final _that = this;
switch (_that) {
case _PatientIdentity():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientIdentity value)?  $default,){
final _that = this;
switch (_that) {
case _PatientIdentity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  int? age,  String? gender, @JsonKey(name: 'hospital_reg_no')  String? hospitalRegNo, @JsonKey(name: 'hospital_id')  String? hospitalId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientIdentity() when $default != null:
return $default(_that.name,_that.age,_that.gender,_that.hospitalRegNo,_that.hospitalId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  int? age,  String? gender, @JsonKey(name: 'hospital_reg_no')  String? hospitalRegNo, @JsonKey(name: 'hospital_id')  String? hospitalId)  $default,) {final _that = this;
switch (_that) {
case _PatientIdentity():
return $default(_that.name,_that.age,_that.gender,_that.hospitalRegNo,_that.hospitalId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  int? age,  String? gender, @JsonKey(name: 'hospital_reg_no')  String? hospitalRegNo, @JsonKey(name: 'hospital_id')  String? hospitalId)?  $default,) {final _that = this;
switch (_that) {
case _PatientIdentity() when $default != null:
return $default(_that.name,_that.age,_that.gender,_that.hospitalRegNo,_that.hospitalId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatientIdentity implements PatientIdentity {
  const _PatientIdentity({this.name, this.age, this.gender, @JsonKey(name: 'hospital_reg_no') this.hospitalRegNo, @JsonKey(name: 'hospital_id') this.hospitalId});
  factory _PatientIdentity.fromJson(Map<String, dynamic> json) => _$PatientIdentityFromJson(json);

@override final  String? name;
@override final  int? age;
@override final  String? gender;
@override@JsonKey(name: 'hospital_reg_no') final  String? hospitalRegNo;
/// Sprint 15 — the facility this document was captured at.
///
/// Needed because a clinician covering several institutions can scan a
/// report at hospital B for a patient whose identity record lives at
/// hospital A. Without this the encounter and its observations are filed
/// against whichever facility happened to be listed first, silently
/// corrupting multi-hospital tracking.
@override@JsonKey(name: 'hospital_id') final  String? hospitalId;

/// Create a copy of PatientIdentity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientIdentityCopyWith<_PatientIdentity> get copyWith => __$PatientIdentityCopyWithImpl<_PatientIdentity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatientIdentityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientIdentity&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.hospitalRegNo, hospitalRegNo) || other.hospitalRegNo == hospitalRegNo)&&(identical(other.hospitalId, hospitalId) || other.hospitalId == hospitalId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,gender,hospitalRegNo,hospitalId);

@override
String toString() {
  return 'PatientIdentity(name: $name, age: $age, gender: $gender, hospitalRegNo: $hospitalRegNo, hospitalId: $hospitalId)';
}


}

/// @nodoc
abstract mixin class _$PatientIdentityCopyWith<$Res> implements $PatientIdentityCopyWith<$Res> {
  factory _$PatientIdentityCopyWith(_PatientIdentity value, $Res Function(_PatientIdentity) _then) = __$PatientIdentityCopyWithImpl;
@override @useResult
$Res call({
 String? name, int? age, String? gender,@JsonKey(name: 'hospital_reg_no') String? hospitalRegNo,@JsonKey(name: 'hospital_id') String? hospitalId
});




}
/// @nodoc
class __$PatientIdentityCopyWithImpl<$Res>
    implements _$PatientIdentityCopyWith<$Res> {
  __$PatientIdentityCopyWithImpl(this._self, this._then);

  final _PatientIdentity _self;
  final $Res Function(_PatientIdentity) _then;

/// Create a copy of PatientIdentity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? age = freezed,Object? gender = freezed,Object? hospitalRegNo = freezed,Object? hospitalId = freezed,}) {
  return _then(_PatientIdentity(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,hospitalRegNo: freezed == hospitalRegNo ? _self.hospitalRegNo : hospitalRegNo // ignore: cast_nullable_to_non_nullable
as String?,hospitalId: freezed == hospitalId ? _self.hospitalId : hospitalId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EncounterContext {

@JsonKey(name: 'document_type') String get documentType; String? get date; String? get department;@JsonKey(name: 'ward_bed') String? get wardBed;
/// Create a copy of EncounterContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncounterContextCopyWith<EncounterContext> get copyWith => _$EncounterContextCopyWithImpl<EncounterContext>(this as EncounterContext, _$identity);

  /// Serializes this EncounterContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncounterContext&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.date, date) || other.date == date)&&(identical(other.department, department) || other.department == department)&&(identical(other.wardBed, wardBed) || other.wardBed == wardBed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,date,department,wardBed);

@override
String toString() {
  return 'EncounterContext(documentType: $documentType, date: $date, department: $department, wardBed: $wardBed)';
}


}

/// @nodoc
abstract mixin class $EncounterContextCopyWith<$Res>  {
  factory $EncounterContextCopyWith(EncounterContext value, $Res Function(EncounterContext) _then) = _$EncounterContextCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'document_type') String documentType, String? date, String? department,@JsonKey(name: 'ward_bed') String? wardBed
});




}
/// @nodoc
class _$EncounterContextCopyWithImpl<$Res>
    implements $EncounterContextCopyWith<$Res> {
  _$EncounterContextCopyWithImpl(this._self, this._then);

  final EncounterContext _self;
  final $Res Function(EncounterContext) _then;

/// Create a copy of EncounterContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentType = null,Object? date = freezed,Object? department = freezed,Object? wardBed = freezed,}) {
  return _then(EncounterContext(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,wardBed: freezed == wardBed ? _self.wardBed : wardBed // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EncounterContext].
extension EncounterContextPatterns on EncounterContext {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncounterContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncounterContext() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncounterContext value)  $default,){
final _that = this;
switch (_that) {
case _EncounterContext():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncounterContext value)?  $default,){
final _that = this;
switch (_that) {
case _EncounterContext() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_type')  String documentType,  String? date,  String? department, @JsonKey(name: 'ward_bed')  String? wardBed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncounterContext() when $default != null:
return $default(_that.documentType,_that.date,_that.department,_that.wardBed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'document_type')  String documentType,  String? date,  String? department, @JsonKey(name: 'ward_bed')  String? wardBed)  $default,) {final _that = this;
switch (_that) {
case _EncounterContext():
return $default(_that.documentType,_that.date,_that.department,_that.wardBed);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'document_type')  String documentType,  String? date,  String? department, @JsonKey(name: 'ward_bed')  String? wardBed)?  $default,) {final _that = this;
switch (_that) {
case _EncounterContext() when $default != null:
return $default(_that.documentType,_that.date,_that.department,_that.wardBed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncounterContext implements EncounterContext {
  const _EncounterContext({@JsonKey(name: 'document_type') this.documentType = '', this.date, this.department, @JsonKey(name: 'ward_bed') this.wardBed});
  factory _EncounterContext.fromJson(Map<String, dynamic> json) => _$EncounterContextFromJson(json);

@override@JsonKey(name: 'document_type') final  String documentType;
@override final  String? date;
@override final  String? department;
@override@JsonKey(name: 'ward_bed') final  String? wardBed;

/// Create a copy of EncounterContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncounterContextCopyWith<_EncounterContext> get copyWith => __$EncounterContextCopyWithImpl<_EncounterContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncounterContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncounterContext&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.date, date) || other.date == date)&&(identical(other.department, department) || other.department == department)&&(identical(other.wardBed, wardBed) || other.wardBed == wardBed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,date,department,wardBed);

@override
String toString() {
  return 'EncounterContext(documentType: $documentType, date: $date, department: $department, wardBed: $wardBed)';
}


}

/// @nodoc
abstract mixin class _$EncounterContextCopyWith<$Res> implements $EncounterContextCopyWith<$Res> {
  factory _$EncounterContextCopyWith(_EncounterContext value, $Res Function(_EncounterContext) _then) = __$EncounterContextCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'document_type') String documentType, String? date, String? department,@JsonKey(name: 'ward_bed') String? wardBed
});




}
/// @nodoc
class __$EncounterContextCopyWithImpl<$Res>
    implements _$EncounterContextCopyWith<$Res> {
  __$EncounterContextCopyWithImpl(this._self, this._then);

  final _EncounterContext _self;
  final $Res Function(_EncounterContext) _then;

/// Create a copy of EncounterContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentType = null,Object? date = freezed,Object? department = freezed,Object? wardBed = freezed,}) {
  return _then(_EncounterContext(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,wardBed: freezed == wardBed ? _self.wardBed : wardBed // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OrderedMedication {

@JsonKey(name: 'drug_name', readValue: _readDrugName) String get drugName;@JsonKey(readValue: _readDosage) String? get dosage; String? get frequency; String? get route; String? get duration;
/// Create a copy of OrderedMedication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderedMedicationCopyWith<OrderedMedication> get copyWith => _$OrderedMedicationCopyWithImpl<OrderedMedication>(this as OrderedMedication, _$identity);

  /// Serializes this OrderedMedication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderedMedication&&(identical(other.drugName, drugName) || other.drugName == drugName)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.route, route) || other.route == route)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,drugName,dosage,frequency,route,duration);

@override
String toString() {
  return 'OrderedMedication(drugName: $drugName, dosage: $dosage, frequency: $frequency, route: $route, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $OrderedMedicationCopyWith<$Res>  {
  factory $OrderedMedicationCopyWith(OrderedMedication value, $Res Function(OrderedMedication) _then) = _$OrderedMedicationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'drug_name', readValue: _readDrugName) String drugName,@JsonKey(readValue: _readDosage) String? dosage, String? frequency, String? route, String? duration
});




}
/// @nodoc
class _$OrderedMedicationCopyWithImpl<$Res>
    implements $OrderedMedicationCopyWith<$Res> {
  _$OrderedMedicationCopyWithImpl(this._self, this._then);

  final OrderedMedication _self;
  final $Res Function(OrderedMedication) _then;

/// Create a copy of OrderedMedication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? drugName = null,Object? dosage = freezed,Object? frequency = freezed,Object? route = freezed,Object? duration = freezed,}) {
  return _then(OrderedMedication(
drugName: null == drugName ? _self.drugName : drugName // ignore: cast_nullable_to_non_nullable
as String,dosage: freezed == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderedMedication].
extension OrderedMedicationPatterns on OrderedMedication {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderedMedication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderedMedication() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderedMedication value)  $default,){
final _that = this;
switch (_that) {
case _OrderedMedication():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderedMedication value)?  $default,){
final _that = this;
switch (_that) {
case _OrderedMedication() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'drug_name', readValue: _readDrugName)  String drugName, @JsonKey(readValue: _readDosage)  String? dosage,  String? frequency,  String? route,  String? duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderedMedication() when $default != null:
return $default(_that.drugName,_that.dosage,_that.frequency,_that.route,_that.duration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'drug_name', readValue: _readDrugName)  String drugName, @JsonKey(readValue: _readDosage)  String? dosage,  String? frequency,  String? route,  String? duration)  $default,) {final _that = this;
switch (_that) {
case _OrderedMedication():
return $default(_that.drugName,_that.dosage,_that.frequency,_that.route,_that.duration);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'drug_name', readValue: _readDrugName)  String drugName, @JsonKey(readValue: _readDosage)  String? dosage,  String? frequency,  String? route,  String? duration)?  $default,) {final _that = this;
switch (_that) {
case _OrderedMedication() when $default != null:
return $default(_that.drugName,_that.dosage,_that.frequency,_that.route,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderedMedication implements OrderedMedication {
  const _OrderedMedication({@JsonKey(name: 'drug_name', readValue: _readDrugName) this.drugName = '', @JsonKey(readValue: _readDosage) this.dosage, this.frequency, this.route, this.duration});
  factory _OrderedMedication.fromJson(Map<String, dynamic> json) => _$OrderedMedicationFromJson(json);

@override@JsonKey(name: 'drug_name', readValue: _readDrugName) final  String drugName;
@override@JsonKey(readValue: _readDosage) final  String? dosage;
@override final  String? frequency;
@override final  String? route;
@override final  String? duration;

/// Create a copy of OrderedMedication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderedMedicationCopyWith<_OrderedMedication> get copyWith => __$OrderedMedicationCopyWithImpl<_OrderedMedication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderedMedicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderedMedication&&(identical(other.drugName, drugName) || other.drugName == drugName)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.route, route) || other.route == route)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,drugName,dosage,frequency,route,duration);

@override
String toString() {
  return 'OrderedMedication(drugName: $drugName, dosage: $dosage, frequency: $frequency, route: $route, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$OrderedMedicationCopyWith<$Res> implements $OrderedMedicationCopyWith<$Res> {
  factory _$OrderedMedicationCopyWith(_OrderedMedication value, $Res Function(_OrderedMedication) _then) = __$OrderedMedicationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'drug_name', readValue: _readDrugName) String drugName,@JsonKey(readValue: _readDosage) String? dosage, String? frequency, String? route, String? duration
});




}
/// @nodoc
class __$OrderedMedicationCopyWithImpl<$Res>
    implements _$OrderedMedicationCopyWith<$Res> {
  __$OrderedMedicationCopyWithImpl(this._self, this._then);

  final _OrderedMedication _self;
  final $Res Function(_OrderedMedication) _then;

/// Create a copy of OrderedMedication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? drugName = null,Object? dosage = freezed,Object? frequency = freezed,Object? route = freezed,Object? duration = freezed,}) {
  return _then(_OrderedMedication(
drugName: null == drugName ? _self.drugName : drugName // ignore: cast_nullable_to_non_nullable
as String,dosage: freezed == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AiProblem {

 String get diagnosis;@JsonKey(name: 'linked_medications') List<OrderedMedication> get linkedMedications;@JsonKey(name: 'linked_investigations') List<AiInvestigation> get linkedInvestigations;@JsonKey(name: 'linked_procedures') List<AiProcedure> get linkedProcedures; String get reasoning;
/// Create a copy of AiProblem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiProblemCopyWith<AiProblem> get copyWith => _$AiProblemCopyWithImpl<AiProblem>(this as AiProblem, _$identity);

  /// Serializes this AiProblem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiProblem&&(identical(other.diagnosis, diagnosis) || other.diagnosis == diagnosis)&&const DeepCollectionEquality().equals(other.linkedMedications, linkedMedications)&&const DeepCollectionEquality().equals(other.linkedInvestigations, linkedInvestigations)&&const DeepCollectionEquality().equals(other.linkedProcedures, linkedProcedures)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diagnosis,const DeepCollectionEquality().hash(linkedMedications),const DeepCollectionEquality().hash(linkedInvestigations),const DeepCollectionEquality().hash(linkedProcedures),reasoning);

@override
String toString() {
  return 'AiProblem(diagnosis: $diagnosis, linkedMedications: $linkedMedications, linkedInvestigations: $linkedInvestigations, linkedProcedures: $linkedProcedures, reasoning: $reasoning)';
}


}

/// @nodoc
abstract mixin class $AiProblemCopyWith<$Res>  {
  factory $AiProblemCopyWith(AiProblem value, $Res Function(AiProblem) _then) = _$AiProblemCopyWithImpl;
@useResult
$Res call({
 String diagnosis,@JsonKey(name: 'linked_medications') List<OrderedMedication> linkedMedications,@JsonKey(name: 'linked_investigations') List<AiInvestigation> linkedInvestigations,@JsonKey(name: 'linked_procedures') List<AiProcedure> linkedProcedures, String reasoning
});




}
/// @nodoc
class _$AiProblemCopyWithImpl<$Res>
    implements $AiProblemCopyWith<$Res> {
  _$AiProblemCopyWithImpl(this._self, this._then);

  final AiProblem _self;
  final $Res Function(AiProblem) _then;

/// Create a copy of AiProblem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? diagnosis = null,Object? linkedMedications = null,Object? linkedInvestigations = null,Object? linkedProcedures = null,Object? reasoning = null,}) {
  return _then(AiProblem(
diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as String,linkedMedications: null == linkedMedications ? _self.linkedMedications : linkedMedications // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,linkedInvestigations: null == linkedInvestigations ? _self.linkedInvestigations : linkedInvestigations // ignore: cast_nullable_to_non_nullable
as List<AiInvestigation>,linkedProcedures: null == linkedProcedures ? _self.linkedProcedures : linkedProcedures // ignore: cast_nullable_to_non_nullable
as List<AiProcedure>,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiProblem].
extension AiProblemPatterns on AiProblem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiProblem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiProblem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiProblem value)  $default,){
final _that = this;
switch (_that) {
case _AiProblem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiProblem value)?  $default,){
final _that = this;
switch (_that) {
case _AiProblem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String diagnosis, @JsonKey(name: 'linked_medications')  List<OrderedMedication> linkedMedications, @JsonKey(name: 'linked_investigations')  List<AiInvestigation> linkedInvestigations, @JsonKey(name: 'linked_procedures')  List<AiProcedure> linkedProcedures,  String reasoning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiProblem() when $default != null:
return $default(_that.diagnosis,_that.linkedMedications,_that.linkedInvestigations,_that.linkedProcedures,_that.reasoning);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String diagnosis, @JsonKey(name: 'linked_medications')  List<OrderedMedication> linkedMedications, @JsonKey(name: 'linked_investigations')  List<AiInvestigation> linkedInvestigations, @JsonKey(name: 'linked_procedures')  List<AiProcedure> linkedProcedures,  String reasoning)  $default,) {final _that = this;
switch (_that) {
case _AiProblem():
return $default(_that.diagnosis,_that.linkedMedications,_that.linkedInvestigations,_that.linkedProcedures,_that.reasoning);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String diagnosis, @JsonKey(name: 'linked_medications')  List<OrderedMedication> linkedMedications, @JsonKey(name: 'linked_investigations')  List<AiInvestigation> linkedInvestigations, @JsonKey(name: 'linked_procedures')  List<AiProcedure> linkedProcedures,  String reasoning)?  $default,) {final _that = this;
switch (_that) {
case _AiProblem() when $default != null:
return $default(_that.diagnosis,_that.linkedMedications,_that.linkedInvestigations,_that.linkedProcedures,_that.reasoning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiProblem implements AiProblem {
  const _AiProblem({this.diagnosis = '', @JsonKey(name: 'linked_medications')  List<OrderedMedication> linkedMedications = const <OrderedMedication>[], @JsonKey(name: 'linked_investigations')  List<AiInvestigation> linkedInvestigations = const <AiInvestigation>[], @JsonKey(name: 'linked_procedures')  List<AiProcedure> linkedProcedures = const <AiProcedure>[], this.reasoning = ''}): _linkedMedications = linkedMedications,_linkedInvestigations = linkedInvestigations,_linkedProcedures = linkedProcedures;
  factory _AiProblem.fromJson(Map<String, dynamic> json) => _$AiProblemFromJson(json);

@override@JsonKey() final  String diagnosis;
 final  List<OrderedMedication> _linkedMedications;
@override@JsonKey(name: 'linked_medications') List<OrderedMedication> get linkedMedications {
  if (_linkedMedications is EqualUnmodifiableListView) return _linkedMedications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linkedMedications);
}

 final  List<AiInvestigation> _linkedInvestigations;
@override@JsonKey(name: 'linked_investigations') List<AiInvestigation> get linkedInvestigations {
  if (_linkedInvestigations is EqualUnmodifiableListView) return _linkedInvestigations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linkedInvestigations);
}

 final  List<AiProcedure> _linkedProcedures;
@override@JsonKey(name: 'linked_procedures') List<AiProcedure> get linkedProcedures {
  if (_linkedProcedures is EqualUnmodifiableListView) return _linkedProcedures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linkedProcedures);
}

@override@JsonKey() final  String reasoning;

/// Create a copy of AiProblem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiProblemCopyWith<_AiProblem> get copyWith => __$AiProblemCopyWithImpl<_AiProblem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiProblemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiProblem&&(identical(other.diagnosis, diagnosis) || other.diagnosis == diagnosis)&&const DeepCollectionEquality().equals(other._linkedMedications, _linkedMedications)&&const DeepCollectionEquality().equals(other._linkedInvestigations, _linkedInvestigations)&&const DeepCollectionEquality().equals(other._linkedProcedures, _linkedProcedures)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diagnosis,const DeepCollectionEquality().hash(_linkedMedications),const DeepCollectionEquality().hash(_linkedInvestigations),const DeepCollectionEquality().hash(_linkedProcedures),reasoning);

@override
String toString() {
  return 'AiProblem(diagnosis: $diagnosis, linkedMedications: $linkedMedications, linkedInvestigations: $linkedInvestigations, linkedProcedures: $linkedProcedures, reasoning: $reasoning)';
}


}

/// @nodoc
abstract mixin class _$AiProblemCopyWith<$Res> implements $AiProblemCopyWith<$Res> {
  factory _$AiProblemCopyWith(_AiProblem value, $Res Function(_AiProblem) _then) = __$AiProblemCopyWithImpl;
@override @useResult
$Res call({
 String diagnosis,@JsonKey(name: 'linked_medications') List<OrderedMedication> linkedMedications,@JsonKey(name: 'linked_investigations') List<AiInvestigation> linkedInvestigations,@JsonKey(name: 'linked_procedures') List<AiProcedure> linkedProcedures, String reasoning
});




}
/// @nodoc
class __$AiProblemCopyWithImpl<$Res>
    implements _$AiProblemCopyWith<$Res> {
  __$AiProblemCopyWithImpl(this._self, this._then);

  final _AiProblem _self;
  final $Res Function(_AiProblem) _then;

/// Create a copy of AiProblem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? diagnosis = null,Object? linkedMedications = null,Object? linkedInvestigations = null,Object? linkedProcedures = null,Object? reasoning = null,}) {
  return _then(_AiProblem(
diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as String,linkedMedications: null == linkedMedications ? _self._linkedMedications : linkedMedications // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,linkedInvestigations: null == linkedInvestigations ? _self._linkedInvestigations : linkedInvestigations // ignore: cast_nullable_to_non_nullable
as List<AiInvestigation>,linkedProcedures: null == linkedProcedures ? _self._linkedProcedures : linkedProcedures // ignore: cast_nullable_to_non_nullable
as List<AiProcedure>,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AiUnlinkedManagement {

 List<OrderedMedication> get medications; List<AiInvestigation> get investigations; List<AiProcedure> get procedures;
/// Create a copy of AiUnlinkedManagement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiUnlinkedManagementCopyWith<AiUnlinkedManagement> get copyWith => _$AiUnlinkedManagementCopyWithImpl<AiUnlinkedManagement>(this as AiUnlinkedManagement, _$identity);

  /// Serializes this AiUnlinkedManagement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiUnlinkedManagement&&const DeepCollectionEquality().equals(other.medications, medications)&&const DeepCollectionEquality().equals(other.investigations, investigations)&&const DeepCollectionEquality().equals(other.procedures, procedures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(medications),const DeepCollectionEquality().hash(investigations),const DeepCollectionEquality().hash(procedures));

@override
String toString() {
  return 'AiUnlinkedManagement(medications: $medications, investigations: $investigations, procedures: $procedures)';
}


}

/// @nodoc
abstract mixin class $AiUnlinkedManagementCopyWith<$Res>  {
  factory $AiUnlinkedManagementCopyWith(AiUnlinkedManagement value, $Res Function(AiUnlinkedManagement) _then) = _$AiUnlinkedManagementCopyWithImpl;
@useResult
$Res call({
 List<OrderedMedication> medications, List<AiInvestigation> investigations, List<AiProcedure> procedures
});




}
/// @nodoc
class _$AiUnlinkedManagementCopyWithImpl<$Res>
    implements $AiUnlinkedManagementCopyWith<$Res> {
  _$AiUnlinkedManagementCopyWithImpl(this._self, this._then);

  final AiUnlinkedManagement _self;
  final $Res Function(AiUnlinkedManagement) _then;

/// Create a copy of AiUnlinkedManagement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? medications = null,Object? investigations = null,Object? procedures = null,}) {
  return _then(AiUnlinkedManagement(
medications: null == medications ? _self.medications : medications // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,investigations: null == investigations ? _self.investigations : investigations // ignore: cast_nullable_to_non_nullable
as List<AiInvestigation>,procedures: null == procedures ? _self.procedures : procedures // ignore: cast_nullable_to_non_nullable
as List<AiProcedure>,
  ));
}

}


/// Adds pattern-matching-related methods to [AiUnlinkedManagement].
extension AiUnlinkedManagementPatterns on AiUnlinkedManagement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiUnlinkedManagement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiUnlinkedManagement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiUnlinkedManagement value)  $default,){
final _that = this;
switch (_that) {
case _AiUnlinkedManagement():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiUnlinkedManagement value)?  $default,){
final _that = this;
switch (_that) {
case _AiUnlinkedManagement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OrderedMedication> medications,  List<AiInvestigation> investigations,  List<AiProcedure> procedures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiUnlinkedManagement() when $default != null:
return $default(_that.medications,_that.investigations,_that.procedures);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OrderedMedication> medications,  List<AiInvestigation> investigations,  List<AiProcedure> procedures)  $default,) {final _that = this;
switch (_that) {
case _AiUnlinkedManagement():
return $default(_that.medications,_that.investigations,_that.procedures);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OrderedMedication> medications,  List<AiInvestigation> investigations,  List<AiProcedure> procedures)?  $default,) {final _that = this;
switch (_that) {
case _AiUnlinkedManagement() when $default != null:
return $default(_that.medications,_that.investigations,_that.procedures);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiUnlinkedManagement implements AiUnlinkedManagement {
  const _AiUnlinkedManagement({ List<OrderedMedication> medications = const <OrderedMedication>[],  List<AiInvestigation> investigations = const <AiInvestigation>[],  List<AiProcedure> procedures = const <AiProcedure>[]}): _medications = medications,_investigations = investigations,_procedures = procedures;
  factory _AiUnlinkedManagement.fromJson(Map<String, dynamic> json) => _$AiUnlinkedManagementFromJson(json);

 final  List<OrderedMedication> _medications;
@override@JsonKey() List<OrderedMedication> get medications {
  if (_medications is EqualUnmodifiableListView) return _medications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medications);
}

 final  List<AiInvestigation> _investigations;
@override@JsonKey() List<AiInvestigation> get investigations {
  if (_investigations is EqualUnmodifiableListView) return _investigations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_investigations);
}

 final  List<AiProcedure> _procedures;
@override@JsonKey() List<AiProcedure> get procedures {
  if (_procedures is EqualUnmodifiableListView) return _procedures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_procedures);
}


/// Create a copy of AiUnlinkedManagement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiUnlinkedManagementCopyWith<_AiUnlinkedManagement> get copyWith => __$AiUnlinkedManagementCopyWithImpl<_AiUnlinkedManagement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiUnlinkedManagementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiUnlinkedManagement&&const DeepCollectionEquality().equals(other._medications, _medications)&&const DeepCollectionEquality().equals(other._investigations, _investigations)&&const DeepCollectionEquality().equals(other._procedures, _procedures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_medications),const DeepCollectionEquality().hash(_investigations),const DeepCollectionEquality().hash(_procedures));

@override
String toString() {
  return 'AiUnlinkedManagement(medications: $medications, investigations: $investigations, procedures: $procedures)';
}


}

/// @nodoc
abstract mixin class _$AiUnlinkedManagementCopyWith<$Res> implements $AiUnlinkedManagementCopyWith<$Res> {
  factory _$AiUnlinkedManagementCopyWith(_AiUnlinkedManagement value, $Res Function(_AiUnlinkedManagement) _then) = __$AiUnlinkedManagementCopyWithImpl;
@override @useResult
$Res call({
 List<OrderedMedication> medications, List<AiInvestigation> investigations, List<AiProcedure> procedures
});




}
/// @nodoc
class __$AiUnlinkedManagementCopyWithImpl<$Res>
    implements _$AiUnlinkedManagementCopyWith<$Res> {
  __$AiUnlinkedManagementCopyWithImpl(this._self, this._then);

  final _AiUnlinkedManagement _self;
  final $Res Function(_AiUnlinkedManagement) _then;

/// Create a copy of AiUnlinkedManagement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? medications = null,Object? investigations = null,Object? procedures = null,}) {
  return _then(_AiUnlinkedManagement(
medications: null == medications ? _self._medications : medications // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,investigations: null == investigations ? _self._investigations : investigations // ignore: cast_nullable_to_non_nullable
as List<AiInvestigation>,procedures: null == procedures ? _self._procedures : procedures // ignore: cast_nullable_to_non_nullable
as List<AiProcedure>,
  ));
}


}


/// @nodoc
mixin _$AiClinicalWarning {

@JsonKey(name: 'medication') String get medication;@JsonKey(name: 'condition') String get condition;@JsonKey(name: 'warning') String get warning;@JsonKey(name: 'dose_adjustment') String? get doseAdjustment;
/// Create a copy of AiClinicalWarning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiClinicalWarningCopyWith<AiClinicalWarning> get copyWith => _$AiClinicalWarningCopyWithImpl<AiClinicalWarning>(this as AiClinicalWarning, _$identity);

  /// Serializes this AiClinicalWarning to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiClinicalWarning&&(identical(other.medication, medication) || other.medication == medication)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.doseAdjustment, doseAdjustment) || other.doseAdjustment == doseAdjustment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,medication,condition,warning,doseAdjustment);

@override
String toString() {
  return 'AiClinicalWarning(medication: $medication, condition: $condition, warning: $warning, doseAdjustment: $doseAdjustment)';
}


}

/// @nodoc
abstract mixin class $AiClinicalWarningCopyWith<$Res>  {
  factory $AiClinicalWarningCopyWith(AiClinicalWarning value, $Res Function(AiClinicalWarning) _then) = _$AiClinicalWarningCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'medication') String medication,@JsonKey(name: 'condition') String condition,@JsonKey(name: 'warning') String warning,@JsonKey(name: 'dose_adjustment') String? doseAdjustment
});




}
/// @nodoc
class _$AiClinicalWarningCopyWithImpl<$Res>
    implements $AiClinicalWarningCopyWith<$Res> {
  _$AiClinicalWarningCopyWithImpl(this._self, this._then);

  final AiClinicalWarning _self;
  final $Res Function(AiClinicalWarning) _then;

/// Create a copy of AiClinicalWarning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? medication = null,Object? condition = null,Object? warning = null,Object? doseAdjustment = freezed,}) {
  return _then(AiClinicalWarning(
medication: null == medication ? _self.medication : medication // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String,doseAdjustment: freezed == doseAdjustment ? _self.doseAdjustment : doseAdjustment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiClinicalWarning].
extension AiClinicalWarningPatterns on AiClinicalWarning {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiClinicalWarning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiClinicalWarning() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiClinicalWarning value)  $default,){
final _that = this;
switch (_that) {
case _AiClinicalWarning():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiClinicalWarning value)?  $default,){
final _that = this;
switch (_that) {
case _AiClinicalWarning() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'medication')  String medication, @JsonKey(name: 'condition')  String condition, @JsonKey(name: 'warning')  String warning, @JsonKey(name: 'dose_adjustment')  String? doseAdjustment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiClinicalWarning() when $default != null:
return $default(_that.medication,_that.condition,_that.warning,_that.doseAdjustment);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'medication')  String medication, @JsonKey(name: 'condition')  String condition, @JsonKey(name: 'warning')  String warning, @JsonKey(name: 'dose_adjustment')  String? doseAdjustment)  $default,) {final _that = this;
switch (_that) {
case _AiClinicalWarning():
return $default(_that.medication,_that.condition,_that.warning,_that.doseAdjustment);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'medication')  String medication, @JsonKey(name: 'condition')  String condition, @JsonKey(name: 'warning')  String warning, @JsonKey(name: 'dose_adjustment')  String? doseAdjustment)?  $default,) {final _that = this;
switch (_that) {
case _AiClinicalWarning() when $default != null:
return $default(_that.medication,_that.condition,_that.warning,_that.doseAdjustment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiClinicalWarning implements AiClinicalWarning {
  const _AiClinicalWarning({@JsonKey(name: 'medication') this.medication = '', @JsonKey(name: 'condition') this.condition = '', @JsonKey(name: 'warning') this.warning = '', @JsonKey(name: 'dose_adjustment') this.doseAdjustment});
  factory _AiClinicalWarning.fromJson(Map<String, dynamic> json) => _$AiClinicalWarningFromJson(json);

@override@JsonKey(name: 'medication') final  String medication;
@override@JsonKey(name: 'condition') final  String condition;
@override@JsonKey(name: 'warning') final  String warning;
@override@JsonKey(name: 'dose_adjustment') final  String? doseAdjustment;

/// Create a copy of AiClinicalWarning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiClinicalWarningCopyWith<_AiClinicalWarning> get copyWith => __$AiClinicalWarningCopyWithImpl<_AiClinicalWarning>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiClinicalWarningToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiClinicalWarning&&(identical(other.medication, medication) || other.medication == medication)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.doseAdjustment, doseAdjustment) || other.doseAdjustment == doseAdjustment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,medication,condition,warning,doseAdjustment);

@override
String toString() {
  return 'AiClinicalWarning(medication: $medication, condition: $condition, warning: $warning, doseAdjustment: $doseAdjustment)';
}


}

/// @nodoc
abstract mixin class _$AiClinicalWarningCopyWith<$Res> implements $AiClinicalWarningCopyWith<$Res> {
  factory _$AiClinicalWarningCopyWith(_AiClinicalWarning value, $Res Function(_AiClinicalWarning) _then) = __$AiClinicalWarningCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'medication') String medication,@JsonKey(name: 'condition') String condition,@JsonKey(name: 'warning') String warning,@JsonKey(name: 'dose_adjustment') String? doseAdjustment
});




}
/// @nodoc
class __$AiClinicalWarningCopyWithImpl<$Res>
    implements _$AiClinicalWarningCopyWith<$Res> {
  __$AiClinicalWarningCopyWithImpl(this._self, this._then);

  final _AiClinicalWarning _self;
  final $Res Function(_AiClinicalWarning) _then;

/// Create a copy of AiClinicalWarning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? medication = null,Object? condition = null,Object? warning = null,Object? doseAdjustment = freezed,}) {
  return _then(_AiClinicalWarning(
medication: null == medication ? _self.medication : medication // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String,doseAdjustment: freezed == doseAdjustment ? _self.doseAdjustment : doseAdjustment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AiInvestigation {

@JsonKey(name: 'test_name') String get testName; String get value; String? get unit;@JsonKey(name: 'is_abnormal') bool get isAbnormal;
/// Create a copy of AiInvestigation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiInvestigationCopyWith<AiInvestigation> get copyWith => _$AiInvestigationCopyWithImpl<AiInvestigation>(this as AiInvestigation, _$identity);

  /// Serializes this AiInvestigation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiInvestigation&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.isAbnormal, isAbnormal) || other.isAbnormal == isAbnormal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testName,value,unit,isAbnormal);

@override
String toString() {
  return 'AiInvestigation(testName: $testName, value: $value, unit: $unit, isAbnormal: $isAbnormal)';
}


}

/// @nodoc
abstract mixin class $AiInvestigationCopyWith<$Res>  {
  factory $AiInvestigationCopyWith(AiInvestigation value, $Res Function(AiInvestigation) _then) = _$AiInvestigationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'test_name') String testName, String value, String? unit,@JsonKey(name: 'is_abnormal') bool isAbnormal
});




}
/// @nodoc
class _$AiInvestigationCopyWithImpl<$Res>
    implements $AiInvestigationCopyWith<$Res> {
  _$AiInvestigationCopyWithImpl(this._self, this._then);

  final AiInvestigation _self;
  final $Res Function(AiInvestigation) _then;

/// Create a copy of AiInvestigation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? testName = null,Object? value = null,Object? unit = freezed,Object? isAbnormal = null,}) {
  return _then(AiInvestigation(
testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,isAbnormal: null == isAbnormal ? _self.isAbnormal : isAbnormal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AiInvestigation].
extension AiInvestigationPatterns on AiInvestigation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiInvestigation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiInvestigation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiInvestigation value)  $default,){
final _that = this;
switch (_that) {
case _AiInvestigation():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiInvestigation value)?  $default,){
final _that = this;
switch (_that) {
case _AiInvestigation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'test_name')  String testName,  String value,  String? unit, @JsonKey(name: 'is_abnormal')  bool isAbnormal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiInvestigation() when $default != null:
return $default(_that.testName,_that.value,_that.unit,_that.isAbnormal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'test_name')  String testName,  String value,  String? unit, @JsonKey(name: 'is_abnormal')  bool isAbnormal)  $default,) {final _that = this;
switch (_that) {
case _AiInvestigation():
return $default(_that.testName,_that.value,_that.unit,_that.isAbnormal);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'test_name')  String testName,  String value,  String? unit, @JsonKey(name: 'is_abnormal')  bool isAbnormal)?  $default,) {final _that = this;
switch (_that) {
case _AiInvestigation() when $default != null:
return $default(_that.testName,_that.value,_that.unit,_that.isAbnormal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiInvestigation implements AiInvestigation {
  const _AiInvestigation({@JsonKey(name: 'test_name') this.testName = '', this.value = '', this.unit, @JsonKey(name: 'is_abnormal') this.isAbnormal = false});
  factory _AiInvestigation.fromJson(Map<String, dynamic> json) => _$AiInvestigationFromJson(json);

@override@JsonKey(name: 'test_name') final  String testName;
@override@JsonKey() final  String value;
@override final  String? unit;
@override@JsonKey(name: 'is_abnormal') final  bool isAbnormal;

/// Create a copy of AiInvestigation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiInvestigationCopyWith<_AiInvestigation> get copyWith => __$AiInvestigationCopyWithImpl<_AiInvestigation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiInvestigationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiInvestigation&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.isAbnormal, isAbnormal) || other.isAbnormal == isAbnormal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testName,value,unit,isAbnormal);

@override
String toString() {
  return 'AiInvestigation(testName: $testName, value: $value, unit: $unit, isAbnormal: $isAbnormal)';
}


}

/// @nodoc
abstract mixin class _$AiInvestigationCopyWith<$Res> implements $AiInvestigationCopyWith<$Res> {
  factory _$AiInvestigationCopyWith(_AiInvestigation value, $Res Function(_AiInvestigation) _then) = __$AiInvestigationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'test_name') String testName, String value, String? unit,@JsonKey(name: 'is_abnormal') bool isAbnormal
});




}
/// @nodoc
class __$AiInvestigationCopyWithImpl<$Res>
    implements _$AiInvestigationCopyWith<$Res> {
  __$AiInvestigationCopyWithImpl(this._self, this._then);

  final _AiInvestigation _self;
  final $Res Function(_AiInvestigation) _then;

/// Create a copy of AiInvestigation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? testName = null,Object? value = null,Object? unit = freezed,Object? isAbnormal = null,}) {
  return _then(_AiInvestigation(
testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,isAbnormal: null == isAbnormal ? _self.isAbnormal : isAbnormal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AiProcedure {

@JsonKey(name: 'procedure_name') String get procedureName;
/// Create a copy of AiProcedure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiProcedureCopyWith<AiProcedure> get copyWith => _$AiProcedureCopyWithImpl<AiProcedure>(this as AiProcedure, _$identity);

  /// Serializes this AiProcedure to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiProcedure&&(identical(other.procedureName, procedureName) || other.procedureName == procedureName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,procedureName);

@override
String toString() {
  return 'AiProcedure(procedureName: $procedureName)';
}


}

/// @nodoc
abstract mixin class $AiProcedureCopyWith<$Res>  {
  factory $AiProcedureCopyWith(AiProcedure value, $Res Function(AiProcedure) _then) = _$AiProcedureCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'procedure_name') String procedureName
});




}
/// @nodoc
class _$AiProcedureCopyWithImpl<$Res>
    implements $AiProcedureCopyWith<$Res> {
  _$AiProcedureCopyWithImpl(this._self, this._then);

  final AiProcedure _self;
  final $Res Function(AiProcedure) _then;

/// Create a copy of AiProcedure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? procedureName = null,}) {
  return _then(AiProcedure(
procedureName: null == procedureName ? _self.procedureName : procedureName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiProcedure].
extension AiProcedurePatterns on AiProcedure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiProcedure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiProcedure() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiProcedure value)  $default,){
final _that = this;
switch (_that) {
case _AiProcedure():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiProcedure value)?  $default,){
final _that = this;
switch (_that) {
case _AiProcedure() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'procedure_name')  String procedureName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiProcedure() when $default != null:
return $default(_that.procedureName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'procedure_name')  String procedureName)  $default,) {final _that = this;
switch (_that) {
case _AiProcedure():
return $default(_that.procedureName);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'procedure_name')  String procedureName)?  $default,) {final _that = this;
switch (_that) {
case _AiProcedure() when $default != null:
return $default(_that.procedureName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiProcedure implements AiProcedure {
  const _AiProcedure({@JsonKey(name: 'procedure_name') this.procedureName = ''});
  factory _AiProcedure.fromJson(Map<String, dynamic> json) => _$AiProcedureFromJson(json);

@override@JsonKey(name: 'procedure_name') final  String procedureName;

/// Create a copy of AiProcedure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiProcedureCopyWith<_AiProcedure> get copyWith => __$AiProcedureCopyWithImpl<_AiProcedure>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiProcedureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiProcedure&&(identical(other.procedureName, procedureName) || other.procedureName == procedureName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,procedureName);

@override
String toString() {
  return 'AiProcedure(procedureName: $procedureName)';
}


}

/// @nodoc
abstract mixin class _$AiProcedureCopyWith<$Res> implements $AiProcedureCopyWith<$Res> {
  factory _$AiProcedureCopyWith(_AiProcedure value, $Res Function(_AiProcedure) _then) = __$AiProcedureCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'procedure_name') String procedureName
});




}
/// @nodoc
class __$AiProcedureCopyWithImpl<$Res>
    implements _$AiProcedureCopyWith<$Res> {
  __$AiProcedureCopyWithImpl(this._self, this._then);

  final _AiProcedure _self;
  final $Res Function(_AiProcedure) _then;

/// Create a copy of AiProcedure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? procedureName = null,}) {
  return _then(_AiProcedure(
procedureName: null == procedureName ? _self.procedureName : procedureName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AiLabResult {

@JsonKey(name: 'test_name') String get testName; String get value; String? get unit;@JsonKey(name: 'is_abnormal') bool get isAbnormal;
/// Create a copy of AiLabResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiLabResultCopyWith<AiLabResult> get copyWith => _$AiLabResultCopyWithImpl<AiLabResult>(this as AiLabResult, _$identity);

  /// Serializes this AiLabResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiLabResult&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.isAbnormal, isAbnormal) || other.isAbnormal == isAbnormal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testName,value,unit,isAbnormal);

@override
String toString() {
  return 'AiLabResult(testName: $testName, value: $value, unit: $unit, isAbnormal: $isAbnormal)';
}


}

/// @nodoc
abstract mixin class $AiLabResultCopyWith<$Res>  {
  factory $AiLabResultCopyWith(AiLabResult value, $Res Function(AiLabResult) _then) = _$AiLabResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'test_name') String testName, String value, String? unit,@JsonKey(name: 'is_abnormal') bool isAbnormal
});




}
/// @nodoc
class _$AiLabResultCopyWithImpl<$Res>
    implements $AiLabResultCopyWith<$Res> {
  _$AiLabResultCopyWithImpl(this._self, this._then);

  final AiLabResult _self;
  final $Res Function(AiLabResult) _then;

/// Create a copy of AiLabResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? testName = null,Object? value = null,Object? unit = freezed,Object? isAbnormal = null,}) {
  return _then(AiLabResult(
testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,isAbnormal: null == isAbnormal ? _self.isAbnormal : isAbnormal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AiLabResult].
extension AiLabResultPatterns on AiLabResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiLabResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiLabResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiLabResult value)  $default,){
final _that = this;
switch (_that) {
case _AiLabResult():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiLabResult value)?  $default,){
final _that = this;
switch (_that) {
case _AiLabResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'test_name')  String testName,  String value,  String? unit, @JsonKey(name: 'is_abnormal')  bool isAbnormal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiLabResult() when $default != null:
return $default(_that.testName,_that.value,_that.unit,_that.isAbnormal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'test_name')  String testName,  String value,  String? unit, @JsonKey(name: 'is_abnormal')  bool isAbnormal)  $default,) {final _that = this;
switch (_that) {
case _AiLabResult():
return $default(_that.testName,_that.value,_that.unit,_that.isAbnormal);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'test_name')  String testName,  String value,  String? unit, @JsonKey(name: 'is_abnormal')  bool isAbnormal)?  $default,) {final _that = this;
switch (_that) {
case _AiLabResult() when $default != null:
return $default(_that.testName,_that.value,_that.unit,_that.isAbnormal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiLabResult implements AiLabResult {
  const _AiLabResult({@JsonKey(name: 'test_name') this.testName = '', this.value = '', this.unit, @JsonKey(name: 'is_abnormal') this.isAbnormal = false});
  factory _AiLabResult.fromJson(Map<String, dynamic> json) => _$AiLabResultFromJson(json);

@override@JsonKey(name: 'test_name') final  String testName;
@override@JsonKey() final  String value;
@override final  String? unit;
@override@JsonKey(name: 'is_abnormal') final  bool isAbnormal;

/// Create a copy of AiLabResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiLabResultCopyWith<_AiLabResult> get copyWith => __$AiLabResultCopyWithImpl<_AiLabResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiLabResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiLabResult&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.isAbnormal, isAbnormal) || other.isAbnormal == isAbnormal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testName,value,unit,isAbnormal);

@override
String toString() {
  return 'AiLabResult(testName: $testName, value: $value, unit: $unit, isAbnormal: $isAbnormal)';
}


}

/// @nodoc
abstract mixin class _$AiLabResultCopyWith<$Res> implements $AiLabResultCopyWith<$Res> {
  factory _$AiLabResultCopyWith(_AiLabResult value, $Res Function(_AiLabResult) _then) = __$AiLabResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'test_name') String testName, String value, String? unit,@JsonKey(name: 'is_abnormal') bool isAbnormal
});




}
/// @nodoc
class __$AiLabResultCopyWithImpl<$Res>
    implements _$AiLabResultCopyWith<$Res> {
  __$AiLabResultCopyWithImpl(this._self, this._then);

  final _AiLabResult _self;
  final $Res Function(_AiLabResult) _then;

/// Create a copy of AiLabResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? testName = null,Object? value = null,Object? unit = freezed,Object? isAbnormal = null,}) {
  return _then(_AiLabResult(
testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,isAbnormal: null == isAbnormal ? _self.isAbnormal : isAbnormal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AiMedication {

 String? get brand; String? get generic; String? get dose;
/// Create a copy of AiMedication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiMedicationCopyWith<AiMedication> get copyWith => _$AiMedicationCopyWithImpl<AiMedication>(this as AiMedication, _$identity);

  /// Serializes this AiMedication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiMedication&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.generic, generic) || other.generic == generic)&&(identical(other.dose, dose) || other.dose == dose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brand,generic,dose);

@override
String toString() {
  return 'AiMedication(brand: $brand, generic: $generic, dose: $dose)';
}


}

/// @nodoc
abstract mixin class $AiMedicationCopyWith<$Res>  {
  factory $AiMedicationCopyWith(AiMedication value, $Res Function(AiMedication) _then) = _$AiMedicationCopyWithImpl;
@useResult
$Res call({
 String? brand, String? generic, String? dose
});




}
/// @nodoc
class _$AiMedicationCopyWithImpl<$Res>
    implements $AiMedicationCopyWith<$Res> {
  _$AiMedicationCopyWithImpl(this._self, this._then);

  final AiMedication _self;
  final $Res Function(AiMedication) _then;

/// Create a copy of AiMedication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brand = freezed,Object? generic = freezed,Object? dose = freezed,}) {
  return _then(AiMedication(
brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,generic: freezed == generic ? _self.generic : generic // ignore: cast_nullable_to_non_nullable
as String?,dose: freezed == dose ? _self.dose : dose // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiMedication].
extension AiMedicationPatterns on AiMedication {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiMedication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiMedication() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiMedication value)  $default,){
final _that = this;
switch (_that) {
case _AiMedication():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiMedication value)?  $default,){
final _that = this;
switch (_that) {
case _AiMedication() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? brand,  String? generic,  String? dose)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiMedication() when $default != null:
return $default(_that.brand,_that.generic,_that.dose);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? brand,  String? generic,  String? dose)  $default,) {final _that = this;
switch (_that) {
case _AiMedication():
return $default(_that.brand,_that.generic,_that.dose);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? brand,  String? generic,  String? dose)?  $default,) {final _that = this;
switch (_that) {
case _AiMedication() when $default != null:
return $default(_that.brand,_that.generic,_that.dose);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiMedication implements AiMedication {
  const _AiMedication({this.brand, this.generic, this.dose});
  factory _AiMedication.fromJson(Map<String, dynamic> json) => _$AiMedicationFromJson(json);

@override final  String? brand;
@override final  String? generic;
@override final  String? dose;

/// Create a copy of AiMedication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiMedicationCopyWith<_AiMedication> get copyWith => __$AiMedicationCopyWithImpl<_AiMedication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiMedicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiMedication&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.generic, generic) || other.generic == generic)&&(identical(other.dose, dose) || other.dose == dose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brand,generic,dose);

@override
String toString() {
  return 'AiMedication(brand: $brand, generic: $generic, dose: $dose)';
}


}

/// @nodoc
abstract mixin class _$AiMedicationCopyWith<$Res> implements $AiMedicationCopyWith<$Res> {
  factory _$AiMedicationCopyWith(_AiMedication value, $Res Function(_AiMedication) _then) = __$AiMedicationCopyWithImpl;
@override @useResult
$Res call({
 String? brand, String? generic, String? dose
});




}
/// @nodoc
class __$AiMedicationCopyWithImpl<$Res>
    implements _$AiMedicationCopyWith<$Res> {
  __$AiMedicationCopyWithImpl(this._self, this._then);

  final _AiMedication _self;
  final $Res Function(_AiMedication) _then;

/// Create a copy of AiMedication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brand = freezed,Object? generic = freezed,Object? dose = freezed,}) {
  return _then(_AiMedication(
brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,generic: freezed == generic ? _self.generic : generic // ignore: cast_nullable_to_non_nullable
as String?,dose: freezed == dose ? _self.dose : dose // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
