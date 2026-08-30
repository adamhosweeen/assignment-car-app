import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/model/listing/listing_enums.dart';

part 'car_interests.freezed.dart';
part 'car_interests.g.dart';

/// A buyer's car preferences, collected during registration and editable from
/// the Profile tab. Stored as jsonb in `profiles.interests`. Everything is
/// optional — an empty value means "no preference".
@freezed
abstract class CarInterests with _$CarInterests {
  const CarInterests._();

  const factory CarInterests({
    @Default(<String>[]) List<String> makes,
    @Default(<BodyType>[]) List<BodyType> bodyTypes,
    Transmission? transmission,
    FuelType? fuelType,
    int? budgetMinMyr,
    int? budgetMaxMyr,
  }) = _CarInterests;

  factory CarInterests.fromJson(Map<String, dynamic> json) =>
      _$CarInterestsFromJson(json);

  bool get isEmpty =>
      makes.isEmpty &&
      bodyTypes.isEmpty &&
      transmission == null &&
      fuelType == null &&
      budgetMinMyr == null &&
      budgetMaxMyr == null;
}
