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

 int? get sbp; int? get dbp;@JsonKey(name: 'pulse') int? get pr;@JsonKey(name: 'temp_f') double? get temperatureC; int? get spo2;
/// Create a copy of AiVitals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiVitalsCopyWith<AiVitals> get copyWith => _$AiVitalsCopyWithImpl<AiVitals>(this as AiVitals, _$identity);

  /// Serializes this AiVitals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiVitals&&(identical(other.sbp, sbp) || other.sbp == sbp)&&(identical(other.dbp, dbp) || other.dbp == dbp)&&(identical(other.pr, pr) || other.pr == pr)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.spo2, spo2) || other.spo2 == spo2));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sbp,dbp,pr,temperatureC,spo2);

@override
String toString() {
  return 'AiVitals(sbp: $sbp, dbp: $dbp, pr: $pr, temperatureC: $temperatureC, spo2: $spo2)';
}


}

/// @nodoc
abstract mixin class $AiVitalsCopyWith<$Res>  {
  factory $AiVitalsCopyWith(AiVitals value, $Res Function(AiVitals) _then) = _$AiVitalsCopyWithImpl;
@useResult
$Res call({
 int? sbp, int? dbp,@JsonKey(name: 'pulse') int? pr,@JsonKey(name: 'temp_f') double? temperatureC, int? spo2
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
@pragma('vm:prefer-inline') @override $Res call({Object? sbp = freezed,Object? dbp = freezed,Object? pr = freezed,Object? temperatureC = freezed,Object? spo2 = freezed,}) {
  return _then(AiVitals(
sbp: freezed == sbp ? _self.sbp : sbp // ignore: cast_nullable_to_non_nullable
as int?,dbp: freezed == dbp ? _self.dbp : dbp // ignore: cast_nullable_to_non_nullable
as int?,pr: freezed == pr ? _self.pr : pr // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,spo2: freezed == spo2 ? _self.spo2 : spo2 // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? sbp,  int? dbp, @JsonKey(name: 'pulse')  int? pr, @JsonKey(name: 'temp_f')  double? temperatureC,  int? spo2)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC,_that.spo2);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? sbp,  int? dbp, @JsonKey(name: 'pulse')  int? pr, @JsonKey(name: 'temp_f')  double? temperatureC,  int? spo2)  $default,) {final _that = this;
switch (_that) {
case _AiVitals():
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC,_that.spo2);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? sbp,  int? dbp, @JsonKey(name: 'pulse')  int? pr, @JsonKey(name: 'temp_f')  double? temperatureC,  int? spo2)?  $default,) {final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC,_that.spo2);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiVitals implements AiVitals {
  const _AiVitals({this.sbp, this.dbp, @JsonKey(name: 'pulse') this.pr, @JsonKey(name: 'temp_f') this.temperatureC, this.spo2});
  factory _AiVitals.fromJson(Map<String, dynamic> json) => _$AiVitalsFromJson(json);

@override final  int? sbp;
@override final  int? dbp;
@override@JsonKey(name: 'pulse') final  int? pr;
@override@JsonKey(name: 'temp_f') final  double? temperatureC;
@override final  int? spo2;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiVitals&&(identical(other.sbp, sbp) || other.sbp == sbp)&&(identical(other.dbp, dbp) || other.dbp == dbp)&&(identical(other.pr, pr) || other.pr == pr)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.spo2, spo2) || other.spo2 == spo2));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sbp,dbp,pr,temperatureC,spo2);

@override
String toString() {
  return 'AiVitals(sbp: $sbp, dbp: $dbp, pr: $pr, temperatureC: $temperatureC, spo2: $spo2)';
}


}

