import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/bid/bid.dart';

Bid bid({String id = 'b1', BidStatus status = BidStatus.placed}) => Bid(
  id: id,
  listingId: 'l1',
  auctionId: 'a1',
  bidderId: 'bidder-1',
  amountMyr: 45000,
  status: status,
  createdAt: DateTime.utc(2026, 8, 30, 9),
  updatedAt: DateTime.utc(2026, 8, 30, 10),
);

void main() {
  group('Bid', () {
    test('isMine follows bidder_id', () {
      expect(bid().isMine('bidder-1'), isTrue);
      expect(bid().isMine('someone-else'), isFalse);
    });

    test('round-trips through snake_case JSON', () {
      final json = bid().toJson();
      expect(json['listing_id'], 'l1');
      expect(json['auction_id'], 'a1');
      expect(json['bidder_id'], 'bidder-1');
      expect(json['amount_myr'], 45000);
      expect(json['status'], 'placed');
      expect(Bid.fromJson(json), bid());
    });

    test('a row with no status defaults to placed', () {
      final b = Bid.fromJson({
        'id': 'b1',
        'listing_id': 'l1',
        'auction_id': 'a1',
        'bidder_id': 'u1',
        'amount_myr': 1000,
        'created_at': '2026-08-30T09:00:00.000Z',
        'updated_at': '2026-08-30T09:00:00.000Z',
      });
      expect(b.status, BidStatus.placed);
    });

    test('every status decodes from its Postgres text value', () {
      for (final status in BidStatus.values) {
        final json = bid(status: status).toJson();
        expect(json['status'], status.name);
        expect(Bid.fromJson(json).status, status);
      }
    });
  });

  group('BidStatus', () {
    test('only a placed bid is live', () {
      expect(BidStatus.placed.isLive, isTrue);
      expect(BidStatus.won.isLive, isFalse);
      expect(BidStatus.lost.isLive, isFalse);
    });

    test('every status has a label', () {
      for (final status in BidStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });
  });
}
