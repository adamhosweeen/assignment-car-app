import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/notifications/notification_alerts.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/notifications/notification_banner.dart';

AppNotification _n(
  String id, {
  String title = 'New match',
  String? route,
  DateTime? createdAt,
  DateTime? readAt,
}) => AppNotification(
  id: id,
  userId: 'u1',
  kind: NotificationKind.listingMatch,
  title: title,
  body: '2020 Perodua Myvi 1.5 AV',
  route: route,
  readAt: readAt,
  createdAt: createdAt ?? DateTime.utc(2026, 9, 5, 10),
);

final _user = Profile(
  id: 'u1',
  email: 'a@b.my',
  createdAt: DateTime.utc(2026, 1, 1),
);

class _FakeNotifications implements NotificationsRepository {
  final List<String> readIds = [];

  @override
  Future<Result<void>> markRead(String id) async {
    readIds.add(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> markAllRead() async => const Ok(null);

  @override
  Future<Result<void>> delete(String id) async => const Ok(null);

  @override
  Stream<List<AppNotification>> watchInbox() =>
      const Stream<List<AppNotification>>.empty();
}

Route<dynamic> _testRoute(RouteSettings settings) {
  final label = switch (Uri.parse(settings.name ?? '').pathSegments) {
    ['listing', final id] => 'Listing $id',
    ['profile', 'inbox'] => 'Inbox screen',
    _ => 'Buy feed',
  };
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(body: Text(label)),
  );
}

Widget _app({
  required AppNavigator navigator,
  required Stream<AsyncSnapshot<List<AppNotification>>> inbox,
  required NotificationsRepository notifications,
}) => MultiProvider(
  providers: [
    Provider<AppNavigator>.value(value: navigator),
    Provider<NotificationsRepository>.value(value: notifications),
    Provider<Profile?>.value(value: _user),
    StreamProvider<AsyncSnapshot<List<AppNotification>>>.value(
      value: inbox,
      initialData: const AsyncSnapshot<List<AppNotification>>.waiting(),
    ),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    navigatorKey: navigator.key,
    navigatorObservers: [navigator.tracker],
    onGenerateRoute: _testRoute,
    home: const Scaffold(body: Text('Buy feed')),
    builder: (context, child) =>
        NotificationBannerHost(child: child ?? const SizedBox.shrink()),
  ),
);

AsyncSnapshot<List<AppNotification>> _data(List<AppNotification> items) =>
    AsyncSnapshot<List<AppNotification>>.withData(
      ConnectionState.active,
      items,
    );

void main() {
  group('newArrivals', () {
    test('announces only unread notifications not already seen', () {
      final items = [
        _n('a'),
        _n('b', readAt: DateTime.utc(2026, 9, 5, 11)),
        _n('c'),
      ];
      final fresh = newArrivals(items, {'a'});
      expect(fresh.map((n) => n.id), ['c']);
    });

    test('returns oldest first so a burst reads in order', () {
      final items = [
        _n('new', createdAt: DateTime.utc(2026, 9, 5, 12)),
        _n('old', createdAt: DateTime.utc(2026, 9, 5, 9)),
      ];
      expect(newArrivals(items, {}).map((n) => n.id), ['old', 'new']);
    });

    test('caps a burst, keeping the most recent', () {
      final items = [
        for (var i = 0; i < 6; i++)
          _n('n$i', createdAt: DateTime.utc(2026, 9, 5, 10 + i)),
      ];
      expect(newArrivals(items, {}, max: 2).map((n) => n.id), ['n4', 'n5']);
    });

    test('nothing new means nothing to announce', () {
      expect(newArrivals([_n('a')], {'a'}), isEmpty);
    });
  });

  group('NotificationBannerHost', () {
    late StreamController<AsyncSnapshot<List<AppNotification>>> inbox;
    late _FakeNotifications notifications;
    late AppNavigator navigator;

    setUp(() {
      inbox = StreamController<AsyncSnapshot<List<AppNotification>>>();
      notifications = _FakeNotifications();
      navigator = AppNavigator();
    });

    tearDown(() async {
      await inbox.close();
      navigator.dispose();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          navigator: navigator,
          inbox: inbox.stream,
          notifications: notifications,
        ),
      );
      await tester.pump();
    }

    Future<void> emit(WidgetTester tester, List<AppNotification> items) async {
      inbox.add(_data(items));
      await tester.idle();
      await tester.pump();
    }

    testWidgets('stays silent for the backlog already in the inbox', (
      tester,
    ) async {
      await pumpApp(tester);
      await emit(tester, [_n('a', title: 'Old news')]);
      await tester.pumpAndSettle();

      expect(find.text('Old news'), findsNothing);
      expect(find.text('Buy feed'), findsOneWidget);
    });

    testWidgets('pops up when a notification arrives after the first load', (
      tester,
    ) async {
      await pumpApp(tester);
      await emit(tester, []);

      await emit(tester, [_n('a', title: 'New match')]);
      await tester.pumpAndSettle();

      expect(find.text('New match'), findsOneWidget);
      expect(find.text('2020 Perodua Myvi 1.5 AV'), findsOneWidget);
    });

    testWidgets('auto-dismisses after a few seconds', (tester) async {
      await pumpApp(tester);
      await emit(tester, []);
      await emit(tester, [_n('a', title: 'New match')]);
      await tester.pumpAndSettle();
      expect(find.text('New match'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('New match'), findsNothing);
    });

    testWidgets('tapping marks it read and opens its route', (tester) async {
      await pumpApp(tester);
      await emit(tester, []);
      await emit(tester, [_n('a', title: 'New match', route: '/listing/l1')]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('New match'));
      await tester.pumpAndSettle();

      expect(notifications.readIds, ['a']);
      expect(find.text('Listing l1'), findsOneWidget);
      expect(find.text('New match'), findsNothing);
    });

    testWidgets('stays silent while the inbox screen is open', (tester) async {
      await pumpApp(tester);
      await emit(tester, []);

      navigator.open('/profile/inbox');
      await tester.pumpAndSettle();
      expect(find.text('Inbox screen'), findsOneWidget);

      await emit(tester, [_n('a', title: 'New match')]);
      await tester.pumpAndSettle();

      expect(find.text('New match'), findsNothing);
    });
  });
}
