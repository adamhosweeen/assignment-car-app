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

  Future<void> insert(AppUser user) async {
    _cached = user;
    await _db.transaction((txn) async {
      await txn.delete('user_cache', where: 'id <> ?', whereArgs: [user.id]);
      await txn.insert(
        'user_cache',
        userToRow(user),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> update(AppUser user) async {
    _cached = user;
    final changed = await _db.update(
      'user_cache',
      userToRow(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    if (changed == 0) await insert(user);
  }

  Future<void> delete(String id) async {
    if (_cached?.id == id) _cached = null;
    await _db.delete('user_cache', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    _cached = null;
    await _db.delete('user_cache');
  }
}

Map<String, Object?> userToRow(AppUser user) => {
  'id': user.id,
  'email': user.email,
  'first_name': user.firstName,
  'last_name': user.lastName,
  'dob': user.dob?.toIso8601String(),
  'phone': user.phone,
  'state': user.state,
  'interests_json': jsonEncode(user.interests.toJson()),
  'avatar_url': user.avatarUrl,
  'display_name': user.displayName,
  'role': user.role.name,
  'banned': user.banned ? 1 : 0,
  'created_at': user.createdAt.toIso8601String(),
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
