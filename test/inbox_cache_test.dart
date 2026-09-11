import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/user/inbox/inbox_cache_repository.dart';
import 'package:assignment/model/user/inbox_message.dart';

void main() {
  group('inbox cache row mapping', () {
    test('a fully populated message round-trips through a row', () {
      final message = InboxMessage(
        id: 'n1',
        userId: 'u1',
        kind: InboxKind.listingMatch,
        title: 'New car that matches your interests',
        body: '2020 Perodua Myvi · RM 45,000 · Selangor',
        listingId: 'l1',
        route: '/listing/l1',
        readAt: DateTime.utc(2026, 9, 2, 10, 30),
        createdAt: DateTime.utc(2026, 9, 1),
      );

      expect(inboxFromRow(inboxToRow(message)), message);
    });

    test('an unread message with no listing round-trips', () {
      final message = InboxMessage(
        id: 'n2',
        userId: 'u1',
        kind: InboxKind.welcome,
        title: 'Welcome to CarSell',
        body: 'Set your car interests.',
        route: '/profile/interests',
        createdAt: DateTime.utc(2026, 9, 1),
      );

      final restored = inboxFromRow(inboxToRow(message));
      expect(restored, message);
      expect(restored.isRead, isFalse);
      expect(restored.listingId, isNull);
    });

    test('kind is stored as the snake_case wire value, not the enum name', () {
      final row = inboxToRow(
        InboxMessage(
          id: 'n3',
          userId: 'u1',
          kind: InboxKind.listingMatch,
          title: 't',
          body: 'b',
          createdAt: DateTime.utc(2026, 9, 1),
        ),
      );

      expect(row['kind'], 'listing_match');
      expect(inboxFromRow(row).kind, InboxKind.listingMatch);
    });
  });
}
