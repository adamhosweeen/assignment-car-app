import 'package:assignment/control/user/admin/admin_repository.dart';
import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/report.dart';
import 'package:assignment/utils/result.dart';

class AdminException implements Exception {
  const AdminException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<List<AppUser>> fetchAppUsers(AdminRepository admin) async {
  final res = await admin.listUsers();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw AdminException(message),
  };
}

Future<List<Report>> fetchReports(AdminRepository admin) async {
  final res = await admin.listReports();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw AdminException(message),
  };
}

List<AppUser> filterAppUsers(List<AppUser> users, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return users;
  bool matches(String? field) => field?.toLowerCase().contains(q) ?? false;
  return [
    for (final u in users)
      if (matches(u.name) ||
          matches(u.email) ||
          matches(u.phone) ||
          matches(u.state))
        u,
  ];
}

enum AdminSort { newest, listed, sold }

List<AppUser> sortAppUsers(List<AppUser> users, AdminSort sort) {
  int byNewest(AppUser a, AppUser b) {
    final c = b.createdAt.compareTo(a.createdAt);
    return c != 0 ? c : a.id.compareTo(b.id);
  }

  final sorted = [...users];
  switch (sort) {
    case AdminSort.newest:
      sorted.sort(byNewest);
    case AdminSort.listed:
      sorted.sort((a, b) {
        final c = (b.activeCount ?? 0).compareTo(a.activeCount ?? 0);
        return c != 0 ? c : byNewest(a, b);
      });
    case AdminSort.sold:
      sorted.sort((a, b) {
        final c = (b.soldCount ?? 0).compareTo(a.soldCount ?? 0);
        return c != 0 ? c : byNewest(a, b);
      });
  }
  return sorted;
}

class UsersException implements Exception {
  const UsersException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<AppUser?> fetchAppUser(UsersRepository profiles, String id) async {
  final res = await profiles.getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw UsersException(message),
  };
}

Future<List<AppUser>> searchSellers(
  UsersRepository profiles,
  String query,
) async {
  if (query.trim().isEmpty) return const [];
  final res = await profiles.search(query);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw UsersException(message),
  };
}
