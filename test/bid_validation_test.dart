import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/bid/bid_validation.dart';

void main() {
  const asking = 48800;

  group('parseBidAmount', () {
    test('accepts plain digits', () {
      expect(parseBidAmount('45000'), 45000);
    });

    test('tolerates the separators and prefix people paste in', () {
      expect(parseBidAmount('RM 45,000'), 45000);
      expect(parseBidAmount('45 000'), 45000);
      expect(parseBidAmount(' 45,000 '), 45000);
    });

    test('rejects empty, non-numeric, and zero input', () {
      expect(parseBidAmount(''), isNull);
      expect(parseBidAmount('   '), isNull);
      expect(parseBidAmount('abc'), isNull);
      expect(parseBidAmount('RM'), isNull);
      expect(parseBidAmount('0'), isNull);
    });
  });

  group('validateBidAmount', () {
    test('accepts a sensible bid below asking', () {
      expect(validateBidAmount('45000', askingPriceMyr: asking), isNull);
    });

    test('accepts a bid above asking — that is what a bidding war is', () {
      expect(validateBidAmount('52000', askingPriceMyr: asking), isNull);
    });

    test('requires an amount', () {
      expect(validateBidAmount('', askingPriceMyr: asking), isNotNull);
    });

    test('rejects a non-numeric amount', () {
      expect(validateBidAmount('abc', askingPriceMyr: asking), isNotNull);
    });

    test('rejects a dropped digit as far below asking', () {
      expect(validateBidAmount('4500', askingPriceMyr: asking), isNotNull);
    });

    test('rejects an added digit as far above asking', () {
      expect(validateBidAmount('450000', askingPriceMyr: asking), isNotNull);
    });

    test('rejects an amount under the absolute floor', () {
      expect(validateBidAmount('50', askingPriceMyr: 200), isNotNull);
    });

    test('accepts the exact asking price', () {
      expect(validateBidAmount('48800', askingPriceMyr: asking), isNull);
    });

    test('accepts the boundaries of the asking-price window', () {
      expect(validateBidAmount('4880', askingPriceMyr: asking), isNull);
      expect(validateBidAmount('146400', askingPriceMyr: asking), isNull);
    });

    test('every rejection is a plain sentence, not an exception dump', () {
      final message = validateBidAmount('1', askingPriceMyr: asking);
      expect(message, isNotNull);
      expect(message, endsWith('.'));
      expect(message, isNot(contains('Exception')));
    });
  });

  group('validateBidPhone', () {
    test(
      'accepts Malaysian mobile numbers with and without the leading zero',
      () {
        expect(validateBidPhone('0111234567'), isNull);
        expect(validateBidPhone('111234567'), isNull);
        expect(validateBidPhone('01116689921'), isNull);
      },
    );

    test('requires a number', () {
      expect(validateBidPhone(''), isNotNull);
      expect(validateBidPhone('   '), isNotNull);
    });

    test('rejects a landline, a too-short number, and letters', () {
      expect(validateBidPhone('0312345678'), isNotNull);
      expect(validateBidPhone('0111'), isNotNull);
      expect(validateBidPhone('not a phone'), isNotNull);
    });
  });

  group('bidAmountHint', () {
    test('names the gap below asking', () {
      expect(
        bidAmountHint(45000, askingPriceMyr: asking),
        contains('below the asking price'),
      );
    });

    test('names the gap above asking', () {
      expect(
        bidAmountHint(52000, askingPriceMyr: asking),
        contains('above the asking price'),
      );
    });

    test('calls out an exact match', () {
      expect(
        bidAmountHint(asking, askingPriceMyr: asking),
        'Same as the asking price.',
      );
    });
  });
}
