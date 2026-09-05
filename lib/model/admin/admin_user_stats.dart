import 'package:assignment/utils/json.dart';

/// Sentinel for [AdminUserStats.copyWith] — see `CarInterests`.
const Object _unset = Object();

/// One row of the admin users screen — the shape returned by the
/// `admin_user_stats()` RPC: a profile plus its computed listing counts.
/// Deliberately its own model: `Profile` is the caller's own row and carries
/// no counts, and `PublicProfile` has no email/phone/DOB by design.
class AdminUserStats {
  const AdminUserStats({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.email,
    this.phone,
    this.dob,
    this.state,
    this.role = 'user',
    this.banned = false,
    required this.createdAt,
    required this.activeCount,
    required this.soldCount,
  });

  factory AdminUserStats.fromJson(Map<String, dynamic> json) => AdminUserStats(
    id: json['id'] as String,
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    dob: asDateOrNull(json['dob']),
    state: json['state'] as String?,
    role: json['role'] as String? ?? 'user',
    banned: json['banned'] as bool? ?? false,
    createdAt: asDate(json['created_at']),
    activeCount: asInt(json['active_count']),
    soldCount: asInt(json['sold_count']),
  );

  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final DateTime? dob;
  final String? state;
  final String role;
  final bool banned;
  final DateTime createdAt;
  final int activeCount;
  final int soldCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'email': email,
    'phone': phone,
    'dob': dob?.toIso8601String(),
    'state': state,
    'role': role,
    'banned': banned,
    'created_at': createdAt.toIso8601String(),
    'active_count': activeCount,
    'sold_count': soldCount,
  };

  /// Always something to render in a row.
  String get name {
    final n = displayName?.trim() ?? '';
    return n.isEmpty ? 'User' : n;
  }

  bool get isAdmin => role == 'admin';

  AdminUserStats copyWith({
    String? id,
    Object? displayName = _unset,
    Object? avatarUrl = _unset,
    Object? email = _unset,
    Object? phone = _unset,
    Object? dob = _unset,
    Object? state = _unset,
    String? role,
    bool? banned,
    DateTime? createdAt,
    int? activeCount,
    int? soldCount,
  }) => AdminUserStats(
    id: id ?? this.id,
    displayName: identical(displayName, _unset)
        ? this.displayName
        : displayName as String?,
    avatarUrl: identical(avatarUrl, _unset)
        ? this.avatarUrl
        : avatarUrl as String?,
    email: identical(email, _unset) ? this.email : email as String?,
    phone: identical(phone, _unset) ? this.phone : phone as String?,
    dob: identical(dob, _unset) ? this.dob : dob as DateTime?,
    state: identical(state, _unset) ? this.state : state as String?,
    role: role ?? this.role,
    banned: banned ?? this.banned,
    createdAt: createdAt ?? this.createdAt,
    activeCount: activeCount ?? this.activeCount,
    soldCount: soldCount ?? this.soldCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserStats &&
          id == other.id &&
          displayName == other.displayName &&
          avatarUrl == other.avatarUrl &&
          email == other.email &&
          phone == other.phone &&
          dob == other.dob &&
          state == other.state &&
          role == other.role &&
          banned == other.banned &&
          createdAt == other.createdAt &&
          activeCount == other.activeCount &&
          soldCount == other.soldCount;

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    avatarUrl,
    email,
    phone,
    dob,
    state,
    role,
    banned,
    createdAt,
    activeCount,
    soldCount,
  );

  @override
  String toString() =>
      'AdminUserStats(id: $id, displayName: $displayName, '
      'avatarUrl: $avatarUrl, email: $email, phone: $phone, dob: $dob, '
      'state: $state, role: $role, banned: $banned, createdAt: $createdAt, '
      'activeCount: $activeCount, soldCount: $soldCount)';
}
