// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Listing _$ListingFromJson(Map<String, dynamic> json) => _Listing(
  id: json['id'] as String,
  sellerId: json['seller_id'] as String,
  status:
      $enumDecodeNullable(_$ListingStatusEnumMap, json['status']) ??
      ListingStatus.draft,
  make: json['make'] as String,
  model: json['model'] as String,
  variant: json['variant'] as String?,
  year: (json['year'] as num).toInt(),
  mileageKm: (json['mileage_km'] as num).toInt(),
  transmission: $enumDecode(_$TransmissionEnumMap, json['transmission']),
  fuelType: $enumDecode(_$FuelTypeEnumMap, json['fuel_type']),
  bodyType: $enumDecode(_$BodyTypeEnumMap, json['body_type']),
  colour: json['colour'] as String,
  ownersCount: (json['owners_count'] as num).toInt(),
  accidentFree: json['accident_free'] as bool,
  roadTaxExpiry: json['road_tax_expiry'] == null
      ? null
      : DateTime.parse(json['road_tax_expiry'] as String),
  registrationRegion: $enumDecode(
    _$RegistrationRegionEnumMap,
    json['registration_region'],
  ),
  state: json['state'] as String,
  city: json['city'] as String,
  priceMyr: (json['price_myr'] as num).toInt(),
  negotiable: json['negotiable'] as bool? ?? true,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => ListingMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ListingMedia>[],
);

Map<String, dynamic> _$ListingToJson(_Listing instance) => <String, dynamic>{
  'id': instance.id,
  'seller_id': instance.sellerId,
  'status': _$ListingStatusEnumMap[instance.status]!,
  'make': instance.make,
  'model': instance.model,
  'variant': instance.variant,
  'year': instance.year,
  'mileage_km': instance.mileageKm,
  'transmission': _$TransmissionEnumMap[instance.transmission]!,
  'fuel_type': _$FuelTypeEnumMap[instance.fuelType]!,
  'body_type': _$BodyTypeEnumMap[instance.bodyType]!,
  'colour': instance.colour,
  'owners_count': instance.ownersCount,
  'accident_free': instance.accidentFree,
  'road_tax_expiry': instance.roadTaxExpiry?.toIso8601String(),
  'registration_region':
      _$RegistrationRegionEnumMap[instance.registrationRegion]!,
  'state': instance.state,
  'city': instance.city,
  'price_myr': instance.priceMyr,
  'negotiable': instance.negotiable,
  'description': instance.description,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'media': instance.media.map((e) => e.toJson()).toList(),
};

const _$ListingStatusEnumMap = {
  ListingStatus.draft: 'draft',
  ListingStatus.active: 'active',
  ListingStatus.sold: 'sold',
  ListingStatus.deleted: 'deleted',
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
