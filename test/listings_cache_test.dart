import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/listings/listings_cache_repository.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/listing/listing_media.dart';

Listing fullListing({String id = 'l1', int year = 2020}) => Listing(
  id: id,
  sellerId: 'seller-1',
  status: ListingStatus.selling,
  make: 'Honda',
  model: 'City',
  variant: '1.5 V',
  year: year,
  mileageKm: 45000,
  transmission: Transmission.automatic,
  fuelType: FuelType.petrol,
  bodyType: BodyType.sedan,
  colour: 'White',
  ownersCount: 1,
  accidentFree: true,
  roadTaxExpiry: DateTime.utc(2027, 3, 1),
  registrationRegion: RegistrationRegion.west,
  state: 'Selangor',
  city: 'Petaling Jaya',
  priceMyr: 62000,
  negotiable: false,
  description: 'Well kept.',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 2),
  media: [
    ListingMedia(
      id: 'm1',
      listingId: id,
      storagePath: 'seller-1/$id/a.jpg',
      position: 0,
      createdAt: DateTime.utc(2026, 8, 1),
    ),
    ListingMedia(
      id: 'm2',
      listingId: id,
      storagePath: 'seller-1/$id/b.jpg',
      position: 1,
    ),
  ],
);

Listing minimalListing({String id = 'l2'}) => Listing(
  id: id,
  sellerId: 'seller-2',
  status: ListingStatus.selling,
  make: 'Perodua',
  model: 'Myvi',
  year: 2018,
  mileageKm: 90000,
  transmission: Transmission.manual,
  fuelType: FuelType.petrol,
  bodyType: BodyType.hatchback,
  colour: 'Red',
  ownersCount: 2,
  accidentFree: false,
  registrationRegion: RegistrationRegion.east,
  state: 'Sabah',
  city: 'Kota Kinabalu',
  priceMyr: 28000,
  createdAt: DateTime.utc(2026, 7, 1),
  updatedAt: DateTime.utc(2026, 7, 1),
);

void main() {
  group('listings cache row mapping', () {
    test('full listing (media, dates, bools, nullables set) round-trips', () {
      final listing = fullListing();
      final row = listingToRow(listing, 0);
      final mediaRows = listing.media.map((m) => m.toJson()).toList();

      expect(listingFromRow(row, mediaRows), listing);
    });

    test('minimal listing (nullables null, no media) round-trips', () {
      final listing = minimalListing();

      expect(listingFromRow(listingToRow(listing, 3), const []), listing);
    });

    test('bools are stored as SQLite integers', () {
      final row = listingToRow(fullListing(), 0);
      expect(row['accident_free'], 1);
      expect(row['negotiable'], 0);
    });

    test('decodeCachedFeed preserves feed order and media pairing', () {
      final a = fullListing(id: 'a', year: 2021);
      final b = minimalListing(id: 'b');
      final listingRows = [listingToRow(a, 0), listingToRow(b, 1)];
      final mediaRows = a.media.map((m) => m.toJson()).toList();

      final decoded = decodeCachedFeed(listingRows, mediaRows);
      expect(decoded, [a, b]);
    });

    test('a corrupt cache decodes to an empty feed, not a crash', () {
      final decoded = decodeCachedFeed([
        {'id': 'x', 'make': 'broken'},
      ], const []);
      expect(decoded, isEmpty);
    });
  });
}
