import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/notifications/app_notification.dart';

void main() {
  test('every notification kind the database can write is decodable', () {
    final sql = File('supabase/migrations/0001_schema.sql').readAsStringSync();
    final check = RegExp(
      r"kind\s+text not null check \(kind in \((.*?)\)\)",
      dotAll: true,
    ).firstMatch(sql);
    expect(check, isNotNull, reason: 'notifications.kind CHECK not found');

    final dbKinds = RegExp(
      r"'(\w+)'",
    ).allMatches(check!.group(1)!).map((m) => m.group(1)!).toSet();
    final appKinds = kindValues.values.toSet();

    expect(
      appKinds,
      dbKinds,
      reason:
          'kindValues in app_notification.dart must match the CHECK '
          'constraint in 0001_schema.sql exactly, or the inbox throws on '
          'an unknown kind',
    );
    for (final kind in dbKinds) {
      expect(() => notificationKindFromValue(kind), returnsNormally);
    }
  });
}
