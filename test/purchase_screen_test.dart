import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/buy/purchase_screen.dart';

final _listing = Listing(
  id: 'l1',
  sellerId: 's1',
  status: ListingStatus.active,
  make: 'Perodua',
  model: 'Myvi',
  year: 2020,
  mileageKm: 38000,
  transmission: Transmission.automatic,
  fuelType: FuelType.petrol,
  bodyType: BodyType.hatchback,
  colour: 'White',
  ownersCount: 1,
  accidentFree: true,
  registrationRegion: RegistrationRegion.west,
  state: 'Selangor',
  city: 'Petaling Jaya',
  priceMyr: 45000,
  createdAt: DateTime.utc(2026, 3, 12),
  updatedAt: DateTime.utc(2026, 3, 12),
);

final _buyer = Profile(
  id: 'b1',
  email: 'buyer@example.com',
  firstName: 'Bob',
  lastName: 'Tan',
  phone: '+60123456789',
  createdAt: DateTime.utc(2026, 1, 1),
);

final _seller = PublicProfile(
  id: 's1',
  displayName: 'Sally Seller',
  state: 'Penang',
  createdAt: DateTime.utc(2025, 1, 1),
);

class _FakeListingsRepo implements ListingsRepository {
  int buyCalls = 0;
  String? lastBoughtId;

  @override
  Future<Result<void>> buy(String id) async {
    buyCalls++;
    lastBoughtId = id;
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeAuth implements AuthRepository {
  @override
  Profile? get currentUser => _buyer;

  @override
  Stream<Profile?> authState() => Stream.value(_buyer);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

Widget _app(_FakeListingsRepo repo) {
  return ProviderScope(
    overrides: [
      listingsRepositoryProvider.overrideWithValue(repo),
      authRepositoryProvider.overrideWithValue(_FakeAuth()),
      activeListingsProvider.overrideWith(
        (ref) => Stream.value(const <Listing>[]),
      ),
      listingByIdProvider('l1').overrideWith((ref) async => _listing),
      publicProfileProvider('s1').overrideWith((ref) async => _seller),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const PurchaseScreen(id: 'l1'),
    ),
  );
}

void main() {
  testWidgets('shows the order summary with the car price', (tester) async {
    final repo = _FakeListingsRepo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    final list = find.byType(Scrollable).first;

    expect(find.text('ORDER SUMMARY'), findsOneWidget);
    expect(find.text('Cash on collection'), findsOneWidget);
    expect(find.text('From seller in Petaling Jaya'), findsOneWidget);
    expect(find.text('2020 Perodua Myvi'), findsWidgets);
    expect(find.text('RM 45,000'), findsWidgets);
    expect(find.text('Confirm purchase · RM 45,000'), findsOneWidget);

    // Seller section, further down the form.
    await tester.scrollUntilVisible(find.text('Sally Seller'), 200,
        scrollable: list);
    expect(find.text('SELLER'), findsOneWidget);
    expect(find.text('Sally Seller'), findsOneWidget);

    // Buyer section, at the bottom.
    await tester.scrollUntilVisible(find.text('Bob Tan'), 200,
        scrollable: list);
    expect(find.text('Bob Tan'), findsOneWidget);
  });

  testWidgets('confirming buys the listing and shows success', (
    tester,
  ) async {
    final repo = _FakeListingsRepo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm purchase · RM 45,000'));
    await tester.pumpAndSettle();

    expect(repo.buyCalls, 1);
    expect(repo.lastBoughtId, 'l1');
    // Title in the app bar + heading in the body.
    expect(find.text('Purchase confirmed'), findsNWidgets(2));
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Confirm purchase · RM 45,000'), findsNothing);
  });
}
