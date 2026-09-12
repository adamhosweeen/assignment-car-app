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
import 'package:assignment/views/bid/bid_screen.dart';
import 'package:assignment/widgets/bid/bid_status_badge.dart';

final _now = DateTime.utc(2026, 9, 5, 12);

final _user = AppUser(
  id: 'u1',
  email: 'u1@example.com',
  createdAt: DateTime.utc(2026, 1, 1),
);

final _listing = Listing(
  id: 'l1',
  sellerId: 's1',
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

final _auction = AuctionWithListing(
  auction: Auction(
    id: 'a1',
    listingId: 'l1',
    sellerId: 's1',
    startingPriceMyr: 30000,
    minIncrementMyr: 500,
    endsAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
    createdAt: _now,
  ),
  listing: _listing,
);

/// One of [_user]'s bids on an auction that has finished the given way. The bid
/// row is `lost` either way — that is what cancel_auction and settlement both
/// write — so only the auction's status separates a withdrawal from a defeat.
BidWithAuction _myBid(AuctionStatus status) => BidWithAuction(
  bid: Bid(
    id: 'b1',
    listingId: 'l1',
    auctionId: 'a1',
    bidderId: _user.id,
    amountMyr: 30000,
    status: BidStatus.lost,
    createdAt: _now,
    updatedAt: _now,
  ),
  auction: AuctionWithListing(
    auction: _auction.auction.copyWith(
      status: status,
      settledAt: _now,
      // Cancelled: mine was the top bid when the seller pulled it. Settled:
      // someone else went higher, which is a real loss.
      highestBidMyr: status == AuctionStatus.cancelled ? 30000 : 35000,
      bidCount: 1,
    ),
    listing: _listing,
  ),
);

class _FakeAuth implements AuthRepository {
  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authState() => Stream.value(_user);

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async => Ok(_user);

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
  }) async => Ok(_user);

  @override
  Future<Result<AppUser>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => Ok(_user);

  @override
  Future<Result<AppUser>> updateAvatar(String localPath) async => Ok(_user);

  @override
  Future<Result<AppUser>> removeAvatar() async => Ok(_user);

  @override
  Future<Result<void>> deleteAccount() async => const Ok(null);

  @override
  Future<void> signOut() async {}
}

/// Hands out single-subscription streams, exactly like the real repository:
/// listening to the same one twice throws "Stream has already been listened
/// to", which is the bug this file pins.
class _FakeBids implements BidsRepository {
  /// Settable so a test can put the screen offline without a network.
  @override
  final ValueNotifier<BidsSyncStatus> syncStatus = ValueNotifier(
    const BidsSyncStatus.unknown(),
  );

  _FakeBids({
    List<AuctionWithListing>? live,
    this.myAuctions = const [],
    this.myBids = const [],
  }) {
    _live = live;
  }

  late final List<AuctionWithListing>? _live;
  List<AuctionWithListing> myAuctions;
  List<BidWithAuction> myBids;
  final List<String> deletedAuctions = [];
  final _myAuctionsCtrl =
      StreamController<List<AuctionWithListing>>.broadcast();
  int liveOpened = 0;

  Stream<T> _single<T>(T value) {
    late StreamController<T> c;
    c = StreamController<T>(onListen: () => c.add(value));
    return c.stream;
  }

  @override
  Stream<List<AuctionWithListing>> watchLiveAuctions() {
    liveOpened++;
    return _single(_live ?? [_auction]);
  }

  @override
  Stream<List<BidWithAuction>> watchMyBids() => _single(myBids);

  @override
  Stream<List<AuctionWithListing>> watchMyAuctions() async* {
    yield myAuctions;
    yield* _myAuctionsCtrl.stream;
  }

  @override
  Future<Result<void>> deleteAuction(String auctionId) async {
    deletedAuctions.add(auctionId);
    myAuctions = [
      for (final a in myAuctions)
        if (a.auction.id != auctionId) a,
    ];
    _myAuctionsCtrl.add(myAuctions);
    return const Ok(null);
  }

  @override
  Stream<AuctionWithListing> watchAuction(String auctionId) =>
      _single(_auction);

  @override
  Stream<List<Bid>> watchBidsForAuction(String auctionId) => _single(const []);

  @override
  Future<Result<String>> startAuction({
    required String listingId,
    required int startingPriceMyr,
    required int minIncrementMyr,
    required DateTime endsAt,
  }) async => const Ok('a1');

