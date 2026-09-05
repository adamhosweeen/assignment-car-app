import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/profile/public_profile.dart';

class ProfilesCacheRepository {
  ProfilesCacheRepository(this._db);

  final Database _db;

  Future<PublicProfile?> getById(String id) async {
    final rows = await _db.query(
      'public_profile_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PublicProfile.fromJson(Map<String, dynamic>.from(rows.first));
  }

  Future<void> save(PublicProfile profile) => _db.insert(
    'public_profile_cache',
    profile.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
