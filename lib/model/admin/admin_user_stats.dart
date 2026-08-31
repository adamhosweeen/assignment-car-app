import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user_stats.freezed.dart';
part 'admin_user_stats.g.dart';

/// One row of the admin users screen — the shape returned by the
/// `admin_user_stats()` RPC: a profile plus its computed listing counts.
/// Deliberately its own model: [Profile] is the caller's own row and carries
/// no counts, and `PublicProfile` has no email/phone/DOB by design.
@freezed
abstract class AdminUserStats with _$AdminUserStats {
  const AdminUserStats._();

  const factory AdminUserStats({
    required String id,
    String? displayName,
    String? avatarUrl,
    String? email,
    String? phone,
    DateTime? dob,
    String? state,
    @Default('user') String role,
    @Default(false) bool banned,
    required DateTime createdAt,
    required int activeCount,
    required int soldCount,
  }) = _AdminUserStats;

  factory AdminUserStats.fromJson(Map<String, dynamic> json) =>
      _$AdminUserStatsFromJson(json);

  /// Always something to render in a row.
  String get name {
    final n = displayName?.trim() ?? '';
    return n.isEmpty ? 'User' : n;
  }

  bool get isAdmin => role == 'admin';
}
