import 'package:assignment/utils/result.dart';

/// Filing a report against another user (seller page → flag button).
/// Reading reports is admin-only and lives in `AdminRepository`.
abstract interface class ReportsRepository {
  /// Insert a report by the signed-in user. RLS enforces that the reporter is
  /// the caller and that users cannot report themselves.
  Future<Result<void>> submit({
    required String reportedId,
    required String title,
    required String description,
  });
}
