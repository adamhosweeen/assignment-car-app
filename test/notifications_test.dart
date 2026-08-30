import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/formatters.dart';

void main() {
  group('AppNotification', () {
    test('round-trips through JSON with snake_case kind values', () {
      final n = AppNotification(
        id: 'n1',
        userId: 'u1',
        kind: NotificationKind.listingMatch,
        title: 'New car that matches your interests',
        body: '2020 Perodua Myvi · RM 45,000',
        listingId: 'l1',
        route: '/listing/l1',
        createdAt: DateTime.utc(2026, 8, 30, 10),
      );
      final json = n.toJson();
      expect(json['kind'], 'listing_match');
      expect(json['listing_id'], 'l1');
      expect(json['read_at'], isNull);
      final back = AppNotification.fromJson(json);
      expect(back, n);
      expect(back.isRead, isFalse);
    });

    test('isRead follows read_at', () {
      final n = AppNotification.fromJson({
        'id': 'n1',
        'user_id': 'u1',
        'kind': 'welcome',
        'title': 't',
        'body': 'b',
        'read_at': '2026-08-30T10:00:00.000Z',
        'created_at': '2026-08-30T09:00:00.000Z',
      });
      expect(n.kind, NotificationKind.welcome);
      expect(n.isRead, isTrue);
    });
  });

  group('formatRelative', () {
    final now = DateTime.utc(2026, 8, 30, 12);
    test('buckets by age', () {
      expect(formatRelative(now, now: now), 'Just now');
      expect(
        formatRelative(now.subtract(const Duration(minutes: 5)), now: now),
        '5m',
      );
      expect(
        formatRelative(now.subtract(const Duration(hours: 3)), now: now),
        '3h',
      );
      expect(
        formatRelative(now.subtract(const Duration(days: 2)), now: now),
        '2d',
      );
    });

    test('falls back to the date after a week', () {
      expect(
        formatRelative(now.subtract(const Duration(days: 10)), now: now),
        formatDate(now.subtract(const Duration(days: 10))),
      );
    });
  });
}
