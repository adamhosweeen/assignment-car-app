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
  );

  final Database db;
  final Map<String, Object?>? initialDraftRow;
  final List<String> initialDraftPhotoPaths;

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

    return AppStorage._(db, draftRow, photoPaths);
  }
}
