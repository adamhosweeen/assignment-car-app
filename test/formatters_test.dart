import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/utils/formatters.dart';

void main() {
  group('formatDateTime', () {
    test('renders an afternoon time in 12-hour form', () {
      expect(
        formatDateTime(DateTime(2026, 9, 7, 16, 43)),
        '7 Sep 2026, 4:43 PM',
      );
    });

    test('midnight is 12 AM, not 0 AM', () {
      expect(formatDateTime(DateTime(2026, 9, 7)), '7 Sep 2026, 12:00 AM');
    });

    test('noon is 12 PM, not 0 PM', () {
      expect(formatDateTime(DateTime(2026, 9, 7, 12)), '7 Sep 2026, 12:00 PM');
    });

    test('pads a single-digit minute', () {
      expect(formatDateTime(DateTime(2026, 9, 7, 9, 5)), '7 Sep 2026, 9:05 AM');
    });
  });
}
