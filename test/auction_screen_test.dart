import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/model/bid/bids_sync_status.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/bid/auction_screen.dart';

final _now = DateTime.utc(2026, 9, 5, 12);

final _buyer = AppUser(
  id: 'buyer-1',
  email: 'b@example.com',
  createdAt: DateTime.utc(2026, 1, 1),
);

final _seller = AppUser(
  id: 'seller-1',
  email: 's@example.com',
  createdAt: DateTime.utc(2026, 1, 1),
);

final _listing = Listing(
  id: 'l1',
  sellerId: 'seller-1',
  status: ListingStatus.bidding,
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
  createdAt: _now,
  updatedAt: _now,
);

// `createdAt` and `endsAt` hang off the real clock, not [_now]: liveness and
// the 7-day extension cap are both measured against DateTime.now().
Auction _auction({
  int? highestBidMyr,
  int bidCount = 0,
  AuctionStatus status = AuctionStatus.running,
  Duration runsFor = const Duration(hours: 2),
}) => Auction(
  id: 'a1',
  listingId: 'l1',
  sellerId: 'seller-1',
  startingPriceMyr: 30000,
  minIncrementMyr: 500,
  endsAt: DateTime.now().toUtc().add(runsFor),
  highestBidMyr: highestBidMyr,
  bidCount: bidCount,
  status: status,
  createdAt: DateTime.now().toUtc(),
);

Bid _bid(int amount) => Bid(
  id: 'b-$amount',
  listingId: 'l1',
  auctionId: 'a1',
  bidderId: 'buyer-1',
  amountMyr: amount,
  createdAt: _now,
  updatedAt: _now,
);

class _FakeAuth implements AuthRepository {
  _FakeAuth(this.user);

  final AppUser user;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> authState() => Stream.value(user);

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async => Ok(user);

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String phoneE164,
    required String state,
    required CarInterests interests,
  }) async => Ok(user);

  @override
  Future<Result<AppUser>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => Ok(user);

  @override
  Future<Result<AppUser>> updateAvatar(String localPath) async => Ok(user);

  @override
  Future<Result<AppUser>> removeAvatar() async => Ok(user);

  @override
  Future<Result<void>> deleteAccount() async => const Ok(null);

  @override
  Future<void> signOut() async {}
}

class _FakeBids implements BidsRepository {
  /// Settable so a test can put the screen offline without a network.
  @override
  final ValueNotifier<BidsSyncStatus> syncStatus = ValueNotifier(
    const BidsSyncStatus.unknown(),
  );

  _FakeBids({required Auction auction, List<Bid> bids = const []})
    : _auctionCtrl = StreamController<AuctionWithListing>.broadcast(),
      _bidsCtrl = StreamController<List<Bid>>.broadcast() {
    _auction = auction;
    _bids = bids;
  }

  final StreamController<AuctionWithListing> _auctionCtrl;
  final StreamController<List<Bid>> _bidsCtrl;
  late Auction _auction;
  late List<Bid> _bids;
  final List<int> placed = [];

  void push({Auction? auction, List<Bid>? bids}) {
    if (auction != null) _auction = auction;
    if (bids != null) _bids = bids;
    _auctionCtrl.add(AuctionWithListing(auction: _auction, listing: _listing));
    _bidsCtrl.add(_bids);
  }

  Future<void> close() async {
    await _auctionCtrl.close();
    await _bidsCtrl.close();
  }

  @override
  Stream<AuctionWithListing> watchAuction(String auctionId) async* {
    yield AuctionWithListing(auction: _auction, listing: _listing);
    yield* _auctionCtrl.stream;
  }

  @override
  Stream<List<Bid>> watchBidsForAuction(String auctionId) async* {
    yield _bids;
    yield* _bidsCtrl.stream;
  }

  @override
  Future<Result<void>> placeBid(String auctionId, int amountMyr) async {
    placed.add(amountMyr);
    push(
      auction: _auction.copyWith(
        highestBidMyr: amountMyr,
        bidCount: _auction.bidCount + 1,
      ),
      bids: [_bid(amountMyr), ..._bids],
    );
    return const Ok(null);
  }

