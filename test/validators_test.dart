import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/validators.dart';

void main() {
  group('isValidEmail', () {
    test('accepts a normal address', () {
      expect(isValidEmail('aiman@example.com'), isTrue);
    });

    test('trims surrounding whitespace', () {
      expect(isValidEmail('  aiman@example.com  '), isTrue);
    });

    test('rejects missing @, missing domain dot, and spaces', () {
      expect(isValidEmail('aiman.example.com'), isFalse);
      expect(isValidEmail('aiman@example'), isFalse);
      expect(isValidEmail('ai man@example.com'), isFalse);
      expect(isValidEmail(''), isFalse);
    });
  });

  group('isValidPassword', () {
    test('requires 8+ chars with a letter and a digit', () {
      expect(isValidPassword('abcd1234'), isTrue);
      expect(isValidPassword('abc123'), isFalse); // too short
      expect(isValidPassword('abcdefgh'), isFalse); // no digit
      expect(isValidPassword('12345678'), isFalse); // no letter
    });

    test('passwordStrength tiers agree with isValidPassword', () {
      expect(passwordStrength(''), 0);
      expect(passwordStrength('abc'), 1); // some rules → weak
      expect(passwordStrength('abcd1234'), 2); // all rules → okay
      expect(passwordStrength('abcdefgh1234'), 2); // long but plain
      expect(passwordStrength('abcdefgh123!'), 3); // long + symbol
      expect(passwordStrength('Abcdefgh1234'), 3); // long + mixed case
      for (final p in ['abc', 'abcd1234', 'Abcdefgh1234']) {
        expect(passwordStrength(p) >= 2, isValidPassword(p));
      }
    });

    test('rule helpers', () {
      expect(hasMinLength('1234567'), isFalse);
      expect(hasMinLength('12345678'), isTrue);
      expect(hasLetter('1234'), isFalse);
      expect(hasLetter('12a4'), isTrue);
      expect(hasDigit('abcd'), isFalse);
      expect(hasDigit('ab3d'), isTrue);
    });
  });

  group('isAtLeast18', () {
    final now = DateTime(2026, 8, 29);

    test('18th birthday is today — allowed', () {
      expect(isAtLeast18(DateTime(2008, 8, 29), now: now), isTrue);
    });

    test('18th birthday is tomorrow — blocked', () {
      expect(isAtLeast18(DateTime(2008, 8, 30), now: now), isFalse);
    });

    test('clearly adult and clearly underage', () {
      expect(isAtLeast18(DateTime(1990, 1, 1), now: now), isTrue);
      expect(isAtLeast18(DateTime(2015, 1, 1), now: now), isFalse);
    });
  });

  group('nationalToE164', () {
    test('accepts national input with and without leading 0', () {
      expect(nationalToE164('0123456789'), '+60123456789');
      expect(nationalToE164('123456789'), '+60123456789');
      expect(nationalToE164('12-345 6789'), '+60123456789');
    });

    test('rejects non-mobile or wrong-length input', () {
      expect(nationalToE164('987654321'), isNull); // not starting with 1
      expect(nationalToE164('12345'), isNull); // too short
      expect(nationalToE164('12345678901'), isNull); // too long
    });
  });
}
