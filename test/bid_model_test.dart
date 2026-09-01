import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/bid/bid.dart';

void main() {
  Bid bid({
    BidStatus status = BidStatus.pending,
    String bidderId = 'bidder',
    int amountMyr = 45000,
  }) => Bid(
    id: 'b1',
    listingId: 'l1',
    bidderId: bidderId,
    amountMyr: amountMyr,
    status: status,
    contactPhone: '0111234567',
    createdAt: DateTime.utc(2026, 8, 30, 9),
    updatedAt: DateTime.utc(2026, 8, 30, 9),
  );

  group('Bid', () {
    test('isMine follows bidder_id', () {
      expect(bid().isMine('bidder'), isTrue);
      expect(bid().isMine('seller'), isFalse);
    });

    test('round-trips through JSON with snake_case column names', () {
      final json = bid().toJson();
      expect(json['listing_id'], 'l1');
      expect(json['bidder_id'], 'bidder');
      expect(json['amount_myr'], 45000);
      expect(json['status'], 'pending');
      expect(json['contact_phone'], '0111234567');
      expect(json['notify_whatsapp'], isFalse);
      expect(Bid.fromJson(json), bid());
    });

    test(
      'defaults a row with no status or opt-in to pending, not opted in',
      () {
        final decoded = Bid.fromJson({
          'id': 'b2',
          'listing_id': 'l1',
          'bidder_id': 'bidder',
          'amount_myr': 30000,
          'created_at': '2026-08-30T09:00:00.000Z',
          'updated_at': '2026-08-30T09:00:00.000Z',
        });
        expect(decoded.status, BidStatus.pending);
        expect(decoded.notifyWhatsapp, isFalse);
        expect(decoded.contactPhone, isNull);
      },
    );

    test('every status decodes from its Postgres text value', () {
      for (final status in BidStatus.values) {
        final json = bid(status: status).toJson();
        expect(json['status'], status.name);
        expect(Bid.fromJson(json).status, status);
      }
    });
  });

  group('BidStatus', () {
    test('only pending is live — the others are terminal', () {
      expect(BidStatus.pending.isLive, isTrue);
      expect(BidStatus.accepted.isLive, isFalse);
      expect(BidStatus.rejected.isLive, isFalse);
      expect(BidStatus.withdrawn.isLive, isFalse);
    });

    test('every status has a display label', () {
      for (final status in BidStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });
  });
}