  @override
  Stream<List<AuctionWithListing>> watchLiveAuctions() => const Stream.empty();

  @override
  Stream<List<BidWithAuction>> watchMyBids() => const Stream.empty();

  @override
  Stream<List<AuctionWithListing>> watchMyAuctions() => const Stream.empty();

  @override
  Future<Result<String>> startAuction({
    required String listingId,
    required int startingPriceMyr,
    required int minIncrementMyr,
    required DateTime endsAt,
  }) async => const Ok('a1');

  @override
  Future<Result<void>> cancelAuction(String auctionId) async => const Ok(null);

  final List<DateTime> extendedTo = [];
  Result<void> extendResult = const Ok(null);

  @override
  Future<Result<void>> extendAuction(String auctionId, DateTime endsAt) async {
    if (extendResult case Err()) return extendResult;
    extendedTo.add(endsAt);
    push(auction: _auction.copyWith(endsAt: endsAt));
    return const Ok(null);
  }

  @override
  Future<Result<String?>> latestAuctionIdForListing(String listingId) async =>
      const Ok(null);

  final List<String> deletedAuctions = [];

  @override
  Future<Result<void>> deleteAuction(String auctionId) async {
    deletedAuctions.add(auctionId);
    return const Ok(null);
  }
}

Widget _app(_FakeBids bids, {AppUser? as}) => MultiProvider(
  providers: [
    Provider<AuthRepository>.value(value: _FakeAuth(as ?? _buyer)),
    Provider<BidsRepository>.value(value: bids),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: const AuctionScreen(id: 'a1'),
  ),
);

bool _buttonEnabled(WidgetTester tester, Key key) =>
    tester.widget<FilledButton>(find.byKey(key)).onPressed != null;

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(bidAmountFieldKey)).controller!.text;

Future<void> _pump(WidgetTester tester, _FakeBids bids, {AppUser? as}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(bids, as: as));
  await tester.pumpAndSettle();
}

