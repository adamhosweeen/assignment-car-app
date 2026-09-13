// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_interests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarInterests _$CarInterestsFromJson(Map<String, dynamic> json) =>
    _CarInterests(
      makes:
          (json['makes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      bodyTypes:
          (json['body_types'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$BodyTypeEnumMap, e))
              .toList() ??
          const <BodyType>[],
      transmission: $enumDecodeNullable(
        _$TransmissionEnumMap,
        json['transmission'],
      ),
      fuelType: $enumDecodeNullable(_$FuelTypeEnumMap, json['fuel_type']),
      budgetMinMyr: (json['budget_min_myr'] as num?)?.toInt(),
      budgetMaxMyr: (json['budget_max_myr'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CarInterestsToJson(
  _CarInterests instance,
) => <String, dynamic>{
  'makes': instance.makes,
  'body_types': instance.bodyTypes.map((e) => _$BodyTypeEnumMap[e]!).toList(),
  'transmission': _$TransmissionEnumMap[instance.transmission],
  'fuel_type': _$FuelTypeEnumMap[instance.fuelType],
  'budget_min_myr': instance.budgetMinMyr,
  'budget_max_myr': instance.budgetMaxMyr,
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
