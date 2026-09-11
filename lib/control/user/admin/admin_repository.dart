import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/report.dart';
import 'package:assignment/utils/result.dart';

abstract interface class AdminRepository {
  Future<Result<List<AppUser>>> listUsers();

  Future<Result<List<Report>>> listReports();

  Future<Result<void>> resolveReport(String reportId);

  Future<Result<void>> setBanned(String userId, bool banned);
}
