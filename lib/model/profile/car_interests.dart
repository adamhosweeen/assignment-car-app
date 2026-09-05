import 'package:flutter/foundation.dart';

import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/json.dart';

/// Sentinel for [CarInterests.copyWith], so an omitted argument is
/// distinguishable from an explicit `null` and a nullable field can be
/// cleared (`copyWith(transmission: null)` really does clear it).
const Object _unset = Object();

/// A buyer's car preferences, collected during registration and editable from
/// the Profile tab. Stored as jsonb in `profiles.interests`. Everything is
/// optional — an empty value means "no preference".
class CarInterests {
  const CarInterests({
    this.makes = const <String>[],
    this.bodyTypes = const <BodyType>[],
    this.transmission,
    this.fuelType,
    this.budgetMinMyr,
    this.budgetMaxMyr,
  });

  factory CarInterests.fromJson(Map<String, dynamic> json) => CarInterests(
    makes: asStringList(json['makes']),
    bodyTypes: asEnumList(BodyType.values, json['body_types']),
    transmission: asEnumOrNull(Transmission.values, json['transmission']),
    fuelType: asEnumOrNull(FuelType.values, json['fuel_type']),
    budgetMinMyr: asIntOrNull(json['budget_min_myr']),
    budgetMaxMyr: asIntOrNull(json['budget_max_myr']),
  );

  final List<String> makes;
  final List<BodyType> bodyTypes;
  final Transmission? transmission;
  final FuelType? fuelType;
  final int? budgetMinMyr;
  final int? budgetMaxMyr;

  Map<String, dynamic> toJson() => {
    'makes': makes,
    'body_types': [for (final b in bodyTypes) b.name],
    'transmission': transmission?.name,
    'fuel_type': fuelType?.name,
    'budget_min_myr': budgetMinMyr,
    'budget_max_myr': budgetMaxMyr,
  };

  bool get isEmpty =>
      makes.isEmpty &&
      bodyTypes.isEmpty &&
      transmission == null &&
      fuelType == null &&
      budgetMinMyr == null &&
      budgetMaxMyr == null;

  CarInterests copyWith({
    List<String>? makes,
    List<BodyType>? bodyTypes,
    Object? transmission = _unset,
    Object? fuelType = _unset,
    Object? budgetMinMyr = _unset,
    Object? budgetMaxMyr = _unset,
  }) => CarInterests(
    makes: makes ?? this.makes,
    bodyTypes: bodyTypes ?? this.bodyTypes,
    transmission: identical(transmission, _unset)
        ? this.transmission
        : transmission as Transmission?,
    fuelType: identical(fuelType, _unset)
        ? this.fuelType
        : fuelType as FuelType?,
    budgetMinMyr: identical(budgetMinMyr, _unset)
        ? this.budgetMinMyr
        : budgetMinMyr as int?,
    budgetMaxMyr: identical(budgetMaxMyr, _unset)
        ? this.budgetMaxMyr
        : budgetMaxMyr as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarInterests &&
          listEquals(makes, other.makes) &&
          listEquals(bodyTypes, other.bodyTypes) &&
          transmission == other.transmission &&
          fuelType == other.fuelType &&
          budgetMinMyr == other.budgetMinMyr &&
          budgetMaxMyr == other.budgetMaxMyr;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(makes),
    Object.hashAll(bodyTypes),
    transmission,
    fuelType,
    budgetMinMyr,
    budgetMaxMyr,
  );

  @override
  String toString() =>
      'CarInterests(makes: $makes, bodyTypes: $bodyTypes, '
      'transmission: $transmission, fuelType: $fuelType, '
      'budgetMinMyr: $budgetMinMyr, budgetMaxMyr: $budgetMaxMyr)';
}
