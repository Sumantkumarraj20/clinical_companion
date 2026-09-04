// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'department_templates.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicineTemplate {

 Map<String, String> get systemicExamFindings; Map<String, num> get inputOutputChart; String get assessment; String get plan;
/// Create a copy of MedicineTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineTemplateCopyWith<MedicineTemplate> get copyWith => _$MedicineTemplateCopyWithImpl<MedicineTemplate>(this as MedicineTemplate, _$identity);

  /// Serializes this MedicineTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineTemplate&&const DeepCollectionEquality().equals(other.systemicExamFindings, systemicExamFindings)&&const DeepCollectionEquality().equals(other.inputOutputChart, inputOutputChart)&&(identical(other.assessment, assessment) || other.assessment == assessment)&&(identical(other.plan, plan) || other.plan == plan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(systemicExamFindings),const DeepCollectionEquality().hash(inputOutputChart),assessment,plan);

@override
String toString() {
  return 'MedicineTemplate(systemicExamFindings: $systemicExamFindings, inputOutputChart: $inputOutputChart, assessment: $assessment, plan: $plan)';
}


}

/// @nodoc
abstract mixin class $MedicineTemplateCopyWith<$Res>  {
  factory $MedicineTemplateCopyWith(MedicineTemplate value, $Res Function(MedicineTemplate) _then) = _$MedicineTemplateCopyWithImpl;
@useResult
$Res call({
 Map<String, String> systemicExamFindings, Map<String, num> inputOutputChart, String assessment, String plan
});




}
/// @nodoc
class _$MedicineTemplateCopyWithImpl<$Res>
    implements $MedicineTemplateCopyWith<$Res> {
  _$MedicineTemplateCopyWithImpl(this._self, this._then);

  final MedicineTemplate _self;
  final $Res Function(MedicineTemplate) _then;

/// Create a copy of MedicineTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemicExamFindings = null,Object? inputOutputChart = null,Object? assessment = null,Object? plan = null,}) {
  return _then(MedicineTemplate(
systemicExamFindings: null == systemicExamFindings ? _self.systemicExamFindings : systemicExamFindings // ignore: cast_nullable_to_non_nullable
as Map<String, String>,inputOutputChart: null == inputOutputChart ? _self.inputOutputChart : inputOutputChart // ignore: cast_nullable_to_non_nullable
as Map<String, num>,assessment: null == assessment ? _self.assessment : assessment // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineTemplate].
extension MedicineTemplatePatterns on MedicineTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineTemplate value)  $default,){
final _that = this;
switch (_that) {
case _MedicineTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, String> systemicExamFindings,  Map<String, num> inputOutputChart,  String assessment,  String plan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineTemplate() when $default != null:
return $default(_that.systemicExamFindings,_that.inputOutputChart,_that.assessment,_that.plan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, String> systemicExamFindings,  Map<String, num> inputOutputChart,  String assessment,  String plan)  $default,) {final _that = this;
switch (_that) {
case _MedicineTemplate():
return $default(_that.systemicExamFindings,_that.inputOutputChart,_that.assessment,_that.plan);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, String> systemicExamFindings,  Map<String, num> inputOutputChart,  String assessment,  String plan)?  $default,) {final _that = this;
switch (_that) {
case _MedicineTemplate() when $default != null:
return $default(_that.systemicExamFindings,_that.inputOutputChart,_that.assessment,_that.plan);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicineTemplate extends MedicineTemplate {
  const _MedicineTemplate({ Map<String, String> systemicExamFindings = const <String, String>{},  Map<String, num> inputOutputChart = const <String, num>{}, this.assessment = '', this.plan = ''}): _systemicExamFindings = systemicExamFindings,_inputOutputChart = inputOutputChart,super._();
  factory _MedicineTemplate.fromJson(Map<String, dynamic> json) => _$MedicineTemplateFromJson(json);

 final  Map<String, String> _systemicExamFindings;
@override@JsonKey() Map<String, String> get systemicExamFindings {
  if (_systemicExamFindings is EqualUnmodifiableMapView) return _systemicExamFindings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_systemicExamFindings);
}

 final  Map<String, num> _inputOutputChart;
@override@JsonKey() Map<String, num> get inputOutputChart {
  if (_inputOutputChart is EqualUnmodifiableMapView) return _inputOutputChart;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_inputOutputChart);
}

@override@JsonKey() final  String assessment;
@override@JsonKey() final  String plan;

/// Create a copy of MedicineTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineTemplateCopyWith<_MedicineTemplate> get copyWith => __$MedicineTemplateCopyWithImpl<_MedicineTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicineTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineTemplate&&const DeepCollectionEquality().equals(other._systemicExamFindings, _systemicExamFindings)&&const DeepCollectionEquality().equals(other._inputOutputChart, _inputOutputChart)&&(identical(other.assessment, assessment) || other.assessment == assessment)&&(identical(other.plan, plan) || other.plan == plan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_systemicExamFindings),const DeepCollectionEquality().hash(_inputOutputChart),assessment,plan);

@override
String toString() {
  return 'MedicineTemplate(systemicExamFindings: $systemicExamFindings, inputOutputChart: $inputOutputChart, assessment: $assessment, plan: $plan)';
}


}

/// @nodoc
abstract mixin class _$MedicineTemplateCopyWith<$Res> implements $MedicineTemplateCopyWith<$Res> {
  factory _$MedicineTemplateCopyWith(_MedicineTemplate value, $Res Function(_MedicineTemplate) _then) = __$MedicineTemplateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, String> systemicExamFindings, Map<String, num> inputOutputChart, String assessment, String plan
});




}
/// @nodoc
class __$MedicineTemplateCopyWithImpl<$Res>
    implements _$MedicineTemplateCopyWith<$Res> {
  __$MedicineTemplateCopyWithImpl(this._self, this._then);

  final _MedicineTemplate _self;
  final $Res Function(_MedicineTemplate) _then;

/// Create a copy of MedicineTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemicExamFindings = null,Object? inputOutputChart = null,Object? assessment = null,Object? plan = null,}) {
  return _then(_MedicineTemplate(
systemicExamFindings: null == systemicExamFindings ? _self._systemicExamFindings : systemicExamFindings // ignore: cast_nullable_to_non_nullable
as Map<String, String>,inputOutputChart: null == inputOutputChart ? _self._inputOutputChart : inputOutputChart // ignore: cast_nullable_to_non_nullable
as Map<String, num>,assessment: null == assessment ? _self.assessment : assessment // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PediatricsTemplate {

 int get apgarOneMinute; int get apgarFiveMinute; String get developmentalMilestones; double get weightKg; String get dosingNotes;
/// Create a copy of PediatricsTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PediatricsTemplateCopyWith<PediatricsTemplate> get copyWith => _$PediatricsTemplateCopyWithImpl<PediatricsTemplate>(this as PediatricsTemplate, _$identity);

  /// Serializes this PediatricsTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PediatricsTemplate&&(identical(other.apgarOneMinute, apgarOneMinute) || other.apgarOneMinute == apgarOneMinute)&&(identical(other.apgarFiveMinute, apgarFiveMinute) || other.apgarFiveMinute == apgarFiveMinute)&&(identical(other.developmentalMilestones, developmentalMilestones) || other.developmentalMilestones == developmentalMilestones)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.dosingNotes, dosingNotes) || other.dosingNotes == dosingNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apgarOneMinute,apgarFiveMinute,developmentalMilestones,weightKg,dosingNotes);

@override
String toString() {
  return 'PediatricsTemplate(apgarOneMinute: $apgarOneMinute, apgarFiveMinute: $apgarFiveMinute, developmentalMilestones: $developmentalMilestones, weightKg: $weightKg, dosingNotes: $dosingNotes)';
}


}

/// @nodoc
abstract mixin class $PediatricsTemplateCopyWith<$Res>  {
  factory $PediatricsTemplateCopyWith(PediatricsTemplate value, $Res Function(PediatricsTemplate) _then) = _$PediatricsTemplateCopyWithImpl;
@useResult
$Res call({
 int apgarOneMinute, int apgarFiveMinute, String developmentalMilestones, double weightKg, String dosingNotes
});




}
/// @nodoc
class _$PediatricsTemplateCopyWithImpl<$Res>
    implements $PediatricsTemplateCopyWith<$Res> {
  _$PediatricsTemplateCopyWithImpl(this._self, this._then);

  final PediatricsTemplate _self;
  final $Res Function(PediatricsTemplate) _then;

/// Create a copy of PediatricsTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? apgarOneMinute = null,Object? apgarFiveMinute = null,Object? developmentalMilestones = null,Object? weightKg = null,Object? dosingNotes = null,}) {
  return _then(PediatricsTemplate(
apgarOneMinute: null == apgarOneMinute ? _self.apgarOneMinute : apgarOneMinute // ignore: cast_nullable_to_non_nullable
as int,apgarFiveMinute: null == apgarFiveMinute ? _self.apgarFiveMinute : apgarFiveMinute // ignore: cast_nullable_to_non_nullable
as int,developmentalMilestones: null == developmentalMilestones ? _self.developmentalMilestones : developmentalMilestones // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,dosingNotes: null == dosingNotes ? _self.dosingNotes : dosingNotes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PediatricsTemplate].
extension PediatricsTemplatePatterns on PediatricsTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PediatricsTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PediatricsTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PediatricsTemplate value)  $default,){
final _that = this;
switch (_that) {
case _PediatricsTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PediatricsTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _PediatricsTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int apgarOneMinute,  int apgarFiveMinute,  String developmentalMilestones,  double weightKg,  String dosingNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PediatricsTemplate() when $default != null:
return $default(_that.apgarOneMinute,_that.apgarFiveMinute,_that.developmentalMilestones,_that.weightKg,_that.dosingNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int apgarOneMinute,  int apgarFiveMinute,  String developmentalMilestones,  double weightKg,  String dosingNotes)  $default,) {final _that = this;
switch (_that) {
case _PediatricsTemplate():
return $default(_that.apgarOneMinute,_that.apgarFiveMinute,_that.developmentalMilestones,_that.weightKg,_that.dosingNotes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int apgarOneMinute,  int apgarFiveMinute,  String developmentalMilestones,  double weightKg,  String dosingNotes)?  $default,) {final _that = this;
switch (_that) {
case _PediatricsTemplate() when $default != null:
return $default(_that.apgarOneMinute,_that.apgarFiveMinute,_that.developmentalMilestones,_that.weightKg,_that.dosingNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PediatricsTemplate extends PediatricsTemplate {
  const _PediatricsTemplate({this.apgarOneMinute = 0, this.apgarFiveMinute = 0, this.developmentalMilestones = '', this.weightKg = 0, this.dosingNotes = ''}): super._();
  factory _PediatricsTemplate.fromJson(Map<String, dynamic> json) => _$PediatricsTemplateFromJson(json);

@override@JsonKey() final  int apgarOneMinute;
@override@JsonKey() final  int apgarFiveMinute;
@override@JsonKey() final  String developmentalMilestones;
@override@JsonKey() final  double weightKg;
@override@JsonKey() final  String dosingNotes;

/// Create a copy of PediatricsTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PediatricsTemplateCopyWith<_PediatricsTemplate> get copyWith => __$PediatricsTemplateCopyWithImpl<_PediatricsTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PediatricsTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PediatricsTemplate&&(identical(other.apgarOneMinute, apgarOneMinute) || other.apgarOneMinute == apgarOneMinute)&&(identical(other.apgarFiveMinute, apgarFiveMinute) || other.apgarFiveMinute == apgarFiveMinute)&&(identical(other.developmentalMilestones, developmentalMilestones) || other.developmentalMilestones == developmentalMilestones)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.dosingNotes, dosingNotes) || other.dosingNotes == dosingNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apgarOneMinute,apgarFiveMinute,developmentalMilestones,weightKg,dosingNotes);

@override
String toString() {
  return 'PediatricsTemplate(apgarOneMinute: $apgarOneMinute, apgarFiveMinute: $apgarFiveMinute, developmentalMilestones: $developmentalMilestones, weightKg: $weightKg, dosingNotes: $dosingNotes)';
}


}

/// @nodoc
abstract mixin class _$PediatricsTemplateCopyWith<$Res> implements $PediatricsTemplateCopyWith<$Res> {
  factory _$PediatricsTemplateCopyWith(_PediatricsTemplate value, $Res Function(_PediatricsTemplate) _then) = __$PediatricsTemplateCopyWithImpl;
@override @useResult
$Res call({
 int apgarOneMinute, int apgarFiveMinute, String developmentalMilestones, double weightKg, String dosingNotes
});




}
/// @nodoc
class __$PediatricsTemplateCopyWithImpl<$Res>
    implements _$PediatricsTemplateCopyWith<$Res> {
  __$PediatricsTemplateCopyWithImpl(this._self, this._then);

  final _PediatricsTemplate _self;
  final $Res Function(_PediatricsTemplate) _then;

/// Create a copy of PediatricsTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? apgarOneMinute = null,Object? apgarFiveMinute = null,Object? developmentalMilestones = null,Object? weightKg = null,Object? dosingNotes = null,}) {
  return _then(_PediatricsTemplate(
apgarOneMinute: null == apgarOneMinute ? _self.apgarOneMinute : apgarOneMinute // ignore: cast_nullable_to_non_nullable
as int,apgarFiveMinute: null == apgarFiveMinute ? _self.apgarFiveMinute : apgarFiveMinute // ignore: cast_nullable_to_non_nullable
as int,developmentalMilestones: null == developmentalMilestones ? _self.developmentalMilestones : developmentalMilestones // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,dosingNotes: null == dosingNotes ? _self.dosingNotes : dosingNotes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ObGynTemplate {

 int get gravida; int get para; int get abortions; int get living; int get fetalHeartRate; int get bishopScore; String get gestationalAge; String get partographNotes;
/// Create a copy of ObGynTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObGynTemplateCopyWith<ObGynTemplate> get copyWith => _$ObGynTemplateCopyWithImpl<ObGynTemplate>(this as ObGynTemplate, _$identity);

  /// Serializes this ObGynTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObGynTemplate&&(identical(other.gravida, gravida) || other.gravida == gravida)&&(identical(other.para, para) || other.para == para)&&(identical(other.abortions, abortions) || other.abortions == abortions)&&(identical(other.living, living) || other.living == living)&&(identical(other.fetalHeartRate, fetalHeartRate) || other.fetalHeartRate == fetalHeartRate)&&(identical(other.bishopScore, bishopScore) || other.bishopScore == bishopScore)&&(identical(other.gestationalAge, gestationalAge) || other.gestationalAge == gestationalAge)&&(identical(other.partographNotes, partographNotes) || other.partographNotes == partographNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gravida,para,abortions,living,fetalHeartRate,bishopScore,gestationalAge,partographNotes);

@override
String toString() {
  return 'ObGynTemplate(gravida: $gravida, para: $para, abortions: $abortions, living: $living, fetalHeartRate: $fetalHeartRate, bishopScore: $bishopScore, gestationalAge: $gestationalAge, partographNotes: $partographNotes)';
}


}

/// @nodoc
abstract mixin class $ObGynTemplateCopyWith<$Res>  {
  factory $ObGynTemplateCopyWith(ObGynTemplate value, $Res Function(ObGynTemplate) _then) = _$ObGynTemplateCopyWithImpl;
@useResult
$Res call({
 int gravida, int para, int abortions, int living, int fetalHeartRate, int bishopScore, String gestationalAge, String partographNotes
});




}
/// @nodoc
class _$ObGynTemplateCopyWithImpl<$Res>
    implements $ObGynTemplateCopyWith<$Res> {
  _$ObGynTemplateCopyWithImpl(this._self, this._then);

  final ObGynTemplate _self;
  final $Res Function(ObGynTemplate) _then;

/// Create a copy of ObGynTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gravida = null,Object? para = null,Object? abortions = null,Object? living = null,Object? fetalHeartRate = null,Object? bishopScore = null,Object? gestationalAge = null,Object? partographNotes = null,}) {
  return _then(ObGynTemplate(
gravida: null == gravida ? _self.gravida : gravida // ignore: cast_nullable_to_non_nullable
as int,para: null == para ? _self.para : para // ignore: cast_nullable_to_non_nullable
as int,abortions: null == abortions ? _self.abortions : abortions // ignore: cast_nullable_to_non_nullable
as int,living: null == living ? _self.living : living // ignore: cast_nullable_to_non_nullable
as int,fetalHeartRate: null == fetalHeartRate ? _self.fetalHeartRate : fetalHeartRate // ignore: cast_nullable_to_non_nullable
as int,bishopScore: null == bishopScore ? _self.bishopScore : bishopScore // ignore: cast_nullable_to_non_nullable
as int,gestationalAge: null == gestationalAge ? _self.gestationalAge : gestationalAge // ignore: cast_nullable_to_non_nullable
as String,partographNotes: null == partographNotes ? _self.partographNotes : partographNotes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ObGynTemplate].
extension ObGynTemplatePatterns on ObGynTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ObGynTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ObGynTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ObGynTemplate value)  $default,){
final _that = this;
switch (_that) {
case _ObGynTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ObGynTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _ObGynTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int gravida,  int para,  int abortions,  int living,  int fetalHeartRate,  int bishopScore,  String gestationalAge,  String partographNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ObGynTemplate() when $default != null:
return $default(_that.gravida,_that.para,_that.abortions,_that.living,_that.fetalHeartRate,_that.bishopScore,_that.gestationalAge,_that.partographNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int gravida,  int para,  int abortions,  int living,  int fetalHeartRate,  int bishopScore,  String gestationalAge,  String partographNotes)  $default,) {final _that = this;
switch (_that) {
case _ObGynTemplate():
return $default(_that.gravida,_that.para,_that.abortions,_that.living,_that.fetalHeartRate,_that.bishopScore,_that.gestationalAge,_that.partographNotes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int gravida,  int para,  int abortions,  int living,  int fetalHeartRate,  int bishopScore,  String gestationalAge,  String partographNotes)?  $default,) {final _that = this;
switch (_that) {
case _ObGynTemplate() when $default != null:
return $default(_that.gravida,_that.para,_that.abortions,_that.living,_that.fetalHeartRate,_that.bishopScore,_that.gestationalAge,_that.partographNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ObGynTemplate extends ObGynTemplate {
  const _ObGynTemplate({this.gravida = 0, this.para = 0, this.abortions = 0, this.living = 0, this.fetalHeartRate = 0, this.bishopScore = 0, this.gestationalAge = '', this.partographNotes = ''}): super._();
  factory _ObGynTemplate.fromJson(Map<String, dynamic> json) => _$ObGynTemplateFromJson(json);

@override@JsonKey() final  int gravida;
@override@JsonKey() final  int para;
@override@JsonKey() final  int abortions;
@override@JsonKey() final  int living;
@override@JsonKey() final  int fetalHeartRate;
@override@JsonKey() final  int bishopScore;
@override@JsonKey() final  String gestationalAge;
@override@JsonKey() final  String partographNotes;

/// Create a copy of ObGynTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObGynTemplateCopyWith<_ObGynTemplate> get copyWith => __$ObGynTemplateCopyWithImpl<_ObGynTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObGynTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ObGynTemplate&&(identical(other.gravida, gravida) || other.gravida == gravida)&&(identical(other.para, para) || other.para == para)&&(identical(other.abortions, abortions) || other.abortions == abortions)&&(identical(other.living, living) || other.living == living)&&(identical(other.fetalHeartRate, fetalHeartRate) || other.fetalHeartRate == fetalHeartRate)&&(identical(other.bishopScore, bishopScore) || other.bishopScore == bishopScore)&&(identical(other.gestationalAge, gestationalAge) || other.gestationalAge == gestationalAge)&&(identical(other.partographNotes, partographNotes) || other.partographNotes == partographNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gravida,para,abortions,living,fetalHeartRate,bishopScore,gestationalAge,partographNotes);

@override
String toString() {
  return 'ObGynTemplate(gravida: $gravida, para: $para, abortions: $abortions, living: $living, fetalHeartRate: $fetalHeartRate, bishopScore: $bishopScore, gestationalAge: $gestationalAge, partographNotes: $partographNotes)';
}


}

/// @nodoc
abstract mixin class _$ObGynTemplateCopyWith<$Res> implements $ObGynTemplateCopyWith<$Res> {
  factory _$ObGynTemplateCopyWith(_ObGynTemplate value, $Res Function(_ObGynTemplate) _then) = __$ObGynTemplateCopyWithImpl;
@override @useResult
$Res call({
 int gravida, int para, int abortions, int living, int fetalHeartRate, int bishopScore, String gestationalAge, String partographNotes
});




}
/// @nodoc
class __$ObGynTemplateCopyWithImpl<$Res>
    implements _$ObGynTemplateCopyWith<$Res> {
  __$ObGynTemplateCopyWithImpl(this._self, this._then);

  final _ObGynTemplate _self;
  final $Res Function(_ObGynTemplate) _then;

/// Create a copy of ObGynTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gravida = null,Object? para = null,Object? abortions = null,Object? living = null,Object? fetalHeartRate = null,Object? bishopScore = null,Object? gestationalAge = null,Object? partographNotes = null,}) {
  return _then(_ObGynTemplate(
gravida: null == gravida ? _self.gravida : gravida // ignore: cast_nullable_to_non_nullable
as int,para: null == para ? _self.para : para // ignore: cast_nullable_to_non_nullable
as int,abortions: null == abortions ? _self.abortions : abortions // ignore: cast_nullable_to_non_nullable
as int,living: null == living ? _self.living : living // ignore: cast_nullable_to_non_nullable
as int,fetalHeartRate: null == fetalHeartRate ? _self.fetalHeartRate : fetalHeartRate // ignore: cast_nullable_to_non_nullable
as int,bishopScore: null == bishopScore ? _self.bishopScore : bishopScore // ignore: cast_nullable_to_non_nullable
as int,gestationalAge: null == gestationalAge ? _self.gestationalAge : gestationalAge // ignore: cast_nullable_to_non_nullable
as String,partographNotes: null == partographNotes ? _self.partographNotes : partographNotes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SurgeryTemplate {

 String get woundStatus; double get drainOutputMl; int get postOpDay; String get procedureName; String get flapVascularity; String get operationNote;
/// Create a copy of SurgeryTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurgeryTemplateCopyWith<SurgeryTemplate> get copyWith => _$SurgeryTemplateCopyWithImpl<SurgeryTemplate>(this as SurgeryTemplate, _$identity);

  /// Serializes this SurgeryTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurgeryTemplate&&(identical(other.woundStatus, woundStatus) || other.woundStatus == woundStatus)&&(identical(other.drainOutputMl, drainOutputMl) || other.drainOutputMl == drainOutputMl)&&(identical(other.postOpDay, postOpDay) || other.postOpDay == postOpDay)&&(identical(other.procedureName, procedureName) || other.procedureName == procedureName)&&(identical(other.flapVascularity, flapVascularity) || other.flapVascularity == flapVascularity)&&(identical(other.operationNote, operationNote) || other.operationNote == operationNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,woundStatus,drainOutputMl,postOpDay,procedureName,flapVascularity,operationNote);

@override
String toString() {
  return 'SurgeryTemplate(woundStatus: $woundStatus, drainOutputMl: $drainOutputMl, postOpDay: $postOpDay, procedureName: $procedureName, flapVascularity: $flapVascularity, operationNote: $operationNote)';
}


}

/// @nodoc
abstract mixin class $SurgeryTemplateCopyWith<$Res>  {
  factory $SurgeryTemplateCopyWith(SurgeryTemplate value, $Res Function(SurgeryTemplate) _then) = _$SurgeryTemplateCopyWithImpl;
@useResult
$Res call({
 String woundStatus, double drainOutputMl, int postOpDay, String procedureName, String flapVascularity, String operationNote
});




}
/// @nodoc
class _$SurgeryTemplateCopyWithImpl<$Res>
    implements $SurgeryTemplateCopyWith<$Res> {
  _$SurgeryTemplateCopyWithImpl(this._self, this._then);

  final SurgeryTemplate _self;
  final $Res Function(SurgeryTemplate) _then;

/// Create a copy of SurgeryTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? woundStatus = null,Object? drainOutputMl = null,Object? postOpDay = null,Object? procedureName = null,Object? flapVascularity = null,Object? operationNote = null,}) {
  return _then(SurgeryTemplate(
woundStatus: null == woundStatus ? _self.woundStatus : woundStatus // ignore: cast_nullable_to_non_nullable
as String,drainOutputMl: null == drainOutputMl ? _self.drainOutputMl : drainOutputMl // ignore: cast_nullable_to_non_nullable
as double,postOpDay: null == postOpDay ? _self.postOpDay : postOpDay // ignore: cast_nullable_to_non_nullable
as int,procedureName: null == procedureName ? _self.procedureName : procedureName // ignore: cast_nullable_to_non_nullable
as String,flapVascularity: null == flapVascularity ? _self.flapVascularity : flapVascularity // ignore: cast_nullable_to_non_nullable
as String,operationNote: null == operationNote ? _self.operationNote : operationNote // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SurgeryTemplate].
extension SurgeryTemplatePatterns on SurgeryTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurgeryTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurgeryTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurgeryTemplate value)  $default,){
final _that = this;
switch (_that) {
case _SurgeryTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurgeryTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _SurgeryTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String woundStatus,  double drainOutputMl,  int postOpDay,  String procedureName,  String flapVascularity,  String operationNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurgeryTemplate() when $default != null:
return $default(_that.woundStatus,_that.drainOutputMl,_that.postOpDay,_that.procedureName,_that.flapVascularity,_that.operationNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String woundStatus,  double drainOutputMl,  int postOpDay,  String procedureName,  String flapVascularity,  String operationNote)  $default,) {final _that = this;
switch (_that) {
case _SurgeryTemplate():
return $default(_that.woundStatus,_that.drainOutputMl,_that.postOpDay,_that.procedureName,_that.flapVascularity,_that.operationNote);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String woundStatus,  double drainOutputMl,  int postOpDay,  String procedureName,  String flapVascularity,  String operationNote)?  $default,) {final _that = this;
switch (_that) {
case _SurgeryTemplate() when $default != null:
return $default(_that.woundStatus,_that.drainOutputMl,_that.postOpDay,_that.procedureName,_that.flapVascularity,_that.operationNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurgeryTemplate extends SurgeryTemplate {
  const _SurgeryTemplate({this.woundStatus = '', this.drainOutputMl = 0, this.postOpDay = 0, this.procedureName = '', this.flapVascularity = '', this.operationNote = ''}): super._();
  factory _SurgeryTemplate.fromJson(Map<String, dynamic> json) => _$SurgeryTemplateFromJson(json);

@override@JsonKey() final  String woundStatus;
@override@JsonKey() final  double drainOutputMl;
@override@JsonKey() final  int postOpDay;
@override@JsonKey() final  String procedureName;
@override@JsonKey() final  String flapVascularity;
@override@JsonKey() final  String operationNote;

/// Create a copy of SurgeryTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurgeryTemplateCopyWith<_SurgeryTemplate> get copyWith => __$SurgeryTemplateCopyWithImpl<_SurgeryTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurgeryTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurgeryTemplate&&(identical(other.woundStatus, woundStatus) || other.woundStatus == woundStatus)&&(identical(other.drainOutputMl, drainOutputMl) || other.drainOutputMl == drainOutputMl)&&(identical(other.postOpDay, postOpDay) || other.postOpDay == postOpDay)&&(identical(other.procedureName, procedureName) || other.procedureName == procedureName)&&(identical(other.flapVascularity, flapVascularity) || other.flapVascularity == flapVascularity)&&(identical(other.operationNote, operationNote) || other.operationNote == operationNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,woundStatus,drainOutputMl,postOpDay,procedureName,flapVascularity,operationNote);

@override
String toString() {
  return 'SurgeryTemplate(woundStatus: $woundStatus, drainOutputMl: $drainOutputMl, postOpDay: $postOpDay, procedureName: $procedureName, flapVascularity: $flapVascularity, operationNote: $operationNote)';
}


}

/// @nodoc
abstract mixin class _$SurgeryTemplateCopyWith<$Res> implements $SurgeryTemplateCopyWith<$Res> {
  factory _$SurgeryTemplateCopyWith(_SurgeryTemplate value, $Res Function(_SurgeryTemplate) _then) = __$SurgeryTemplateCopyWithImpl;
@override @useResult
$Res call({
 String woundStatus, double drainOutputMl, int postOpDay, String procedureName, String flapVascularity, String operationNote
});




}
/// @nodoc
class __$SurgeryTemplateCopyWithImpl<$Res>
    implements _$SurgeryTemplateCopyWith<$Res> {
  __$SurgeryTemplateCopyWithImpl(this._self, this._then);

  final _SurgeryTemplate _self;
  final $Res Function(_SurgeryTemplate) _then;

/// Create a copy of SurgeryTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? woundStatus = null,Object? drainOutputMl = null,Object? postOpDay = null,Object? procedureName = null,Object? flapVascularity = null,Object? operationNote = null,}) {
  return _then(_SurgeryTemplate(
woundStatus: null == woundStatus ? _self.woundStatus : woundStatus // ignore: cast_nullable_to_non_nullable
as String,drainOutputMl: null == drainOutputMl ? _self.drainOutputMl : drainOutputMl // ignore: cast_nullable_to_non_nullable
as double,postOpDay: null == postOpDay ? _self.postOpDay : postOpDay // ignore: cast_nullable_to_non_nullable
as int,procedureName: null == procedureName ? _self.procedureName : procedureName // ignore: cast_nullable_to_non_nullable
as String,flapVascularity: null == flapVascularity ? _self.flapVascularity : flapVascularity // ignore: cast_nullable_to_non_nullable
as String,operationNote: null == operationNote ? _self.operationNote : operationNote // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PsychiatryTemplate {

 String get appearance; String get behavior; String get speech; String get mood; String get thoughtProcess; String get perception; String get cognition; String get insight; bool get suicidalIdeation; bool get homicidalIdeation; bool get hallucinations;
/// Create a copy of PsychiatryTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PsychiatryTemplateCopyWith<PsychiatryTemplate> get copyWith => _$PsychiatryTemplateCopyWithImpl<PsychiatryTemplate>(this as PsychiatryTemplate, _$identity);

  /// Serializes this PsychiatryTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PsychiatryTemplate&&(identical(other.appearance, appearance) || other.appearance == appearance)&&(identical(other.behavior, behavior) || other.behavior == behavior)&&(identical(other.speech, speech) || other.speech == speech)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.thoughtProcess, thoughtProcess) || other.thoughtProcess == thoughtProcess)&&(identical(other.perception, perception) || other.perception == perception)&&(identical(other.cognition, cognition) || other.cognition == cognition)&&(identical(other.insight, insight) || other.insight == insight)&&(identical(other.suicidalIdeation, suicidalIdeation) || other.suicidalIdeation == suicidalIdeation)&&(identical(other.homicidalIdeation, homicidalIdeation) || other.homicidalIdeation == homicidalIdeation)&&(identical(other.hallucinations, hallucinations) || other.hallucinations == hallucinations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appearance,behavior,speech,mood,thoughtProcess,perception,cognition,insight,suicidalIdeation,homicidalIdeation,hallucinations);

@override
String toString() {
  return 'PsychiatryTemplate(appearance: $appearance, behavior: $behavior, speech: $speech, mood: $mood, thoughtProcess: $thoughtProcess, perception: $perception, cognition: $cognition, insight: $insight, suicidalIdeation: $suicidalIdeation, homicidalIdeation: $homicidalIdeation, hallucinations: $hallucinations)';
}


}

/// @nodoc
abstract mixin class $PsychiatryTemplateCopyWith<$Res>  {
  factory $PsychiatryTemplateCopyWith(PsychiatryTemplate value, $Res Function(PsychiatryTemplate) _then) = _$PsychiatryTemplateCopyWithImpl;
@useResult
$Res call({
 String appearance, String behavior, String speech, String mood, String thoughtProcess, String perception, String cognition, String insight, bool suicidalIdeation, bool homicidalIdeation, bool hallucinations
});




}
/// @nodoc
class _$PsychiatryTemplateCopyWithImpl<$Res>
    implements $PsychiatryTemplateCopyWith<$Res> {
  _$PsychiatryTemplateCopyWithImpl(this._self, this._then);

  final PsychiatryTemplate _self;
  final $Res Function(PsychiatryTemplate) _then;

/// Create a copy of PsychiatryTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appearance = null,Object? behavior = null,Object? speech = null,Object? mood = null,Object? thoughtProcess = null,Object? perception = null,Object? cognition = null,Object? insight = null,Object? suicidalIdeation = null,Object? homicidalIdeation = null,Object? hallucinations = null,}) {
  return _then(PsychiatryTemplate(
appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,behavior: null == behavior ? _self.behavior : behavior // ignore: cast_nullable_to_non_nullable
as String,speech: null == speech ? _self.speech : speech // ignore: cast_nullable_to_non_nullable
as String,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,thoughtProcess: null == thoughtProcess ? _self.thoughtProcess : thoughtProcess // ignore: cast_nullable_to_non_nullable
as String,perception: null == perception ? _self.perception : perception // ignore: cast_nullable_to_non_nullable
as String,cognition: null == cognition ? _self.cognition : cognition // ignore: cast_nullable_to_non_nullable
as String,insight: null == insight ? _self.insight : insight // ignore: cast_nullable_to_non_nullable
as String,suicidalIdeation: null == suicidalIdeation ? _self.suicidalIdeation : suicidalIdeation // ignore: cast_nullable_to_non_nullable
as bool,homicidalIdeation: null == homicidalIdeation ? _self.homicidalIdeation : homicidalIdeation // ignore: cast_nullable_to_non_nullable
as bool,hallucinations: null == hallucinations ? _self.hallucinations : hallucinations // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PsychiatryTemplate].
extension PsychiatryTemplatePatterns on PsychiatryTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PsychiatryTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PsychiatryTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PsychiatryTemplate value)  $default,){
final _that = this;
switch (_that) {
case _PsychiatryTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PsychiatryTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _PsychiatryTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appearance,  String behavior,  String speech,  String mood,  String thoughtProcess,  String perception,  String cognition,  String insight,  bool suicidalIdeation,  bool homicidalIdeation,  bool hallucinations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PsychiatryTemplate() when $default != null:
return $default(_that.appearance,_that.behavior,_that.speech,_that.mood,_that.thoughtProcess,_that.perception,_that.cognition,_that.insight,_that.suicidalIdeation,_that.homicidalIdeation,_that.hallucinations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appearance,  String behavior,  String speech,  String mood,  String thoughtProcess,  String perception,  String cognition,  String insight,  bool suicidalIdeation,  bool homicidalIdeation,  bool hallucinations)  $default,) {final _that = this;
switch (_that) {
case _PsychiatryTemplate():
return $default(_that.appearance,_that.behavior,_that.speech,_that.mood,_that.thoughtProcess,_that.perception,_that.cognition,_that.insight,_that.suicidalIdeation,_that.homicidalIdeation,_that.hallucinations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appearance,  String behavior,  String speech,  String mood,  String thoughtProcess,  String perception,  String cognition,  String insight,  bool suicidalIdeation,  bool homicidalIdeation,  bool hallucinations)?  $default,) {final _that = this;
switch (_that) {
case _PsychiatryTemplate() when $default != null:
return $default(_that.appearance,_that.behavior,_that.speech,_that.mood,_that.thoughtProcess,_that.perception,_that.cognition,_that.insight,_that.suicidalIdeation,_that.homicidalIdeation,_that.hallucinations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PsychiatryTemplate extends PsychiatryTemplate {
  const _PsychiatryTemplate({this.appearance = '', this.behavior = '', this.speech = '', this.mood = '', this.thoughtProcess = '', this.perception = '', this.cognition = '', this.insight = '', this.suicidalIdeation = false, this.homicidalIdeation = false, this.hallucinations = false}): super._();
  factory _PsychiatryTemplate.fromJson(Map<String, dynamic> json) => _$PsychiatryTemplateFromJson(json);

@override@JsonKey() final  String appearance;
@override@JsonKey() final  String behavior;
@override@JsonKey() final  String speech;
@override@JsonKey() final  String mood;
@override@JsonKey() final  String thoughtProcess;
@override@JsonKey() final  String perception;
@override@JsonKey() final  String cognition;
@override@JsonKey() final  String insight;
@override@JsonKey() final  bool suicidalIdeation;
@override@JsonKey() final  bool homicidalIdeation;
@override@JsonKey() final  bool hallucinations;

/// Create a copy of PsychiatryTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PsychiatryTemplateCopyWith<_PsychiatryTemplate> get copyWith => __$PsychiatryTemplateCopyWithImpl<_PsychiatryTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PsychiatryTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PsychiatryTemplate&&(identical(other.appearance, appearance) || other.appearance == appearance)&&(identical(other.behavior, behavior) || other.behavior == behavior)&&(identical(other.speech, speech) || other.speech == speech)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.thoughtProcess, thoughtProcess) || other.thoughtProcess == thoughtProcess)&&(identical(other.perception, perception) || other.perception == perception)&&(identical(other.cognition, cognition) || other.cognition == cognition)&&(identical(other.insight, insight) || other.insight == insight)&&(identical(other.suicidalIdeation, suicidalIdeation) || other.suicidalIdeation == suicidalIdeation)&&(identical(other.homicidalIdeation, homicidalIdeation) || other.homicidalIdeation == homicidalIdeation)&&(identical(other.hallucinations, hallucinations) || other.hallucinations == hallucinations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appearance,behavior,speech,mood,thoughtProcess,perception,cognition,insight,suicidalIdeation,homicidalIdeation,hallucinations);

@override
String toString() {
  return 'PsychiatryTemplate(appearance: $appearance, behavior: $behavior, speech: $speech, mood: $mood, thoughtProcess: $thoughtProcess, perception: $perception, cognition: $cognition, insight: $insight, suicidalIdeation: $suicidalIdeation, homicidalIdeation: $homicidalIdeation, hallucinations: $hallucinations)';
}


}

/// @nodoc
abstract mixin class _$PsychiatryTemplateCopyWith<$Res> implements $PsychiatryTemplateCopyWith<$Res> {
  factory _$PsychiatryTemplateCopyWith(_PsychiatryTemplate value, $Res Function(_PsychiatryTemplate) _then) = __$PsychiatryTemplateCopyWithImpl;
@override @useResult
$Res call({
 String appearance, String behavior, String speech, String mood, String thoughtProcess, String perception, String cognition, String insight, bool suicidalIdeation, bool homicidalIdeation, bool hallucinations
});




}
/// @nodoc
class __$PsychiatryTemplateCopyWithImpl<$Res>
    implements _$PsychiatryTemplateCopyWith<$Res> {
  __$PsychiatryTemplateCopyWithImpl(this._self, this._then);

  final _PsychiatryTemplate _self;
  final $Res Function(_PsychiatryTemplate) _then;

/// Create a copy of PsychiatryTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appearance = null,Object? behavior = null,Object? speech = null,Object? mood = null,Object? thoughtProcess = null,Object? perception = null,Object? cognition = null,Object? insight = null,Object? suicidalIdeation = null,Object? homicidalIdeation = null,Object? hallucinations = null,}) {
  return _then(_PsychiatryTemplate(
appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,behavior: null == behavior ? _self.behavior : behavior // ignore: cast_nullable_to_non_nullable
as String,speech: null == speech ? _self.speech : speech // ignore: cast_nullable_to_non_nullable
as String,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,thoughtProcess: null == thoughtProcess ? _self.thoughtProcess : thoughtProcess // ignore: cast_nullable_to_non_nullable
as String,perception: null == perception ? _self.perception : perception // ignore: cast_nullable_to_non_nullable
as String,cognition: null == cognition ? _self.cognition : cognition // ignore: cast_nullable_to_non_nullable
as String,insight: null == insight ? _self.insight : insight // ignore: cast_nullable_to_non_nullable
as String,suicidalIdeation: null == suicidalIdeation ? _self.suicidalIdeation : suicidalIdeation // ignore: cast_nullable_to_non_nullable
as bool,homicidalIdeation: null == homicidalIdeation ? _self.homicidalIdeation : homicidalIdeation // ignore: cast_nullable_to_non_nullable
as bool,hallucinations: null == hallucinations ? _self.hallucinations : hallucinations // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GenericClinicalTemplate {

 Map<String, dynamic> get values;
/// Create a copy of GenericClinicalTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenericClinicalTemplateCopyWith<GenericClinicalTemplate> get copyWith => _$GenericClinicalTemplateCopyWithImpl<GenericClinicalTemplate>(this as GenericClinicalTemplate, _$identity);

  /// Serializes this GenericClinicalTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenericClinicalTemplate&&const DeepCollectionEquality().equals(other.values, values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'GenericClinicalTemplate(values: $values)';
}


}

/// @nodoc
abstract mixin class $GenericClinicalTemplateCopyWith<$Res>  {
  factory $GenericClinicalTemplateCopyWith(GenericClinicalTemplate value, $Res Function(GenericClinicalTemplate) _then) = _$GenericClinicalTemplateCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> values
});




}
/// @nodoc
class _$GenericClinicalTemplateCopyWithImpl<$Res>
    implements $GenericClinicalTemplateCopyWith<$Res> {
  _$GenericClinicalTemplateCopyWithImpl(this._self, this._then);

  final GenericClinicalTemplate _self;
  final $Res Function(GenericClinicalTemplate) _then;

/// Create a copy of GenericClinicalTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? values = null,}) {
  return _then(GenericClinicalTemplate(
values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [GenericClinicalTemplate].
extension GenericClinicalTemplatePatterns on GenericClinicalTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenericClinicalTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenericClinicalTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenericClinicalTemplate value)  $default,){
final _that = this;
switch (_that) {
case _GenericClinicalTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenericClinicalTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _GenericClinicalTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenericClinicalTemplate() when $default != null:
return $default(_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> values)  $default,) {final _that = this;
switch (_that) {
case _GenericClinicalTemplate():
return $default(_that.values);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> values)?  $default,) {final _that = this;
switch (_that) {
case _GenericClinicalTemplate() when $default != null:
return $default(_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenericClinicalTemplate extends GenericClinicalTemplate {
  const _GenericClinicalTemplate({ Map<String, dynamic> values = const <String, dynamic>{}}): _values = values,super._();
  factory _GenericClinicalTemplate.fromJson(Map<String, dynamic> json) => _$GenericClinicalTemplateFromJson(json);

 final  Map<String, dynamic> _values;
@override@JsonKey() Map<String, dynamic> get values {
  if (_values is EqualUnmodifiableMapView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_values);
}


/// Create a copy of GenericClinicalTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenericClinicalTemplateCopyWith<_GenericClinicalTemplate> get copyWith => __$GenericClinicalTemplateCopyWithImpl<_GenericClinicalTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenericClinicalTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenericClinicalTemplate&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'GenericClinicalTemplate(values: $values)';
}


}

/// @nodoc
abstract mixin class _$GenericClinicalTemplateCopyWith<$Res> implements $GenericClinicalTemplateCopyWith<$Res> {
  factory _$GenericClinicalTemplateCopyWith(_GenericClinicalTemplate value, $Res Function(_GenericClinicalTemplate) _then) = __$GenericClinicalTemplateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> values
});




}
/// @nodoc
class __$GenericClinicalTemplateCopyWithImpl<$Res>
    implements _$GenericClinicalTemplateCopyWith<$Res> {
  __$GenericClinicalTemplateCopyWithImpl(this._self, this._then);

  final _GenericClinicalTemplate _self;
  final $Res Function(_GenericClinicalTemplate) _then;

/// Create a copy of GenericClinicalTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? values = null,}) {
  return _then(_GenericClinicalTemplate(
values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
