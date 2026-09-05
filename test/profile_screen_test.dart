import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/model/auth/registration_data.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/profile/profile_screen.dart';
import 'package:assignment/widgets/common/grouped_section.dart';

Profile _profile({bool admin = false, String? state = 'Selangor'}) => Profile(
  id: 'u1',
  email: 'aiman@example.com',
  firstName: 'Aiman',
  lastName: 'Rahman',
  state: state,
  role: admin ? 'admin' : 'user',
  createdAt: DateTime.utc(2026, 3, 12),
);

AppNotification _unread(String id) => AppNotification(
  id: id,
  userId: 'u1',
  kind: NotificationKind.welcome,
  title: 't',
  body: 'b',
  createdAt: DateTime.utc(2026, 9, 1),
);

class _FakeAuth implements AuthRepository {
  _FakeAuth(this.user);

  final Profile user;
  int signOuts = 0;

  @override
  Profile? get currentUser => user;

  @override
  Stream<Profile?> authState() => Stream.value(user);

  @override
  Future<Result<Profile>> signIn({
    required String email,
    required String password,
  }) async => Ok(user);

  @override
  Future<Result<Profile>> signUp({
    required String email,
    required String password,
    required RegistrationData data,
  }) async => Ok(user);

  @override
  Future<Result<Profile>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => Ok(user);

  @override
  Future<Result<Profile>> updateAvatar(String localPath) async => Ok(user);

  @override
  Future<Result<Profile>> removeAvatar() async => Ok(user);

  @override
  Future<Result<void>> deleteAccount() async => const Ok(null);

  @override
  Future<void> signOut() async {
    signOuts++;
  }
}

class _NoDraftRepo implements DraftRepository {
  @override
  bool get hasDraft => false;

  @override
  ListingDraft? load() => null;

  @override
  Future<void> save(ListingDraft draft) async {}

  @override
  Future<void> clear() async {}
}

Widget _app(Profile profile, {List<AppNotification> inbox = const []}) {
  final router = GoRouter(
    initialLocation: '/home/profile',
    routes: [
      GoRoute(path: '/home/profile', builder: (_, _) => const ProfileScreen()),
      for (final path in [
        '/profile/inbox',
        '/profile/info',
        '/profile/interests',
        '/profile/purchases',
        '/profile/insights',
        '/sellers',
        '/admin',
      ])
        GoRoute(
          path: path,
          builder: (_, _) => Scaffold(body: Text('ROUTE $path')),
        ),
    ],
  );
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: _FakeAuth(profile)),
      Provider<DraftRepository>.value(value: _NoDraftRepo()),
      Provider<Profile?>.value(value: profile),
      Provider<AsyncSnapshot<List<AppNotification>>>.value(
        value: AsyncSnapshot.withData(ConnectionState.active, inbox),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

void main() {
  Future<void> pump(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('header shows name, email, state and member-since', (
    tester,
  ) async {
    await pump(tester, _app(_profile()));

    expect(find.text('Aiman Rahman'), findsOneWidget);
    expect(find.text('aiman@example.com'), findsOneWidget);
    expect(find.text('Selangor · Member since Mar 2026'), findsOneWidget);
  });

  testWidgets('a profile with no state still shows member-since', (
    tester,
  ) async {
    await pump(tester, _app(_profile(state: null)));
    expect(find.text('Member since Mar 2026'), findsOneWidget);
  });

  testWidgets('rows are grouped under section headers with icons', (
    tester,
  ) async {
    await pump(tester, _app(_profile()));

    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('MARKETPLACE'), findsOneWidget);
    expect(find.text('MODERATION'), findsNothing);
    expect(find.text('Admin'), findsNothing);

    final rows = tester.widgetList<GroupedRow>(find.byType(GroupedRow));
    expect(rows.length, 6);
    expect(rows.every((r) => r.leading != null), isTrue);
  });

  testWidgets('admins get a Moderation section and an Admin tag', (
    tester,
  ) async {
    await pump(tester, _app(_profile(admin: true)));

    expect(find.text('MODERATION'), findsOneWidget);
    expect(find.widgetWithText(GroupedRow, 'Admin'), findsOneWidget);
    expect(find.text('Admin'), findsNWidgets(2));
  });

  testWidgets('the inbox row shows the unread count', (tester) async {
    await pump(tester, _app(_profile(), inbox: [_unread('a'), _unread('b')]));
    expect(find.text('2 new'), findsOneWidget);
  });

  testWidgets('log out and delete sit together and both confirm first', (
    tester,
  ) async {
    await pump(tester, _app(_profile()));

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
  });

  testWidgets('tapping a row navigates', (tester) async {
    await pump(tester, _app(_profile()));

    await tester.tap(find.text('Purchases'));
    await tester.pumpAndSettle();
    expect(find.text('ROUTE /profile/purchases'), findsOneWidget);
  });
}
