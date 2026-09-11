import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/utils/json.dart';

const Object _unset = Object();

enum UserRole { customer, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.dob,
    this.phone,
    this.state,
    this.interests = const CarInterests(),
    this.avatarUrl,
    this.role = UserRole.customer,
    this.banned = false,
    required this.createdAt,
    this.activeCount,
    this.soldCount,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    displayName: json['display_name'] as String?,
    dob: asDateOrNull(json['dob']),
    phone: json['phone'] as String?,
    state: json['state'] as String?,
    interests: json['interests'] == null
        ? const CarInterests()
        : CarInterests.fromJson(json['interests'] as Map<String, dynamic>),
    avatarUrl: json['avatar_url'] as String?,
    role: asEnumOrNull(UserRole.values, json['role']) ?? UserRole.customer,
    banned: json['banned'] as bool? ?? false,
    createdAt: asDate(json['created_at']),
    activeCount: asIntOrNull(json['active_count']),
    soldCount: asIntOrNull(json['sold_count']),
  );

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final DateTime? dob;
  final String? phone;
  final String? state;
  final CarInterests interests;
  final String? avatarUrl;
  final UserRole role;
  final bool banned;
  final DateTime createdAt;
  final int? activeCount;
  final int? soldCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'display_name': displayName,
    'dob': dob?.toIso8601String(),
    'phone': phone,
    'state': state,
    'interests': interests.toJson(),
    'avatar_url': avatarUrl,
    'role': role.name,
    'banned': banned,
    'created_at': createdAt.toIso8601String(),
    'active_count': activeCount,
    'sold_count': soldCount,
  };

  bool get isAdmin => role == UserRole.admin;

  String get name {
    final stored = displayName?.trim() ?? '';
    if (stored.isNotEmpty) return stored;
    final full = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (full.isNotEmpty) return full;
    final at = email.indexOf('@');
    if (at > 0) return email.substring(0, at);
    return email.isEmpty ? 'User' : email;
  }

  AppUser copyWith({
    String? id,
    String? email,
    Object? firstName = _unset,
    Object? lastName = _unset,
    Object? displayName = _unset,
    Object? dob = _unset,
    Object? phone = _unset,
    Object? state = _unset,
    CarInterests? interests,
    Object? avatarUrl = _unset,
    UserRole? role,
    bool? banned,
    DateTime? createdAt,
    Object? activeCount = _unset,
    Object? soldCount = _unset,
  }) => AppUser(
    id: id ?? this.id,
    email: email ?? this.email,
    firstName: identical(firstName, _unset)
        ? this.firstName
        : firstName as String?,
    lastName: identical(lastName, _unset) ? this.lastName : lastName as String?,
    displayName: identical(displayName, _unset)
        ? this.displayName
        : displayName as String?,
    dob: identical(dob, _unset) ? this.dob : dob as DateTime?,
    phone: identical(phone, _unset) ? this.phone : phone as String?,
    state: identical(state, _unset) ? this.state : state as String?,
    interests: interests ?? this.interests,
    avatarUrl: identical(avatarUrl, _unset)
        ? this.avatarUrl
        : avatarUrl as String?,
    role: role ?? this.role,
    banned: banned ?? this.banned,
    createdAt: createdAt ?? this.createdAt,
    activeCount: identical(activeCount, _unset)
        ? this.activeCount
        : activeCount as int?,
    soldCount: identical(soldCount, _unset)
        ? this.soldCount
        : soldCount as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          id == other.id &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          displayName == other.displayName &&
          dob == other.dob &&
          phone == other.phone &&
          state == other.state &&
          interests == other.interests &&
          avatarUrl == other.avatarUrl &&
          role == other.role &&
          banned == other.banned &&
          createdAt == other.createdAt &&
          activeCount == other.activeCount &&
          soldCount == other.soldCount;

  @override
  int get hashCode => Object.hash(
    id,
    email,
    firstName,
    lastName,
    displayName,
    dob,
    phone,
    state,
    interests,
    avatarUrl,
    role,
    banned,
    createdAt,
    activeCount,
    soldCount,
  );

  @override
  String toString() =>
      'AppUser(id: $id, email: $email, firstName: $firstName, '
      'lastName: $lastName, displayName: $displayName, dob: $dob, '
      'phone: $phone, state: $state, interests: $interests, '
      'avatarUrl: $avatarUrl, role: ${role.name}, banned: $banned, '
      'createdAt: $createdAt, activeCount: $activeCount, '
      'soldCount: $soldCount)';
}
