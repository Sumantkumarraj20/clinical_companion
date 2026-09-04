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

 int? get sbp; int? get dbp; int? get pr;@JsonKey(name: 'temp') double? get temperatureC;
/// Create a copy of AiVitals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiVitalsCopyWith<AiVitals> get copyWith => _$AiVitalsCopyWithImpl<AiVitals>(this as AiVitals, _$identity);

  /// Serializes this AiVitals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiVitals&&(identical(other.sbp, sbp) || other.sbp == sbp)&&(identical(other.dbp, dbp) || other.dbp == dbp)&&(identical(other.pr, pr) || other.pr == pr)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sbp,dbp,pr,temperatureC);

@override
String toString() {
  return 'AiVitals(sbp: $sbp, dbp: $dbp, pr: $pr, temperatureC: $temperatureC)';
}


}

/// @nodoc
abstract mixin class $AiVitalsCopyWith<$Res>  {
  factory $AiVitalsCopyWith(AiVitals value, $Res Function(AiVitals) _then) = _$AiVitalsCopyWithImpl;
@useResult
$Res call({
 int? sbp, int? dbp, int? pr,@JsonKey(name: 'temp') double? temperatureC
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
@pragma('vm:prefer-inline') @override $Res call({Object? sbp = freezed,Object? dbp = freezed,Object? pr = freezed,Object? temperatureC = freezed,}) {
  return _then(AiVitals(
sbp: freezed == sbp ? _self.sbp : sbp // ignore: cast_nullable_to_non_nullable
as int?,dbp: freezed == dbp ? _self.dbp : dbp // ignore: cast_nullable_to_non_nullable
as int?,pr: freezed == pr ? _self.pr : pr // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? sbp,  int? dbp,  int? pr, @JsonKey(name: 'temp')  double? temperatureC)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? sbp,  int? dbp,  int? pr, @JsonKey(name: 'temp')  double? temperatureC)  $default,) {final _that = this;
switch (_that) {
case _AiVitals():
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? sbp,  int? dbp,  int? pr, @JsonKey(name: 'temp')  double? temperatureC)?  $default,) {final _that = this;
switch (_that) {
case _AiVitals() when $default != null:
return $default(_that.sbp,_that.dbp,_that.pr,_that.temperatureC);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiVitals implements AiVitals {
  const _AiVitals({this.sbp, this.dbp, this.pr, @JsonKey(name: 'temp') this.temperatureC});
  factory _AiVitals.fromJson(Map<String, dynamic> json) => _$AiVitalsFromJson(json);

@override final  int? sbp;
@override final  int? dbp;
@override final  int? pr;
@override@JsonKey(name: 'temp') final  double? temperatureC;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiVitals&&(identical(other.sbp, sbp) || other.sbp == sbp)&&(identical(other.dbp, dbp) || other.dbp == dbp)&&(identical(other.pr, pr) || other.pr == pr)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sbp,dbp,pr,temperatureC);

@override
String toString() {
  return 'AiVitals(sbp: $sbp, dbp: $dbp, pr: $pr, temperatureC: $temperatureC)';
}


}

/// @nodoc
abstract mixin class _$AiVitalsCopyWith<$Res> implements $AiVitalsCopyWith<$Res> {
  factory _$AiVitalsCopyWith(_AiVitals value, $Res Function(_AiVitals) _then) = __$AiVitalsCopyWithImpl;
@override @useResult
$Res call({
 int? sbp, int? dbp, int? pr,@JsonKey(name: 'temp') double? temperatureC
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
@override @pragma('vm:prefer-inline') $Res call({Object? sbp = freezed,Object? dbp = freezed,Object? pr = freezed,Object? temperatureC = freezed,}) {
  return _then(_AiVitals(
sbp: freezed == sbp ? _self.sbp : sbp // ignore: cast_nullable_to_non_nullable
as int?,dbp: freezed == dbp ? _self.dbp : dbp // ignore: cast_nullable_to_non_nullable
as int?,pr: freezed == pr ? _self.pr : pr // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$AiExtractionResult {

@JsonKey(name: 'patient_identifier') String? get patientIdentifier; AiLocation get location;@JsonKey(name: 'document_type') String get documentType;@JsonKey(name: 'vitals_extracted') AiVitals get vitalsExtracted;@JsonKey(name: 'clinical_summary') String get clinicalSummary;@JsonKey(name: 'raw_text') String get rawText;@JsonKey(name: 'identified_problems') List<String> get identifiedProblems;@JsonKey(name: 'medications_mentioned') List<AiMedication> get medicationsMentioned;
/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiExtractionResultCopyWith<AiExtractionResult> get copyWith => _$AiExtractionResultCopyWithImpl<AiExtractionResult>(this as AiExtractionResult, _$identity);

  /// Serializes this AiExtractionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiExtractionResult&&(identical(other.patientIdentifier, patientIdentifier) || other.patientIdentifier == patientIdentifier)&&(identical(other.location, location) || other.location == location)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.vitalsExtracted, vitalsExtracted) || other.vitalsExtracted == vitalsExtracted)&&(identical(other.clinicalSummary, clinicalSummary) || other.clinicalSummary == clinicalSummary)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&const DeepCollectionEquality().equals(other.identifiedProblems, identifiedProblems)&&const DeepCollectionEquality().equals(other.medicationsMentioned, medicationsMentioned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientIdentifier,location,documentType,vitalsExtracted,clinicalSummary,rawText,const DeepCollectionEquality().hash(identifiedProblems),const DeepCollectionEquality().hash(medicationsMentioned));

@override
String toString() {
  return 'AiExtractionResult(patientIdentifier: $patientIdentifier, location: $location, documentType: $documentType, vitalsExtracted: $vitalsExtracted, clinicalSummary: $clinicalSummary, rawText: $rawText, identifiedProblems: $identifiedProblems, medicationsMentioned: $medicationsMentioned)';
}


}

/// @nodoc
abstract mixin class $AiExtractionResultCopyWith<$Res>  {
  factory $AiExtractionResultCopyWith(AiExtractionResult value, $Res Function(AiExtractionResult) _then) = _$AiExtractionResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'patient_identifier') String? patientIdentifier, AiLocation location,@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'vitals_extracted') AiVitals vitalsExtracted,@JsonKey(name: 'clinical_summary') String clinicalSummary,@JsonKey(name: 'raw_text') String rawText,@JsonKey(name: 'identified_problems') List<String> identifiedProblems,@JsonKey(name: 'medications_mentioned') List<AiMedication> medicationsMentioned
});


$AiLocationCopyWith<$Res> get location;$AiVitalsCopyWith<$Res> get vitalsExtracted;

}
/// @nodoc
class _$AiExtractionResultCopyWithImpl<$Res>
    implements $AiExtractionResultCopyWith<$Res> {
  _$AiExtractionResultCopyWithImpl(this._self, this._then);

  final AiExtractionResult _self;
  final $Res Function(AiExtractionResult) _then;

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patientIdentifier = freezed,Object? location = null,Object? documentType = null,Object? vitalsExtracted = null,Object? clinicalSummary = null,Object? rawText = null,Object? identifiedProblems = null,Object? medicationsMentioned = null,}) {
  return _then(AiExtractionResult(
patientIdentifier: freezed == patientIdentifier ? _self.patientIdentifier : patientIdentifier // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AiLocation,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,vitalsExtracted: null == vitalsExtracted ? _self.vitalsExtracted : vitalsExtracted // ignore: cast_nullable_to_non_nullable
as AiVitals,clinicalSummary: null == clinicalSummary ? _self.clinicalSummary : clinicalSummary // ignore: cast_nullable_to_non_nullable
as String,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,identifiedProblems: null == identifiedProblems ? _self.identifiedProblems : identifiedProblems // ignore: cast_nullable_to_non_nullable
as List<String>,medicationsMentioned: null == medicationsMentioned ? _self.medicationsMentioned : medicationsMentioned // ignore: cast_nullable_to_non_nullable
as List<AiMedication>,
  ));
}
/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiLocationCopyWith<$Res> get location {
  
  return $AiLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiVitalsCopyWith<$Res> get vitalsExtracted {
  
  return $AiVitalsCopyWith<$Res>(_self.vitalsExtracted, (value) {
    return _then(_self.copyWith(vitalsExtracted: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'patient_identifier')  String? patientIdentifier,  AiLocation location, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'vitals_extracted')  AiVitals vitalsExtracted, @JsonKey(name: 'clinical_summary')  String clinicalSummary, @JsonKey(name: 'raw_text')  String rawText, @JsonKey(name: 'identified_problems')  List<String> identifiedProblems, @JsonKey(name: 'medications_mentioned')  List<AiMedication> medicationsMentioned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that.patientIdentifier,_that.location,_that.documentType,_that.vitalsExtracted,_that.clinicalSummary,_that.rawText,_that.identifiedProblems,_that.medicationsMentioned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'patient_identifier')  String? patientIdentifier,  AiLocation location, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'vitals_extracted')  AiVitals vitalsExtracted, @JsonKey(name: 'clinical_summary')  String clinicalSummary, @JsonKey(name: 'raw_text')  String rawText, @JsonKey(name: 'identified_problems')  List<String> identifiedProblems, @JsonKey(name: 'medications_mentioned')  List<AiMedication> medicationsMentioned)  $default,) {final _that = this;
switch (_that) {
case _AiExtractionResult():
return $default(_that.patientIdentifier,_that.location,_that.documentType,_that.vitalsExtracted,_that.clinicalSummary,_that.rawText,_that.identifiedProblems,_that.medicationsMentioned);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'patient_identifier')  String? patientIdentifier,  AiLocation location, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'vitals_extracted')  AiVitals vitalsExtracted, @JsonKey(name: 'clinical_summary')  String clinicalSummary, @JsonKey(name: 'raw_text')  String rawText, @JsonKey(name: 'identified_problems')  List<String> identifiedProblems, @JsonKey(name: 'medications_mentioned')  List<AiMedication> medicationsMentioned)?  $default,) {final _that = this;
switch (_that) {
case _AiExtractionResult() when $default != null:
return $default(_that.patientIdentifier,_that.location,_that.documentType,_that.vitalsExtracted,_that.clinicalSummary,_that.rawText,_that.identifiedProblems,_that.medicationsMentioned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiExtractionResult implements AiExtractionResult {
  const _AiExtractionResult({@JsonKey(name: 'patient_identifier') this.patientIdentifier, required this.location, @JsonKey(name: 'document_type') required this.documentType, @JsonKey(name: 'vitals_extracted') required this.vitalsExtracted, @JsonKey(name: 'clinical_summary') required this.clinicalSummary, @JsonKey(name: 'raw_text') required this.rawText, @JsonKey(name: 'identified_problems')  List<String> identifiedProblems = const <String>[], @JsonKey(name: 'medications_mentioned')  List<AiMedication> medicationsMentioned = const <AiMedication>[]}): _identifiedProblems = identifiedProblems,_medicationsMentioned = medicationsMentioned;
  factory _AiExtractionResult.fromJson(Map<String, dynamic> json) => _$AiExtractionResultFromJson(json);

@override@JsonKey(name: 'patient_identifier') final  String? patientIdentifier;
@override final  AiLocation location;
@override@JsonKey(name: 'document_type') final  String documentType;
@override@JsonKey(name: 'vitals_extracted') final  AiVitals vitalsExtracted;
@override@JsonKey(name: 'clinical_summary') final  String clinicalSummary;
@override@JsonKey(name: 'raw_text') final  String rawText;
 final  List<String> _identifiedProblems;
@override@JsonKey(name: 'identified_problems') List<String> get identifiedProblems {
  if (_identifiedProblems is EqualUnmodifiableListView) return _identifiedProblems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_identifiedProblems);
}

 final  List<AiMedication> _medicationsMentioned;
@override@JsonKey(name: 'medications_mentioned') List<AiMedication> get medicationsMentioned {
  if (_medicationsMentioned is EqualUnmodifiableListView) return _medicationsMentioned;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medicationsMentioned);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiExtractionResult&&(identical(other.patientIdentifier, patientIdentifier) || other.patientIdentifier == patientIdentifier)&&(identical(other.location, location) || other.location == location)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.vitalsExtracted, vitalsExtracted) || other.vitalsExtracted == vitalsExtracted)&&(identical(other.clinicalSummary, clinicalSummary) || other.clinicalSummary == clinicalSummary)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&const DeepCollectionEquality().equals(other._identifiedProblems, _identifiedProblems)&&const DeepCollectionEquality().equals(other._medicationsMentioned, _medicationsMentioned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientIdentifier,location,documentType,vitalsExtracted,clinicalSummary,rawText,const DeepCollectionEquality().hash(_identifiedProblems),const DeepCollectionEquality().hash(_medicationsMentioned));

@override
String toString() {
  return 'AiExtractionResult(patientIdentifier: $patientIdentifier, location: $location, documentType: $documentType, vitalsExtracted: $vitalsExtracted, clinicalSummary: $clinicalSummary, rawText: $rawText, identifiedProblems: $identifiedProblems, medicationsMentioned: $medicationsMentioned)';
}


}

/// @nodoc
abstract mixin class _$AiExtractionResultCopyWith<$Res> implements $AiExtractionResultCopyWith<$Res> {
  factory _$AiExtractionResultCopyWith(_AiExtractionResult value, $Res Function(_AiExtractionResult) _then) = __$AiExtractionResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'patient_identifier') String? patientIdentifier, AiLocation location,@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'vitals_extracted') AiVitals vitalsExtracted,@JsonKey(name: 'clinical_summary') String clinicalSummary,@JsonKey(name: 'raw_text') String rawText,@JsonKey(name: 'identified_problems') List<String> identifiedProblems,@JsonKey(name: 'medications_mentioned') List<AiMedication> medicationsMentioned
});


@override $AiLocationCopyWith<$Res> get location;@override $AiVitalsCopyWith<$Res> get vitalsExtracted;

}
/// @nodoc
class __$AiExtractionResultCopyWithImpl<$Res>
    implements _$AiExtractionResultCopyWith<$Res> {
  __$AiExtractionResultCopyWithImpl(this._self, this._then);

  final _AiExtractionResult _self;
  final $Res Function(_AiExtractionResult) _then;

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patientIdentifier = freezed,Object? location = null,Object? documentType = null,Object? vitalsExtracted = null,Object? clinicalSummary = null,Object? rawText = null,Object? identifiedProblems = null,Object? medicationsMentioned = null,}) {
  return _then(_AiExtractionResult(
patientIdentifier: freezed == patientIdentifier ? _self.patientIdentifier : patientIdentifier // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AiLocation,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,vitalsExtracted: null == vitalsExtracted ? _self.vitalsExtracted : vitalsExtracted // ignore: cast_nullable_to_non_nullable
as AiVitals,clinicalSummary: null == clinicalSummary ? _self.clinicalSummary : clinicalSummary // ignore: cast_nullable_to_non_nullable
as String,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,identifiedProblems: null == identifiedProblems ? _self._identifiedProblems : identifiedProblems // ignore: cast_nullable_to_non_nullable
as List<String>,medicationsMentioned: null == medicationsMentioned ? _self._medicationsMentioned : medicationsMentioned // ignore: cast_nullable_to_non_nullable
as List<AiMedication>,
  ));
}

/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiLocationCopyWith<$Res> get location {
  
  return $AiLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of AiExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiVitalsCopyWith<$Res> get vitalsExtracted {
  
  return $AiVitalsCopyWith<$Res>(_self.vitalsExtracted, (value) {
    return _then(_self.copyWith(vitalsExtracted: value));
  });
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
