// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_interests.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarInterests {

 List<String> get makes; List<BodyType> get bodyTypes; Transmission? get transmission; FuelType? get fuelType; int? get budgetMinMyr; int? get budgetMaxMyr;
/// Create a copy of CarInterests
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarInterestsCopyWith<CarInterests> get copyWith => _$CarInterestsCopyWithImpl<CarInterests>(this as CarInterests, _$identity);

  /// Serializes this CarInterests to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarInterests&&const DeepCollectionEquality().equals(other.makes, makes)&&const DeepCollectionEquality().equals(other.bodyTypes, bodyTypes)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.budgetMinMyr, budgetMinMyr) || other.budgetMinMyr == budgetMinMyr)&&(identical(other.budgetMaxMyr, budgetMaxMyr) || other.budgetMaxMyr == budgetMaxMyr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(makes),const DeepCollectionEquality().hash(bodyTypes),transmission,fuelType,budgetMinMyr,budgetMaxMyr);

@override
String toString() {
  return 'CarInterests(makes: $makes, bodyTypes: $bodyTypes, transmission: $transmission, fuelType: $fuelType, budgetMinMyr: $budgetMinMyr, budgetMaxMyr: $budgetMaxMyr)';
}


}

/// @nodoc
abstract mixin class $CarInterestsCopyWith<$Res>  {
  factory $CarInterestsCopyWith(CarInterests value, $Res Function(CarInterests) _then) = _$CarInterestsCopyWithImpl;
@useResult
$Res call({
 List<String> makes, List<BodyType> bodyTypes, Transmission? transmission, FuelType? fuelType, int? budgetMinMyr, int? budgetMaxMyr
});




}
/// @nodoc
class _$CarInterestsCopyWithImpl<$Res>
    implements $CarInterestsCopyWith<$Res> {
  _$CarInterestsCopyWithImpl(this._self, this._then);

  final CarInterests _self;
  final $Res Function(CarInterests) _then;

/// Create a copy of CarInterests
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? makes = null,Object? bodyTypes = null,Object? transmission = freezed,Object? fuelType = freezed,Object? budgetMinMyr = freezed,Object? budgetMaxMyr = freezed,}) {
  return _then(_self.copyWith(
makes: null == makes ? _self.makes : makes // ignore: cast_nullable_to_non_nullable
as List<String>,bodyTypes: null == bodyTypes ? _self.bodyTypes : bodyTypes // ignore: cast_nullable_to_non_nullable
as List<BodyType>,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as Transmission?,fuelType: freezed == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType?,budgetMinMyr: freezed == budgetMinMyr ? _self.budgetMinMyr : budgetMinMyr // ignore: cast_nullable_to_non_nullable
as int?,budgetMaxMyr: freezed == budgetMaxMyr ? _self.budgetMaxMyr : budgetMaxMyr // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CarInterests].
extension CarInterestsPatterns on CarInterests {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarInterests value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarInterests() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarInterests value)  $default,){
final _that = this;
switch (_that) {
case _CarInterests():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarInterests value)?  $default,){
final _that = this;
switch (_that) {
case _CarInterests() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> makes,  List<BodyType> bodyTypes,  Transmission? transmission,  FuelType? fuelType,  int? budgetMinMyr,  int? budgetMaxMyr)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarInterests() when $default != null:
return $default(_that.makes,_that.bodyTypes,_that.transmission,_that.fuelType,_that.budgetMinMyr,_that.budgetMaxMyr);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> makes,  List<BodyType> bodyTypes,  Transmission? transmission,  FuelType? fuelType,  int? budgetMinMyr,  int? budgetMaxMyr)  $default,) {final _that = this;
switch (_that) {
case _CarInterests():
return $default(_that.makes,_that.bodyTypes,_that.transmission,_that.fuelType,_that.budgetMinMyr,_that.budgetMaxMyr);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> makes,  List<BodyType> bodyTypes,  Transmission? transmission,  FuelType? fuelType,  int? budgetMinMyr,  int? budgetMaxMyr)?  $default,) {final _that = this;
switch (_that) {
case _CarInterests() when $default != null:
return $default(_that.makes,_that.bodyTypes,_that.transmission,_that.fuelType,_that.budgetMinMyr,_that.budgetMaxMyr);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarInterests extends CarInterests {
  const _CarInterests({final  List<String> makes = const <String>[], final  List<BodyType> bodyTypes = const <BodyType>[], this.transmission, this.fuelType, this.budgetMinMyr, this.budgetMaxMyr}): _makes = makes,_bodyTypes = bodyTypes,super._();
  factory _CarInterests.fromJson(Map<String, dynamic> json) => _$CarInterestsFromJson(json);

 final  List<String> _makes;
@override@JsonKey() List<String> get makes {
  if (_makes is EqualUnmodifiableListView) return _makes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_makes);
}

 final  List<BodyType> _bodyTypes;
@override@JsonKey() List<BodyType> get bodyTypes {
  if (_bodyTypes is EqualUnmodifiableListView) return _bodyTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bodyTypes);
}

@override final  Transmission? transmission;
@override final  FuelType? fuelType;
@override final  int? budgetMinMyr;
@override final  int? budgetMaxMyr;

/// Create a copy of CarInterests
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarInterestsCopyWith<_CarInterests> get copyWith => __$CarInterestsCopyWithImpl<_CarInterests>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarInterestsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarInterests&&const DeepCollectionEquality().equals(other._makes, _makes)&&const DeepCollectionEquality().equals(other._bodyTypes, _bodyTypes)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.budgetMinMyr, budgetMinMyr) || other.budgetMinMyr == budgetMinMyr)&&(identical(other.budgetMaxMyr, budgetMaxMyr) || other.budgetMaxMyr == budgetMaxMyr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_makes),const DeepCollectionEquality().hash(_bodyTypes),transmission,fuelType,budgetMinMyr,budgetMaxMyr);

