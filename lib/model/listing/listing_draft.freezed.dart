// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingDraft {

 String get id;/// Local file paths of picked/compressed photos; index 0 is the cover.
 List<String> get photoPaths; String? get videoPath; String? get make; String? get model; String? get variant; int? get year; int? get mileageKm; Transmission? get transmission; FuelType? get fuelType; BodyType? get bodyType; String? get colour; int? get ownersCount; bool? get accidentFree; DateTime? get roadTaxExpiry; RegistrationRegion? get registrationRegion; String? get state; String? get city; int? get priceMyr; bool get negotiable; String? get description;/// Furthest step the user has reached (0-based), for resume.
 int get currentStep; DateTime get updatedAt;
/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingDraftCopyWith<ListingDraft> get copyWith => _$ListingDraftCopyWithImpl<ListingDraft>(this as ListingDraft, _$identity);

  /// Serializes this ListingDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingDraft&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.photoPaths, photoPaths)&&(identical(other.videoPath, videoPath) || other.videoPath == videoPath)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.year, year) || other.year == year)&&(identical(other.mileageKm, mileageKm) || other.mileageKm == mileageKm)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.bodyType, bodyType) || other.bodyType == bodyType)&&(identical(other.colour, colour) || other.colour == colour)&&(identical(other.ownersCount, ownersCount) || other.ownersCount == ownersCount)&&(identical(other.accidentFree, accidentFree) || other.accidentFree == accidentFree)&&(identical(other.roadTaxExpiry, roadTaxExpiry) || other.roadTaxExpiry == roadTaxExpiry)&&(identical(other.registrationRegion, registrationRegion) || other.registrationRegion == registrationRegion)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.priceMyr, priceMyr) || other.priceMyr == priceMyr)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.description, description) || other.description == description)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,const DeepCollectionEquality().hash(photoPaths),videoPath,make,model,variant,year,mileageKm,transmission,fuelType,bodyType,colour,ownersCount,accidentFree,roadTaxExpiry,registrationRegion,state,city,priceMyr,negotiable,description,currentStep,updatedAt]);

