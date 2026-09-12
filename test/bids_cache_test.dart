import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/bid/bids_cache_repository.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/listing/listing_media.dart';

final _at = DateTime.utc(2026, 9, 12, 8);

Listing _listing({String id = 'l1', bool withMedia = true}) => Listing(
  id: id,
  sellerId: 'seller-1',
  status: ListingStatus.bidding,
  make: 'Toyota',
  model: 'Hilux',
  variant: withMedia ? 'GRS' : null,
  year: 2026,
  mileageKm: 12000,
  transmission: Transmission.automatic,
  fuelType: FuelType.diesel,
  bodyType: BodyType.pickup,
  colour: 'Black',
  ownersCount: 1,
  accidentFree: true,
  roadTaxExpiry: withMedia ? DateTime.utc(2027, 3, 1) : null,
  registrationRegion: RegistrationRegion.west,
  state: 'Selangor',
  city: 'Shah Alam',
  priceMyr: 160000,
  negotiable: false,
  description: withMedia ? 'One owner.' : null,
  createdAt: _at,
  updatedAt: _at,
  media: withMedia
      ? [
          ListingMedia(
            id: 'm1',
            listingId: id,
            storagePath: 'seller-1/$id/a.jpg',
            position: 0,
            createdAt: _at,
          ),
          ListingMedia(
            id: 'm2',
            listingId: id,
            storagePath: 'seller-1/$id/b.jpg',
            position: 1,
          ),
        ]
      : const [],
);

/// Every nullable populated, so a round-trip has something to lose.
AuctionWithListing _full({String id = 'a1'}) => AuctionWithListing(
  auction: Auction(
    id: id,
    listingId: 'l1',
    sellerId: 'seller-1',
    startingPriceMyr: 160000,
    minIncrementMyr: 500,
    endsAt: DateTime.utc(2026, 9, 13, 8),
    status: AuctionStatus.settled,
    highestBidMyr: 160500,
    bidCount: 1,
    winningBidId: 'b1',
    settledAt: DateTime.utc(2026, 9, 13, 8, 1),
    createdAt: _at,
  ),
  listing: _listing(),
);

/// Every nullable left null, and a listing with no media.
AuctionWithListing _minimal({String id = 'a2'}) => AuctionWithListing(
  auction: Auction(
    id: id,
    listingId: 'l2',
    sellerId: 'seller-1',
    startingPriceMyr: 30000,
    minIncrementMyr: 500,
    endsAt: DateTime.utc(2026, 9, 20, 8),
    createdAt: _at,
  ),
  listing: _listing(id: 'l2', withMedia: false),
);

Bid _bid({String id = 'b1', BidStatus status = BidStatus.placed}) => Bid(
  id: id,
  listingId: 'l1',
  auctionId: 'a1',
  bidderId: 'u1',
  amountMyr: 160500,
  status: status,
  createdAt: _at,
  updatedAt: _at,
);

Map<String, Object?> _row(
  AuctionWithListing entry, {
  String scope = AuctionScope.live,
  String? userId,
  int sortOrder = 0,
}) => auctionToRow(
  entry,
  scope: scope,
  userId: userId,
  sortOrder: sortOrder,
  cachedAt: _at,
);

void main() {
  group('bids cache row mapping', () {
    test('a full auction (nullables set, listing with media) round-trips', () {
      final entry = _full();

      expect(auctionFromRow(_row(entry)), entry);
    });

    test('a minimal auction (nullables null, no media) round-trips', () {
      final entry = _minimal();

      expect(auctionFromRow(_row(entry, sortOrder: 3)), entry);
    });

    test('enums are stored as their names and null stays null', () {
      final full = _row(_full());
      expect(full['status'], 'settled');
      expect(full['highest_bid_myr'], 160500);

      final minimal = _row(_minimal());
      expect(minimal['status'], 'running');
      expect(minimal['highest_bid_myr'], isNull);
      expect(minimal['winning_bid_id'], isNull);
      expect(minimal['settled_at'], isNull);
    });

    test('the embedded listing survives whole, media and order included', () {
      final restored = auctionFromRow(_row(_full())).listing;

      expect(restored.media.map((m) => m.id), ['m1', 'm2']);
      expect(restored.cover?.storagePath, 'seller-1/l1/a.jpg');
      // The bool that listing_cache has to convert by hand is free here: the
      // listing rides as JSON, which has real booleans.
      expect(restored.accidentFree, isTrue);
      expect(restored.negotiable, isFalse);
    });

    test('scope and owner are kept out of the decoded auction', () {
      final row = _row(_full(), scope: AuctionScope.mine, userId: 'u1');
      expect(row['scope'], 'mine');
      expect(row['user_id'], 'u1');

      // They are cache bookkeeping; decoding must not leak them into the model.
      expect(auctionFromRow(row), _full());
    });

    // The suite has no database, so this is what stands between a column
    // rename and a DatabaseException on the first tap of the Bid tab.
    test('a row carries exactly the columns the tables declare', () {
      expect(_row(_full()).keys.toSet(), auctionCacheColumns.toSet());
      expect(_row(_minimal()).keys.toSet(), auctionCacheColumns.toSet());

      final bidRow = bidToRow(
        _bid(),
        scope: BidScope.mine,
        userId: 'u1',
        sortOrder: 0,
        cachedAt: _at,
      );
      expect(bidRow.keys.toSet(), bidCacheColumns.toSet());
    });

    test('decodeCachedAuctions keeps the order the rows came in', () {
      final a = _full();
      final b = _minimal();

      final decoded = decodeCachedAuctions([_row(a), _row(b, sortOrder: 1)]);

      expect(decoded, [a, b]);
    });

    test('a corrupt row decodes to an empty feed, not a crash', () {
      expect(
        decodeCachedAuctions([
          {'id': 'x', 'status': 'running'},
        ]),
        isEmpty,
      );
    });

    test('my bids are rejoined to their auctions, in cached order', () {
      final second = _bid(id: 'b2');
      final joined = joinBidsToAuctions(
        [_bid(), second],
        [_full(), _minimal()],
      );

      expect(joined.map((e) => e.bid.id), ['b1', 'b2']);
      expect(joined.first.auction, _full());
    });

    test('a bid whose auction was never cached is dropped, not half-drawn', () {
      // The card is built almost entirely from the auction, so there would be
      // nothing to render.
      final orphan = Bid(
        id: 'b9',
        listingId: 'l9',
        auctionId: 'gone',
        bidderId: 'u1',
        amountMyr: 500,
        createdAt: _at,
        updatedAt: _at,
      );

      expect(joinBidsToAuctions([orphan], [_full()]), isEmpty);
      expect(joinBidsToAuctions([_bid(), orphan], [_full()]), hasLength(1));
    });

    test('a bid round-trips, and a corrupt one decodes to empty', () {
      final bid = _bid(status: BidStatus.won);
      final row = bidToRow(
        bid,
        scope: BidScope.mine,
        userId: 'u1',
        sortOrder: 0,
        cachedAt: _at,
      );

      expect(row['status'], 'won');
      expect(bidFromRow(row), bid);
      expect(
        decodeCachedBids([
          {'id': 'x'},
        ]),
        isEmpty,
      );
    });
  });
}
