import 'package:flutter/foundation.dart';

import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/listing/listing_media.dart';
import 'package:assignment/utils/json.dart';

const Object _unset = Object();

class Listing {
  const Listing({
    required this.id,
    required this.sellerId,
    this.status = ListingStatus.hidden,
    required this.make,
    required this.model,
    this.variant,
    required this.year,
    required this.mileageKm,
    required this.transmission,
    required this.fuelType,
    required this.bodyType,
    required this.colour,
    required this.ownersCount,
    required this.accidentFree,
    this.roadTaxExpiry,
    required this.registrationRegion,
    required this.state,
    required this.city,
    required this.priceMyr,
    this.negotiable = true,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.media = const <ListingMedia>[],
  });

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
    id: json['id'] as String,
    sellerId: json['seller_id'] as String,
    status: listingStatusFromValue(json['status']),
    make: json['make'] as String,
    model: json['model'] as String,
    variant: json['variant'] as String?,
    year: asInt(json['year']),
    mileageKm: asInt(json['mileage_km']),
    transmission: asEnum(Transmission.values, json['transmission']),
    fuelType: asEnum(FuelType.values, json['fuel_type']),
    bodyType: asEnum(BodyType.values, json['body_type']),
    colour: json['colour'] as String,
    ownersCount: asInt(json['owners_count']),
    accidentFree: json['accident_free'] as bool,
    roadTaxExpiry: asDateOrNull(json['road_tax_expiry']),
    registrationRegion: asEnum(
      RegistrationRegion.values,
      json['registration_region'],
    ),
    state: json['state'] as String,
    city: json['city'] as String,
    priceMyr: asInt(json['price_myr']),
    negotiable: json['negotiable'] as bool? ?? true,
    description: json['description'] as String?,
    createdAt: asDate(json['created_at']),
    updatedAt: asDate(json['updated_at']),
    media: asModelList(json['media'], ListingMedia.fromJson),
  );

  final String id;
  final String sellerId;
  final ListingStatus status;
  final String make;
  final String model;
  final String? variant;
  final int year;
  final int mileageKm;
  final Transmission transmission;
  final FuelType fuelType;
  final BodyType bodyType;
  final String colour;
  final int ownersCount;
  final bool accidentFree;
  final DateTime? roadTaxExpiry;
  final RegistrationRegion registrationRegion;
  final String state;
  final String city;
  final int priceMyr;
  final bool negotiable;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ListingMedia> media;

  Map<String, dynamic> toJson() => {
    'id': id,
    'seller_id': sellerId,
    'status': status.name,
    'make': make,
    'model': model,
    'variant': variant,
    'year': year,
    'mileage_km': mileageKm,
    'transmission': transmission.name,
    'fuel_type': fuelType.name,
    'body_type': bodyType.name,
    'colour': colour,
    'owners_count': ownersCount,
    'accident_free': accidentFree,
    'road_tax_expiry': roadTaxExpiry?.toIso8601String(),
    'registration_region': registrationRegion.name,
    'state': state,
    'city': city,
    'price_myr': priceMyr,
    'negotiable': negotiable,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'media': [for (final m in media) m.toJson()],
  };

  ListingMedia? get cover {
    if (media.isEmpty) return null;
    return media.firstWhere((m) => m.position == 0, orElse: () => media.first);
  }

  String get title => [
    year.toString(),
    make,
    model,
    if (variant != null && variant!.isNotEmpty) variant,
  ].join(' ');

  Listing copyWith({
    String? id,
    String? sellerId,
    ListingStatus? status,
    String? make,
    String? model,
    Object? variant = _unset,
    int? year,
    int? mileageKm,
    Transmission? transmission,
    FuelType? fuelType,
    BodyType? bodyType,
    String? colour,
    int? ownersCount,
    bool? accidentFree,
    Object? roadTaxExpiry = _unset,
    RegistrationRegion? registrationRegion,
    String? state,
    String? city,
    int? priceMyr,
    bool? negotiable,
    Object? description = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ListingMedia>? media,
  }) => Listing(
    id: id ?? this.id,
    sellerId: sellerId ?? this.sellerId,
    status: status ?? this.status,
    make: make ?? this.make,
    model: model ?? this.model,
    variant: identical(variant, _unset) ? this.variant : variant as String?,
    year: year ?? this.year,
    mileageKm: mileageKm ?? this.mileageKm,
    transmission: transmission ?? this.transmission,
    fuelType: fuelType ?? this.fuelType,
    bodyType: bodyType ?? this.bodyType,
    colour: colour ?? this.colour,
    ownersCount: ownersCount ?? this.ownersCount,
    accidentFree: accidentFree ?? this.accidentFree,
    roadTaxExpiry: identical(roadTaxExpiry, _unset)
        ? this.roadTaxExpiry
        : roadTaxExpiry as DateTime?,
    registrationRegion: registrationRegion ?? this.registrationRegion,
    state: state ?? this.state,
    city: city ?? this.city,
    priceMyr: priceMyr ?? this.priceMyr,
    negotiable: negotiable ?? this.negotiable,
    description: identical(description, _unset)
        ? this.description
        : description as String?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    media: media ?? this.media,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Listing &&
          id == other.id &&
          sellerId == other.sellerId &&
          status == other.status &&
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
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          listEquals(media, other.media);

  @override
  int get hashCode => Object.hashAll([
    id,
    sellerId,
    status,
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
    createdAt,
    updatedAt,
    Object.hashAll(media),
  ]);

  @override
  String toString() =>
      'Listing(id: $id, title: $title, status: $status, '
      'priceMyr: $priceMyr, sellerId: $sellerId)';
}
