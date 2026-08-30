import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/utils/search.dart';

void main() {
  test('trims and collapses whitespace', () {
    expect(sanitizeSearchQuery('  perodua   myvi  '), 'perodua myvi');
  });

  test('strips filter-reserved characters', () {
    expect(sanitizeSearchQuery('my%vi_(1.5),"x"*'), 'my vi 1 5 x');
  });

  test('caps the length', () {
    final long = 'a' * 100;
    expect(sanitizeSearchQuery(long).length, maxSearchQueryLength);
  });

  test('nothing searchable → empty', () {
    expect(sanitizeSearchQuery(''), '');
    expect(sanitizeSearchQuery('   '), '');
    expect(sanitizeSearchQuery('%%%'), '');
  });
}