@override
String toString() {
  return 'ListingDraft(id: $id, photoPaths: $photoPaths, videoPath: $videoPath, make: $make, model: $model, variant: $variant, year: $year, mileageKm: $mileageKm, transmission: $transmission, fuelType: $fuelType, bodyType: $bodyType, colour: $colour, ownersCount: $ownersCount, accidentFree: $accidentFree, roadTaxExpiry: $roadTaxExpiry, registrationRegion: $registrationRegion, state: $state, city: $city, priceMyr: $priceMyr, negotiable: $negotiable, description: $description, currentStep: $currentStep, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ListingDraftCopyWith<$Res>  {
  factory $ListingDraftCopyWith(ListingDraft value, $Res Function(ListingDraft) _then) = _$ListingDraftCopyWithImpl;
@useResult
$Res call({
 String id, List<String> photoPaths, String? videoPath, String? make, String? model, String? variant, int? year, int? mileageKm, Transmission? transmission, FuelType? fuelType, BodyType? bodyType, String? colour, int? ownersCount, bool? accidentFree, DateTime? roadTaxExpiry, RegistrationRegion? registrationRegion, String? state, String? city, int? priceMyr, bool negotiable, String? description, int currentStep, DateTime updatedAt
});




}
/// @nodoc
class _$ListingDraftCopyWithImpl<$Res>
    implements $ListingDraftCopyWith<$Res> {
  _$ListingDraftCopyWithImpl(this._self, this._then);

  final ListingDraft _self;
  final $Res Function(ListingDraft) _then;

/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? photoPaths = null,Object? videoPath = freezed,Object? make = freezed,Object? model = freezed,Object? variant = freezed,Object? year = freezed,Object? mileageKm = freezed,Object? transmission = freezed,Object? fuelType = freezed,Object? bodyType = freezed,Object? colour = freezed,Object? ownersCount = freezed,Object? accidentFree = freezed,Object? roadTaxExpiry = freezed,Object? registrationRegion = freezed,Object? state = freezed,Object? city = freezed,Object? priceMyr = freezed,Object? negotiable = null,Object? description = freezed,Object? currentStep = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,photoPaths: null == photoPaths ? _self.photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,videoPath: freezed == videoPath ? _self.videoPath : videoPath // ignore: cast_nullable_to_non_nullable
as String?,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,mileageKm: freezed == mileageKm ? _self.mileageKm : mileageKm // ignore: cast_nullable_to_non_nullable
as int?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as Transmission?,fuelType: freezed == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType?,bodyType: freezed == bodyType ? _self.bodyType : bodyType // ignore: cast_nullable_to_non_nullable
as BodyType?,colour: freezed == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as String?,ownersCount: freezed == ownersCount ? _self.ownersCount : ownersCount // ignore: cast_nullable_to_non_nullable
as int?,accidentFree: freezed == accidentFree ? _self.accidentFree : accidentFree // ignore: cast_nullable_to_non_nullable
as bool?,roadTaxExpiry: freezed == roadTaxExpiry ? _self.roadTaxExpiry : roadTaxExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationRegion: freezed == registrationRegion ? _self.registrationRegion : registrationRegion // ignore: cast_nullable_to_non_nullable
as RegistrationRegion?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,priceMyr: freezed == priceMyr ? _self.priceMyr : priceMyr // ignore: cast_nullable_to_non_nullable
as int?,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingDraft].
extension ListingDraftPatterns on ListingDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingDraft value)  $default,){
final _that = this;
switch (_that) {
case _ListingDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> photoPaths,  String? videoPath,  String? make,  String? model,  String? variant,  int? year,  int? mileageKm,  Transmission? transmission,  FuelType? fuelType,  BodyType? bodyType,  String? colour,  int? ownersCount,  bool? accidentFree,  DateTime? roadTaxExpiry,  RegistrationRegion? registrationRegion,  String? state,  String? city,  int? priceMyr,  bool negotiable,  String? description,  int currentStep,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
return $default(_that.id,_that.photoPaths,_that.videoPath,_that.make,_that.model,_that.variant,_that.year,_that.mileageKm,_that.transmission,_that.fuelType,_that.bodyType,_that.colour,_that.ownersCount,_that.accidentFree,_that.roadTaxExpiry,_that.registrationRegion,_that.state,_that.city,_that.priceMyr,_that.negotiable,_that.description,_that.currentStep,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> photoPaths,  String? videoPath,  String? make,  String? model,  String? variant,  int? year,  int? mileageKm,  Transmission? transmission,  FuelType? fuelType,  BodyType? bodyType,  String? colour,  int? ownersCount,  bool? accidentFree,  DateTime? roadTaxExpiry,  RegistrationRegion? registrationRegion,  String? state,  String? city,  int? priceMyr,  bool negotiable,  String? description,  int currentStep,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ListingDraft():
return $default(_that.id,_that.photoPaths,_that.videoPath,_that.make,_that.model,_that.variant,_that.year,_that.mileageKm,_that.transmission,_that.fuelType,_that.bodyType,_that.colour,_that.ownersCount,_that.accidentFree,_that.roadTaxExpiry,_that.registrationRegion,_that.state,_that.city,_that.priceMyr,_that.negotiable,_that.description,_that.currentStep,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> photoPaths,  String? videoPath,  String? make,  String? model,  String? variant,  int? year,  int? mileageKm,  Transmission? transmission,  FuelType? fuelType,  BodyType? bodyType,  String? colour,  int? ownersCount,  bool? accidentFree,  DateTime? roadTaxExpiry,  RegistrationRegion? registrationRegion,  String? state,  String? city,  int? priceMyr,  bool negotiable,  String? description,  int currentStep,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
return $default(_that.id,_that.photoPaths,_that.videoPath,_that.make,_that.model,_that.variant,_that.year,_that.mileageKm,_that.transmission,_that.fuelType,_that.bodyType,_that.colour,_that.ownersCount,_that.accidentFree,_that.roadTaxExpiry,_that.registrationRegion,_that.state,_that.city,_that.priceMyr,_that.negotiable,_that.description,_that.currentStep,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingDraft extends ListingDraft {
  const _ListingDraft({required this.id, final  List<String> photoPaths = const <String>[], this.videoPath, this.make, this.model, this.variant, this.year, this.mileageKm, this.transmission, this.fuelType, this.bodyType, this.colour, this.ownersCount, this.accidentFree, this.roadTaxExpiry, this.registrationRegion, this.state, this.city, this.priceMyr, this.negotiable = true, this.description, this.currentStep = 0, required this.updatedAt}): _photoPaths = photoPaths,super._();
  factory _ListingDraft.fromJson(Map<String, dynamic> json) => _$ListingDraftFromJson(json);

@override final  String id;
/// Local file paths of picked/compressed photos; index 0 is the cover.
 final  List<String> _photoPaths;
/// Local file paths of picked/compressed photos; index 0 is the cover.
@override@JsonKey() List<String> get photoPaths {
  if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoPaths);
}

@override final  String? videoPath;
@override final  String? make;
@override final  String? model;
@override final  String? variant;
@override final  int? year;
@override final  int? mileageKm;
@override final  Transmission? transmission;
@override final  FuelType? fuelType;
@override final  BodyType? bodyType;
@override final  String? colour;
@override final  int? ownersCount;
@override final  bool? accidentFree;
@override final  DateTime? roadTaxExpiry;
@override final  RegistrationRegion? registrationRegion;
@override final  String? state;
@override final  String? city;
@override final  int? priceMyr;
@override@JsonKey() final  bool negotiable;
@override final  String? description;
/// Furthest step the user has reached (0-based), for resume.
@override@JsonKey() final  int currentStep;
@override final  DateTime updatedAt;

/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingDraftCopyWith<_ListingDraft> get copyWith => __$ListingDraftCopyWithImpl<_ListingDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingDraft&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._photoPaths, _photoPaths)&&(identical(other.videoPath, videoPath) || other.videoPath == videoPath)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.year, year) || other.year == year)&&(identical(other.mileageKm, mileageKm) || other.mileageKm == mileageKm)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.bodyType, bodyType) || other.bodyType == bodyType)&&(identical(other.colour, colour) || other.colour == colour)&&(identical(other.ownersCount, ownersCount) || other.ownersCount == ownersCount)&&(identical(other.accidentFree, accidentFree) || other.accidentFree == accidentFree)&&(identical(other.roadTaxExpiry, roadTaxExpiry) || other.roadTaxExpiry == roadTaxExpiry)&&(identical(other.registrationRegion, registrationRegion) || other.registrationRegion == registrationRegion)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.priceMyr, priceMyr) || other.priceMyr == priceMyr)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.description, description) || other.description == description)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,const DeepCollectionEquality().hash(_photoPaths),videoPath,make,model,variant,year,mileageKm,transmission,fuelType,bodyType,colour,ownersCount,accidentFree,roadTaxExpiry,registrationRegion,state,city,priceMyr,negotiable,description,currentStep,updatedAt]);

