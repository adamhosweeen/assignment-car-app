// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminReport {

 String get id; String get reporterId; String get reportedId; String? get reporterName; String? get reportedName; bool get reportedBanned; String get title; String get description; String get status; DateTime get createdAt;
/// Create a copy of AdminReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminReportCopyWith<AdminReport> get copyWith => _$AdminReportCopyWithImpl<AdminReport>(this as AdminReport, _$identity);

  /// Serializes this AdminReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reportedId, reportedId) || other.reportedId == reportedId)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.reportedName, reportedName) || other.reportedName == reportedName)&&(identical(other.reportedBanned, reportedBanned) || other.reportedBanned == reportedBanned)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporterId,reportedId,reporterName,reportedName,reportedBanned,title,description,status,createdAt);

@override
String toString() {
  return 'AdminReport(id: $id, reporterId: $reporterId, reportedId: $reportedId, reporterName: $reporterName, reportedName: $reportedName, reportedBanned: $reportedBanned, title: $title, description: $description, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AdminReportCopyWith<$Res>  {
  factory $AdminReportCopyWith(AdminReport value, $Res Function(AdminReport) _then) = _$AdminReportCopyWithImpl;
@useResult
$Res call({
 String id, String reporterId, String reportedId, String? reporterName, String? reportedName, bool reportedBanned, String title, String description, String status, DateTime createdAt
});




}
/// @nodoc
class _$AdminReportCopyWithImpl<$Res>
    implements $AdminReportCopyWith<$Res> {
  _$AdminReportCopyWithImpl(this._self, this._then);

  final AdminReport _self;
  final $Res Function(AdminReport) _then;

/// Create a copy of AdminReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reporterId = null,Object? reportedId = null,Object? reporterName = freezed,Object? reportedName = freezed,Object? reportedBanned = null,Object? title = null,Object? description = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reportedId: null == reportedId ? _self.reportedId : reportedId // ignore: cast_nullable_to_non_nullable
as String,reporterName: freezed == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String?,reportedName: freezed == reportedName ? _self.reportedName : reportedName // ignore: cast_nullable_to_non_nullable
as String?,reportedBanned: null == reportedBanned ? _self.reportedBanned : reportedBanned // ignore: cast_nullable_to_non_nullable
as bool,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminReport].
extension AdminReportPatterns on AdminReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminReport value)  $default,){
final _that = this;
switch (_that) {
case _AdminReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminReport value)?  $default,){
final _that = this;
switch (_that) {
case _AdminReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reporterId,  String reportedId,  String? reporterName,  String? reportedName,  bool reportedBanned,  String title,  String description,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminReport() when $default != null:
return $default(_that.id,_that.reporterId,_that.reportedId,_that.reporterName,_that.reportedName,_that.reportedBanned,_that.title,_that.description,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reporterId,  String reportedId,  String? reporterName,  String? reportedName,  bool reportedBanned,  String title,  String description,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminReport():
return $default(_that.id,_that.reporterId,_that.reportedId,_that.reporterName,_that.reportedName,_that.reportedBanned,_that.title,_that.description,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reporterId,  String reportedId,  String? reporterName,  String? reportedName,  bool reportedBanned,  String title,  String description,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminReport() when $default != null:
return $default(_that.id,_that.reporterId,_that.reportedId,_that.reporterName,_that.reportedName,_that.reportedBanned,_that.title,_that.description,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminReport extends AdminReport {
  const _AdminReport({required this.id, required this.reporterId, required this.reportedId, this.reporterName, this.reportedName, this.reportedBanned = false, required this.title, required this.description, this.status = 'open', required this.createdAt}): super._();
  factory _AdminReport.fromJson(Map<String, dynamic> json) => _$AdminReportFromJson(json);

@override final  String id;
@override final  String reporterId;
@override final  String reportedId;
@override final  String? reporterName;
@override final  String? reportedName;
@override@JsonKey() final  bool reportedBanned;
@override final  String title;
@override final  String description;
@override@JsonKey() final  String status;
@override final  DateTime createdAt;

/// Create a copy of AdminReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminReportCopyWith<_AdminReport> get copyWith => __$AdminReportCopyWithImpl<_AdminReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reportedId, reportedId) || other.reportedId == reportedId)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.reportedName, reportedName) || other.reportedName == reportedName)&&(identical(other.reportedBanned, reportedBanned) || other.reportedBanned == reportedBanned)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporterId,reportedId,reporterName,reportedName,reportedBanned,title,description,status,createdAt);

@override
String toString() {
  return 'AdminReport(id: $id, reporterId: $reporterId, reportedId: $reportedId, reporterName: $reporterName, reportedName: $reportedName, reportedBanned: $reportedBanned, title: $title, description: $description, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminReportCopyWith<$Res> implements $AdminReportCopyWith<$Res> {
  factory _$AdminReportCopyWith(_AdminReport value, $Res Function(_AdminReport) _then) = __$AdminReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String reporterId, String reportedId, String? reporterName, String? reportedName, bool reportedBanned, String title, String description, String status, DateTime createdAt
});




}
/// @nodoc
class __$AdminReportCopyWithImpl<$Res>
    implements _$AdminReportCopyWith<$Res> {
  __$AdminReportCopyWithImpl(this._self, this._then);

  final _AdminReport _self;
  final $Res Function(_AdminReport) _then;

/// Create a copy of AdminReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reporterId = null,Object? reportedId = null,Object? reporterName = freezed,Object? reportedName = freezed,Object? reportedBanned = null,Object? title = null,Object? description = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_AdminReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reportedId: null == reportedId ? _self.reportedId : reportedId // ignore: cast_nullable_to_non_nullable
as String,reporterName: freezed == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String?,reportedName: freezed == reportedName ? _self.reportedName : reportedName // ignore: cast_nullable_to_non_nullable
as String?,reportedBanned: null == reportedBanned ? _self.reportedBanned : reportedBanned // ignore: cast_nullable_to_non_nullable
as bool,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
