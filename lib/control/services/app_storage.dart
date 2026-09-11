import 'package:sqflite/sqflite.dart';

import 'package:assignment/control/services/app_database.dart';

class AppStorage {
  const AppStorage._(
    this.db,
    this.initialDraftRow,
    this.initialDraftPhotoPaths,
    this.initialProfileRow,
    this.initialListingRows,
    this.initialListingMediaRows,
    this.initialConversationRows,
  );

  final Database db;
  final Map<String, Object?>? initialDraftRow;
  final List<String> initialDraftPhotoPaths;
  final Map<String, Object?>? initialProfileRow;
  final List<Map<String, Object?>> initialListingRows;
  final List<Map<String, Object?>> initialListingMediaRows;
  final List<Map<String, Object?>> initialConversationRows;

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

    final profileRows = await db.query('user_cache');
    final profileRow = profileRows.isEmpty ? null : profileRows.first;

    final listingRows = await db.query(
      'listing_cache',
      orderBy: 'sort_order ASC',
    );
    final listingMediaRows = await db.query('listing_cache_media');

    final conversationRows = await db.query(
      'conversation_cache',
      orderBy: 'sort_order ASC',
    );

    return AppStorage._(
      db,
      draftRow,
      photoPaths,
      profileRow,
      listingRows,
      listingMediaRows,
      conversationRows,
    );
  }
}
