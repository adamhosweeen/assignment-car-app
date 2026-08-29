import 'package:sqflite/sqflite.dart';

import 'package:assignment/control/services/app_database.dart';

/// The open sqflite database plus whatever rows were already on disk at
/// launch, so the repositories below can decode them synchronously.
///
/// sqflite has no synchronous read API, but two call sites
/// (`DraftRepository.hasDraft`/`.load()`, used inside Riverpod `build()`
/// methods) need a synchronous answer. Since [init] is already awaited once in
/// `main()` before `runApp`, it does the one-time async row fetch here; the
/// repositories decode and cache in memory, then read that cache from then on
/// (CLAUDE.md §3: sqflite is a cache/draft store, never the source of truth).
class AppStorage {
  const AppStorage._(
    this.db,
    this.initialDraftRow,
    this.initialDraftPhotoPaths,
    this.initialProfileRow,
    this.initialListingRows,
    this.initialListingMediaRows,
  );

  final Database db;
  final Map<String, Object?>? initialDraftRow;
  final List<String> initialDraftPhotoPaths;
  final Map<String, Object?>? initialProfileRow;
  final List<Map<String, Object?>> initialListingRows;
  final List<Map<String, Object?>> initialListingMediaRows;

  static Future<AppStorage> init() async {
    final db = await AppDatabase.open();

    final draftRows = await db.query('listing_draft');
    final draftRow = draftRows.isEmpty ? null : draftRows.first;

    var photoPaths = const <String>[];
    if (draftRow != null) {
      final photoRows = await db.query(
        'listing_draft_photo',
        where: 'draft_id = ?',
        whereArgs: [draftRow['id']],
        orderBy: 'position ASC',
      );
      photoPaths = [for (final p in photoRows) p['path'] as String];
    }

    final profileRows = await db.query('profile_cache');
    final profileRow = profileRows.isEmpty ? null : profileRows.first;

    final listingRows = await db.query(
      'listing_cache',
      orderBy: 'sort_order ASC',
    );
    final listingMediaRows = await db.query('listing_cache_media');

    return AppStorage._(
      db,
      draftRow,
      photoPaths,
      profileRow,
      listingRows,
      listingMediaRows,
    );
  }
}
