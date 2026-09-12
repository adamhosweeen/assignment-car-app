import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/services/error_mapper.dart';

void main() {
  group('mapError', () {
    test('a missing RPC says the database is behind, not "try again"', () {
      // PGRST202 is what PostgREST returns for a function the schema cache has
      // never seen — a migration that was written but never applied. Folded
      // into the generic message it looked like a transient hiccup, so the
      // undeployed extend_auction went unnoticed.
      final message = mapError(
        const PostgrestException(
          message:
              'Could not find the function public.extend_auction'
              '(p_auction_id, p_ends_at) in the schema cache',
          code: 'PGRST202',
        ),
      );
      expect(message, contains('not available on the server yet'));
      expect(message, isNot(contains('try again')));
    });

    test('any other Postgrest failure keeps the generic message', () {
      final message = mapError(
        const PostgrestException(message: 'duplicate key', code: '23505'),
      );
      expect(message, 'Something went wrong saving that. Please try again.');
    });
  });
}
