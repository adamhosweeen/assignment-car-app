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
