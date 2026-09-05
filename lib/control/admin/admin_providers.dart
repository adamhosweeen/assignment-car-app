import 'package:assignment/control/admin/admin_repository.dart';
import 'package:assignment/model/admin/admin_user.dart';
import 'package:assignment/model/report/admin_report.dart';
import 'package:assignment/utils/result.dart';

class AdminException implements Exception {
  const AdminException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<List<AdminUser>> fetchAdminUsers(AdminRepository admin) async {
  final res = await admin.listUsers();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw AdminException(message),
  };
}

Future<List<AdminReport>> fetchAdminReports(AdminRepository admin) async {
  final res = await admin.listReports();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw AdminException(message),
  };
}

List<AdminUser> filterAdminUsers(List<AdminUser> users, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return users;
  bool matches(String? field) => field?.toLowerCase().contains(q) ?? false;
  return [
    for (final u in users)
      if (matches(u.name) ||
          matches(u.profile.email) ||
          matches(u.profile.phone) ||
          matches(u.profile.state))
        u,
  ];
}

enum AdminSort { newest, listed, sold }

List<AdminUser> sortAdminUsers(List<AdminUser> users, AdminSort sort) {
  int byNewest(AdminUser a, AdminUser b) {
    final c = b.profile.createdAt.compareTo(a.profile.createdAt);
    return c != 0 ? c : a.id.compareTo(b.id);
  }

  final sorted = [...users];
  switch (sort) {
    case AdminSort.newest:
      sorted.sort(byNewest);
    case AdminSort.listed:
      sorted.sort((a, b) {
        final c = b.activeCount.compareTo(a.activeCount);
        return c != 0 ? c : byNewest(a, b);
      });
    case AdminSort.sold:
      sorted.sort((a, b) {
        final c = b.soldCount.compareTo(a.soldCount);
        return c != 0 ? c : byNewest(a, b);
      });
  }
  return sorted;
}
