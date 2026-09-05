import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/auth/registration_data.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/bid/bid_screen.dart';

final _now = DateTime.utc(2026, 9, 5, 12);

final _user = Profile(
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

class _FakeAuth implements AuthRepository {
  @override
  Profile? get currentUser => _user;

  @override
  Stream<Profile?> authState() => Stream.value(_user);

  @override
  Future<Result<Profile>> signIn({
    required String email,
    required String password,
  }) async => Ok(_user);

  @override
  Future<Result<Profile>> signUp({
    required String email,
    required String password,
    required RegistrationData data,
  }) async => Ok(_user);

  @override
  Future<Result<Profile>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => Ok(_user);

  @override
  Future<Result<Profile>> updateAvatar(String localPath) async => Ok(_user);

  @override
  Future<Result<Profile>> removeAvatar() async => Ok(_user);

  @override
  Future<Result<void>> deleteAccount() async => const Ok(null);

  @override
  Future<void> signOut() async {}
}

/// Hands out single-subscription streams, exactly like the real repository:
/// listening to the same one twice throws "Stream has already been listened
/// to", which is the bug this file pins.
class _FakeBids implements BidsRepository {
  _FakeBids({List<AuctionWithListing>? live, this.myAuctions = const []}) {
    _live = live;
  }

  late final List<AuctionWithListing>? _live;
  List<AuctionWithListing> myAuctions;
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
  Stream<List<BidWithAuction>> watchMyBids() => _single(const []);

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
