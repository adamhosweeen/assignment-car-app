import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/model/auth/registration_data.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/sell/sell_home_screen.dart';

final _seller = Profile(
  id: 'seller-1',
  email: 's@example.com',
  createdAt: DateTime.utc(2026, 1, 1),
);

Listing _car(ListingStatus status) => Listing(
  id: 'l1',
  sellerId: 'seller-1',
  status: status,
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

class _NoDraftRepo implements DraftRepository {
  @override
  bool get hasDraft => false;

  @override
  ListingDraft? load() => null;

  @override
  Future<void> save(ListingDraft draft) async {}

  @override
  Future<void> clear() async {}
}

class _FakeAuth implements AuthRepository {
  @override
  Profile? get currentUser => _seller;

  @override
  Stream<Profile?> authState() => Stream.value(_seller);

  @override
  Future<Result<Profile>> signIn({
    required String email,
    required String password,
  }) async => Ok(_seller);

  @override
  Future<Result<Profile>> signUp({
    required String email,
    required String password,
    required RegistrationData data,
  }) async => Ok(_seller);

  @override
  Future<Result<Profile>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => Ok(_seller);

  @override
  Future<Result<Profile>> updateAvatar(String localPath) async => Ok(_seller);

  @override
  Future<Result<Profile>> removeAvatar() async => Ok(_seller);

  @override
  Future<Result<void>> deleteAccount() async => const Ok(null);

  @override
  Future<void> signOut() async {}
}

class _FakeListings implements ListingsRepository {
  _FakeListings(this.listing, {this.deleteResult = const Ok(null)});

  final Listing listing;
  final Result<void> deleteResult;
  final List<String> deleted = [];

  @override
  Stream<List<Listing>> watchBySeller(String sellerId) =>
      Stream.value([listing]);

  @override
  Future<Result<void>> deleteListing(String id) async {
    deleted.add(id);
    return deleteResult;
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Widget _app(_FakeListings listings) => MultiProvider(
  providers: [
    Provider<AuthRepository>.value(value: _FakeAuth()),
    Provider<ListingsRepository>.value(value: listings),
    Provider<DraftRepository>.value(value: _NoDraftRepo()),
    ChangeNotifierProvider<SellController>(
      create: (_) => SellController(_NoDraftRepo()),
    ),
  ],
  child: MaterialApp(theme: AppTheme.light, home: const SellHomeScreen()),
);

Future<void> _openActions(WidgetTester tester, _FakeListings listings) async {
  await tester.pumpWidget(_app(listings));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.more_horiz));
  await tester.pumpAndSettle();
}

void main() {
  group('actions sheet per status', () {
    testWidgets('a car in an auction cannot be deleted, edited or sold', (
      tester,
    ) async {
      await _openActions(tester, _FakeListings(_car(ListingStatus.bidding)));

      expect(find.text('Auction running'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
      expect(find.text('Mark as sold'), findsNothing);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('a sold car offers no destructive action at all', (
      tester,
    ) async {
      await _openActions(tester, _FakeListings(_car(ListingStatus.sold)));

      expect(find.text('Delete'), findsNothing);
      expect(find.text('Mark as sold'), findsNothing);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('a car on sale can be sold, edited, hidden or deleted', (
      tester,
    ) async {
      await _openActions(tester, _FakeListings(_car(ListingStatus.selling)));

      expect(find.text('Mark as sold'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Hide from buyers'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('a hidden car can be relisted, edited or deleted', (
      tester,
    ) async {
      await _openActions(tester, _FakeListings(_car(ListingStatus.hidden)));

      expect(find.text('Put back on sale'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Mark as sold'), findsNothing);
    });
  });

  group('deleting', () {
    testWidgets('asks for confirmation, then deletes', (tester) async {
      final listings = _FakeListings(_car(ListingStatus.selling));
      await _openActions(tester, listings);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this listing?'), findsOneWidget);
      expect(listings.deleted, isEmpty, reason: 'nothing before confirming');

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(listings.deleted, ['l1']);
    });

    testWidgets('a delete the server refused is shown, not swallowed', (
      tester,
    ) async {
      final listings = _FakeListings(
        _car(ListingStatus.selling),
        deleteResult: const Err('This car can’t be deleted right now.'),
      );
      await _openActions(tester, listings);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('This car can’t be deleted right now.'), findsOneWidget);
    });
  });

  group('resume banner', () {
    testWidgets('disappears when the draft is discarded elsewhere '
        '(e.g. published from inside the wizard)', (tester) async {
      final repo = _MutableDraftRepo(hasDraft: true);
      late SellController controller;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: _FakeAuth()),
            Provider<ListingsRepository>.value(
              value: _FakeListings(_car(ListingStatus.selling)),
            ),
            Provider<DraftRepository>.value(value: repo),
            ChangeNotifierProvider<SellController>(
              create: (_) => controller = SellController(repo),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const SellHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Unfinished listing'), findsOneWidget);

      // What the wizard's publish/discard path does.
      await controller.discard();
      await tester.pumpAndSettle();

      expect(find.text('Unfinished listing'), findsNothing);
    });
  });
}

class _MutableDraftRepo implements DraftRepository {
  _MutableDraftRepo({required bool hasDraft}) : _has = hasDraft;

  bool _has;

  @override
  bool get hasDraft => _has;

  @override
  ListingDraft? load() => null;

  @override
  Future<void> save(ListingDraft draft) async => _has = true;

  @override
  Future<void> clear() async => _has = false;
}
