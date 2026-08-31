import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/listings/recommendations_provider.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/profile.dart';

Listing listing({
  required String id,
  String sellerId = 'seller-1',
  String make = 'Perodua',
  BodyType bodyType = BodyType.hatchback,
  FuelType fuelType = FuelType.petrol,
  Transmission transmission = Transmission.automatic,
  int priceMyr = 50000,
  String state = 'Selangor',
  DateTime? createdAt,
}) {
  final ts = createdAt ?? DateTime.utc(2026, 1, 1);
  return Listing(
    id: id,
    sellerId: sellerId,
    status: ListingStatus.active,
    make: make,
    model: 'Model',
    year: 2020,
    mileageKm: 50000,
    transmission: transmission,
    fuelType: fuelType,
    bodyType: bodyType,
    colour: 'White',
    ownersCount: 1,
    accidentFree: true,
    registrationRegion: RegistrationRegion.west,
    state: state,
    city: 'City',
    priceMyr: priceMyr,
    createdAt: ts,
    updatedAt: ts,
  );
}

Profile profile({
  String id = 'buyer-1',
  String? state,
  CarInterests interests = const CarInterests(),
}) => Profile(
  id: id,
  email: 'buyer@example.com',
  state: state,
  interests: interests,
  createdAt: DateTime.utc(2026, 1, 1),
);

void main() {
  group('rankRecommended', () {
    test('no interests and no state → nothing recommended', () {
      final result = rankRecommended([listing(id: 'a')], profile());
      expect(result, isEmpty);
    });

    test('a brand the buyer did not pick is excluded', () {
      final buyer = profile(interests: const CarInterests(makes: ['Honda']));
      final result = rankRecommended([
        listing(id: 'a', make: 'Perodua', state: 'Johor'),
      ], buyer);
      expect(result, isEmpty);
    });

    test('fuel or transmission alone never qualifies a car', () {
      final buyer = profile(
        interests: const CarInterests(
          makes: ['Honda'],
          fuelType: FuelType.petrol,
          transmission: Transmission.automatic,
        ),
      );
      final result = rankRecommended([
        listing(id: 'fuel-only', make: 'Perodua'),
        listing(id: 'brand', make: 'Honda', fuelType: FuelType.diesel),
      ], buyer);
      expect(result.map((l) => l.id), ['brand']);
    });

    test('every set preference must match: brand AND body type', () {
      final buyer = profile(
        interests: const CarInterests(
          makes: ['Honda'],
          bodyTypes: [BodyType.suv],
        ),
      );
      final result = rankRecommended([
        listing(id: 'honda-sedan', make: 'Honda', bodyType: BodyType.sedan),
        listing(id: 'honda-suv', make: 'Honda', bodyType: BodyType.suv),
        listing(id: 'other-suv', make: 'Mazda', bodyType: BodyType.suv),
      ], buyer);
      expect(result.map((l) => l.id), ['honda-suv']);
    });

    test('budget is a hard limit even when the brand matches', () {
      final buyer = profile(
        interests: const CarInterests(makes: ['Honda'], budgetMaxMyr: 60000),
      );
      final result = rankRecommended([
        listing(id: 'affordable', make: 'Honda', priceMyr: 55000),
        listing(id: 'too-expensive', make: 'Honda', priceMyr: 90000),
      ], buyer);
      expect(result.map((l) => l.id), ['affordable']);
    });

    test('location orders the matches: nearby first, then newest', () {
      final buyer = profile(
        state: 'Selangor',
        interests: const CarInterests(makes: ['Honda']),
      );
      final result = rankRecommended([
        listing(
          id: 'far-new',
          make: 'Honda',
          state: 'Sabah',
          createdAt: DateTime.utc(2026, 6, 1),
        ),
        listing(
          id: 'near-old',
          make: 'Honda',
          state: 'Selangor',
          createdAt: DateTime.utc(2026, 1, 1),
        ),
        listing(
          id: 'near-new',
          make: 'Honda',
          state: 'Selangor',
          createdAt: DateTime.utc(2026, 6, 1),
        ),
      ], buyer);
      expect(result.map((l) => l.id), ['near-new', 'near-old', 'far-new']);
    });

    test('equal score ties break newest-first', () {
      final buyer = profile(interests: const CarInterests(makes: ['Honda']));
      final result = rankRecommended([
        listing(id: 'old', make: 'Honda', createdAt: DateTime.utc(2026, 1, 1)),
        listing(id: 'new', make: 'Honda', createdAt: DateTime.utc(2026, 6, 1)),
      ], buyer);
      expect(result.map((l) => l.id), ['new', 'old']);
    });

    test('budget bounds: inside counts, outside does not', () {
      final buyer = profile(
        interests: const CarInterests(budgetMinMyr: 40000, budgetMaxMyr: 60000),
      );
      final result = rankRecommended([
        listing(id: 'inside', priceMyr: 50000),
        listing(id: 'too-expensive', priceMyr: 90000),
        listing(id: 'too-cheap', priceMyr: 10000),
      ], buyer);
      expect(result.map((l) => l.id), ['inside']);
    });

    test('open-ended budget: only-max counts everything at or below', () {
      final buyer = profile(interests: const CarInterests(budgetMaxMyr: 60000));
      final result = rankRecommended([
        listing(id: 'cheap', priceMyr: 10000),
        listing(id: 'over', priceMyr: 90000),
      ], buyer);
      expect(result.map((l) => l.id), ['cheap']);
    });

    test('with no car preferences, same state is the fallback', () {
      final buyer = profile(state: 'Selangor');
      final result = rankRecommended([
        listing(id: 'near', state: 'Selangor'),
        listing(id: 'far', state: 'Sabah'),
      ], buyer);
      expect(result.map((l) => l.id), ['near']);
    });

    test('state alone does not qualify once car preferences are set', () {
      final buyer = profile(
        state: 'Selangor',
        interests: const CarInterests(makes: ['Honda']),
      );
      final result = rankRecommended([
        listing(id: 'near-other-brand', make: 'Perodua', state: 'Selangor'),
      ], buyer);
      expect(result, isEmpty);
    });

    test("the buyer's own listings never appear", () {
      final buyer = profile(
        id: 'me',
        interests: const CarInterests(makes: ['Honda']),
      );
      final result = rankRecommended([
        listing(id: 'mine', sellerId: 'me', make: 'Honda'),
        listing(id: 'theirs', make: 'Honda'),
      ], buyer);
      expect(result.map((l) => l.id), ['theirs']);
    });

    test('caps at the limit', () {
      final buyer = profile(interests: const CarInterests(makes: ['Honda']));
      final many = [
        for (var i = 0; i < 15; i++) listing(id: 'l$i', make: 'Honda'),
      ];
      expect(rankRecommended(many, buyer).length, 10);
    });
  });
}
