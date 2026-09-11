import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/admin/admin_repository.dart';
import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/model/user/report.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/user/admin_users_screen.dart';

final _admin = AppUser(
  id: 'admin-1',
  email: 'admin@example.com',
  role: UserRole.admin,
  createdAt: DateTime.utc(2026, 1, 1),
);

final _user = AppUser(
  id: 'u1',
  firstName: 'Nur Aisyah',
  lastName: 'binti Abdullah',
  email: 'nur.aisyah.abdullah@verylongdomainexample.com.my',
  phone: '+60123456789',
  dob: DateTime.utc(1999, 4, 12),
  state: 'Wilayah Persekutuan Kuala Lumpur',
  createdAt: DateTime.utc(2026, 2, 2),
  activeCount: 3,
  soldCount: 2,
);

class _FakeAdmin implements AdminRepository {
  @override
  Future<Result<List<AppUser>>> listUsers() async => Ok([_user]);

  @override
  Future<Result<List<Report>>> listReports() async => const Ok([]);

  @override
  Future<Result<void>> resolveReport(String reportId) async => const Ok(null);

  @override
  Future<Result<void>> setBanned(String userId, bool banned) async =>
      const Ok(null);
}

class _FakeAuth implements AuthRepository {
  @override
  AppUser? get currentUser => _admin;

  @override
  Stream<AppUser?> authState() => Stream.value(_admin);

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async => Ok(_admin);

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
  }) async => Ok(_admin);

  @override
  Future<Result<AppUser>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => Ok(_admin);

  @override
  Future<Result<AppUser>> updateAvatar(String localPath) async => Ok(_admin);

  @override
  Future<Result<AppUser>> removeAvatar() async => Ok(_admin);

  @override
  Future<Result<void>> deleteAccount() async => const Ok(null);

  @override
  Future<void> signOut() async {}
}

Widget _app() => MultiProvider(
  providers: [
    Provider<AdminRepository>.value(value: _FakeAdmin()),
    Provider<AuthRepository>.value(value: _FakeAuth()),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: AppUsersTab(users: Future.value([_user]), onChanged: () {}),
    ),
  ),
);

void main() {
  testWidgets('user detail sheet fits a small phone without overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nur Aisyah binti Abdullah'));
    await tester.pumpAndSettle();

    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('Ban user'), findsOneWidget);
  });

  testWidgets('every detail row is reachable on a small phone', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nur Aisyah binti Abdullah'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ban user'));
    await tester.pumpAndSettle();

    expect(find.text('Ban user'), findsOneWidget);
  });
}
