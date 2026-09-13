// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegistrationState {

 String get email; String get password; String get confirmPassword; String get firstName; String get lastName; DateTime? get dob; String get phoneInput; String? get stateName; bool get detectingLocation; bool get locationFailed; CarInterests get interests;
/// Create a copy of RegistrationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationStateCopyWith<RegistrationState> get copyWith => _$RegistrationStateCopyWithImpl<RegistrationState>(this as RegistrationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.phoneInput, phoneInput) || other.phoneInput == phoneInput)&&(identical(other.stateName, stateName) || other.stateName == stateName)&&(identical(other.detectingLocation, detectingLocation) || other.detectingLocation == detectingLocation)&&(identical(other.locationFailed, locationFailed) || other.locationFailed == locationFailed)&&(identical(other.interests, interests) || other.interests == interests));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,confirmPassword,firstName,lastName,dob,phoneInput,stateName,detectingLocation,locationFailed,interests);

@override
String toString() {
  return 'RegistrationState(email: $email, password: $password, confirmPassword: $confirmPassword, firstName: $firstName, lastName: $lastName, dob: $dob, phoneInput: $phoneInput, stateName: $stateName, detectingLocation: $detectingLocation, locationFailed: $locationFailed, interests: $interests)';
}


}

/// @nodoc
abstract mixin class $RegistrationStateCopyWith<$Res>  {
  factory $RegistrationStateCopyWith(RegistrationState value, $Res Function(RegistrationState) _then) = _$RegistrationStateCopyWithImpl;
@useResult
$Res call({
 String email, String password, String confirmPassword, String firstName, String lastName, DateTime? dob, String phoneInput, String? stateName, bool detectingLocation, bool locationFailed, CarInterests interests
});


$CarInterestsCopyWith<$Res> get interests;

}
/// @nodoc
class _$RegistrationStateCopyWithImpl<$Res>
    implements $RegistrationStateCopyWith<$Res> {
  _$RegistrationStateCopyWithImpl(this._self, this._then);

  final RegistrationState _self;
  final $Res Function(RegistrationState) _then;

/// Create a copy of RegistrationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? confirmPassword = null,Object? firstName = null,Object? lastName = null,Object? dob = freezed,Object? phoneInput = null,Object? stateName = freezed,Object? detectingLocation = null,Object? locationFailed = null,Object? interests = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,phoneInput: null == phoneInput ? _self.phoneInput : phoneInput // ignore: cast_nullable_to_non_nullable
as String,stateName: freezed == stateName ? _self.stateName : stateName // ignore: cast_nullable_to_non_nullable
as String?,detectingLocation: null == detectingLocation ? _self.detectingLocation : detectingLocation // ignore: cast_nullable_to_non_nullable
as bool,locationFailed: null == locationFailed ? _self.locationFailed : locationFailed // ignore: cast_nullable_to_non_nullable
as bool,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as CarInterests,
  ));
}
/// Create a copy of RegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarInterestsCopyWith<$Res> get interests {
  
  return $CarInterestsCopyWith<$Res>(_self.interests, (value) {
    return _then(_self.copyWith(interests: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegistrationState].
extension RegistrationStatePatterns on RegistrationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrationState value)  $default,){
final _that = this;
switch (_that) {
case _RegistrationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrationState value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String confirmPassword,  String firstName,  String lastName,  DateTime? dob,  String phoneInput,  String? stateName,  bool detectingLocation,  bool locationFailed,  CarInterests interests)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrationState() when $default != null:
return $default(_that.email,_that.password,_that.confirmPassword,_that.firstName,_that.lastName,_that.dob,_that.phoneInput,_that.stateName,_that.detectingLocation,_that.locationFailed,_that.interests);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String confirmPassword,  String firstName,  String lastName,  DateTime? dob,  String phoneInput,  String? stateName,  bool detectingLocation,  bool locationFailed,  CarInterests interests)  $default,) {final _that = this;
switch (_that) {
case _RegistrationState():
return $default(_that.email,_that.password,_that.confirmPassword,_that.firstName,_that.lastName,_that.dob,_that.phoneInput,_that.stateName,_that.detectingLocation,_that.locationFailed,_that.interests);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String confirmPassword,  String firstName,  String lastName,  DateTime? dob,  String phoneInput,  String? stateName,  bool detectingLocation,  bool locationFailed,  CarInterests interests)?  $default,) {final _that = this;
switch (_that) {
case _RegistrationState() when $default != null:
return $default(_that.email,_that.password,_that.confirmPassword,_that.firstName,_that.lastName,_that.dob,_that.phoneInput,_that.stateName,_that.detectingLocation,_that.locationFailed,_that.interests);case _:
  return null;

}
}

}

