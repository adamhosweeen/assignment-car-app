import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the on-device sqflite database. Schema is intentionally relational —
/// one table per entity, not a generic key-value blob store (CLAUDE.md §3).
class AppDatabase {
  static Future<Database> open() async {
    final path = join(await getDatabasesPath(), 'assignment.db');
    return openDatabase(
      path,
      version: 6,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // v3 removes cached_session entirely: the fake backend that used it
          // is gone, and Supabase persists its own session. Drafts survive.
          await db.execute('DROP TABLE IF EXISTS cached_session');
        }
        if (oldVersion < 4) {
          // v4 adds the profile read-cache (offline/cold-start Profile tab).
          await _createProfileCache(db);
        }
        if (oldVersion < 5) {
          // v5 adds the feed read-cache (offline/cold-start Buy feed).
          await _createListingCache(db);
        }
        if (oldVersion < 6) {
          // v6 (master) caches the profile's role (admin gate on Profile hub).
          await db.execute('ALTER TABLE profile_cache ADD COLUMN role TEXT');
          // v6 (Listing) collapses registration_region to west/east
          // (migration 0005). Map any in-progress draft; the feed cache
          // just re-fetches.
          await db.execute('''
            UPDATE listing_draft SET registration_region = CASE registration_region
              WHEN 'peninsular' THEN 'west'
              WHEN 'sabah' THEN 'east'
              WHEN 'sarawak' THEN 'east'
              ELSE registration_region END
          ''');
          await db.execute('DELETE FROM listing_cache_media');
          await db.execute('DELETE FROM listing_cache');
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
        await _createProfileCache(db);
        await _createListingCache(db);
      },
    );
  }

  /// Read-cache of the active-listings feed, so the Buy feed renders
  /// instantly on cold start and offline. Written only after successful
  /// Supabase fetches; never authoritative (CLAUDE.md §3).
  static Future<void> _createListingCache(Database db) async {
    await db.execute('''
        CREATE TABLE listing_cache (
          id TEXT PRIMARY KEY,
          seller_id TEXT NOT NULL,
          status TEXT NOT NULL,
          make TEXT NOT NULL,
          model TEXT NOT NULL,
          variant TEXT,
          year INTEGER NOT NULL,
          mileage_km INTEGER NOT NULL,
          transmission TEXT NOT NULL,
          fuel_type TEXT NOT NULL,
          body_type TEXT NOT NULL,
          colour TEXT NOT NULL,
          owners_count INTEGER NOT NULL,
          accident_free INTEGER NOT NULL,
          road_tax_expiry TEXT,
          registration_region TEXT NOT NULL,
          state TEXT NOT NULL,
          city TEXT NOT NULL,
          price_myr INTEGER NOT NULL,
          negotiable INTEGER NOT NULL,
          description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          sort_order INTEGER NOT NULL
        )
      ''');
    await db.execute('''
        CREATE TABLE listing_cache_media (
          id TEXT NOT NULL,
          listing_id TEXT NOT NULL,
          storage_path TEXT NOT NULL,
          media_type TEXT NOT NULL,
          position INTEGER NOT NULL,
          created_at TEXT,
          PRIMARY KEY (listing_id, position)
        )
      ''');
  }

  /// Read-cache of the signed-in user's `profiles` row, so identity renders
  /// instantly on cold start and offline. Written only after successful
  /// Supabase reads; never authoritative (CLAUDE.md §3).
  static Future<void> _createProfileCache(Database db) => db.execute('''
        CREATE TABLE profile_cache (
          id TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          first_name TEXT,
          last_name TEXT,
          dob TEXT,
          phone TEXT,
          state TEXT,
          interests_json TEXT,
          avatar_url TEXT,
          role TEXT,
          created_at TEXT NOT NULL
        )
      ''');
}
