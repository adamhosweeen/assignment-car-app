import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/admin/admin_repository.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/report.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/user/admin/admin_reports_screen.dart';

final _report = Report(
  id: 'r1',
  reporterId: 'u1',
  reportedId: 'u2',
  reporterName: 'Aiman Rahman',
  reportedName: 'Siti Nur',
  title: 'Fake listing',
  description: 'Car in the photos is not the car being sold.',
  createdAt: DateTime.utc(2026, 8, 30),
);

class _FakeAdmin implements AdminRepository {
  _FakeAdmin({this.deleteFails = false});

  final bool deleteFails;
  final deletedReports = <String>[];

  @override
  Future<Result<List<AppUser>>> listUsers() async => const Ok([]);

  @override
  Future<Result<List<Report>>> listReports() async => Ok([_report]);

  @override
  Future<Result<void>> resolveReport(String reportId) async => const Ok(null);

  @override
  Future<Result<void>> deleteReport(String reportId) async {
    if (deleteFails) return const Err('Could not delete that report.');
    deletedReports.add(reportId);
    return const Ok(null);
  }

  @override
  Future<Result<void>> setBanned(String userId, bool banned) async =>
      const Ok(null);

  @override
  Future<Result<void>> deleteUser(String userId, {String? avatarUrl}) async =>
      const Ok(null);
}

Widget _app(_FakeAdmin admin, VoidCallback onChanged) => MultiProvider(
  providers: [Provider<AdminRepository>.value(value: admin)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: ReportsTab(reports: Future.value([_report]), onChanged: onChanged),
    ),
  ),
);

Future<void> _openDeleteDialog(WidgetTester tester) async {
  await tester.tap(find.text('Fake listing'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete report'));
  await tester.pumpAndSettle();
  expect(find.text('Delete this report?'), findsOneWidget);
}

final Finder _confirmButton = find.widgetWithText(TextButton, 'Delete');

void main() {
  testWidgets('an admin can delete a report after confirming', (tester) async {
    final admin = _FakeAdmin();
    var changed = 0;
    await tester.pumpWidget(_app(admin, () => changed++));
    await tester.pumpAndSettle();

    await _openDeleteDialog(tester);
    await tester.tap(_confirmButton);
    await tester.pumpAndSettle();

    expect(admin.deletedReports, ['r1']);
    expect(changed, 1, reason: 'the list reloads');
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling deletes nothing', (tester) async {
    final admin = _FakeAdmin();
    var changed = 0;
    await tester.pumpWidget(_app(admin, () => changed++));
    await tester.pumpAndSettle();

    await _openDeleteDialog(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(admin.deletedReports, isEmpty);
    expect(changed, 0);
  });

  testWidgets('a failed delete says so and keeps the list', (tester) async {
    final admin = _FakeAdmin(deleteFails: true);
    var changed = 0;
    await tester.pumpWidget(_app(admin, () => changed++));
    await tester.pumpAndSettle();

    await _openDeleteDialog(tester);
    await tester.tap(_confirmButton);
    await tester.pumpAndSettle();

    expect(find.text('Could not delete that report.'), findsOneWidget);
    expect(changed, 0);
  });

  testWidgets('resolved reports can be deleted too', (tester) async {
    final admin = _FakeAdmin();
    final resolved = _report.copyWith(status: 'resolved');
    await tester.pumpWidget(
      MultiProvider(
        providers: [Provider<AdminRepository>.value(value: admin)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ReportsTab(
              reports: Future.value([resolved]),
              onChanged: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resolved'));
    await tester.pumpAndSettle();

    await _openDeleteDialog(tester);
    await tester.tap(_confirmButton);
    await tester.pumpAndSettle();

    expect(admin.deletedReports, ['r1']);
  });
}
