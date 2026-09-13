// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUserStats {

 String get id; String? get displayName; String? get avatarUrl; String? get email; String? get phone; DateTime? get dob; String? get state; String get role; bool get banned; DateTime get createdAt; int get activeCount; int get soldCount;
/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserStatsCopyWith<AdminUserStats> get copyWith => _$AdminUserStatsCopyWithImpl<AdminUserStats>(this as AdminUserStats, _$identity);

  /// Serializes this AdminUserStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserStats&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.state, state) || other.state == state)&&(identical(other.role, role) || other.role == role)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount)&&(identical(other.soldCount, soldCount) || other.soldCount == soldCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,avatarUrl,email,phone,dob,state,role,banned,createdAt,activeCount,soldCount);

@override
String toString() {
  return 'AdminUserStats(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, email: $email, phone: $phone, dob: $dob, state: $state, role: $role, banned: $banned, createdAt: $createdAt, activeCount: $activeCount, soldCount: $soldCount)';
}


}

/// @nodoc
abstract mixin class $AdminUserStatsCopyWith<$Res>  {
  factory $AdminUserStatsCopyWith(AdminUserStats value, $Res Function(AdminUserStats) _then) = _$AdminUserStatsCopyWithImpl;
@useResult
$Res call({
 String id, String? displayName, String? avatarUrl, String? email, String? phone, DateTime? dob, String? state, String role, bool banned, DateTime createdAt, int activeCount, int soldCount
});




}
/// @nodoc
class _$AdminUserStatsCopyWithImpl<$Res>
    implements $AdminUserStatsCopyWith<$Res> {
  _$AdminUserStatsCopyWithImpl(this._self, this._then);

  final AdminUserStats _self;
  final $Res Function(AdminUserStats) _then;

/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? dob = freezed,Object? state = freezed,Object? role = null,Object? banned = null,Object? createdAt = null,Object? activeCount = null,Object? soldCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,soldCount: null == soldCount ? _self.soldCount : soldCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUserStats].
extension AdminUserStatsPatterns on AdminUserStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserStats value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserStats value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? avatarUrl,  String? email,  String? phone,  DateTime? dob,  String? state,  String role,  bool banned,  DateTime createdAt,  int activeCount,  int soldCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.email,_that.phone,_that.dob,_that.state,_that.role,_that.banned,_that.createdAt,_that.activeCount,_that.soldCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? avatarUrl,  String? email,  String? phone,  DateTime? dob,  String? state,  String role,  bool banned,  DateTime createdAt,  int activeCount,  int soldCount)  $default,) {final _that = this;
switch (_that) {
case _AdminUserStats():
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.email,_that.phone,_that.dob,_that.state,_that.role,_that.banned,_that.createdAt,_that.activeCount,_that.soldCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? displayName,  String? avatarUrl,  String? email,  String? phone,  DateTime? dob,  String? state,  String role,  bool banned,  DateTime createdAt,  int activeCount,  int soldCount)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.email,_that.phone,_that.dob,_that.state,_that.role,_that.banned,_that.createdAt,_that.activeCount,_that.soldCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserStats extends AdminUserStats {
  const _AdminUserStats({required this.id, this.displayName, this.avatarUrl, this.email, this.phone, this.dob, this.state, this.role = 'user', this.banned = false, required this.createdAt, required this.activeCount, required this.soldCount}): super._();
  factory _AdminUserStats.fromJson(Map<String, dynamic> json) => _$AdminUserStatsFromJson(json);

@override final  String id;
@override final  String? displayName;
@override final  String? avatarUrl;
@override final  String? email;
@override final  String? phone;
@override final  DateTime? dob;
@override final  String? state;
@override@JsonKey() final  String role;
@override@JsonKey() final  bool banned;
@override final  DateTime createdAt;
@override final  int activeCount;
@override final  int soldCount;

/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserStatsCopyWith<_AdminUserStats> get copyWith => __$AdminUserStatsCopyWithImpl<_AdminUserStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserStats&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.state, state) || other.state == state)&&(identical(other.role, role) || other.role == role)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount)&&(identical(other.soldCount, soldCount) || other.soldCount == soldCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,avatarUrl,email,phone,dob,state,role,banned,createdAt,activeCount,soldCount);

@override
String toString() {
  return 'AdminUserStats(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, email: $email, phone: $phone, dob: $dob, state: $state, role: $role, banned: $banned, createdAt: $createdAt, activeCount: $activeCount, soldCount: $soldCount)';
}


}

/// @nodoc
abstract mixin class _$AdminUserStatsCopyWith<$Res> implements $AdminUserStatsCopyWith<$Res> {
  factory _$AdminUserStatsCopyWith(_AdminUserStats value, $Res Function(_AdminUserStats) _then) = __$AdminUserStatsCopyWithImpl;
@override @useResult
$Res call({
 String id, String? displayName, String? avatarUrl, String? email, String? phone, DateTime? dob, String? state, String role, bool banned, DateTime createdAt, int activeCount, int soldCount
});




}
/// @nodoc
class __$AdminUserStatsCopyWithImpl<$Res>
    implements _$AdminUserStatsCopyWith<$Res> {
  __$AdminUserStatsCopyWithImpl(this._self, this._then);

  final _AdminUserStats _self;
  final $Res Function(_AdminUserStats) _then;

/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? dob = freezed,Object? state = freezed,Object? role = null,Object? banned = null,Object? createdAt = null,Object? activeCount = null,Object? soldCount = null,}) {
  return _then(_AdminUserStats(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,soldCount: null == soldCount ? _self.soldCount : soldCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