/// @nodoc


class _RegistrationState implements RegistrationState {
  const _RegistrationState({this.email = '', this.password = '', this.confirmPassword = '', this.firstName = '', this.lastName = '', this.dob, this.phoneInput = '', this.stateName, this.detectingLocation = false, this.locationFailed = false, this.interests = const CarInterests()});
  

@override@JsonKey() final  String email;
@override@JsonKey() final  String password;
@override@JsonKey() final  String confirmPassword;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override final  DateTime? dob;
@override@JsonKey() final  String phoneInput;
@override final  String? stateName;
@override@JsonKey() final  bool detectingLocation;
@override@JsonKey() final  bool locationFailed;
@override@JsonKey() final  CarInterests interests;

/// Create a copy of RegistrationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationStateCopyWith<_RegistrationState> get copyWith => __$RegistrationStateCopyWithImpl<_RegistrationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.phoneInput, phoneInput) || other.phoneInput == phoneInput)&&(identical(other.stateName, stateName) || other.stateName == stateName)&&(identical(other.detectingLocation, detectingLocation) || other.detectingLocation == detectingLocation)&&(identical(other.locationFailed, locationFailed) || other.locationFailed == locationFailed)&&(identical(other.interests, interests) || other.interests == interests));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,confirmPassword,firstName,lastName,dob,phoneInput,stateName,detectingLocation,locationFailed,interests);

@override
String toString() {
  return 'RegistrationState(email: $email, password: $password, confirmPassword: $confirmPassword, firstName: $firstName, lastName: $lastName, dob: $dob, phoneInput: $phoneInput, stateName: $stateName, detectingLocation: $detectingLocation, locationFailed: $locationFailed, interests: $interests)';
}


}

/// @nodoc
abstract mixin class _$RegistrationStateCopyWith<$Res> implements $RegistrationStateCopyWith<$Res> {
  factory _$RegistrationStateCopyWith(_RegistrationState value, $Res Function(_RegistrationState) _then) = __$RegistrationStateCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String confirmPassword, String firstName, String lastName, DateTime? dob, String phoneInput, String? stateName, bool detectingLocation, bool locationFailed, CarInterests interests
});


@override $CarInterestsCopyWith<$Res> get interests;

}
/// @nodoc
class __$RegistrationStateCopyWithImpl<$Res>
    implements _$RegistrationStateCopyWith<$Res> {
  __$RegistrationStateCopyWithImpl(this._self, this._then);

  final _RegistrationState _self;
  final $Res Function(_RegistrationState) _then;

/// Create a copy of RegistrationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? confirmPassword = null,Object? firstName = null,Object? lastName = null,Object? dob = freezed,Object? phoneInput = null,Object? stateName = freezed,Object? detectingLocation = null,Object? locationFailed = null,Object? interests = null,}) {
  return _then(_RegistrationState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,phoneInput: null == phoneInput ? _self.phoneInput : phoneInput // ignore: cast_nullable_to_non_nullable
as String,stateName: freezed == stateName ? _self.stateName : stateName // ignore: cast_nullable_to_non_nullable
as String?,detectingLocation: null == detectingLocation ? _self.detectingLocation : detectingLocation // ignore: cast_nullable_to_non_nullable
as bool,locationFailed: null == locationFailed ? _self.locationFailed : locationFailed // ignore: cast_nullable_to_non_nullable
as bool,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as CarInterests,
  ));
}

/// Create a copy of RegistrationState
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
