// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Listing {

 String get id; String get sellerId; ListingStatus get status; String get make; String get model; String? get variant; int get year; int get mileageKm; Transmission get transmission; FuelType get fuelType; BodyType get bodyType; String get colour; int get ownersCount; bool get accidentFree; DateTime? get roadTaxExpiry; RegistrationRegion get registrationRegion; String get state; String get city; int get priceMyr; bool get negotiable; String? get description; DateTime get createdAt; DateTime get updatedAt; List<ListingMedia> get media;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.year, year) || other.year == year)&&(identical(other.mileageKm, mileageKm) || other.mileageKm == mileageKm)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.bodyType, bodyType) || other.bodyType == bodyType)&&(identical(other.colour, colour) || other.colour == colour)&&(identical(other.ownersCount, ownersCount) || other.ownersCount == ownersCount)&&(identical(other.accidentFree, accidentFree) || other.accidentFree == accidentFree)&&(identical(other.roadTaxExpiry, roadTaxExpiry) || other.roadTaxExpiry == roadTaxExpiry)&&(identical(other.registrationRegion, registrationRegion) || other.registrationRegion == registrationRegion)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.priceMyr, priceMyr) || other.priceMyr == priceMyr)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.media, media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,status,make,model,variant,year,mileageKm,transmission,fuelType,bodyType,colour,ownersCount,accidentFree,roadTaxExpiry,registrationRegion,state,city,priceMyr,negotiable,description,createdAt,updatedAt,const DeepCollectionEquality().hash(media)]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, status: $status, make: $make, model: $model, variant: $variant, year: $year, mileageKm: $mileageKm, transmission: $transmission, fuelType: $fuelType, bodyType: $bodyType, colour: $colour, ownersCount: $ownersCount, accidentFree: $accidentFree, roadTaxExpiry: $roadTaxExpiry, registrationRegion: $registrationRegion, state: $state, city: $city, priceMyr: $priceMyr, negotiable: $negotiable, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, media: $media)';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, ListingStatus status, String make, String model, String? variant, int year, int mileageKm, Transmission transmission, FuelType fuelType, BodyType bodyType, String colour, int ownersCount, bool accidentFree, DateTime? roadTaxExpiry, RegistrationRegion registrationRegion, String state, String city, int priceMyr, bool negotiable, String? description, DateTime createdAt, DateTime updatedAt, List<ListingMedia> media
});




}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? status = null,Object? make = null,Object? model = null,Object? variant = freezed,Object? year = null,Object? mileageKm = null,Object? transmission = null,Object? fuelType = null,Object? bodyType = null,Object? colour = null,Object? ownersCount = null,Object? accidentFree = null,Object? roadTaxExpiry = freezed,Object? registrationRegion = null,Object? state = null,Object? city = null,Object? priceMyr = null,Object? negotiable = null,Object? description = freezed,Object? createdAt = null,Object? updatedAt = null,Object? media = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,mileageKm: null == mileageKm ? _self.mileageKm : mileageKm // ignore: cast_nullable_to_non_nullable
as int,transmission: null == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as Transmission,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType,bodyType: null == bodyType ? _self.bodyType : bodyType // ignore: cast_nullable_to_non_nullable
as BodyType,colour: null == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as String,ownersCount: null == ownersCount ? _self.ownersCount : ownersCount // ignore: cast_nullable_to_non_nullable
as int,accidentFree: null == accidentFree ? _self.accidentFree : accidentFree // ignore: cast_nullable_to_non_nullable
as bool,roadTaxExpiry: freezed == roadTaxExpiry ? _self.roadTaxExpiry : roadTaxExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationRegion: null == registrationRegion ? _self.registrationRegion : registrationRegion // ignore: cast_nullable_to_non_nullable
as RegistrationRegion,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,priceMyr: null == priceMyr ? _self.priceMyr : priceMyr // ignore: cast_nullable_to_non_nullable
as int,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<ListingMedia>,
  ));
}

}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  ListingStatus status,  String make,  String model,  String? variant,  int year,  int mileageKm,  Transmission transmission,  FuelType fuelType,  BodyType bodyType,  String colour,  int ownersCount,  bool accidentFree,  DateTime? roadTaxExpiry,  RegistrationRegion registrationRegion,  String state,  String city,  int priceMyr,  bool negotiable,  String? description,  DateTime createdAt,  DateTime updatedAt,  List<ListingMedia> media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.status,_that.make,_that.model,_that.variant,_that.year,_that.mileageKm,_that.transmission,_that.fuelType,_that.bodyType,_that.colour,_that.ownersCount,_that.accidentFree,_that.roadTaxExpiry,_that.registrationRegion,_that.state,_that.city,_that.priceMyr,_that.negotiable,_that.description,_that.createdAt,_that.updatedAt,_that.media);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  ListingStatus status,  String make,  String model,  String? variant,  int year,  int mileageKm,  Transmission transmission,  FuelType fuelType,  BodyType bodyType,  String colour,  int ownersCount,  bool accidentFree,  DateTime? roadTaxExpiry,  RegistrationRegion registrationRegion,  String state,  String city,  int priceMyr,  bool negotiable,  String? description,  DateTime createdAt,  DateTime updatedAt,  List<ListingMedia> media)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.sellerId,_that.status,_that.make,_that.model,_that.variant,_that.year,_that.mileageKm,_that.transmission,_that.fuelType,_that.bodyType,_that.colour,_that.ownersCount,_that.accidentFree,_that.roadTaxExpiry,_that.registrationRegion,_that.state,_that.city,_that.priceMyr,_that.negotiable,_that.description,_that.createdAt,_that.updatedAt,_that.media);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  ListingStatus status,  String make,  String model,  String? variant,  int year,  int mileageKm,  Transmission transmission,  FuelType fuelType,  BodyType bodyType,  String colour,  int ownersCount,  bool accidentFree,  DateTime? roadTaxExpiry,  RegistrationRegion registrationRegion,  String state,  String city,  int priceMyr,  bool negotiable,  String? description,  DateTime createdAt,  DateTime updatedAt,  List<ListingMedia> media)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.status,_that.make,_that.model,_that.variant,_that.year,_that.mileageKm,_that.transmission,_that.fuelType,_that.bodyType,_that.colour,_that.ownersCount,_that.accidentFree,_that.roadTaxExpiry,_that.registrationRegion,_that.state,_that.city,_that.priceMyr,_that.negotiable,_that.description,_that.createdAt,_that.updatedAt,_that.media);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Listing extends Listing {
  const _Listing({required this.id, required this.sellerId, this.status = ListingStatus.draft, required this.make, required this.model, this.variant, required this.year, required this.mileageKm, required this.transmission, required this.fuelType, required this.bodyType, required this.colour, required this.ownersCount, required this.accidentFree, this.roadTaxExpiry, required this.registrationRegion, required this.state, required this.city, required this.priceMyr, this.negotiable = true, this.description, required this.createdAt, required this.updatedAt, final  List<ListingMedia> media = const <ListingMedia>[]}): _media = media,super._();
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override final  String sellerId;
@override@JsonKey() final  ListingStatus status;
@override final  String make;
@override final  String model;
@override final  String? variant;
@override final  int year;
@override final  int mileageKm;
@override final  Transmission transmission;
@override final  FuelType fuelType;
@override final  BodyType bodyType;
@override final  String colour;
@override final  int ownersCount;
@override final  bool accidentFree;
@override final  DateTime? roadTaxExpiry;
@override final  RegistrationRegion registrationRegion;
@override final  String state;
@override final  String city;
@override final  int priceMyr;
@override@JsonKey() final  bool negotiable;
@override final  String? description;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<ListingMedia> _media;
@override@JsonKey() List<ListingMedia> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}


