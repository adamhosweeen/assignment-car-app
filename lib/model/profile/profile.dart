import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/utils/json.dart';

const Object _unset = Object();

class Profile {
  const Profile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.dob,
    this.phone,
    this.state,
    this.interests = const CarInterests(),
    this.avatarUrl,
    this.role = 'user',
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    dob: asDateOrNull(json['dob']),
    phone: json['phone'] as String?,
    state: json['state'] as String?,
    interests: json['interests'] == null
        ? const CarInterests()
        : CarInterests.fromJson(json['interests'] as Map<String, dynamic>),
    avatarUrl: json['avatar_url'] as String?,
    role: json['role'] as String? ?? 'user',
    createdAt: asDate(json['created_at']),
  );

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final String? phone;
  final String? state;
  final CarInterests interests;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'dob': dob?.toIso8601String(),
    'phone': phone,
    'state': state,
    'interests': interests.toJson(),
    'avatar_url': avatarUrl,
    'role': role,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isAdmin => role == 'admin';

  String get displayName {
    final name = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (name.isNotEmpty) return name;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  Profile copyWith({
    String? id,
    String? email,
    Object? firstName = _unset,
    Object? lastName = _unset,
    Object? dob = _unset,
    Object? phone = _unset,
    Object? state = _unset,
    CarInterests? interests,
    Object? avatarUrl = _unset,
    String? role,
    DateTime? createdAt,
  }) => Profile(
    id: id ?? this.id,
    email: email ?? this.email,
    firstName: identical(firstName, _unset)
        ? this.firstName
        : firstName as String?,
    lastName: identical(lastName, _unset) ? this.lastName : lastName as String?,
    dob: identical(dob, _unset) ? this.dob : dob as DateTime?,
    phone: identical(phone, _unset) ? this.phone : phone as String?,
    state: identical(state, _unset) ? this.state : state as String?,
    interests: interests ?? this.interests,
    avatarUrl: identical(avatarUrl, _unset)
        ? this.avatarUrl
        : avatarUrl as String?,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          id == other.id &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          dob == other.dob &&
          phone == other.phone &&
          state == other.state &&
          interests == other.interests &&
          avatarUrl == other.avatarUrl &&
          role == other.role &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    email,
    firstName,
    lastName,
    dob,
    phone,
    state,
    interests,
    avatarUrl,
    role,
    createdAt,
  );

  @override
  String toString() =>
      'Profile(id: $id, email: $email, firstName: $firstName, '
      'lastName: $lastName, dob: $dob, phone: $phone, state: $state, '
      'interests: $interests, avatarUrl: $avatarUrl, role: $role, '
      'createdAt: $createdAt)';
}
