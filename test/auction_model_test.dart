import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/listing/listing_enums.dart';

final _now = DateTime.utc(2026, 9, 5, 12);

Auction auction({
  int startingPriceMyr = 30000,
  int minIncrementMyr = 500,
  int? highestBidMyr,
  int bidCount = 0,
  AuctionStatus status = AuctionStatus.running,
  DateTime? endsAt,
}) => Auction(
  id: 'a1',
  listingId: 'l1',
  sellerId: 's1',
  startingPriceMyr: startingPriceMyr,
  minIncrementMyr: minIncrementMyr,
  endsAt: endsAt ?? _now.add(const Duration(hours: 2)),
  status: status,
  highestBidMyr: highestBidMyr,
  bidCount: bidCount,
  createdAt: _now,
);

void main() {
  group('Auction JSON', () {
    test('round-trips with every field set', () {
      final a = auction(highestBidMyr: 32000, bidCount: 4).copyWith(
        winningBidId: 'b9',
        settledAt: _now,
        status: AuctionStatus.settled,
      );
      final json = a.toJson();
      expect(json['listing_id'], 'l1');
      expect(json['starting_price_myr'], 30000);
      expect(json['min_increment_myr'], 500);
      expect(json['highest_bid_myr'], 32000);
      expect(json['bid_count'], 4);
      expect(json['status'], 'settled');
      expect(Auction.fromJson(json), a);
    });

    test('a fresh auction has no highest bid and no count', () {
      final a = Auction.fromJson({
        'id': 'a1',
        'listing_id': 'l1',
        'seller_id': 's1',
        'starting_price_myr': 30000,
        'min_increment_myr': 500,
        'ends_at': '2026-09-05T14:00:00.000Z',
        'created_at': '2026-09-05T12:00:00.000Z',
      });
      expect(a.highestBidMyr, isNull);
      expect(a.bidCount, 0);
      expect(a.status, AuctionStatus.running);
    });
  });

  group('minimumNextBidMyr', () {
    test('the first bid has to reach the starting price', () {
      expect(auction().minimumNextBidMyr, 30000);
    });

    test('later bids have to clear the highest by the increment', () {
      expect(auction(highestBidMyr: 30000).minimumNextBidMyr, 30500);
      expect(
        auction(highestBidMyr: 41000, minIncrementMyr: 1000).minimumNextBidMyr,
        42000,
      );
    });
  });

  group('lifecycle', () {
    test('is live while running and before the deadline', () {
      expect(auction().isLive(now: _now), isTrue);
      expect(auction().hasEnded(now: _now), isFalse);
    });

    test('the deadline passing ends it even while still marked running', () {
      final a = auction(endsAt: _now.subtract(const Duration(minutes: 1)));
      expect(a.hasEnded(now: _now), isTrue);
      expect(a.isLive(now: _now), isFalse);
      expect(a.status, AuctionStatus.running);
    });

    test('a settled auction is never live', () {
      expect(auction(status: AuctionStatus.settled).isLive(now: _now), isFalse);
    });

    test('remaining never goes negative', () {
      final a = auction(endsAt: _now.subtract(const Duration(hours: 3)));
      expect(a.remaining(now: _now), Duration.zero);
      expect(auction().remaining(now: _now), const Duration(hours: 2));
    });
  });

  group('canCancel', () {
    test('the seller may cancel only before the first bid', () {
      expect(auction().canCancel('s1', now: _now), isTrue);
      expect(
        auction(bidCount: 1, highestBidMyr: 30000).canCancel('s1', now: _now),
        isFalse,
      );
    });

    test('nobody else may cancel', () {
      expect(auction().canCancel('someone-else', now: _now), isFalse);
    });

    test('an ended auction cannot be cancelled', () {
      final a = auction(endsAt: _now.subtract(const Duration(minutes: 1)));
      expect(a.canCancel('s1', now: _now), isFalse);
    });
  });

  group('listingStatusFromValue', () {
    test('decodes the four current values', () {
      expect(listingStatusFromValue('selling'), ListingStatus.selling);
      expect(listingStatusFromValue('bidding'), ListingStatus.bidding);
      expect(listingStatusFromValue('hidden'), ListingStatus.hidden);
      expect(listingStatusFromValue('sold'), ListingStatus.sold);
    });

    test('maps the pre-0013 names so a stale cache still decodes', () {
      expect(listingStatusFromValue('active'), ListingStatus.selling);
      expect(listingStatusFromValue('draft'), ListingStatus.hidden);
      expect(listingStatusFromValue('deleted'), ListingStatus.hidden);
    });

    test('an unknown value degrades to hidden instead of throwing', () {
      expect(listingStatusFromValue('something_new'), ListingStatus.hidden);
      expect(listingStatusFromValue(null), ListingStatus.hidden);
      expect(listingStatusFromValue(42), ListingStatus.hidden);
    });

    test(
      'every status has a label and buyer visibility is selling+bidding',
      () {
        for (final s in ListingStatus.values) {
          expect(s.label, isNotEmpty);
        }
        expect(ListingStatus.selling.isVisibleToBuyers, isTrue);
        expect(ListingStatus.bidding.isVisibleToBuyers, isTrue);
        expect(ListingStatus.hidden.isVisibleToBuyers, isFalse);
        expect(ListingStatus.sold.isVisibleToBuyers, isFalse);
      },
    );
  });
}