void main() {
  group('buyer with no bid yet', () {
    testWidgets('the field is prefilled with the minimum next bid', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      expect(find.text('Place your bid'), findsOneWidget);
      expect(_fieldText(tester), '30000');
      expect(find.text('Bid RM 30,000'), findsOneWidget);
    });

    testWidgets('a chip sets the amount and updates the button label', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction(highestBidMyr: 30000));
      addTearDown(bids.close);
      await _pump(tester, bids);

      await tester.tap(find.text('+RM 1,000'));
      await tester.pumpAndSettle();

      expect(_fieldText(tester), '31500');
      expect(find.text('Bid RM 31,500'), findsOneWidget);
    });

    testWidgets('typing below the minimum disables the button with a hint', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      await tester.enterText(find.byKey(bidAmountFieldKey), '25000');
      await tester.pumpAndSettle();

      expect(find.textContaining('below the minimum'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byKey(placeBidButtonKey));
      expect(button.onPressed, isNull);
      expect(bids.placed, isEmpty);
    });

    testWidgets('what the user typed survives someone else bidding', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      await tester.enterText(find.byKey(bidAmountFieldKey), '40000');
      await tester.pumpAndSettle();

      bids.push(auction: _auction(highestBidMyr: 32000, bidCount: 1));
      await tester.pumpAndSettle();

      expect(
        _fieldText(tester),
        '40000',
        reason: 'the minimum changed but the typed amount must stay',
      );
      expect(find.text('RM 32,500'), findsOneWidget);
    });

    testWidgets('an untouched prefill follows the minimum as it moves', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);
      expect(_fieldText(tester), '30000');

      bids.push(auction: _auction(highestBidMyr: 32000, bidCount: 1));
      await tester.pumpAndSettle();

      expect(_fieldText(tester), '32500');
    });
  });

  group('after placing a bid', () {
    testWidgets('shows the leading state instead of a fresh form', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      await tester.tap(find.byKey(placeBidButtonKey));
      await tester.pumpAndSettle();

      expect(bids.placed, [30000]);
      expect(find.textContaining('highest bidder at RM 30,000'), findsWidgets);
      expect(find.byKey(bidAmountFieldKey), findsNothing);
      expect(find.byKey(raiseBidButtonKey), findsOneWidget);
    });

    testWidgets('raise my bid reopens the form above the current highest', (
      tester,
    ) async {
      final bids = _FakeBids(
        auction: _auction(highestBidMyr: 30000, bidCount: 1),
        bids: [_bid(30000)],
      );
      addTearDown(bids.close);
      await _pump(tester, bids);

      await tester.tap(find.byKey(raiseBidButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Raise your bid'), findsOneWidget);
      expect(_fieldText(tester), '30500');
      expect(find.text('Keep my current bid'), findsOneWidget);
    });
  });

  group('when the two streams disagree', () {
    // watchAuction settles before it fetches and watchBidsForAuction does not,
    // so after place_bid the bid row lands a round trip ahead of the auction
    // row. For that moment the screen holds a bid with no highest bid reported
    // — the state that used to throw on `highestBidMyr!` and flash the red
    // ErrorWidget. _FakeBids reproduces it because push(bids:) re-emits the
    // auction it already has.
    testWidgets('a bid arriving before the auction row does not crash', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      bids.push(bids: [_bid(30000)]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('reads as leading, not as outbid', (tester) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      bids.push(bids: [_bid(30000)]);
      await tester.pumpAndSettle();

      // place_bid only accepts a bid that beats the current highest, so a bid
      // of mine with nothing higher reported is winning — claiming otherwise
      // would flash a false "you've been outbid" on the way to the truth.
      expect(find.textContaining('highest bidder at RM 30,000'), findsWidgets);
      expect(find.textContaining('You’ve been outbid'), findsNothing);
    });
  });

  group('after being outbid', () {
    testWidgets('says so and offers the form again', (tester) async {
      final bids = _FakeBids(
        auction: _auction(highestBidMyr: 33000, bidCount: 2),
        bids: [_bid(30000)],
      );
      addTearDown(bids.close);
      await _pump(tester, bids);

      expect(find.textContaining('You’ve been outbid'), findsOneWidget);
      expect(find.text('Raise your bid'), findsOneWidget);
      expect(_fieldText(tester), '33500');
    });
  });

  group('seller', () {
    testWidgets('sees every bid and no bid form', (tester) async {
      final bids = _FakeBids(
        auction: _auction(highestBidMyr: 33000, bidCount: 2),
        bids: [_bid(33000), _bid(30000)],
      );
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      expect(find.text('This is your auction'), findsOneWidget);
      expect(find.text('BIDS SO FAR'), findsOneWidget);
      expect(find.text('RM 33,000'), findsWidgets);
      expect(find.byKey(bidAmountFieldKey), findsNothing);
      final cancel = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Cancel auction'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(
        cancel.onPressed,
        isNotNull,
        reason: 'the seller may cancel at any time, bids or not',
      );
    });

    testWidgets('a finished auction offers Delete auction', (tester) async {
      final bids = _FakeBids(
        auction: _auction(
          highestBidMyr: 33000,
          bidCount: 2,
          status: AuctionStatus.settled,
        ),
      );
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      expect(find.byKey(extendAuctionButtonKey), findsNothing);

      await tester.tap(find.byKey(deleteAuctionButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('Delete this auction?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(bids.deletedAuctions, ['a1']);
    });

    testWidgets('a live auction has no Delete button', (tester) async {
      final bids = _FakeBids(
        auction: _auction(highestBidMyr: 33000, bidCount: 2),
      );
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      expect(find.byKey(deleteAuctionButtonKey), findsNothing);
    });
  });

  group('offline', () {
    // The cache can keep an auction on screen, but the price and the clock it
    // shows are a snapshot. place_bid re-validates against the live highest
    // bid, so a bid composed against that snapshot is one the server would
    // refuse — better to withhold the button and say why.
    testWidgets('says the data is stale and will not take a bid', (
      tester,
    ) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      expect(find.textContaining('You’re offline'), findsNothing);
      expect(_buttonEnabled(tester, placeBidButtonKey), isTrue);

      bids.syncStatus.value = BidsSyncStatus(
        online: false,
        lastSyncedAt: DateTime.now().toUtc().subtract(
          const Duration(minutes: 5),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('You’re offline'), findsOneWidget);
      expect(find.textContaining('Last updated 5m'), findsOneWidget);
      expect(_buttonEnabled(tester, placeBidButtonKey), isFalse);
    });

    testWidgets('a seller cannot extend or cancel either', (tester) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      expect(_buttonEnabled(tester, extendAuctionButtonKey), isTrue);

      bids.syncStatus.value = const BidsSyncStatus(online: false);
      await tester.pumpAndSettle();

      expect(_buttonEnabled(tester, extendAuctionButtonKey), isFalse);
      // No lastSyncedAt: this session never reached the server at all.
      expect(find.textContaining('Showing saved auctions'), findsOneWidget);
    });

    testWidgets('coming back online restores the page', (tester) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      bids.syncStatus.value = const BidsSyncStatus(online: false);
      await tester.pumpAndSettle();
      bids.syncStatus.value = BidsSyncStatus(
        online: true,
        lastSyncedAt: DateTime.now().toUtc(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('You’re offline'), findsNothing);
      expect(_buttonEnabled(tester, placeBidButtonKey), isTrue);
    });
  });

  group('extending', () {
    testWidgets('picking an amount pushes the deadline back by it', (
      tester,
    ) async {
      final auction = _auction(highestBidMyr: 33000, bidCount: 2);
      final bids = _FakeBids(auction: auction);
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      await tester.tap(find.byKey(extendAuctionButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('Add how much time?'), findsOneWidget);

      await tester.tap(find.textContaining('+1 day'));
      await tester.pumpAndSettle();

      expect(bids.extendedTo, [auction.endsAt.add(const Duration(days: 1))]);
      expect(find.textContaining('Time updated to'), findsOneWidget);
      expect(find.textContaining('successfully'), findsOneWidget);
    });

    testWidgets('backing out of the sheet changes nothing', (tester) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      await tester.tap(find.byKey(extendAuctionButtonKey));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(bids.extendedTo, isEmpty);
    });

    testWidgets('an auction already running the full 7 days cannot move', (
      tester,
    ) async {
      final bids = _FakeBids(
        auction: _auction(runsFor: const Duration(days: 7)),
      );
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      final button = tester.widget<FilledButton>(
        find.byKey(extendAuctionButtonKey),
      );
      expect(button.onPressed, isNull);
      expect(
        find.textContaining('already running the full 7 days'),
        findsOneWidget,
      );
    });

    testWidgets('a refusal by rule says which rule', (tester) async {
      final bids = _FakeBids(auction: _auction())
        ..extendResult = const Err('This auction has already ended.');
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      await tester.tap(find.byKey(extendAuctionButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('+1 hour'));
      await tester.pumpAndSettle();

      expect(bids.extendedTo, isEmpty);
      expect(find.textContaining('Failed to extend or update'), findsOneWidget);
      expect(find.textContaining('already ended'), findsOneWidget);
    });

    testWidgets('a generic failure does not apologise twice', (tester) async {
      // Exactly what the device saw while extend_auction was undeployed.
      final bids = _FakeBids(auction: _auction())
        ..extendResult = const Err(
          'Something went wrong saving that. Please try again.',
        );
      addTearDown(bids.close);
      await _pump(tester, bids, as: _seller);

      await tester.tap(find.byKey(extendAuctionButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('+1 hour'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Failed to extend or update the time duration for this bidding.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('went wrong'), findsNothing);
    });

    testWidgets('a buyer is never offered it', (tester) async {
      final bids = _FakeBids(auction: _auction());
      addTearDown(bids.close);
      await _pump(tester, bids);

      expect(find.byKey(extendAuctionButtonKey), findsNothing);
    });
  });
}
