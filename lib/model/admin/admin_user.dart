import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/json.dart';

class AdminUser {
  const AdminUser({
    required this.profile,
    required this.activeCount,
    required this.soldCount,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    profile: Profile.fromJson(json),
    activeCount: asInt(json['active_count']),
    soldCount: asInt(json['sold_count']),
  );

  final Profile profile;
  final int activeCount;
  final int soldCount;

  Map<String, dynamic> toJson() => {
    ...profile.toJson(),
    'active_count': activeCount,
    'sold_count': soldCount,
  };

  String get id => profile.id;

  bool get banned => profile.banned;

  bool get isAdmin => profile.isAdmin;

  String get name {
    final n = profile.displayName.trim();
    return n.isEmpty ? 'User' : n;
  }

  AdminUser copyWith({Profile? profile, int? activeCount, int? soldCount}) =>
      AdminUser(
        profile: profile ?? this.profile,
        activeCount: activeCount ?? this.activeCount,
        soldCount: soldCount ?? this.soldCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUser &&
          profile == other.profile &&
          activeCount == other.activeCount &&
          soldCount == other.soldCount;

  @override
  int get hashCode => Object.hash(profile, activeCount, soldCount);

  @override
  String toString() =>
      'AdminUser(profile: $profile, activeCount: $activeCount, '
      'soldCount: $soldCount)';
}