/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.year, year) || other.year == year)&&(identical(other.mileageKm, mileageKm) || other.mileageKm == mileageKm)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.bodyType, bodyType) || other.bodyType == bodyType)&&(identical(other.colour, colour) || other.colour == colour)&&(identical(other.ownersCount, ownersCount) || other.ownersCount == ownersCount)&&(identical(other.accidentFree, accidentFree) || other.accidentFree == accidentFree)&&(identical(other.roadTaxExpiry, roadTaxExpiry) || other.roadTaxExpiry == roadTaxExpiry)&&(identical(other.registrationRegion, registrationRegion) || other.registrationRegion == registrationRegion)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.priceMyr, priceMyr) || other.priceMyr == priceMyr)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._media, _media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,status,make,model,variant,year,mileageKm,transmission,fuelType,bodyType,colour,ownersCount,accidentFree,roadTaxExpiry,registrationRegion,state,city,priceMyr,negotiable,description,createdAt,updatedAt,const DeepCollectionEquality().hash(_media)]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, status: $status, make: $make, model: $model, variant: $variant, year: $year, mileageKm: $mileageKm, transmission: $transmission, fuelType: $fuelType, bodyType: $bodyType, colour: $colour, ownersCount: $ownersCount, accidentFree: $accidentFree, roadTaxExpiry: $roadTaxExpiry, registrationRegion: $registrationRegion, state: $state, city: $city, priceMyr: $priceMyr, negotiable: $negotiable, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, media: $media)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, ListingStatus status, String make, String model, String? variant, int year, int mileageKm, Transmission transmission, FuelType fuelType, BodyType bodyType, String colour, int ownersCount, bool accidentFree, DateTime? roadTaxExpiry, RegistrationRegion registrationRegion, String state, String city, int priceMyr, bool negotiable, String? description, DateTime createdAt, DateTime updatedAt, List<ListingMedia> media
});




}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? status = null,Object? make = null,Object? model = null,Object? variant = freezed,Object? year = null,Object? mileageKm = null,Object? transmission = null,Object? fuelType = null,Object? bodyType = null,Object? colour = null,Object? ownersCount = null,Object? accidentFree = null,Object? roadTaxExpiry = freezed,Object? registrationRegion = null,Object? state = null,Object? city = null,Object? priceMyr = null,Object? negotiable = null,Object? description = freezed,Object? createdAt = null,Object? updatedAt = null,Object? media = null,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,mileageKm: null == mileageKm ? _self.mileageKm : mileageKm // ignore: cast_nullable_to_non_nullable
as int,transmission: null == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as Transmission,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType,bodyType: null == bodyType ? _self.bodyType : bodyType // ignore: cast_nullable_to_non_nullable
as BodyType,colour: null == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as String,ownersCount: null == ownersCount ? _self.ownersCount : ownersCount // ignore: cast_nullable_to_non_nullable
as int,accidentFree: null == accidentFree ? _self.accidentFree : accidentFree // ignore: cast_nullable_to_non_nullable
as bool,roadTaxExpiry: freezed == roadTaxExpiry ? _self.roadTaxExpiry : roadTaxExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationRegion: null == registrationRegion ? _self.registrationRegion : registrationRegion // ignore: cast_nullable_to_non_nullable
as RegistrationRegion,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,priceMyr: null == priceMyr ? _self.priceMyr : priceMyr // ignore: cast_nullable_to_non_nullable
as int,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<ListingMedia>,
  ));
}


}

// dart format on
