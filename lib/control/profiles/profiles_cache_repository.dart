import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/profile/public_profile.dart';

/// sqflite read-cache of other users' `public_profiles` rows
/// (`public_profile_cache`), one row per id ever looked up — the other
/// participant's name/avatar in a chat thread, a seller row on Listing
/// Detail, a seller page. Written after every successful Supabase lookup so
/// a previously-seen profile still renders offline. Never authoritative —
/// Supabase is the source of truth (CLAUDE.md §3).
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
