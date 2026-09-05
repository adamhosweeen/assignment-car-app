import 'package:assignment/utils/json.dart';

/// Sentinel for [PublicProfile.copyWith] — see `CarInterests`.
const Object _unset = Object();

/// The part of a user's profile any signed-in user may see — a row of the
/// `public_profiles` view. Deliberately has no email, phone, DOB, or
/// interests; those never leave the owner's own `profiles` row.
class PublicProfile {
  const PublicProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.state,
    required this.createdAt,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) => PublicProfile(
    id: json['id'] as String,
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    state: json['state'] as String?,
    createdAt: asDate(json['created_at']),
  );

  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? state;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'state': state,
    'created_at': createdAt.toIso8601String(),
  };

  /// Display name, or a neutral fallback for accounts without one.
  String get name {
    final n = displayName?.trim() ?? '';
    return n.isEmpty ? 'Seller' : n;
  }

  PublicProfile copyWith({
    String? id,
    Object? displayName = _unset,
    Object? avatarUrl = _unset,
    Object? state = _unset,
    DateTime? createdAt,
  }) => PublicProfile(
    id: id ?? this.id,
    displayName: identical(displayName, _unset)
        ? this.displayName
        : displayName as String?,
    avatarUrl: identical(avatarUrl, _unset)
        ? this.avatarUrl
        : avatarUrl as String?,
    state: identical(state, _unset) ? this.state : state as String?,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicProfile &&
          id == other.id &&
          displayName == other.displayName &&
          avatarUrl == other.avatarUrl &&
          state == other.state &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, displayName, avatarUrl, state, createdAt);

  @override
  String toString() =>
      'PublicProfile(id: $id, displayName: $displayName, '
      'avatarUrl: $avatarUrl, state: $state, createdAt: $createdAt)';
}
