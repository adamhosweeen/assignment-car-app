// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid_with_listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BidWithListing {

 Bid get bid; Listing get listing;
/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidWithListingCopyWith<BidWithListing> get copyWith => _$BidWithListingCopyWithImpl<BidWithListing>(this as BidWithListing, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BidWithListing&&(identical(other.bid, bid) || other.bid == bid)&&(identical(other.listing, listing) || other.listing == listing));
}


@override
int get hashCode => Object.hash(runtimeType,bid,listing);

@override
String toString() {
  return 'BidWithListing(bid: $bid, listing: $listing)';
}


}

/// @nodoc
abstract mixin class $BidWithListingCopyWith<$Res>  {
  factory $BidWithListingCopyWith(BidWithListing value, $Res Function(BidWithListing) _then) = _$BidWithListingCopyWithImpl;
@useResult
$Res call({
 Bid bid, Listing listing
});


$BidCopyWith<$Res> get bid;$ListingCopyWith<$Res> get listing;

}
/// @nodoc
class _$BidWithListingCopyWithImpl<$Res>
    implements $BidWithListingCopyWith<$Res> {
  _$BidWithListingCopyWithImpl(this._self, this._then);

  final BidWithListing _self;
  final $Res Function(BidWithListing) _then;

/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bid = null,Object? listing = null,}) {
  return _then(_self.copyWith(
bid: null == bid ? _self.bid : bid // ignore: cast_nullable_to_non_nullable
as Bid,listing: null == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing,
  ));
}
/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BidCopyWith<$Res> get bid {
  
  return $BidCopyWith<$Res>(_self.bid, (value) {
    return _then(_self.copyWith(bid: value));
  });
}/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingCopyWith<$Res> get listing {
  
  return $ListingCopyWith<$Res>(_self.listing, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}


/// Adds pattern-matching-related methods to [BidWithListing].
extension BidWithListingPatterns on BidWithListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BidWithListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BidWithListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BidWithListing value)  $default,){
final _that = this;
switch (_that) {
case _BidWithListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BidWithListing value)?  $default,){
final _that = this;
switch (_that) {
case _BidWithListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Bid bid,  Listing listing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BidWithListing() when $default != null:
return $default(_that.bid,_that.listing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Bid bid,  Listing listing)  $default,) {final _that = this;
switch (_that) {
case _BidWithListing():
return $default(_that.bid,_that.listing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Bid bid,  Listing listing)?  $default,) {final _that = this;
switch (_that) {
case _BidWithListing() when $default != null:
return $default(_that.bid,_that.listing);case _:
  return null;

}
}

}

/// @nodoc


class _BidWithListing extends BidWithListing {
  const _BidWithListing({required this.bid, required this.listing}): super._();
  

@override final  Bid bid;
@override final  Listing listing;

/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidWithListingCopyWith<_BidWithListing> get copyWith => __$BidWithListingCopyWithImpl<_BidWithListing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BidWithListing&&(identical(other.bid, bid) || other.bid == bid)&&(identical(other.listing, listing) || other.listing == listing));
}


@override
int get hashCode => Object.hash(runtimeType,bid,listing);

@override
String toString() {
  return 'BidWithListing(bid: $bid, listing: $listing)';
}


}

/// @nodoc
abstract mixin class _$BidWithListingCopyWith<$Res> implements $BidWithListingCopyWith<$Res> {
  factory _$BidWithListingCopyWith(_BidWithListing value, $Res Function(_BidWithListing) _then) = __$BidWithListingCopyWithImpl;
@override @useResult
$Res call({
 Bid bid, Listing listing
});


@override $BidCopyWith<$Res> get bid;@override $ListingCopyWith<$Res> get listing;

}
/// @nodoc
class __$BidWithListingCopyWithImpl<$Res>
    implements _$BidWithListingCopyWith<$Res> {
  __$BidWithListingCopyWithImpl(this._self, this._then);

  final _BidWithListing _self;
  final $Res Function(_BidWithListing) _then;

/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bid = null,Object? listing = null,}) {
  return _then(_BidWithListing(
bid: null == bid ? _self.bid : bid // ignore: cast_nullable_to_non_nullable
as Bid,listing: null == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing,
  ));
}

/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BidCopyWith<$Res> get bid {
  
  return $BidCopyWith<$Res>(_self.bid, (value) {
    return _then(_self.copyWith(bid: value));
  });
}/// Create a copy of BidWithListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingCopyWith<$Res> get listing {
  
  return $ListingCopyWith<$Res>(_self.listing, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}

// dart format on
