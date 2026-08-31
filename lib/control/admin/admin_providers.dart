import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/admin/admin_user_stats.dart';
import 'package:assignment/model/report/admin_report.dart';
import 'package:assignment/utils/result.dart';

part 'admin_providers.g.dart';

/// Carries the repository's user-facing message through Riverpod's error
/// channel without exposing a raw backend exception to the UI.
class AdminException implements Exception {
  const AdminException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// All users with their listing counts (admin screen). Errors for non-admin
/// callers — the server refuses the RPC.
@riverpod
Future<List<AdminUserStats>> adminUsers(Ref ref) async {
  final res = await ref.watch(adminRepositoryProvider).listUsers();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw AdminException(message),
  };
}

/// All user-filed reports, newest first (admin reports screen).
@riverpod
Future<List<AdminReport>> adminReports(Ref ref) async {
  final res = await ref.watch(adminRepositoryProvider).listReports();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw AdminException(message),
  };
}

/// Case-insensitive filter over what an admin would search by: name, email,
/// phone, and state. Client-side — the list is already fully fetched.
/// A blank query returns the input unchanged.
List<AdminUserStats> filterAdminUsers(
  List<AdminUserStats> users,
  String query,
) {
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

/// How the admin list is ordered. Sorting is client-side — the dataset is a
/// single small fetch, so no round-trip per sort.
enum AdminSort { newest, listed, sold }

/// Pure sort used by the admin screen: [AdminSort.newest] by joined date
/// descending; [AdminSort.listed]/[AdminSort.sold] by that count descending
/// with newest as the tiebreak, then id for stability. Returns a new list.
List<AdminUserStats> sortAdminUsers(
  List<AdminUserStats> users,
  AdminSort sort,
) {
  int byNewest(AdminUserStats a, AdminUserStats b) {
    final c = b.createdAt.compareTo(a.createdAt);
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