  @override
  Future<Result<void>> placeBid(String auctionId, int amountMyr) async =>
      const Ok(null);

  @override
  Future<Result<void>> cancelAuction(String auctionId) async => const Ok(null);

  @override
  Future<Result<void>> extendAuction(String auctionId, DateTime endsAt) async =>
      const Ok(null);

  @override
  Future<Result<String?>> latestAuctionIdForListing(String listingId) async =>
      const Ok(null);
}

Widget _app(_FakeBids bids) => MultiProvider(
  providers: [
    Provider<AuthRepository>.value(value: _FakeAuth()),
    Provider<BidsRepository>.value(value: bids),
  ],
  child: MaterialApp(theme: AppTheme.light, home: const BidScreen()),
);

void main() {
  testWidgets('switching segments and back does not re-listen to a stream', (
    tester,
  ) async {
    final bids = _FakeBids();
    await tester.pumpWidget(_app(bids));
    await tester.pumpAndSettle();

    expect(find.text('2020 Perodua Myvi'), findsOneWidget);

    await tester.tap(find.text('My bids'));
    await tester.pumpAndSettle();
    expect(find.text('No bids yet'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('2020 Perodua Myvi'), findsOneWidget);
    expect(
      bids.liveOpened,
      1,
      reason: 'the live stream is subscribed once and kept alive',
    );
  });

  testWidgets('a finished auction can be swiped away from My auctions', (
    tester,
  ) async {
    final ended = AuctionWithListing(
      auction: _auction.auction.copyWith(
        status: AuctionStatus.settled,
        highestBidMyr: 31000,
        bidCount: 1,
      ),
      listing: _listing,
    );
    final bids = _FakeBids(live: const [], myAuctions: [ended]);
    await tester.pumpWidget(_app(bids));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My auctions'));
    await tester.pumpAndSettle();
    expect(find.text('2020 Perodua Myvi'), findsOneWidget);
    expect(find.textContaining('Swipe left'), findsOneWidget);

    await tester.drag(find.text('2020 Perodua Myvi'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(bids.deletedAuctions, ['a1']);
    expect(find.text('2020 Perodua Myvi'), findsNothing);
  });

  testWidgets('a live auction cannot be swiped away', (tester) async {
    final bids = _FakeBids(live: const [], myAuctions: [_auction]);
    await tester.pumpWidget(_app(bids));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My auctions'));
    await tester.pumpAndSettle();

    await tester.drag(find.text('2020 Perodua Myvi'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(bids.deletedAuctions, isEmpty);
    expect(find.text('2020 Perodua Myvi'), findsOneWidget);
  });

  group('a bid on a cancelled auction', () {
    // cancel_auction writes `lost` on the row so the bid stops counting as
    // live, but the seller withdrawing is not the bidder losing — nobody
    // outbid them. "Cancelled" is the whole story.
    testWidgets('shows no outcome badge, only Cancelled', (tester) async {
      final bids = _FakeBids(myBids: [_myBid(AuctionStatus.cancelled)]);
      await tester.pumpWidget(_app(bids));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My bids'));
      await tester.pumpAndSettle();

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Lost'), findsNothing);
      expect(find.byType(BidStatusBadge), findsNothing);
    });

    testWidgets('still says what was bid', (tester) async {
      final bids = _FakeBids(myBids: [_myBid(AuctionStatus.cancelled)]);
      await tester.pumpWidget(_app(bids));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My bids'));
      await tester.pumpAndSettle();

      expect(find.textContaining('You bid RM 30,000'), findsOneWidget);
      expect(find.textContaining('leading'), findsNothing);
    });
  });

  testWidgets('a genuine loss still shows the Lost badge', (tester) async {
    // The guard is on cancellation alone — an auction that ran its course and
    // was won by someone else must still tell the bidder they lost.
    final bids = _FakeBids(myBids: [_myBid(AuctionStatus.settled)]);
    await tester.pumpWidget(_app(bids));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My bids'));
    await tester.pumpAndSettle();

    expect(find.text('Lost'), findsOneWidget);
  });

  testWidgets('every segment renders its empty state', (tester) async {
    final bids = _FakeBids();
    await tester.pumpWidget(_app(bids));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My auctions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('haven’t run an auction'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
