import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Future<Database> open() async {
    final path = join(await getDatabasesPath(), 'assignment.db');
    return openDatabase(
      path,
      version: 11,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS cached_session');
        }
        if (oldVersion < 4) {
          await _createProfileCache(db);
        }
        if (oldVersion < 5) {
          await _createListingCache(db);
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE profile_cache ADD COLUMN role TEXT');
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
        if (oldVersion < 7) {
          await _createChatCache(db);
        }
        if (oldVersion < 8) {
          await _createPublicProfileCache(db);
        }
        if (oldVersion < 9) {
          await db.execute(
            'ALTER TABLE message_cache ADD COLUMN offer_confirmed_at TEXT',
          );
          await db.execute(
            'ALTER TABLE conversation_cache ADD COLUMN last_msg_offer_confirmed_at TEXT',
          );
        }
        if (oldVersion < 10) {
          await _createBidCache(db);
        }
        if (oldVersion < 11) {
          await db.execute('DELETE FROM listing_cache_media');
          await db.execute('DELETE FROM listing_cache');
          await db.execute('DELETE FROM bid_cache_listing_media');
          await db.execute('DELETE FROM bid_cache_listing');
          await db.execute('DELETE FROM bid_cache');
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
        await _createChatCache(db);
        await _createPublicProfileCache(db);
        await _createBidCache(db);
      },
    );
  }

  static Future<void> _createBidCache(Database db) async {
    await db.execute('''
        CREATE TABLE bid_cache (
          id TEXT PRIMARY KEY,
          listing_id TEXT NOT NULL,
          bidder_id TEXT NOT NULL,
          amount_myr INTEGER NOT NULL,
          status TEXT NOT NULL,
          contact_phone TEXT,
          notify_whatsapp INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          side TEXT NOT NULL,
          sort_order INTEGER NOT NULL
        )
      ''');
    await db.execute('''
        CREATE INDEX bid_cache_side_idx ON bid_cache (side, sort_order)
      ''');
    await db.execute('''
        CREATE TABLE bid_cache_listing (
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
        CREATE TABLE bid_cache_listing_media (
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

  static Future<void> _createChatCache(Database db) async {
    await db.execute('''
        CREATE TABLE conversation_cache (
          id TEXT PRIMARY KEY,
          listing_id TEXT NOT NULL,
          buyer_id TEXT NOT NULL,
          seller_id TEXT NOT NULL,
          created_at TEXT NOT NULL,
          last_message_at TEXT,
          unread_count INTEGER NOT NULL,
          sort_order INTEGER NOT NULL,
          last_msg_id TEXT,
          last_msg_sender_id TEXT,
          last_msg_body TEXT,
          last_msg_type TEXT,
          last_msg_offer_amount_myr INTEGER,
          last_msg_created_at TEXT,
          last_msg_read_at TEXT,
          last_msg_offer_confirmed_at TEXT
        )
      ''');
    await db.execute('''
        CREATE TABLE message_cache (
          id TEXT PRIMARY KEY,
          conversation_id TEXT NOT NULL,
          sender_id TEXT NOT NULL,
          body TEXT NOT NULL,
          message_type TEXT NOT NULL,
          offer_amount_myr INTEGER,
          created_at TEXT NOT NULL,
          read_at TEXT,
          offer_confirmed_at TEXT
        )
      ''');
    await db.execute('''
        CREATE INDEX message_cache_conversation_idx
          ON message_cache (conversation_id)
      ''');
  }

  static Future<void> _createPublicProfileCache(Database db) => db.execute('''
        CREATE TABLE public_profile_cache (
          id TEXT PRIMARY KEY,
          display_name TEXT,
          avatar_url TEXT,
          state TEXT,
          created_at TEXT NOT NULL
        )
      ''');

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
