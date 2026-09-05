import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/bid/bid_validation.dart';

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
}