@override
String toString() {
  return 'ListingDraft(id: $id, photoPaths: $photoPaths, videoPath: $videoPath, make: $make, model: $model, variant: $variant, year: $year, mileageKm: $mileageKm, transmission: $transmission, fuelType: $fuelType, bodyType: $bodyType, colour: $colour, ownersCount: $ownersCount, accidentFree: $accidentFree, roadTaxExpiry: $roadTaxExpiry, registrationRegion: $registrationRegion, state: $state, city: $city, priceMyr: $priceMyr, negotiable: $negotiable, description: $description, currentStep: $currentStep, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingDraftCopyWith<$Res> implements $ListingDraftCopyWith<$Res> {
  factory _$ListingDraftCopyWith(_ListingDraft value, $Res Function(_ListingDraft) _then) = __$ListingDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> photoPaths, String? videoPath, String? make, String? model, String? variant, int? year, int? mileageKm, Transmission? transmission, FuelType? fuelType, BodyType? bodyType, String? colour, int? ownersCount, bool? accidentFree, DateTime? roadTaxExpiry, RegistrationRegion? registrationRegion, String? state, String? city, int? priceMyr, bool negotiable, String? description, int currentStep, DateTime updatedAt
});




}
/// @nodoc
class __$ListingDraftCopyWithImpl<$Res>
    implements _$ListingDraftCopyWith<$Res> {
  __$ListingDraftCopyWithImpl(this._self, this._then);

  final _ListingDraft _self;
  final $Res Function(_ListingDraft) _then;

/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? photoPaths = null,Object? videoPath = freezed,Object? make = freezed,Object? model = freezed,Object? variant = freezed,Object? year = freezed,Object? mileageKm = freezed,Object? transmission = freezed,Object? fuelType = freezed,Object? bodyType = freezed,Object? colour = freezed,Object? ownersCount = freezed,Object? accidentFree = freezed,Object? roadTaxExpiry = freezed,Object? registrationRegion = freezed,Object? state = freezed,Object? city = freezed,Object? priceMyr = freezed,Object? negotiable = null,Object? description = freezed,Object? currentStep = null,Object? updatedAt = null,}) {
  return _then(_ListingDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,photoPaths: null == photoPaths ? _self._photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,videoPath: freezed == videoPath ? _self.videoPath : videoPath // ignore: cast_nullable_to_non_nullable
as String?,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,mileageKm: freezed == mileageKm ? _self.mileageKm : mileageKm // ignore: cast_nullable_to_non_nullable
as int?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as Transmission?,fuelType: freezed == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as FuelType?,bodyType: freezed == bodyType ? _self.bodyType : bodyType // ignore: cast_nullable_to_non_nullable
as BodyType?,colour: freezed == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as String?,ownersCount: freezed == ownersCount ? _self.ownersCount : ownersCount // ignore: cast_nullable_to_non_nullable
as int?,accidentFree: freezed == accidentFree ? _self.accidentFree : accidentFree // ignore: cast_nullable_to_non_nullable
as bool?,roadTaxExpiry: freezed == roadTaxExpiry ? _self.roadTaxExpiry : roadTaxExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationRegion: freezed == registrationRegion ? _self.registrationRegion : registrationRegion // ignore: cast_nullable_to_non_nullable
as RegistrationRegion?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,priceMyr: freezed == priceMyr ? _self.priceMyr : priceMyr // ignore: cast_nullable_to_non_nullable
as int?,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
