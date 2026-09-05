import 'package:assignment/model/admin/admin_user_stats.dart';
import 'package:assignment/model/report/admin_report.dart';
import 'package:assignment/utils/result.dart';

abstract interface class AdminRepository {
  Future<Result<List<AdminUserStats>>> listUsers();

  Future<Result<List<AdminReport>>> listReports();

  Future<Result<void>> resolveReport(String reportId);

  Future<Result<void>> setBanned(String userId, bool banned);
}
