import 'package:assignment/utils/json.dart';

/// Sentinel for [AdminReport.copyWith] — see `CarInterests`.
const Object _unset = Object();

/// One user-filed report as the admin sees it — the shape returned by the
/// `admin_reports()` RPC (report fields joined to both users' names).
class AdminReport {
  const AdminReport({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    this.reporterName,
    this.reportedName,
    this.reportedBanned = false,
    required this.title,
    required this.description,
    this.status = 'open',
    required this.createdAt,
  });

  factory AdminReport.fromJson(Map<String, dynamic> json) => AdminReport(
    id: json['id'] as String,
    reporterId: json['reporter_id'] as String,
    reportedId: json['reported_id'] as String,
    reporterName: json['reporter_name'] as String?,
    reportedName: json['reported_name'] as String?,
    reportedBanned: json['reported_banned'] as bool? ?? false,
    title: json['title'] as String,
    description: json['description'] as String,
    status: json['status'] as String? ?? 'open',
    createdAt: asDate(json['created_at']),
  );

  final String id;
  final String reporterId;
  final String reportedId;
  final String? reporterName;
  final String? reportedName;
  final bool reportedBanned;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'reporter_id': reporterId,
    'reported_id': reportedId,
    'reporter_name': reporterName,
    'reported_name': reportedName,
    'reported_banned': reportedBanned,
    'title': title,
    'description': description,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isOpen => status == 'open';

  /// Names with fallbacks so rows always render.
  String get reporter => _name(reporterName);
  String get reported => _name(reportedName);

  static String _name(String? n) {
    final t = n?.trim() ?? '';
    return t.isEmpty ? 'User' : t;
  }

  AdminReport copyWith({
    String? id,
    String? reporterId,
    String? reportedId,
    Object? reporterName = _unset,
    Object? reportedName = _unset,
    bool? reportedBanned,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
  }) => AdminReport(
    id: id ?? this.id,
    reporterId: reporterId ?? this.reporterId,
    reportedId: reportedId ?? this.reportedId,
    reporterName: identical(reporterName, _unset)
        ? this.reporterName
        : reporterName as String?,
    reportedName: identical(reportedName, _unset)
        ? this.reportedName
        : reportedName as String?,
    reportedBanned: reportedBanned ?? this.reportedBanned,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminReport &&
          id == other.id &&
          reporterId == other.reporterId &&
          reportedId == other.reportedId &&
          reporterName == other.reporterName &&
          reportedName == other.reportedName &&
          reportedBanned == other.reportedBanned &&
          title == other.title &&
          description == other.description &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    reporterId,
    reportedId,
    reporterName,
    reportedName,
    reportedBanned,
    title,
    description,
    status,
    createdAt,
  );

  @override
  String toString() =>
      'AdminReport(id: $id, reporterId: $reporterId, '
      'reportedId: $reportedId, reporterName: $reporterName, '
      'reportedName: $reportedName, reportedBanned: $reportedBanned, '
      'title: $title, description: $description, status: $status, '
      'createdAt: $createdAt)';
}
