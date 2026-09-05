import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';

class ProfileCacheRepository {
  ProfileCacheRepository(this._db, Map<String, Object?>? initialRow)
    : _cached = initialRow == null ? null : profileFromRow(initialRow);

  final Database _db;
  Profile? _cached;

  Profile? get cached => _cached;

  Future<void> save(Profile profile) async {
    _cached = profile;
    await _db.delete('profile_cache');
    await _db.insert('profile_cache', profileToRow(profile));
  }

  Future<void> clear() async {
    _cached = null;
    await _db.delete('profile_cache');
  }
}

Map<String, Object?> profileToRow(Profile profile) => {
  'id': profile.id,
  'email': profile.email,
  'first_name': profile.firstName,
  'last_name': profile.lastName,
  'dob': profile.dob?.toIso8601String(),
  'phone': profile.phone,
  'state': profile.state,
  'interests_json': jsonEncode(profile.interests.toJson()),
  'avatar_url': profile.avatarUrl,
  'role': profile.role,
  'created_at': profile.createdAt.toIso8601String(),
};

Profile profileFromRow(Map<String, Object?> row) => Profile(
  id: row['id']! as String,
  email: row['email']! as String,
  firstName: row['first_name'] as String?,
  lastName: row['last_name'] as String?,
  dob: DateTime.tryParse(row['dob'] as String? ?? ''),
  phone: row['phone'] as String?,
  state: row['state'] as String?,
  interests: decodeInterests(row['interests_json'] as String?),
  avatarUrl: row['avatar_url'] as String?,
  role: row['role'] as String? ?? 'user',
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
