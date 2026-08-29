import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/listing/listing_media.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

/// A car listing. Mirrors the `listings` table (plus its `listing_media`,
/// embedded here as [media] for convenience).
@freezed
abstract class Listing with _$Listing {
  const factory Listing({
    required String id,
    required String sellerId,
    @Default(ListingStatus.draft) ListingStatus status,
    required String make,
    required String model,
    String? variant,
    required int year,
    required int mileageKm,
    required Transmission transmission,
    required FuelType fuelType,
    required BodyType bodyType,
    required String colour,
    required int ownersCount,
    required bool accidentFree,
    DateTime? roadTaxExpiry,
    required RegistrationRegion registrationRegion,
    required String state,
    required String city,
    required int priceMyr,
    @Default(true) bool negotiable,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(<ListingMedia>[]) List<ListingMedia> media,
  }) = _Listing;

  const Listing._();

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  /// Cover photo (position 0), or the first media, or null.
  ListingMedia? get cover {
    if (media.isEmpty) return null;
    return media.firstWhere((m) => m.position == 0, orElse: () => media.first);
  }

  /// e.g. "2020 Perodua Myvi 1.5 AV".
  String get title => [
    year.toString(),
    make,
    model,
    if (variant != null && variant!.isNotEmpty) variant,
  ].join(' ');
}
