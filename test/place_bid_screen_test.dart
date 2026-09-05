import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/bid/place_bid_screen.dart';

final _listing = Listing(
  id: 'l1',
  sellerId: 's1',
  status: ListingStatus.active,
  make: 'Perodua',
  model: 'Myvi',
  variant: '1.5 AV',
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

final _bidder = Profile(
  id: 'b1',
  email: 'buyer@example.com',
  firstName: 'Bob',
  lastName: 'Tan',
  phone: '0123456789',
  createdAt: DateTime.utc(2026, 1, 1),
);

class _FakeBidsRepo implements BidsRepository {
  _FakeBidsRepo({this.existing});

  final Bid? existing;

  int placeCalls = 0;
  int? lastAmount;
  String? lastPhone;
  bool? lastNotify;

  @override
  Future<Result<Bid?>> myPendingBidFor(String listingId) async => Ok(existing);

  @override
  Future<Result<Bid>> placeBid(
    String listingId,
    int amountMyr, {
    required String contactPhone,
    bool notifyWhatsapp = false,
  }) async {
    placeCalls++;
    lastAmount = amountMyr;
    lastPhone = contactPhone;
    lastNotify = notifyWhatsapp;
    return Ok(
      Bid(
        id: 'newbid',
        listingId: listingId,
        bidderId: _bidder.id,
        amountMyr: amountMyr,
        contactPhone: contactPhone,
        notifyWhatsapp: notifyWhatsapp,
        createdAt: DateTime.utc(2026, 8, 30),
        updatedAt: DateTime.utc(2026, 8, 30),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuth implements AuthRepository {
  @override
  Profile? get currentUser => _bidder;

  @override
  Stream<Profile?> authState() => Stream.value(_bidder);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeListingsRepo implements ListingsRepository {
  _FakeListingsRepo(this._listing);

  final Listing _listing;

  @override
  Future<Result<Listing>> getById(String id) async => Ok(_listing);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeBidsRepo repo, {Listing? listing}) {
  return MultiProvider(
    providers: [
      Provider<BidsRepository>.value(value: repo),
      Provider<AuthRepository>.value(value: _FakeAuth()),
      Provider<ListingsRepository>.value(
        value: _FakeListingsRepo(listing ?? _listing),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const PlaceBidScreen(listingId: 'l1'),
    ),
  );
}

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('shows the car spec locked, taken from the listing', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_app(_FakeBidsRepo()));
    await tester.pumpAndSettle();

    for (final label in [
      'Car Brand',
      'Car Model',
      'Car Year',
      'Car Variant',
      'Engine',
      'Transmission',
      'Mileage',
      'Car Region',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'missing $label');
    }

    expect(find.text('Perodua'), findsOneWidget);
    expect(find.text('Myvi'), findsOneWidget);
    expect(find.text('2020'), findsOneWidget);
    expect(find.text('1.5 AV'), findsOneWidget);
    expect(find.text('Petrol'), findsOneWidget);
    expect(find.text('Automatic'), findsOneWidget);
    expect(find.text('38,000 km'), findsOneWidget);
    expect(find.text('West Malaysia'), findsOneWidget);

    expect(find.byIcon(Icons.lock_outline), findsNWidgets(8));
    expect(find.byIcon(Icons.expand_more), findsNothing);

    expect(find.text('Place Your Bid'), findsOneWidget);
  });

  testWidgets('prefills the mobile number from the signed-in profile', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_app(_FakeBidsRepo()));
    await tester.pumpAndSettle();

    expect(find.text('0123456789'), findsOneWidget);
  });

  testWidgets('blocks an empty amount and never calls the repository', (
    tester,
  ) async {
    _useTallSurface(tester);
    final repo = _FakeBidsRepo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Place Your Bid'));
    await tester.pumpAndSettle();

    expect(find.text('Enter how much you want to bid.'), findsOneWidget);
    expect(repo.placeCalls, 0);
  });

  testWidgets('blocks an amount far below the asking price', (tester) async {
    _useTallSurface(tester);
    final repo = _FakeBidsRepo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(bidAmountFieldKey), '450');
    await tester.tap(find.text('Place Your Bid'));
    await tester.pumpAndSettle();

    expect(find.textContaining('far below'), findsOneWidget);
    expect(repo.placeCalls, 0);
  });

  testWidgets('blocks an invalid mobile number', (tester) async {
    _useTallSurface(tester);
    final repo = _FakeBidsRepo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(bidAmountFieldKey), '40000');
    await tester.enterText(find.byKey(bidPhoneFieldKey), '03123');
    await tester.tap(find.text('Place Your Bid'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Malaysian mobile number'), findsOneWidget);
    expect(repo.placeCalls, 0);
  });

  testWidgets('shows how the amount compares to the asking price', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_app(_FakeBidsRepo()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(bidAmountFieldKey), '40000');
    await tester.pumpAndSettle();

    expect(find.text('RM 5,000 below the asking price.'), findsOneWidget);
  });

  testWidgets('a valid bid reaches the repository and confirms', (
    tester,
  ) async {
    _useTallSurface(tester);
    final repo = _FakeBidsRepo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(bidAmountFieldKey), '40000');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Your Bid'));
    await tester.pumpAndSettle();

    expect(repo.placeCalls, 1);
    expect(repo.lastAmount, 40000);
    expect(repo.lastPhone, '0123456789');
    expect(repo.lastNotify, isTrue);

    expect(find.text('Bid placed'), findsNWidgets(2));
    expect(find.text('View my bids'), findsOneWidget);
    expect(find.text('Place Your Bid'), findsNothing);
  });

  testWidgets('an existing pending bid turns the form into an update', (
    tester,
  ) async {
    _useTallSurface(tester);
    final existing = Bid(
      id: 'old',
      listingId: 'l1',
      bidderId: _bidder.id,
      amountMyr: 38000,
      contactPhone: '0119998888',
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 1),
    );
    await tester.pumpWidget(_app(_FakeBidsRepo(existing: existing)));
    await tester.pumpAndSettle();

    expect(find.text('Update Your Bid'), findsOneWidget);
    expect(find.text('Place Your Bid'), findsNothing);
    expect(find.textContaining('already have a RM 38,000 bid'), findsOneWidget);
    expect(find.text('38000'), findsOneWidget);
    expect(find.text('0119998888'), findsOneWidget);
  });

  testWidgets('refuses to bid on your own car', (tester) async {
    _useTallSurface(tester);
    final repo = _FakeBidsRepo();
    await tester.pumpWidget(
      _app(repo, listing: _listing.copyWith(sellerId: _bidder.id)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('your own car'), findsOneWidget);
    expect(find.text('Place Your Bid'), findsNothing);
  });

  testWidgets('refuses to bid on a car that is already sold', (tester) async {
    _useTallSurface(tester);
    final repo = _FakeBidsRepo();
    await tester.pumpWidget(
      _app(repo, listing: _listing.copyWith(status: ListingStatus.sold)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This car is no longer available to bid on.'),
      findsOneWidget,
    );
    expect(find.text('Place Your Bid'), findsNothing);
  });
}
