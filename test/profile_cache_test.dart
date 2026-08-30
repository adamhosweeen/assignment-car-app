import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/auth/profile_cache_repository.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';

void main() {
  group('profile cache row mapping', () {
    test('full profile round-trips through a row', () {
      final profile = Profile(
        id: 'user-1',
        email: 'aiman@example.com',
        firstName: 'Aiman',
        lastName: 'Rahman',
        dob: DateTime.utc(2000, 5, 17),
        phone: '+60123456789',
        state: 'Selangor',
        interests: const CarInterests(
          makes: ['Honda', 'Toyota'],
          bodyTypes: [BodyType.suv, BodyType.sedan],
          transmission: Transmission.automatic,
          fuelType: FuelType.hybrid,
          budgetMinMyr: 30000,
          budgetMaxMyr: 80000,
        ),
        avatarUrl: null,
        createdAt: DateTime.utc(2026, 1, 1),
      );

      expect(profileFromRow(profileToRow(profile)), profile);
    });

    test('minimal profile (all nullables null) round-trips', () {
      final profile = Profile(
        id: 'user-2',
        email: 'min@example.com',
        createdAt: DateTime.utc(2026, 1, 1),
      );

      expect(profileFromRow(profileToRow(profile)), profile);
    });

    test('corrupt interests_json decodes to empty interests, not a crash', () {
      expect(decodeInterests('not json at all'), const CarInterests());
      expect(decodeInterests(''), const CarInterests());
      expect(decodeInterests(null), const CarInterests());
    });
  });
}