/// @nodoc
abstract mixin class _$AiVitalsCopyWith<$Res> implements $AiVitalsCopyWith<$Res> {
  factory _$AiVitalsCopyWith(_AiVitals value, $Res Function(_AiVitals) _then) = __$AiVitalsCopyWithImpl;
@override @useResult
$Res call({
 int? sbp, int? dbp,@JsonKey(name: 'pulse') int? pr,@JsonKey(name: 'temp_f') double? temperatureC, int? spo2
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
@override @pragma('vm:prefer-inline') $Res call({Object? sbp = freezed,Object? dbp = freezed,Object? pr = freezed,Object? temperatureC = freezed,Object? spo2 = freezed,}) {
  return _then(_AiVitals(
sbp: freezed == sbp ? _self.sbp : sbp // ignore: cast_nullable_to_non_nullable
as int?,dbp: freezed == dbp ? _self.dbp : dbp // ignore: cast_nullable_to_non_nullable
as int?,pr: freezed == pr ? _self.pr : pr // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,spo2: freezed == spo2 ? _self.spo2 : spo2 // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AiExtractionResult {

@JsonKey(name: 'patient_identity') PatientIdentity get patientIdentity;@JsonKey(name: 'encounter_context') EncounterContext get encounterContext; AiVitals get vitals;@JsonKey(name: 'medications_ordered') List<OrderedMedication> get medicationsOrdered;@JsonKey(name: 'lab_results') List<AiLabResult> get labResults; String get clinicalSummary;
/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiExtractionResultCopyWith<AiExtractionResult> get copyWith => _$AiExtractionResultCopyWithImpl<AiExtractionResult>(this as AiExtractionResult, _$identity);

  /// Serializes this AiExtractionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiExtractionResult&&(identical(other.patientIdentity, patientIdentity) || other.patientIdentity == patientIdentity)&&(identical(other.encounterContext, encounterContext) || other.encounterContext == encounterContext)&&(identical(other.vitals, vitals) || other.vitals == vitals)&&const DeepCollectionEquality().equals(other.medicationsOrdered, medicationsOrdered)&&const DeepCollectionEquality().equals(other.labResults, labResults)&&(identical(other.clinicalSummary, clinicalSummary) || other.clinicalSummary == clinicalSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientIdentity,encounterContext,vitals,const DeepCollectionEquality().hash(medicationsOrdered),const DeepCollectionEquality().hash(labResults),clinicalSummary);

@override
String toString() {
  return 'AiExtractionResult(patientIdentity: $patientIdentity, encounterContext: $encounterContext, vitals: $vitals, medicationsOrdered: $medicationsOrdered, labResults: $labResults, clinicalSummary: $clinicalSummary)';
}


}

/// @nodoc
abstract mixin class $AiExtractionResultCopyWith<$Res>  {
  factory $AiExtractionResultCopyWith(AiExtractionResult value, $Res Function(AiExtractionResult) _then) = _$AiExtractionResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'patient_identity') PatientIdentity patientIdentity,@JsonKey(name: 'encounter_context') EncounterContext encounterContext, AiVitals vitals,@JsonKey(name: 'medications_ordered') List<OrderedMedication> medicationsOrdered,@JsonKey(name: 'lab_results') List<AiLabResult> labResults, String clinicalSummary
});


$PatientIdentityCopyWith<$Res> get patientIdentity;$EncounterContextCopyWith<$Res> get encounterContext;$AiVitalsCopyWith<$Res> get vitals;

}
/// @nodoc
class _$AiExtractionResultCopyWithImpl<$Res>
    implements $AiExtractionResultCopyWith<$Res> {
  _$AiExtractionResultCopyWithImpl(this._self, this._then);

  final AiExtractionResult _self;
  final $Res Function(AiExtractionResult) _then;

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patientIdentity = null,Object? encounterContext = null,Object? vitals = null,Object? medicationsOrdered = null,Object? labResults = null,Object? clinicalSummary = null,}) {
  return _then(AiExtractionResult(
patientIdentity: null == patientIdentity ? _self.patientIdentity : patientIdentity // ignore: cast_nullable_to_non_nullable
as PatientIdentity,encounterContext: null == encounterContext ? _self.encounterContext : encounterContext // ignore: cast_nullable_to_non_nullable
as EncounterContext,vitals: null == vitals ? _self.vitals : vitals // ignore: cast_nullable_to_non_nullable
as AiVitals,medicationsOrdered: null == medicationsOrdered ? _self.medicationsOrdered : medicationsOrdered // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,labResults: null == labResults ? _self.labResults : labResults // ignore: cast_nullable_to_non_nullable
as List<AiLabResult>,clinicalSummary: null == clinicalSummary ? _self.clinicalSummary : clinicalSummary // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'patient_identity')  PatientIdentity patientIdentity, @JsonKey(name: 'encounter_context')  EncounterContext encounterContext,  AiVitals vitals, @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered, @JsonKey(name: 'lab_results')  List<AiLabResult> labResults,  String clinicalSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that.patientIdentity,_that.encounterContext,_that.vitals,_that.medicationsOrdered,_that.labResults,_that.clinicalSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'patient_identity')  PatientIdentity patientIdentity, @JsonKey(name: 'encounter_context')  EncounterContext encounterContext,  AiVitals vitals, @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered, @JsonKey(name: 'lab_results')  List<AiLabResult> labResults,  String clinicalSummary)  $default,) {final _that = this;
switch (_that) {
case _AiExtractionResult():
return $default(_that.patientIdentity,_that.encounterContext,_that.vitals,_that.medicationsOrdered,_that.labResults,_that.clinicalSummary);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'patient_identity')  PatientIdentity patientIdentity, @JsonKey(name: 'encounter_context')  EncounterContext encounterContext,  AiVitals vitals, @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered, @JsonKey(name: 'lab_results')  List<AiLabResult> labResults,  String clinicalSummary)?  $default,) {final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that.patientIdentity,_that.encounterContext,_that.vitals,_that.medicationsOrdered,_that.labResults,_that.clinicalSummary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiExtractionResult extends AiExtractionResult {
  const _AiExtractionResult({@JsonKey(name: 'patient_identity') this.patientIdentity = const PatientIdentity(), @JsonKey(name: 'encounter_context') this.encounterContext = const EncounterContext(), this.vitals = const AiVitals(), @JsonKey(name: 'medications_ordered')  List<OrderedMedication> medicationsOrdered = const <OrderedMedication>[], @JsonKey(name: 'lab_results')  List<AiLabResult> labResults = const <AiLabResult>[], this.clinicalSummary = ''}): _medicationsOrdered = medicationsOrdered,_labResults = labResults,super._();
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

@override@JsonKey() final  String clinicalSummary;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiExtractionResult&&(identical(other.patientIdentity, patientIdentity) || other.patientIdentity == patientIdentity)&&(identical(other.encounterContext, encounterContext) || other.encounterContext == encounterContext)&&(identical(other.vitals, vitals) || other.vitals == vitals)&&const DeepCollectionEquality().equals(other._medicationsOrdered, _medicationsOrdered)&&const DeepCollectionEquality().equals(other._labResults, _labResults)&&(identical(other.clinicalSummary, clinicalSummary) || other.clinicalSummary == clinicalSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientIdentity,encounterContext,vitals,const DeepCollectionEquality().hash(_medicationsOrdered),const DeepCollectionEquality().hash(_labResults),clinicalSummary);

@override
String toString() {
  return 'AiExtractionResult(patientIdentity: $patientIdentity, encounterContext: $encounterContext, vitals: $vitals, medicationsOrdered: $medicationsOrdered, labResults: $labResults, clinicalSummary: $clinicalSummary)';
}


}

/// @nodoc
abstract mixin class _$AiExtractionResultCopyWith<$Res> implements $AiExtractionResultCopyWith<$Res> {
  factory _$AiExtractionResultCopyWith(_AiExtractionResult value, $Res Function(_AiExtractionResult) _then) = __$AiExtractionResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'patient_identity') PatientIdentity patientIdentity,@JsonKey(name: 'encounter_context') EncounterContext encounterContext, AiVitals vitals,@JsonKey(name: 'medications_ordered') List<OrderedMedication> medicationsOrdered,@JsonKey(name: 'lab_results') List<AiLabResult> labResults, String clinicalSummary
});


@override $PatientIdentityCopyWith<$Res> get patientIdentity;@override $EncounterContextCopyWith<$Res> get encounterContext;@override $AiVitalsCopyWith<$Res> get vitals;

}
/// @nodoc
class __$AiExtractionResultCopyWithImpl<$Res>
    implements _$AiExtractionResultCopyWith<$Res> {
  __$AiExtractionResultCopyWithImpl(this._self, this._then);

  final _AiExtractionResult _self;
  final $Res Function(_AiExtractionResult) _then;

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patientIdentity = null,Object? encounterContext = null,Object? vitals = null,Object? medicationsOrdered = null,Object? labResults = null,Object? clinicalSummary = null,}) {
  return _then(_AiExtractionResult(
patientIdentity: null == patientIdentity ? _self.patientIdentity : patientIdentity // ignore: cast_nullable_to_non_nullable
as PatientIdentity,encounterContext: null == encounterContext ? _self.encounterContext : encounterContext // ignore: cast_nullable_to_non_nullable
as EncounterContext,vitals: null == vitals ? _self.vitals : vitals // ignore: cast_nullable_to_non_nullable
as AiVitals,medicationsOrdered: null == medicationsOrdered ? _self._medicationsOrdered : medicationsOrdered // ignore: cast_nullable_to_non_nullable
as List<OrderedMedication>,labResults: null == labResults ? _self._labResults : labResults // ignore: cast_nullable_to_non_nullable
as List<AiLabResult>,clinicalSummary: null == clinicalSummary ? _self.clinicalSummary : clinicalSummary // ignore: cast_nullable_to_non_nullable
as String,
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
}
}


/// @nodoc
mixin _$PatientIdentity {

 String? get name; int? get age; String? get gender;@JsonKey(name: 'hospital_reg_no') String? get hospitalRegNo;
/// Create a copy of PatientIdentity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientIdentityCopyWith<PatientIdentity> get copyWith => _$PatientIdentityCopyWithImpl<PatientIdentity>(this as PatientIdentity, _$identity);

  /// Serializes this PatientIdentity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientIdentity&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.hospitalRegNo, hospitalRegNo) || other.hospitalRegNo == hospitalRegNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,gender,hospitalRegNo);

@override
String toString() {
  return 'PatientIdentity(name: $name, age: $age, gender: $gender, hospitalRegNo: $hospitalRegNo)';
}


}

/// @nodoc
abstract mixin class $PatientIdentityCopyWith<$Res>  {
  factory $PatientIdentityCopyWith(PatientIdentity value, $Res Function(PatientIdentity) _then) = _$PatientIdentityCopyWithImpl;
@useResult
$Res call({
 String? name, int? age, String? gender,@JsonKey(name: 'hospital_reg_no') String? hospitalRegNo
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? age = freezed,Object? gender = freezed,Object? hospitalRegNo = freezed,}) {
  return _then(PatientIdentity(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,hospitalRegNo: freezed == hospitalRegNo ? _self.hospitalRegNo : hospitalRegNo // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  int? age,  String? gender, @JsonKey(name: 'hospital_reg_no')  String? hospitalRegNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientIdentity() when $default != null:
return $default(_that.name,_that.age,_that.gender,_that.hospitalRegNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  int? age,  String? gender, @JsonKey(name: 'hospital_reg_no')  String? hospitalRegNo)  $default,) {final _that = this;
switch (_that) {
case _PatientIdentity():
return $default(_that.name,_that.age,_that.gender,_that.hospitalRegNo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  int? age,  String? gender, @JsonKey(name: 'hospital_reg_no')  String? hospitalRegNo)?  $default,) {final _that = this;
switch (_that) {
case _PatientIdentity() when $default != null:
return $default(_that.name,_that.age,_that.gender,_that.hospitalRegNo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatientIdentity implements PatientIdentity {
  const _PatientIdentity({this.name, this.age, this.gender, @JsonKey(name: 'hospital_reg_no') this.hospitalRegNo});
  factory _PatientIdentity.fromJson(Map<String, dynamic> json) => _$PatientIdentityFromJson(json);

@override final  String? name;
@override final  int? age;
@override final  String? gender;
@override@JsonKey(name: 'hospital_reg_no') final  String? hospitalRegNo;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientIdentity&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.hospitalRegNo, hospitalRegNo) || other.hospitalRegNo == hospitalRegNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,gender,hospitalRegNo);

@override
String toString() {
  return 'PatientIdentity(name: $name, age: $age, gender: $gender, hospitalRegNo: $hospitalRegNo)';
}


}

/// @nodoc
abstract mixin class _$PatientIdentityCopyWith<$Res> implements $PatientIdentityCopyWith<$Res> {
  factory _$PatientIdentityCopyWith(_PatientIdentity value, $Res Function(_PatientIdentity) _then) = __$PatientIdentityCopyWithImpl;
@override @useResult
$Res call({
 String? name, int? age, String? gender,@JsonKey(name: 'hospital_reg_no') String? hospitalRegNo
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? age = freezed,Object? gender = freezed,Object? hospitalRegNo = freezed,}) {
  return _then(_PatientIdentity(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,hospitalRegNo: freezed == hospitalRegNo ? _self.hospitalRegNo : hospitalRegNo // ignore: cast_nullable_to_non_nullable
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

@JsonKey(name: 'drug_name') String get drugName; String? get dosage; String? get frequency;
/// Create a copy of OrderedMedication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderedMedicationCopyWith<OrderedMedication> get copyWith => _$OrderedMedicationCopyWithImpl<OrderedMedication>(this as OrderedMedication, _$identity);

  /// Serializes this OrderedMedication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderedMedication&&(identical(other.drugName, drugName) || other.drugName == drugName)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.frequency, frequency) || other.frequency == frequency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,drugName,dosage,frequency);

@override
String toString() {
  return 'OrderedMedication(drugName: $drugName, dosage: $dosage, frequency: $frequency)';
}


}

/// @nodoc
abstract mixin class $OrderedMedicationCopyWith<$Res>  {
  factory $OrderedMedicationCopyWith(OrderedMedication value, $Res Function(OrderedMedication) _then) = _$OrderedMedicationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'drug_name') String drugName, String? dosage, String? frequency
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
@pragma('vm:prefer-inline') @override $Res call({Object? drugName = null,Object? dosage = freezed,Object? frequency = freezed,}) {
  return _then(OrderedMedication(
drugName: null == drugName ? _self.drugName : drugName // ignore: cast_nullable_to_non_nullable
as String,dosage: freezed == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'drug_name')  String drugName,  String? dosage,  String? frequency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderedMedication() when $default != null:
return $default(_that.drugName,_that.dosage,_that.frequency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'drug_name')  String drugName,  String? dosage,  String? frequency)  $default,) {final _that = this;
switch (_that) {
case _OrderedMedication():
return $default(_that.drugName,_that.dosage,_that.frequency);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'drug_name')  String drugName,  String? dosage,  String? frequency)?  $default,) {final _that = this;
switch (_that) {
case _OrderedMedication() when $default != null:
return $default(_that.drugName,_that.dosage,_that.frequency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderedMedication implements OrderedMedication {
  const _OrderedMedication({@JsonKey(name: 'drug_name') this.drugName = '', this.dosage, this.frequency});
  factory _OrderedMedication.fromJson(Map<String, dynamic> json) => _$OrderedMedicationFromJson(json);

@override@JsonKey(name: 'drug_name') final  String drugName;
@override final  String? dosage;
@override final  String? frequency;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderedMedication&&(identical(other.drugName, drugName) || other.drugName == drugName)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.frequency, frequency) || other.frequency == frequency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,drugName,dosage,frequency);

@override
String toString() {
  return 'OrderedMedication(drugName: $drugName, dosage: $dosage, frequency: $frequency)';
}


}

/// @nodoc
abstract mixin class _$OrderedMedicationCopyWith<$Res> implements $OrderedMedicationCopyWith<$Res> {
  factory _$OrderedMedicationCopyWith(_OrderedMedication value, $Res Function(_OrderedMedication) _then) = __$OrderedMedicationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'drug_name') String drugName, String? dosage, String? frequency
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
@override @pragma('vm:prefer-inline') $Res call({Object? drugName = null,Object? dosage = freezed,Object? frequency = freezed,}) {
  return _then(_OrderedMedication(
drugName: null == drugName ? _self.drugName : drugName // ignore: cast_nullable_to_non_nullable
as String,dosage: freezed == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,
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
