import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/listing/listing_media.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';

void main() {
  group('CarInterests JSON', () {
    const interests = CarInterests(
      makes: ['Honda', 'Toyota'],
      bodyTypes: [BodyType.suv, BodyType.sedan],
      transmission: Transmission.automatic,
      fuelType: FuelType.hybrid,
      budgetMinMyr: 30000,
      budgetMaxMyr: 80000,
    );

    test('round-trips with every field set', () {
      expect(CarInterests.fromJson(interests.toJson()), interests);
    });

    test('uses snake_case keys and enum names', () {
      final json = interests.toJson();
      expect(json['makes'], ['Honda', 'Toyota']);
      expect(json['body_types'], ['suv', 'sedan']);
      expect(json['transmission'], 'automatic');
      expect(json['fuel_type'], 'hybrid');
      expect(json['budget_min_myr'], 30000);
      expect(json['budget_max_myr'], 80000);
    });

    test('an absent key falls back to the default', () {
      final empty = CarInterests.fromJson(const {});
      expect(empty.makes, isEmpty);
      expect(empty.bodyTypes, isEmpty);
      expect(empty.transmission, isNull);
      expect(empty.isEmpty, isTrue);
    });
  });

  group('Profile JSON', () {
    final profile = Profile(
      id: 'u1',
      email: 'aiman@example.com',
      firstName: 'Aiman',
      lastName: 'Rahman',
      dob: DateTime.utc(2000, 5, 17),
      phone: '+60123456789',
      state: 'Selangor',
      interests: const CarInterests(makes: ['Perodua']),
      avatarUrl: 'u1/avatar.jpg',
      role: 'admin',
      createdAt: DateTime.utc(2026, 1, 1),
    );

    test('round-trips with every field set', () {
      expect(Profile.fromJson(profile.toJson()), profile);
    });

    test('uses snake_case keys and nests interests', () {
      final json = profile.toJson();
      expect(json['first_name'], 'Aiman');
      expect(json['last_name'], 'Rahman');
      expect(json['avatar_url'], 'u1/avatar.jpg');
      expect(json['created_at'], '2026-01-01T00:00:00.000Z');
      expect(json['interests'], isA<Map<String, dynamic>>());
      expect((json['interests'] as Map)['makes'], ['Perodua']);
    });

    test('role defaults to user and interests to empty', () {
      final minimal = Profile.fromJson({
        'id': 'u2',
        'email': 'b@c.my',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(minimal.role, 'user');
      expect(minimal.isAdmin, isFalse);
      expect(minimal.interests, const CarInterests());
      expect(minimal.dob, isNull);
    });
  });

  group('Listing JSON', () {
    final listing = Listing(
      id: 'l1',
      sellerId: 'u1',
      status: ListingStatus.selling,
      make: 'Perodua',
      model: 'Myvi',
      variant: '1.5 AV',
      year: 2020,
      mileageKm: 45000,
      transmission: Transmission.automatic,
      fuelType: FuelType.petrol,
      bodyType: BodyType.hatchback,
      colour: 'Red',
      ownersCount: 1,
      accidentFree: true,
      roadTaxExpiry: DateTime.utc(2027, 3, 1),
      registrationRegion: RegistrationRegion.west,
      state: 'Selangor',
      city: 'Shah Alam',
      priceMyr: 42000,
      negotiable: false,
      description: 'Well kept.',
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 2),
      media: [
        ListingMedia(
          id: 'm1',
          listingId: 'l1',
          storagePath: 'u1/l1/a.jpg',
          position: 0,
          createdAt: DateTime.utc(2026, 8, 1),
        ),
        const ListingMedia(
          id: 'm2',
          listingId: 'l1',
          storagePath: 'u1/l1/b.mp4',
          mediaType: MediaType.video,
          position: 1,
        ),
      ],
    );

    test('round-trips with every field set, media included', () {
      expect(Listing.fromJson(listing.toJson()), listing);
    });

    test('uses snake_case keys and enum names', () {
      final json = listing.toJson();
      expect(json['seller_id'], 'u1');
      expect(json['mileage_km'], 45000);
      expect(json['price_myr'], 42000);
      expect(json['fuel_type'], 'petrol');
      expect(json['body_type'], 'hatchback');
      expect(json['registration_region'], 'west');
      expect(json['accident_free'], isTrue);
      expect(json['road_tax_expiry'], '2027-03-01T00:00:00.000Z');
      expect((json['media'] as List).length, 2);
      expect(
        ((json['media'] as List).first as Map)['storage_path'],
        'u1/l1/a.jpg',
      );
      expect(((json['media'] as List).last as Map)['media_type'], 'video');
    });

    test('media defaults to empty when the join returns nothing', () {
      final json = listing.toJson()..remove('media');
      expect(Listing.fromJson(json).media, isEmpty);
      expect(Listing.fromJson(json).cover, isNull);
    });

    test('an integer column arriving as a num still decodes', () {
      final json = listing.toJson()..['price_myr'] = 42000.0;
      expect(Listing.fromJson(json).priceMyr, 42000);
    });
  });

  group('ListingDraft JSON', () {
    final draft = ListingDraft(
      id: 'd1',
      photoPaths: const ['/tmp/a.jpg', '/tmp/b.jpg'],
      videoPath: '/tmp/c.mp4',
      make: 'Proton',
      model: 'X50',
      variant: 'Flagship',
      year: 2022,
      mileageKm: 12000,
      transmission: Transmission.automatic,
      fuelType: FuelType.petrol,
      bodyType: BodyType.suv,
      colour: 'Blue',
      ownersCount: 1,
      accidentFree: false,
      roadTaxExpiry: DateTime.utc(2027, 1, 31),
      registrationRegion: RegistrationRegion.east,
      state: 'Sabah',
      city: 'Kota Kinabalu',
      priceMyr: 88000,
      negotiable: false,
      description: 'Under warranty.',
      currentStep: 6,
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    test('round-trips with every field set', () {
      expect(ListingDraft.fromJson(draft.toJson()), draft);
    });

    test('an empty draft round-trips with its nulls intact', () {
      final empty = ListingDraft(id: 'd2', updatedAt: DateTime.utc(2026, 9, 1));
      final back = ListingDraft.fromJson(empty.toJson());
      expect(back, empty);
      expect(back.make, isNull);
      expect(back.photoPaths, isEmpty);
      expect(back.negotiable, isTrue);
      expect(back.currentStep, 0);
    });

    test('uses snake_case keys', () {
      final json = draft.toJson();
      expect(json['photo_paths'], ['/tmp/a.jpg', '/tmp/b.jpg']);
      expect(json['video_path'], '/tmp/c.mp4');
      expect(json['mileage_km'], 12000);
      expect(json['owners_count'], 1);
      expect(json['registration_region'], 'east');
      expect(json['current_step'], 6);
    });
  });
}
