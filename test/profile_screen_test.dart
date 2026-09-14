import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/user/profile/profile_screen.dart';
import 'package:assignment/widgets/common/grouped_section.dart';

AppUser _profile({bool admin = false, String? state = 'Selangor'}) => AppUser(
  id: 'u1',
  email: 'aiman@example.com',
  firstName: 'Aiman',
  lastName: 'Rahman',
  state: state,
  role: admin ? UserRole.admin : UserRole.customer,
  createdAt: DateTime.utc(2026, 3, 12),
);

class _FakeAuth implements AuthRepository {
  _FakeAuth(this.user);

  final AppUser user;
  int signOuts = 0;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> authState() => Stream.value(user);

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async => Ok(user);

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String phoneE164,
    required String state,
    required CarInterests interests,
  }) async => Ok(user);

  @override
  Future<Result<AppUser>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => Ok(user);

  @override
  Future<Result<AppUser>> updateAvatar(String localPath) async => Ok(user);

  @override
  Future<Result<AppUser>> removeAvatar() async => Ok(user);

  @override
  Future<Result<void>> deleteAccount() async => const Ok(null);

  @override
  Future<void> signOut() async {
    signOuts++;
  }
}

Widget _app(AppUser profile) {
  final navigator = AppNavigator();
  return MultiProvider(
    providers: [
      Provider<AppNavigator>.value(value: navigator),
      Provider<AuthRepository>.value(value: _FakeAuth(profile)),
      Provider<AppUser?>.value(value: profile),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      navigatorKey: navigator.key,
      navigatorObservers: [navigator.tracker],
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => Scaffold(body: Text('ROUTE ${settings.name}')),
      ),
      home: const ProfileScreen(),
    ),
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
