import 'package:flutter/foundation.dart';

import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/json.dart';

const int kMaxPriceMyr = 100000000;

const Object _unset = Object();

class ListingDraft {
  const ListingDraft({
    required this.id,
    this.photoPaths = const <String>[],
    this.videoPath,
    this.make,
    this.model,
    this.variant,
    this.year,
    this.mileageKm,
    this.transmission,
    this.fuelType,
    this.bodyType,
    this.colour,
    this.ownersCount,
    this.accidentFree,
    this.roadTaxExpiry,
    this.registrationRegion,
    this.state,
    this.city,
    this.priceMyr,
    this.negotiable = true,
    this.description,
    this.currentStep = 0,
    required this.updatedAt,
  });

  factory ListingDraft.fromJson(Map<String, dynamic> json) => ListingDraft(
    id: json['id'] as String,
    photoPaths: asStringList(json['photo_paths']),
    videoPath: json['video_path'] as String?,
    make: json['make'] as String?,
    model: json['model'] as String?,
    variant: json['variant'] as String?,
    year: asIntOrNull(json['year']),
    mileageKm: asIntOrNull(json['mileage_km']),
    transmission: asEnumOrNull(Transmission.values, json['transmission']),
    fuelType: asEnumOrNull(FuelType.values, json['fuel_type']),
    bodyType: asEnumOrNull(BodyType.values, json['body_type']),
    colour: json['colour'] as String?,
    ownersCount: asIntOrNull(json['owners_count']),
    accidentFree: json['accident_free'] as bool?,
    roadTaxExpiry: asDateOrNull(json['road_tax_expiry']),
    registrationRegion: asEnumOrNull(
      RegistrationRegion.values,
      json['registration_region'],
    ),
    state: json['state'] as String?,
    city: json['city'] as String?,
    priceMyr: asIntOrNull(json['price_myr']),
    negotiable: json['negotiable'] as bool? ?? true,
    description: json['description'] as String?,
    currentStep: asIntOrNull(json['current_step']) ?? 0,
    updatedAt: asDate(json['updated_at']),
  );

  final String id;

  final List<String> photoPaths;
  final String? videoPath;

  final String? make;
  final String? model;
  final String? variant;
  final int? year;

  final int? mileageKm;
  final Transmission? transmission;
  final FuelType? fuelType;
  final BodyType? bodyType;
  final String? colour;

  final int? ownersCount;
  final bool? accidentFree;
  final DateTime? roadTaxExpiry;

  final RegistrationRegion? registrationRegion;
  final String? state;
  final String? city;

  final int? priceMyr;
  final bool negotiable;

  final String? description;

  final int currentStep;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo_paths': photoPaths,
    'video_path': videoPath,
    'make': make,
    'model': model,
    'variant': variant,
    'year': year,
    'mileage_km': mileageKm,
    'transmission': transmission?.name,
    'fuel_type': fuelType?.name,
    'body_type': bodyType?.name,
    'colour': colour,
    'owners_count': ownersCount,
    'accident_free': accidentFree,
    'road_tax_expiry': roadTaxExpiry?.toIso8601String(),
    'registration_region': registrationRegion?.name,
    'state': state,
    'city': city,
    'price_myr': priceMyr,
    'negotiable': negotiable,
    'description': description,
    'current_step': currentStep,
    'updated_at': updatedAt.toIso8601String(),
  };

  bool get hasEnoughPhotos => photoPaths.length >= 3;

  ListingDraft copyWith({
    String? id,
    List<String>? photoPaths,
    Object? videoPath = _unset,
    Object? make = _unset,
    Object? model = _unset,
    Object? variant = _unset,
    Object? year = _unset,
    Object? mileageKm = _unset,
    Object? transmission = _unset,
    Object? fuelType = _unset,
    Object? bodyType = _unset,
    Object? colour = _unset,
    Object? ownersCount = _unset,
    Object? accidentFree = _unset,
    Object? roadTaxExpiry = _unset,
    Object? registrationRegion = _unset,
    Object? state = _unset,
    Object? city = _unset,
    Object? priceMyr = _unset,
    bool? negotiable,
    Object? description = _unset,
    int? currentStep,
    DateTime? updatedAt,
  }) => ListingDraft(
    id: id ?? this.id,
    photoPaths: photoPaths ?? this.photoPaths,
    videoPath: identical(videoPath, _unset)
        ? this.videoPath
        : videoPath as String?,
    make: identical(make, _unset) ? this.make : make as String?,
    model: identical(model, _unset) ? this.model : model as String?,
    variant: identical(variant, _unset) ? this.variant : variant as String?,
    year: identical(year, _unset) ? this.year : year as int?,
    mileageKm: identical(mileageKm, _unset)
        ? this.mileageKm
        : mileageKm as int?,
    transmission: identical(transmission, _unset)
        ? this.transmission
        : transmission as Transmission?,
    fuelType: identical(fuelType, _unset)
        ? this.fuelType
        : fuelType as FuelType?,
    bodyType: identical(bodyType, _unset)
        ? this.bodyType
        : bodyType as BodyType?,
    colour: identical(colour, _unset) ? this.colour : colour as String?,
    ownersCount: identical(ownersCount, _unset)
        ? this.ownersCount
        : ownersCount as int?,
    accidentFree: identical(accidentFree, _unset)
        ? this.accidentFree
        : accidentFree as bool?,
    roadTaxExpiry: identical(roadTaxExpiry, _unset)
        ? this.roadTaxExpiry
        : roadTaxExpiry as DateTime?,
    registrationRegion: identical(registrationRegion, _unset)
        ? this.registrationRegion
        : registrationRegion as RegistrationRegion?,
    state: identical(state, _unset) ? this.state : state as String?,
    city: identical(city, _unset) ? this.city : city as String?,
    priceMyr: identical(priceMyr, _unset) ? this.priceMyr : priceMyr as int?,
    negotiable: negotiable ?? this.negotiable,
    description: identical(description, _unset)
        ? this.description
        : description as String?,
    currentStep: currentStep ?? this.currentStep,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingDraft &&
          id == other.id &&
          listEquals(photoPaths, other.photoPaths) &&
          videoPath == other.videoPath &&
          make == other.make &&
          model == other.model &&
          variant == other.variant &&
          year == other.year &&
          mileageKm == other.mileageKm &&
          transmission == other.transmission &&
          fuelType == other.fuelType &&
          bodyType == other.bodyType &&
          colour == other.colour &&
          ownersCount == other.ownersCount &&
          accidentFree == other.accidentFree &&
          roadTaxExpiry == other.roadTaxExpiry &&
          registrationRegion == other.registrationRegion &&
          state == other.state &&
          city == other.city &&
          priceMyr == other.priceMyr &&
          negotiable == other.negotiable &&
          description == other.description &&
          currentStep == other.currentStep &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    id,
    Object.hashAll(photoPaths),
    videoPath,
    make,
    model,
    variant,
    year,
    mileageKm,
    transmission,
    fuelType,
    bodyType,
    colour,
    ownersCount,
    accidentFree,
    roadTaxExpiry,
    registrationRegion,
    state,
    city,
    priceMyr,
    negotiable,
    description,
    currentStep,
    updatedAt,
  ]);

  @override
  String toString() =>
      'ListingDraft(id: $id, make: $make, model: $model, year: $year, '
      'priceMyr: $priceMyr, currentStep: $currentStep, '
      'photos: ${photoPaths.length})';
}
