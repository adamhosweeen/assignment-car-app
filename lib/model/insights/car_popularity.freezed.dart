// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_popularity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RankedCount {

 String get name; int get count;
/// Create a copy of RankedCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankedCountCopyWith<RankedCount> get copyWith => _$RankedCountCopyWithImpl<RankedCount>(this as RankedCount, _$identity);

  /// Serializes this RankedCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankedCount&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,count);

@override
String toString() {
  return 'RankedCount(name: $name, count: $count)';
}


}

/// @nodoc
abstract mixin class $RankedCountCopyWith<$Res>  {
  factory $RankedCountCopyWith(RankedCount value, $Res Function(RankedCount) _then) = _$RankedCountCopyWithImpl;
@useResult
$Res call({
 String name, int count
});




}
/// @nodoc
class _$RankedCountCopyWithImpl<$Res>
    implements $RankedCountCopyWith<$Res> {
  _$RankedCountCopyWithImpl(this._self, this._then);

  final RankedCount _self;
  final $Res Function(RankedCount) _then;

/// Create a copy of RankedCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? count = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RankedCount].
extension RankedCountPatterns on RankedCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankedCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankedCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankedCount value)  $default,){
final _that = this;
switch (_that) {
case _RankedCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankedCount value)?  $default,){
final _that = this;
switch (_that) {
case _RankedCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankedCount() when $default != null:
return $default(_that.name,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int count)  $default,) {final _that = this;
switch (_that) {
case _RankedCount():
return $default(_that.name,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int count)?  $default,) {final _that = this;
switch (_that) {
case _RankedCount() when $default != null:
return $default(_that.name,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankedCount implements RankedCount {
  const _RankedCount({required this.name, required this.count});
  factory _RankedCount.fromJson(Map<String, dynamic> json) => _$RankedCountFromJson(json);

@override final  String name;
@override final  int count;

/// Create a copy of RankedCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankedCountCopyWith<_RankedCount> get copyWith => __$RankedCountCopyWithImpl<_RankedCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankedCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankedCount&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,count);

@override
String toString() {
  return 'RankedCount(name: $name, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RankedCountCopyWith<$Res> implements $RankedCountCopyWith<$Res> {
  factory _$RankedCountCopyWith(_RankedCount value, $Res Function(_RankedCount) _then) = __$RankedCountCopyWithImpl;
@override @useResult
$Res call({
 String name, int count
});




}
/// @nodoc
class __$RankedCountCopyWithImpl<$Res>
    implements _$RankedCountCopyWith<$Res> {
  __$RankedCountCopyWithImpl(this._self, this._then);

  final _RankedCount _self;
  final $Res Function(_RankedCount) _then;

/// Create a copy of RankedCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? count = null,}) {
  return _then(_RankedCount(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RankedModel {

 String get name; String get maker; int get count;
/// Create a copy of RankedModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankedModelCopyWith<RankedModel> get copyWith => _$RankedModelCopyWithImpl<RankedModel>(this as RankedModel, _$identity);

  /// Serializes this RankedModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankedModel&&(identical(other.name, name) || other.name == name)&&(identical(other.maker, maker) || other.maker == maker)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,maker,count);

@override
String toString() {
  return 'RankedModel(name: $name, maker: $maker, count: $count)';
}


}

/// @nodoc
abstract mixin class $RankedModelCopyWith<$Res>  {
  factory $RankedModelCopyWith(RankedModel value, $Res Function(RankedModel) _then) = _$RankedModelCopyWithImpl;
@useResult
$Res call({
 String name, String maker, int count
});




}
/// @nodoc
class _$RankedModelCopyWithImpl<$Res>
    implements $RankedModelCopyWith<$Res> {
  _$RankedModelCopyWithImpl(this._self, this._then);

  final RankedModel _self;
  final $Res Function(RankedModel) _then;

/// Create a copy of RankedModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? maker = null,Object? count = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maker: null == maker ? _self.maker : maker // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RankedModel].
extension RankedModelPatterns on RankedModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankedModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankedModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankedModel value)  $default,){
final _that = this;
switch (_that) {
case _RankedModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankedModel value)?  $default,){
final _that = this;
switch (_that) {
case _RankedModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String maker,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankedModel() when $default != null:
return $default(_that.name,_that.maker,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String maker,  int count)  $default,) {final _that = this;
switch (_that) {
case _RankedModel():
return $default(_that.name,_that.maker,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String maker,  int count)?  $default,) {final _that = this;
switch (_that) {
case _RankedModel() when $default != null:
return $default(_that.name,_that.maker,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankedModel implements RankedModel {
  const _RankedModel({required this.name, required this.maker, required this.count});
  factory _RankedModel.fromJson(Map<String, dynamic> json) => _$RankedModelFromJson(json);

@override final  String name;
@override final  String maker;
@override final  int count;

/// Create a copy of RankedModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankedModelCopyWith<_RankedModel> get copyWith => __$RankedModelCopyWithImpl<_RankedModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankedModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankedModel&&(identical(other.name, name) || other.name == name)&&(identical(other.maker, maker) || other.maker == maker)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,maker,count);

@override
String toString() {
  return 'RankedModel(name: $name, maker: $maker, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RankedModelCopyWith<$Res> implements $RankedModelCopyWith<$Res> {
  factory _$RankedModelCopyWith(_RankedModel value, $Res Function(_RankedModel) _then) = __$RankedModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String maker, int count
});




}
/// @nodoc
class __$RankedModelCopyWithImpl<$Res>
    implements _$RankedModelCopyWith<$Res> {
  __$RankedModelCopyWithImpl(this._self, this._then);

  final _RankedModel _self;
  final $Res Function(_RankedModel) _then;

/// Create a copy of RankedModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? maker = null,Object? count = null,}) {
  return _then(_RankedModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maker: null == maker ? _self.maker : maker // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MonthCount {

 String get month; int get count;
/// Create a copy of MonthCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthCountCopyWith<MonthCount> get copyWith => _$MonthCountCopyWithImpl<MonthCount>(this as MonthCount, _$identity);

  /// Serializes this MonthCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCount&&(identical(other.month, month) || other.month == month)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,count);

@override
String toString() {
  return 'MonthCount(month: $month, count: $count)';
}


}

/// @nodoc
abstract mixin class $MonthCountCopyWith<$Res>  {
  factory $MonthCountCopyWith(MonthCount value, $Res Function(MonthCount) _then) = _$MonthCountCopyWithImpl;
@useResult
$Res call({
 String month, int count
});




}
/// @nodoc
class _$MonthCountCopyWithImpl<$Res>
    implements $MonthCountCopyWith<$Res> {
  _$MonthCountCopyWithImpl(this._self, this._then);

  final MonthCount _self;
  final $Res Function(MonthCount) _then;

/// Create a copy of MonthCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? count = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthCount].
extension MonthCountPatterns on MonthCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthCount value)  $default,){
final _that = this;
switch (_that) {
case _MonthCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthCount value)?  $default,){
final _that = this;
switch (_that) {
case _MonthCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthCount() when $default != null:
return $default(_that.month,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  int count)  $default,) {final _that = this;
switch (_that) {
case _MonthCount():
return $default(_that.month,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  int count)?  $default,) {final _that = this;
switch (_that) {
case _MonthCount() when $default != null:
return $default(_that.month,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthCount implements MonthCount {
  const _MonthCount({required this.month, required this.count});
  factory _MonthCount.fromJson(Map<String, dynamic> json) => _$MonthCountFromJson(json);

@override final  String month;
@override final  int count;

/// Create a copy of MonthCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthCountCopyWith<_MonthCount> get copyWith => __$MonthCountCopyWithImpl<_MonthCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthCount&&(identical(other.month, month) || other.month == month)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,count);

@override
String toString() {
  return 'MonthCount(month: $month, count: $count)';
}


}

/// @nodoc
abstract mixin class _$MonthCountCopyWith<$Res> implements $MonthCountCopyWith<$Res> {
  factory _$MonthCountCopyWith(_MonthCount value, $Res Function(_MonthCount) _then) = __$MonthCountCopyWithImpl;
@override @useResult
$Res call({
 String month, int count
});




}
/// @nodoc
class __$MonthCountCopyWithImpl<$Res>
    implements _$MonthCountCopyWith<$Res> {
  __$MonthCountCopyWithImpl(this._self, this._then);

  final _MonthCount _self;
  final $Res Function(_MonthCount) _then;

/// Create a copy of MonthCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? count = null,}) {
  return _then(_MonthCount(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CarPopularity {

/// Human-readable window, e.g. "Aug 2025 – Jul 2026".
 String get periodLabel; DateTime get periodStart; DateTime get periodEnd; DateTime get generatedAt; String get sourceUrl; int get totalRegistrations; List<RankedCount> get topMakers; List<RankedModel> get topModels;/// Top makers per Malaysian state (dealer-portal registrations carry no
/// state and are excluded here, though they count nationally).
 Map<String, List<RankedCount>> get byState; List<RankedCount> get fuelSplit; List<RankedCount> get typeSplit; List<MonthCount> get monthly;
/// Create a copy of CarPopularity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarPopularityCopyWith<CarPopularity> get copyWith => _$CarPopularityCopyWithImpl<CarPopularity>(this as CarPopularity, _$identity);

  /// Serializes this CarPopularity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarPopularity&&(identical(other.periodLabel, periodLabel) || other.periodLabel == periodLabel)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.totalRegistrations, totalRegistrations) || other.totalRegistrations == totalRegistrations)&&const DeepCollectionEquality().equals(other.topMakers, topMakers)&&const DeepCollectionEquality().equals(other.topModels, topModels)&&const DeepCollectionEquality().equals(other.byState, byState)&&const DeepCollectionEquality().equals(other.fuelSplit, fuelSplit)&&const DeepCollectionEquality().equals(other.typeSplit, typeSplit)&&const DeepCollectionEquality().equals(other.monthly, monthly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodLabel,periodStart,periodEnd,generatedAt,sourceUrl,totalRegistrations,const DeepCollectionEquality().hash(topMakers),const DeepCollectionEquality().hash(topModels),const DeepCollectionEquality().hash(byState),const DeepCollectionEquality().hash(fuelSplit),const DeepCollectionEquality().hash(typeSplit),const DeepCollectionEquality().hash(monthly));

@override
String toString() {
  return 'CarPopularity(periodLabel: $periodLabel, periodStart: $periodStart, periodEnd: $periodEnd, generatedAt: $generatedAt, sourceUrl: $sourceUrl, totalRegistrations: $totalRegistrations, topMakers: $topMakers, topModels: $topModels, byState: $byState, fuelSplit: $fuelSplit, typeSplit: $typeSplit, monthly: $monthly)';
}


}

/// @nodoc
abstract mixin class $CarPopularityCopyWith<$Res>  {
  factory $CarPopularityCopyWith(CarPopularity value, $Res Function(CarPopularity) _then) = _$CarPopularityCopyWithImpl;
@useResult
$Res call({
 String periodLabel, DateTime periodStart, DateTime periodEnd, DateTime generatedAt, String sourceUrl, int totalRegistrations, List<RankedCount> topMakers, List<RankedModel> topModels, Map<String, List<RankedCount>> byState, List<RankedCount> fuelSplit, List<RankedCount> typeSplit, List<MonthCount> monthly
});




}
/// @nodoc
class _$CarPopularityCopyWithImpl<$Res>
    implements $CarPopularityCopyWith<$Res> {
  _$CarPopularityCopyWithImpl(this._self, this._then);

  final CarPopularity _self;
  final $Res Function(CarPopularity) _then;

/// Create a copy of CarPopularity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodLabel = null,Object? periodStart = null,Object? periodEnd = null,Object? generatedAt = null,Object? sourceUrl = null,Object? totalRegistrations = null,Object? topMakers = null,Object? topModels = null,Object? byState = null,Object? fuelSplit = null,Object? typeSplit = null,Object? monthly = null,}) {
  return _then(_self.copyWith(
periodLabel: null == periodLabel ? _self.periodLabel : periodLabel // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,totalRegistrations: null == totalRegistrations ? _self.totalRegistrations : totalRegistrations // ignore: cast_nullable_to_non_nullable
as int,topMakers: null == topMakers ? _self.topMakers : topMakers // ignore: cast_nullable_to_non_nullable
as List<RankedCount>,topModels: null == topModels ? _self.topModels : topModels // ignore: cast_nullable_to_non_nullable
as List<RankedModel>,byState: null == byState ? _self.byState : byState // ignore: cast_nullable_to_non_nullable
as Map<String, List<RankedCount>>,fuelSplit: null == fuelSplit ? _self.fuelSplit : fuelSplit // ignore: cast_nullable_to_non_nullable
as List<RankedCount>,typeSplit: null == typeSplit ? _self.typeSplit : typeSplit // ignore: cast_nullable_to_non_nullable
as List<RankedCount>,monthly: null == monthly ? _self.monthly : monthly // ignore: cast_nullable_to_non_nullable
as List<MonthCount>,
  ));
}

}


/// Adds pattern-matching-related methods to [CarPopularity].
extension CarPopularityPatterns on CarPopularity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarPopularity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarPopularity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarPopularity value)  $default,){
final _that = this;
switch (_that) {
case _CarPopularity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarPopularity value)?  $default,){
final _that = this;
switch (_that) {
case _CarPopularity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String periodLabel,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  String sourceUrl,  int totalRegistrations,  List<RankedCount> topMakers,  List<RankedModel> topModels,  Map<String, List<RankedCount>> byState,  List<RankedCount> fuelSplit,  List<RankedCount> typeSplit,  List<MonthCount> monthly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarPopularity() when $default != null:
return $default(_that.periodLabel,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.sourceUrl,_that.totalRegistrations,_that.topMakers,_that.topModels,_that.byState,_that.fuelSplit,_that.typeSplit,_that.monthly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String periodLabel,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  String sourceUrl,  int totalRegistrations,  List<RankedCount> topMakers,  List<RankedModel> topModels,  Map<String, List<RankedCount>> byState,  List<RankedCount> fuelSplit,  List<RankedCount> typeSplit,  List<MonthCount> monthly)  $default,) {final _that = this;
switch (_that) {
case _CarPopularity():
return $default(_that.periodLabel,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.sourceUrl,_that.totalRegistrations,_that.topMakers,_that.topModels,_that.byState,_that.fuelSplit,_that.typeSplit,_that.monthly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String periodLabel,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  String sourceUrl,  int totalRegistrations,  List<RankedCount> topMakers,  List<RankedModel> topModels,  Map<String, List<RankedCount>> byState,  List<RankedCount> fuelSplit,  List<RankedCount> typeSplit,  List<MonthCount> monthly)?  $default,) {final _that = this;
switch (_that) {
case _CarPopularity() when $default != null:
return $default(_that.periodLabel,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.sourceUrl,_that.totalRegistrations,_that.topMakers,_that.topModels,_that.byState,_that.fuelSplit,_that.typeSplit,_that.monthly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarPopularity extends CarPopularity {
  const _CarPopularity({required this.periodLabel, required this.periodStart, required this.periodEnd, required this.generatedAt, required this.sourceUrl, required this.totalRegistrations, final  List<RankedCount> topMakers = const <RankedCount>[], final  List<RankedModel> topModels = const <RankedModel>[], final  Map<String, List<RankedCount>> byState = const <String, List<RankedCount>>{}, final  List<RankedCount> fuelSplit = const <RankedCount>[], final  List<RankedCount> typeSplit = const <RankedCount>[], final  List<MonthCount> monthly = const <MonthCount>[]}): _topMakers = topMakers,_topModels = topModels,_byState = byState,_fuelSplit = fuelSplit,_typeSplit = typeSplit,_monthly = monthly,super._();
  factory _CarPopularity.fromJson(Map<String, dynamic> json) => _$CarPopularityFromJson(json);

/// Human-readable window, e.g. "Aug 2025 – Jul 2026".
@override final  String periodLabel;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  DateTime generatedAt;
@override final  String sourceUrl;
@override final  int totalRegistrations;
 final  List<RankedCount> _topMakers;
@override@JsonKey() List<RankedCount> get topMakers {
  if (_topMakers is EqualUnmodifiableListView) return _topMakers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topMakers);
}

 final  List<RankedModel> _topModels;
@override@JsonKey() List<RankedModel> get topModels {
  if (_topModels is EqualUnmodifiableListView) return _topModels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topModels);
}

/// Top makers per Malaysian state (dealer-portal registrations carry no
/// state and are excluded here, though they count nationally).
 final  Map<String, List<RankedCount>> _byState;
/// Top makers per Malaysian state (dealer-portal registrations carry no
/// state and are excluded here, though they count nationally).
@override@JsonKey() Map<String, List<RankedCount>> get byState {
  if (_byState is EqualUnmodifiableMapView) return _byState;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byState);
}

 final  List<RankedCount> _fuelSplit;
@override@JsonKey() List<RankedCount> get fuelSplit {
  if (_fuelSplit is EqualUnmodifiableListView) return _fuelSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fuelSplit);
}

 final  List<RankedCount> _typeSplit;
@override@JsonKey() List<RankedCount> get typeSplit {
  if (_typeSplit is EqualUnmodifiableListView) return _typeSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_typeSplit);
}

 final  List<MonthCount> _monthly;
@override@JsonKey() List<MonthCount> get monthly {
  if (_monthly is EqualUnmodifiableListView) return _monthly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthly);
}


/// Create a copy of CarPopularity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarPopularityCopyWith<_CarPopularity> get copyWith => __$CarPopularityCopyWithImpl<_CarPopularity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarPopularityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarPopularity&&(identical(other.periodLabel, periodLabel) || other.periodLabel == periodLabel)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.totalRegistrations, totalRegistrations) || other.totalRegistrations == totalRegistrations)&&const DeepCollectionEquality().equals(other._topMakers, _topMakers)&&const DeepCollectionEquality().equals(other._topModels, _topModels)&&const DeepCollectionEquality().equals(other._byState, _byState)&&const DeepCollectionEquality().equals(other._fuelSplit, _fuelSplit)&&const DeepCollectionEquality().equals(other._typeSplit, _typeSplit)&&const DeepCollectionEquality().equals(other._monthly, _monthly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodLabel,periodStart,periodEnd,generatedAt,sourceUrl,totalRegistrations,const DeepCollectionEquality().hash(_topMakers),const DeepCollectionEquality().hash(_topModels),const DeepCollectionEquality().hash(_byState),const DeepCollectionEquality().hash(_fuelSplit),const DeepCollectionEquality().hash(_typeSplit),const DeepCollectionEquality().hash(_monthly));

@override
String toString() {
  return 'CarPopularity(periodLabel: $periodLabel, periodStart: $periodStart, periodEnd: $periodEnd, generatedAt: $generatedAt, sourceUrl: $sourceUrl, totalRegistrations: $totalRegistrations, topMakers: $topMakers, topModels: $topModels, byState: $byState, fuelSplit: $fuelSplit, typeSplit: $typeSplit, monthly: $monthly)';
}


}

/// @nodoc
abstract mixin class _$CarPopularityCopyWith<$Res> implements $CarPopularityCopyWith<$Res> {
  factory _$CarPopularityCopyWith(_CarPopularity value, $Res Function(_CarPopularity) _then) = __$CarPopularityCopyWithImpl;
@override @useResult
$Res call({
 String periodLabel, DateTime periodStart, DateTime periodEnd, DateTime generatedAt, String sourceUrl, int totalRegistrations, List<RankedCount> topMakers, List<RankedModel> topModels, Map<String, List<RankedCount>> byState, List<RankedCount> fuelSplit, List<RankedCount> typeSplit, List<MonthCount> monthly
});




}
/// @nodoc
class __$CarPopularityCopyWithImpl<$Res>
    implements _$CarPopularityCopyWith<$Res> {
  __$CarPopularityCopyWithImpl(this._self, this._then);

  final _CarPopularity _self;
  final $Res Function(_CarPopularity) _then;

/// Create a copy of CarPopularity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodLabel = null,Object? periodStart = null,Object? periodEnd = null,Object? generatedAt = null,Object? sourceUrl = null,Object? totalRegistrations = null,Object? topMakers = null,Object? topModels = null,Object? byState = null,Object? fuelSplit = null,Object? typeSplit = null,Object? monthly = null,}) {
  return _then(_CarPopularity(
periodLabel: null == periodLabel ? _self.periodLabel : periodLabel // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,totalRegistrations: null == totalRegistrations ? _self.totalRegistrations : totalRegistrations // ignore: cast_nullable_to_non_nullable
as int,topMakers: null == topMakers ? _self._topMakers : topMakers // ignore: cast_nullable_to_non_nullable
as List<RankedCount>,topModels: null == topModels ? _self._topModels : topModels // ignore: cast_nullable_to_non_nullable
as List<RankedModel>,byState: null == byState ? _self._byState : byState // ignore: cast_nullable_to_non_nullable
as Map<String, List<RankedCount>>,fuelSplit: null == fuelSplit ? _self._fuelSplit : fuelSplit // ignore: cast_nullable_to_non_nullable
as List<RankedCount>,typeSplit: null == typeSplit ? _self._typeSplit : typeSplit // ignore: cast_nullable_to_non_nullable
as List<RankedCount>,monthly: null == monthly ? _self._monthly : monthly // ignore: cast_nullable_to_non_nullable
as List<MonthCount>,
  ));
}


}

// dart format on
