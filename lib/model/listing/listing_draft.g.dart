// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingDraft _$ListingDraftFromJson(Map<String, dynamic> json) =>
    _ListingDraft(
      id: json['id'] as String,
      photoPaths:
          (json['photo_paths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      videoPath: json['video_path'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      variant: json['variant'] as String?,
      year: (json['year'] as num?)?.toInt(),
      mileageKm: (json['mileage_km'] as num?)?.toInt(),
      transmission: $enumDecodeNullable(
        _$TransmissionEnumMap,
        json['transmission'],
      ),
      fuelType: $enumDecodeNullable(_$FuelTypeEnumMap, json['fuel_type']),
      bodyType: $enumDecodeNullable(_$BodyTypeEnumMap, json['body_type']),
      colour: json['colour'] as String?,
      ownersCount: (json['owners_count'] as num?)?.toInt(),
      accidentFree: json['accident_free'] as bool?,
      roadTaxExpiry: json['road_tax_expiry'] == null
          ? null
          : DateTime.parse(json['road_tax_expiry'] as String),
      registrationRegion: $enumDecodeNullable(
        _$RegistrationRegionEnumMap,
        json['registration_region'],
      ),
      state: json['state'] as String?,
      city: json['city'] as String?,
      priceMyr: (json['price_myr'] as num?)?.toInt(),
      negotiable: json['negotiable'] as bool? ?? true,
      description: json['description'] as String?,
      currentStep: (json['current_step'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ListingDraftToJson(_ListingDraft instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photo_paths': instance.photoPaths,
      'video_path': instance.videoPath,
      'make': instance.make,
      'model': instance.model,
      'variant': instance.variant,
      'year': instance.year,
      'mileage_km': instance.mileageKm,
      'transmission': _$TransmissionEnumMap[instance.transmission],
      'fuel_type': _$FuelTypeEnumMap[instance.fuelType],
      'body_type': _$BodyTypeEnumMap[instance.bodyType],
      'colour': instance.colour,
      'owners_count': instance.ownersCount,
      'accident_free': instance.accidentFree,
      'road_tax_expiry': instance.roadTaxExpiry?.toIso8601String(),
      'registration_region':
          _$RegistrationRegionEnumMap[instance.registrationRegion],
      'state': instance.state,
      'city': instance.city,
      'price_myr': instance.priceMyr,
      'negotiable': instance.negotiable,
      'description': instance.description,
      'current_step': instance.currentStep,
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$TransmissionEnumMap = {
  Transmission.automatic: 'automatic',
  Transmission.manual: 'manual',
};

const _$FuelTypeEnumMap = {
  FuelType.petrol: 'petrol',
  FuelType.diesel: 'diesel',
  FuelType.hybrid: 'hybrid',
  FuelType.electric: 'electric',
};

const _$BodyTypeEnumMap = {
  BodyType.sedan: 'sedan',
  BodyType.hatchback: 'hatchback',
  BodyType.suv: 'suv',
  BodyType.mpv: 'mpv',
  BodyType.pickup: 'pickup',
  BodyType.coupe: 'coupe',
  BodyType.other: 'other',
};

const _$RegistrationRegionEnumMap = {
  RegistrationRegion.west: 'west',
  RegistrationRegion.east: 'east',
};
