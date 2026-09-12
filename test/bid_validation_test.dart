import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/bid_validation.dart';

final _now = DateTime.utc(2026, 9, 5, 12);

Auction _auction({
  Duration runsFor = const Duration(hours: 2),
  AuctionStatus status = AuctionStatus.running,
}) => Auction(
  id: 'a1',
  listingId: 'l1',
  sellerId: 's1',
  startingPriceMyr: 30000,
  minIncrementMyr: 500,
  endsAt: _now.add(runsFor),
  status: status,
  createdAt: _now,
);

void main() {
  group('parseBidAmount', () {
    test('accepts plain digits', () {
      expect(parseBidAmount('45000'), 45000);
    });

    test('tolerates formatting the user pasted in', () {
      expect(parseBidAmount('RM 45,000'), 45000);
      expect(parseBidAmount('45 000'), 45000);
      expect(parseBidAmount('  45000  '), 45000);
    });

    test('rejects anything that is not a positive amount', () {
      expect(parseBidAmount(''), isNull);
      expect(parseBidAmount('   '), isNull);
      expect(parseBidAmount('abc'), isNull);
      expect(parseBidAmount('RM'), isNull);
      expect(parseBidAmount('0'), isNull);
    });
  });

  group('validateBidAmount', () {
    test('accepts the minimum exactly and anything above it', () {
      expect(validateBidAmount('50000', minimumMyr: 50000), isNull);
      expect(validateBidAmount('51000', minimumMyr: 50000), isNull);
    });

    test('refuses a bid below the minimum next bid', () {
      final error = validateBidAmount('49999', minimumMyr: 50000);
      expect(error, isNotNull);
      expect(error, contains('RM 50,000'));
    });

    test('refuses empty and unparseable input', () {
      expect(validateBidAmount('', minimumMyr: 1000), isNotNull);
      expect(validateBidAmount('abc', minimumMyr: 1000), isNotNull);
    });

    test('every message is a plain sentence with no exception text', () {
      for (final raw in ['', 'abc', '10', '999999999999']) {
        final message = validateBidAmount(raw, minimumMyr: 1000);
        expect(message, isNotNull);
        expect(message, endsWith('.'));
        expect(message, isNot(contains('Exception')));
      }
    });
  });

  group('auction setup validation', () {
    test('a sensible starting price and increment pass', () {
      expect(validateStartingPrice('30000'), isNull);
      expect(validateIncrement('500'), isNull);
    });

    test('a starting price below the floor is refused', () {
      expect(validateStartingPrice('50'), isNotNull);
      expect(validateStartingPrice(''), isNotNull);
    });

    test('an increment below the floor is refused', () {
      expect(validateIncrement('10'), isNotNull);
      expect(validateIncrement(''), isNotNull);
    });
  });

  group('auction durations', () {
    test('every preset is positive and labelled', () {
      for (final d in kAuctionDurations) {
        expect(d.inMinutes, greaterThan(0));
        expect(auctionDurationLabel(d), isNotEmpty);
      }
    });

    test('the presets match the set the database allows', () {
      expect(kAuctionDurations.map((d) => d.inMinutes).toList(), [
        60,
        360,
        720,
        1440,
        4320,
        10080,
      ]);
    });

    test('labels read naturally in hours and days', () {
      expect(auctionDurationLabel(const Duration(hours: 1)), '1 hour');
      expect(auctionDurationLabel(const Duration(hours: 6)), '6 hours');
      expect(auctionDurationLabel(const Duration(days: 1)), '1 day');
      expect(auctionDurationLabel(const Duration(days: 7)), '7 days');
    });
  });

  group('formatCountdown', () {
    test('counts down through days, hours and minutes', () {
      expect(formatCountdown(const Duration(days: 2, hours: 3)), '2d 3h left');
      expect(
        formatCountdown(const Duration(hours: 5, minutes: 20)),
        '5h 20m left',
      );
      expect(formatCountdown(const Duration(minutes: 9)), '9m left');
    });

    test('handles the last seconds and a passed deadline', () {
      expect(formatCountdown(const Duration(seconds: 30)), 'Ending now');
      expect(formatCountdown(Duration.zero), 'Ended');
      expect(formatCountdown(const Duration(seconds: -5)), 'Ended');
    });
  });

  group('extending an auction', () {
    test('headroom is what is left of the 7-day run', () {
      expect(
        extensionHeadroom(_auction(runsFor: const Duration(days: 2))),
        const Duration(days: 5),
      );
      expect(
        extensionHeadroom(_auction(runsFor: kMaxAuctionRun)),
        Duration.zero,
      );
    });

    test('headroom never goes negative past the cap', () {
      final over = _auction(runsFor: const Duration(days: 9));
      expect(extensionHeadroom(over), Duration.zero);
    });

    test('only the extensions that fit are offered', () {
      expect(extensionOptions(_auction()), kAuctionExtensions);
      expect(
        extensionOptions(_auction(runsFor: const Duration(days: 6, hours: 12))),
        const [Duration(hours: 1), Duration(hours: 6), Duration(hours: 12)],
      );
      expect(extensionOptions(_auction(runsFor: kMaxAuctionRun)), isEmpty);
    });

    test('only the seller of a live auction with room left may extend', () {
      expect(canExtendAuction(_auction(), 's1', now: _now), isTrue);
      expect(canExtendAuction(_auction(), 'someone-else', now: _now), isFalse);
      expect(
        canExtendAuction(_auction(runsFor: kMaxAuctionRun), 's1', now: _now),
        isFalse,
        reason: 'already running the longest an auction may run',
      );
      expect(
        canExtendAuction(
          _auction(status: AuctionStatus.cancelled),
          's1',
          now: _now,
        ),
        isFalse,
      );
      expect(
        canExtendAuction(
          _auction(runsFor: const Duration(hours: -1)),
          's1',
          now: _now,
        ),
        isFalse,
        reason: 'the clock ran out, even though it still reads running',
      );
    });

    test('labels read as an addition', () {
      expect(auctionExtensionLabel(const Duration(hours: 1)), '+1 hour');
      expect(auctionExtensionLabel(const Duration(days: 3)), '+3 days');
    });
  });
}
