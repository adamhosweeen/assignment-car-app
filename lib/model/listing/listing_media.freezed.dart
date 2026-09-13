// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingMedia {

 String get id; String get listingId; String get storagePath; MediaType get mediaType;/// 0 = cover.
 int get position; DateTime? get createdAt;
/// Create a copy of ListingMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingMediaCopyWith<ListingMedia> get copyWith => _$ListingMediaCopyWithImpl<ListingMedia>(this as ListingMedia, _$identity);

  /// Serializes this ListingMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,storagePath,mediaType,position,createdAt);

@override
String toString() {
  return 'ListingMedia(id: $id, listingId: $listingId, storagePath: $storagePath, mediaType: $mediaType, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ListingMediaCopyWith<$Res>  {
  factory $ListingMediaCopyWith(ListingMedia value, $Res Function(ListingMedia) _then) = _$ListingMediaCopyWithImpl;
@useResult
$Res call({
 String id, String listingId, String storagePath, MediaType mediaType, int position, DateTime? createdAt
});




}
/// @nodoc
class _$ListingMediaCopyWithImpl<$Res>
    implements $ListingMediaCopyWith<$Res> {
  _$ListingMediaCopyWithImpl(this._self, this._then);

  final ListingMedia _self;
  final $Res Function(ListingMedia) _then;

/// Create a copy of ListingMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listingId = null,Object? storagePath = null,Object? mediaType = null,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingMedia].
extension ListingMediaPatterns on ListingMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingMedia value)  $default,){
final _that = this;
switch (_that) {
case _ListingMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingMedia value)?  $default,){
final _that = this;
switch (_that) {
case _ListingMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String listingId,  String storagePath,  MediaType mediaType,  int position,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingMedia() when $default != null:
return $default(_that.id,_that.listingId,_that.storagePath,_that.mediaType,_that.position,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String listingId,  String storagePath,  MediaType mediaType,  int position,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ListingMedia():
return $default(_that.id,_that.listingId,_that.storagePath,_that.mediaType,_that.position,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String listingId,  String storagePath,  MediaType mediaType,  int position,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ListingMedia() when $default != null:
return $default(_that.id,_that.listingId,_that.storagePath,_that.mediaType,_that.position,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingMedia implements ListingMedia {
  const _ListingMedia({required this.id, required this.listingId, required this.storagePath, this.mediaType = MediaType.photo, required this.position, this.createdAt});
  factory _ListingMedia.fromJson(Map<String, dynamic> json) => _$ListingMediaFromJson(json);

@override final  String id;
@override final  String listingId;
@override final  String storagePath;
@override@JsonKey() final  MediaType mediaType;
/// 0 = cover.
@override final  int position;
@override final  DateTime? createdAt;

/// Create a copy of ListingMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingMediaCopyWith<_ListingMedia> get copyWith => __$ListingMediaCopyWithImpl<_ListingMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,storagePath,mediaType,position,createdAt);

@override
String toString() {
  return 'ListingMedia(id: $id, listingId: $listingId, storagePath: $storagePath, mediaType: $mediaType, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ListingMediaCopyWith<$Res> implements $ListingMediaCopyWith<$Res> {
  factory _$ListingMediaCopyWith(_ListingMedia value, $Res Function(_ListingMedia) _then) = __$ListingMediaCopyWithImpl;
@override @useResult
$Res call({
 String id, String listingId, String storagePath, MediaType mediaType, int position, DateTime? createdAt
});




}
/// @nodoc
class __$ListingMediaCopyWithImpl<$Res>
    implements _$ListingMediaCopyWith<$Res> {
  __$ListingMediaCopyWithImpl(this._self, this._then);

  final _ListingMedia _self;
  final $Res Function(_ListingMedia) _then;

/// Create a copy of ListingMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listingId = null,Object? storagePath = null,Object? mediaType = null,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_ListingMedia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
