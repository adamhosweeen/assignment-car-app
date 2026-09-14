import 'package:sqflite/sqflite.dart';

import 'package:assignment/control/user/auth/user_cache.dart';
import 'package:assignment/model/user/app_user.dart';

class OtherUsersCache {
  OtherUsersCache(this._db);

  final Database _db;

  Future<AppUser?> getById(String id) async {
    final rows = await _db.query(
      'other_user_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return userFromRow(rows.first);
  }

  Future<void> save(AppUser user) => _db.insert(
    'other_user_cache',
    userToRow(user),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Future<void> clear() async {
    await _db.delete('other_user_cache');
  }
}
