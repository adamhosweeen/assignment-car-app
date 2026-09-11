import 'package:assignment/utils/result.dart';

abstract interface class ReportRepository {
  Future<Result<void>> submit({
    required String reportedId,
    required String title,
    required String description,
  });
}
