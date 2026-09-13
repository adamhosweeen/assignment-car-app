// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bid {

 String get id; String get listingId; String get bidderId; int get amountMyr; BidStatus get status;/// Contact number captured on the bid form, so the seller can reach the
/// bidder without seeing their (RLS-protected) profile row.
 String? get contactPhone; bool get notifyWhatsapp; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidCopyWith<Bid> get copyWith => _$BidCopyWithImpl<Bid>(this as Bid, _$identity);

  /// Serializes this Bid to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amountMyr, amountMyr) || other.amountMyr == amountMyr)&&(identical(other.status, status) || other.status == status)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.notifyWhatsapp, notifyWhatsapp) || other.notifyWhatsapp == notifyWhatsapp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,bidderId,amountMyr,status,contactPhone,notifyWhatsapp,createdAt,updatedAt);

@override
String toString() {
  return 'Bid(id: $id, listingId: $listingId, bidderId: $bidderId, amountMyr: $amountMyr, status: $status, contactPhone: $contactPhone, notifyWhatsapp: $notifyWhatsapp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BidCopyWith<$Res>  {
  factory $BidCopyWith(Bid value, $Res Function(Bid) _then) = _$BidCopyWithImpl;
@useResult
$Res call({
 String id, String listingId, String bidderId, int amountMyr, BidStatus status, String? contactPhone, bool notifyWhatsapp, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$BidCopyWithImpl<$Res>
    implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._self, this._then);

  final Bid _self;
  final $Res Function(Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listingId = null,Object? bidderId = null,Object? amountMyr = null,Object? status = null,Object? contactPhone = freezed,Object? notifyWhatsapp = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amountMyr: null == amountMyr ? _self.amountMyr : amountMyr // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BidStatus,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,notifyWhatsapp: null == notifyWhatsapp ? _self.notifyWhatsapp : notifyWhatsapp // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Bid].
extension BidPatterns on Bid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bid value)  $default,){
final _that = this;
switch (_that) {
case _Bid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bid value)?  $default,){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String listingId,  String bidderId,  int amountMyr,  BidStatus status,  String? contactPhone,  bool notifyWhatsapp,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.listingId,_that.bidderId,_that.amountMyr,_that.status,_that.contactPhone,_that.notifyWhatsapp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String listingId,  String bidderId,  int amountMyr,  BidStatus status,  String? contactPhone,  bool notifyWhatsapp,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Bid():
return $default(_that.id,_that.listingId,_that.bidderId,_that.amountMyr,_that.status,_that.contactPhone,_that.notifyWhatsapp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String listingId,  String bidderId,  int amountMyr,  BidStatus status,  String? contactPhone,  bool notifyWhatsapp,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.listingId,_that.bidderId,_that.amountMyr,_that.status,_that.contactPhone,_that.notifyWhatsapp,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bid extends Bid {
  const _Bid({required this.id, required this.listingId, required this.bidderId, required this.amountMyr, this.status = BidStatus.pending, this.contactPhone, this.notifyWhatsapp = false, required this.createdAt, required this.updatedAt}): super._();
  factory _Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

@override final  String id;
@override final  String listingId;
@override final  String bidderId;
@override final  int amountMyr;
@override@JsonKey() final  BidStatus status;
/// Contact number captured on the bid form, so the seller can reach the
/// bidder without seeing their (RLS-protected) profile row.
@override final  String? contactPhone;
@override@JsonKey() final  bool notifyWhatsapp;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidCopyWith<_Bid> get copyWith => __$BidCopyWithImpl<_Bid>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amountMyr, amountMyr) || other.amountMyr == amountMyr)&&(identical(other.status, status) || other.status == status)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.notifyWhatsapp, notifyWhatsapp) || other.notifyWhatsapp == notifyWhatsapp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,bidderId,amountMyr,status,contactPhone,notifyWhatsapp,createdAt,updatedAt);

@override
String toString() {
  return 'Bid(id: $id, listingId: $listingId, bidderId: $bidderId, amountMyr: $amountMyr, status: $status, contactPhone: $contactPhone, notifyWhatsapp: $notifyWhatsapp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BidCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$BidCopyWith(_Bid value, $Res Function(_Bid) _then) = __$BidCopyWithImpl;
@override @useResult
$Res call({
 String id, String listingId, String bidderId, int amountMyr, BidStatus status, String? contactPhone, bool notifyWhatsapp, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$BidCopyWithImpl<$Res>
    implements _$BidCopyWith<$Res> {
  __$BidCopyWithImpl(this._self, this._then);

  final _Bid _self;
  final $Res Function(_Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listingId = null,Object? bidderId = null,Object? amountMyr = null,Object? status = null,Object? contactPhone = freezed,Object? notifyWhatsapp = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Bid(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amountMyr: null == amountMyr ? _self.amountMyr : amountMyr // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BidStatus,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,notifyWhatsapp: null == notifyWhatsapp ? _self.notifyWhatsapp : notifyWhatsapp // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