@override
String toString() {
  return 'CarInterests(makes: $makes, bodyTypes: $bodyTypes, transmission: $transmission, fuelType: $fuelType, budgetMinMyr: $budgetMinMyr, budgetMaxMyr: $budgetMaxMyr)';
}


}

/// @nodoc
abstract mixin class _$CarInterestsCopyWith<$Res> implements $CarInterestsCopyWith<$Res> {
  factory _$CarInterestsCopyWith(_CarInterests value, $Res Function(_CarInterests) _then) = __$CarInterestsCopyWithImpl;
@override @useResult
$Res call({
 List<String> makes, List<BodyType> bodyTypes, Transmission? transmission, FuelType? fuelType, int? budgetMinMyr, int? budgetMaxMyr
});




}
/// @nodoc
class __$CarInterestsCopyWithImpl<$Res>
    implements _$CarInterestsCopyWith<$Res> {
  __$CarInterestsCopyWithImpl(this._self, this._then);

  final _CarInterests _self;
  final $Res Function(_CarInterests) _then;

/// Create a copy of CarInterests
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? makes = null,Object? bodyTypes = null,Object? transmission = freezed,Object? fuelType = freezed,Object? budgetMinMyr = freezed,Object? budgetMaxMyr = freezed,}) {
  return _then(_CarInterests(
makes: null == makes ? _self._makes : makes // ignore: cast_nullable_to_non_nullable
as List<String>,bodyTypes: null == bodyTypes ? _self._bodyTypes : bodyTypes // ignore: cast_nullable_to_non_nullable
as List<BodyType>,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as Transmission?,fuelType: freezed == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType?,budgetMinMyr: freezed == budgetMinMyr ? _self.budgetMinMyr : budgetMinMyr // ignore: cast_nullable_to_non_nullable
as int?,budgetMaxMyr: freezed == budgetMaxMyr ? _self.budgetMaxMyr : budgetMaxMyr // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
