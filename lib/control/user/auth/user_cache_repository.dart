import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/utils/json.dart';
import 'package:assignment/model/user/app_user.dart';

class UserCacheRepository {
  UserCacheRepository(this._db, Map<String, Object?>? initialRow)
    : _cached = initialRow == null ? null : userFromRow(initialRow);

  final Database _db;
  AppUser? _cached;

  AppUser? get cached => _cached;

  Future<void> save(AppUser profile) async {
    _cached = profile;
    await _db.delete('user_cache');
    await _db.insert('user_cache', userToRow(profile));
  }

  Future<void> clear() async {
    _cached = null;
    await _db.delete('user_cache');
  }
}

Map<String, Object?> userToRow(AppUser profile) => {
  'id': profile.id,
  'email': profile.email,
  'first_name': profile.firstName,
  'last_name': profile.lastName,
  'dob': profile.dob?.toIso8601String(),
  'phone': profile.phone,
  'state': profile.state,
  'interests_json': jsonEncode(profile.interests.toJson()),
  'avatar_url': profile.avatarUrl,
  'display_name': profile.displayName,
  'role': profile.role.name,
  'banned': profile.banned ? 1 : 0,
  'created_at': profile.createdAt.toIso8601String(),
};

AppUser userFromRow(Map<String, Object?> row) => AppUser(
  id: row['id']! as String,
  email: row['email']! as String,
  firstName: row['first_name'] as String?,
  lastName: row['last_name'] as String?,
  dob: DateTime.tryParse(row['dob'] as String? ?? ''),
  phone: row['phone'] as String?,
  state: row['state'] as String?,
  interests: decodeInterests(row['interests_json'] as String?),
  avatarUrl: row['avatar_url'] as String?,
  displayName: row['display_name'] as String?,
  role: asEnumOrNull(UserRole.values, row['role']) ?? UserRole.customer,
  banned: (row['banned'] as int? ?? 0) == 1,
  createdAt: DateTime.parse(row['created_at']! as String),
);

CarInterests decodeInterests(String? json) {
  if (json == null || json.isEmpty) return const CarInterests();
  try {
    return CarInterests.fromJson(jsonDecode(json) as Map<String, dynamic>);
  } catch (_) {
    return const CarInterests();
  }
}
