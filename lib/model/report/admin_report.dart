import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_report.freezed.dart';
part 'admin_report.g.dart';

/// One user-filed report as the admin sees it — the shape returned by the
/// `admin_reports()` RPC (report fields joined to both users' names).
@freezed
abstract class AdminReport with _$AdminReport {
  const AdminReport._();

  const factory AdminReport({
    required String id,
    required String reporterId,
    required String reportedId,
    String? reporterName,
    String? reportedName,
    @Default(false) bool reportedBanned,
    required String title,
    required String description,
    @Default('open') String status,
    required DateTime createdAt,
  }) = _AdminReport;

  factory AdminReport.fromJson(Map<String, dynamic> json) =>
      _$AdminReportFromJson(json);

  bool get isOpen => status == 'open';

  /// Names with fallbacks so rows always render.
  String get reporter => _name(reporterName);
  String get reported => _name(reportedName);

  static String _name(String? n) {
    final t = n?.trim() ?? '';
    return t.isEmpty ? 'User' : t;
  }
}
