import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/bid/bids_cache_repository.dart';
import 'package:assignment/control/listings/listings_cache_repository.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';

import 'listings_cache_test.dart' show fullListing, minimalListing;

Bid sampleBid({
  String id = 'b1',
  String listingId = 'l1',
  BidStatus status = BidStatus.pending,
  bool notifyWhatsapp = true,
  String? contactPhone = '0111234567',
}) => Bid(
  id: id,
  listingId: listingId,
  bidderId: 'bidder-1',
  amountMyr: 45000,
  status: status,
  contactPhone: contactPhone,
  notifyWhatsapp: notifyWhatsapp,
  createdAt: DateTime.utc(2026, 8, 30, 9),
  updatedAt: DateTime.utc(2026, 8, 30, 10),
);

void main() {
  group('bid cache row mapping', () {
    test('a bid round-trips through a cache row', () {
      final bid = sampleBid();
      expect(bidFromRow(bidToRow(bid, BidSide.mine, 0)), bid);
    });

    test('a bid with nullables unset round-trips', () {
      final bid = sampleBid(contactPhone: null, notifyWhatsapp: false);
      expect(bidFromRow(bidToRow(bid, BidSide.received, 2)), bid);
    });

    test('the bool is stored as a SQLite integer', () {
      expect(bidToRow(sampleBid(), BidSide.mine, 0)['notify_whatsapp'], 1);
      expect(
        bidToRow(
          sampleBid(notifyWhatsapp: false),
          BidSide.mine,
          0,
        )['notify_whatsapp'],
        0,
      );
    });

    test('the row carries which list it belongs to and its position', () {
      final row = bidToRow(sampleBid(), BidSide.received, 4);
      expect(row['side'], 'received');
      expect(row['sort_order'], 4);
    });

    test('side and sort_order are stripped back off when decoding', () {
      final decoded = bidFromRow(bidToRow(sampleBid(), BidSide.mine, 7));
      expect(decoded.id, 'b1');
    });
  });

  group('decodeCachedBids', () {
    test('joins each bid to its car and preserves list order', () {
      final carA = fullListing(id: 'l1');
      final carB = minimalListing(id: 'l2');
      final bidA = sampleBid(id: 'b1', listingId: 'l1');
      final bidB = sampleBid(id: 'b2', listingId: 'l2');

      final decoded = decodeCachedBids(
        [bidToRow(bidA, BidSide.mine, 0), bidToRow(bidB, BidSide.mine, 1)],
        [listingToRow(carA, 0), listingToRow(carB, 0)],
        carA.media.map((m) => m.toJson()).toList(),
      );

      expect(decoded, [
        BidWithListing(bid: bidA, listing: carA),
        BidWithListing(bid: bidB, listing: carB),
      ]);
    });

    test('drops a bid whose car snapshot is missing rather than crashing', () {
      final decoded = decodeCachedBids(
        [bidToRow(sampleBid(listingId: 'gone'), BidSide.mine, 0)],
        const [],
        const [],
      );
      expect(decoded, isEmpty);
    });

    test('a corrupt cache decodes to an empty list, not a crash', () {
      final decoded = decodeCachedBids(
        [
          {'id': 'x', 'listing_id': 'l1', 'notify_whatsapp': 0},
        ],
        [listingToRow(fullListing(id: 'l1'), 0)],
        const [],
      );
      expect(decoded, isEmpty);
    });
  });

  group('BidWithListing', () {
    test('differenceMyr is negative below asking and positive above', () {
      final car = fullListing(id: 'l1');
      expect(
        BidWithListing(bid: sampleBid(), listing: car).differenceMyr,
        45000 - 62000,
      );
    });
  });
}
