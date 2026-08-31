import 'package:assignment/model/admin/admin_user_stats.dart';
import 'package:assignment/model/report/admin_report.dart';
import 'package:assignment/utils/result.dart';

/// Admin data and moderation actions. The server enforces access — every call
/// fails for non-admin accounts (each RPC checks `is_admin()`), so the
/// client-side gate on `Profile.isAdmin` is cosmetic only.
abstract interface class AdminRepository {
  /// Every user with their active-listed and sold counts, newest first.
  Future<Result<List<AdminUserStats>>> listUsers();

  /// Every user-filed report, newest first.
  Future<Result<List<AdminReport>>> listReports();

  /// Mark a report resolved.
  Future<Result<void>> resolveReport(String reportId);

  /// Ban or unban a user. Banning blocks login/token refresh
  /// (`auth.users.banned_until`) and hides their listings; the server refuses
  /// self-bans and banning other admins.
  Future<Result<void>> setBanned(String userId, bool banned);
}
