// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegistrationData {

 String get firstName; String get lastName; DateTime get dob; String get phoneE164; String get state; CarInterests get interests;
/// Create a copy of RegistrationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationDataCopyWith<RegistrationData> get copyWith => _$RegistrationDataCopyWithImpl<RegistrationData>(this as RegistrationData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationData&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.state, state) || other.state == state)&&(identical(other.interests, interests) || other.interests == interests));
}


@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,dob,phoneE164,state,interests);

@override
String toString() {
  return 'RegistrationData(firstName: $firstName, lastName: $lastName, dob: $dob, phoneE164: $phoneE164, state: $state, interests: $interests)';
}


}

/// @nodoc
abstract mixin class $RegistrationDataCopyWith<$Res>  {
  factory $RegistrationDataCopyWith(RegistrationData value, $Res Function(RegistrationData) _then) = _$RegistrationDataCopyWithImpl;
@useResult
$Res call({
 String firstName, String lastName, DateTime dob, String phoneE164, String state, CarInterests interests
});


$CarInterestsCopyWith<$Res> get interests;

}
/// @nodoc
class _$RegistrationDataCopyWithImpl<$Res>
    implements $RegistrationDataCopyWith<$Res> {
  _$RegistrationDataCopyWithImpl(this._self, this._then);

  final RegistrationData _self;
  final $Res Function(RegistrationData) _then;

/// Create a copy of RegistrationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? lastName = null,Object? dob = null,Object? phoneE164 = null,Object? state = null,Object? interests = null,}) {
  return _then(_self.copyWith(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dob: null == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime,phoneE164: null == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as CarInterests,
  ));
}
/// Create a copy of RegistrationData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarInterestsCopyWith<$Res> get interests {
  
  return $CarInterestsCopyWith<$Res>(_self.interests, (value) {
    return _then(_self.copyWith(interests: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegistrationData].
extension RegistrationDataPatterns on RegistrationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrationData value)  $default,){
final _that = this;
switch (_that) {
case _RegistrationData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrationData value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String lastName,  DateTime dob,  String phoneE164,  String state,  CarInterests interests)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrationData() when $default != null:
return $default(_that.firstName,_that.lastName,_that.dob,_that.phoneE164,_that.state,_that.interests);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String lastName,  DateTime dob,  String phoneE164,  String state,  CarInterests interests)  $default,) {final _that = this;
switch (_that) {
case _RegistrationData():
return $default(_that.firstName,_that.lastName,_that.dob,_that.phoneE164,_that.state,_that.interests);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String lastName,  DateTime dob,  String phoneE164,  String state,  CarInterests interests)?  $default,) {final _that = this;
switch (_that) {
case _RegistrationData() when $default != null:
return $default(_that.firstName,_that.lastName,_that.dob,_that.phoneE164,_that.state,_that.interests);case _:
  return null;

}
}

}

/// @nodoc


class _RegistrationData implements RegistrationData {
  const _RegistrationData({required this.firstName, required this.lastName, required this.dob, required this.phoneE164, required this.state, required this.interests});
  

@override final  String firstName;
@override final  String lastName;
@override final  DateTime dob;
@override final  String phoneE164;
@override final  String state;
@override final  CarInterests interests;

/// Create a copy of RegistrationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationDataCopyWith<_RegistrationData> get copyWith => __$RegistrationDataCopyWithImpl<_RegistrationData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationData&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.state, state) || other.state == state)&&(identical(other.interests, interests) || other.interests == interests));
}


@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,dob,phoneE164,state,interests);

@override
String toString() {
  return 'RegistrationData(firstName: $firstName, lastName: $lastName, dob: $dob, phoneE164: $phoneE164, state: $state, interests: $interests)';
}


}

/// @nodoc
abstract mixin class _$RegistrationDataCopyWith<$Res> implements $RegistrationDataCopyWith<$Res> {
  factory _$RegistrationDataCopyWith(_RegistrationData value, $Res Function(_RegistrationData) _then) = __$RegistrationDataCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String lastName, DateTime dob, String phoneE164, String state, CarInterests interests
});


@override $CarInterestsCopyWith<$Res> get interests;

}
/// @nodoc
class __$RegistrationDataCopyWithImpl<$Res>
    implements _$RegistrationDataCopyWith<$Res> {
  __$RegistrationDataCopyWithImpl(this._self, this._then);

  final _RegistrationData _self;
  final $Res Function(_RegistrationData) _then;

/// Create a copy of RegistrationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = null,Object? dob = null,Object? phoneE164 = null,Object? state = null,Object? interests = null,}) {
  return _then(_RegistrationData(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dob: null == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime,phoneE164: null == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as CarInterests,
  ));
}

/// Create a copy of RegistrationData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarInterestsCopyWith<$Res> get interests {
  
  return $CarInterestsCopyWith<$Res>(_self.interests, (value) {
    return _then(_self.copyWith(interests: value));
  });
}
}

// dart format on
