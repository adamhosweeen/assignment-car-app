import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the on-device sqflite database. Schema is intentionally relational —
/// one table per entity, not a generic key-value blob store (CLAUDE.md §3).
class AppDatabase {
  static Future<Database> open() async {
    final path = join(await getDatabasesPath(), 'assignment.db');
    return openDatabase(
      path,
      version: 3,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // v3 removes cached_session entirely: the fake backend that used it
          // is gone, and Supabase persists its own session. Drafts survive.
          await db.execute('DROP TABLE IF EXISTS cached_session');
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE listing_draft (
            id TEXT PRIMARY KEY,
            video_path TEXT,
            make TEXT,
            model TEXT,
            variant TEXT,
            year INTEGER,
            mileage_km INTEGER,
            transmission TEXT,
            fuel_type TEXT,
            body_type TEXT,
            colour TEXT,
            owners_count INTEGER,
            accident_free INTEGER,
            road_tax_expiry TEXT,
            registration_region TEXT,
            state TEXT,
            city TEXT,
            price_myr INTEGER,
            negotiable INTEGER NOT NULL DEFAULT 1,
            description TEXT,
            current_step INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE listing_draft_photo (
            draft_id TEXT NOT NULL REFERENCES listing_draft(id) ON DELETE CASCADE,
            position INTEGER NOT NULL,
            path TEXT NOT NULL,
            PRIMARY KEY (draft_id, position)
          )
        ''');
      },
    );
  }
}
