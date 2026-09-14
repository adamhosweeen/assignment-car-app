import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Future<Database> open() async {
    final path = join(await getDatabasesPath(), 'carsell_v3.db');
    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
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
        await db.execute('''
          CREATE TABLE user_cache (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            first_name TEXT,
            last_name TEXT,
            display_name TEXT,
            dob TEXT,
            phone TEXT,
            state TEXT,
            interests_json TEXT,
            avatar_url TEXT,
            role TEXT,
            banned INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
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
            last_msg_offer_confirmed_at TEXT,
            last_msg_recalled_at TEXT
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
            image_path TEXT,
            created_at TEXT NOT NULL,
            read_at TEXT,
            offer_confirmed_at TEXT,
            recalled_at TEXT
          )
        ''');
        await db.execute('''
          CREATE INDEX message_cache_conversation_idx
            ON message_cache (conversation_id)
        ''');
        await db.execute('''
          CREATE TABLE inbox_cache (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            kind TEXT NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            listing_id TEXT,
            route TEXT,
            read_at TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX inbox_cache_user_idx
            ON inbox_cache (user_id, created_at DESC)
        ''');
        await db.execute('''
          CREATE TABLE other_user_cache (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            first_name TEXT,
            last_name TEXT,
            display_name TEXT,
            dob TEXT,
            phone TEXT,
            state TEXT,
            interests_json TEXT,
            avatar_url TEXT,
            role TEXT,
            banned INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        await _createBidTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createBidTables(db);
        if (oldVersion < 3) await _addChatRecallColumns(db);
        if (oldVersion < 4) await _addChatImageColumn(db);
      },
    );
  }

  static Future<void> _addChatRecallColumns(Database db) async {
    await db.execute('ALTER TABLE message_cache ADD COLUMN recalled_at TEXT');
    await db.execute(
      'ALTER TABLE conversation_cache ADD COLUMN last_msg_recalled_at TEXT',
    );
  }

  static Future<void> _addChatImageColumn(Database db) async {
    await db.execute('ALTER TABLE message_cache ADD COLUMN image_path TEXT');
  }

  static Future<void> _createBidTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS auction_cache (
        id TEXT NOT NULL,
        scope TEXT NOT NULL,
        user_id TEXT,
        sort_order INTEGER NOT NULL,
        listing_id TEXT NOT NULL,
        seller_id TEXT NOT NULL,
        starting_price_myr INTEGER NOT NULL,
        min_increment_myr INTEGER NOT NULL,
        ends_at TEXT NOT NULL,
        status TEXT NOT NULL,
        highest_bid_myr INTEGER,
        bid_count INTEGER NOT NULL,
        winning_bid_id TEXT,
        settled_at TEXT,
        created_at TEXT NOT NULL,
        listing_json TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        PRIMARY KEY (id, scope)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS auction_cache_scope_idx
        ON auction_cache (scope, user_id, sort_order)
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bid_cache (
        id TEXT NOT NULL,
        scope TEXT NOT NULL,
        user_id TEXT,
        sort_order INTEGER NOT NULL,
        listing_id TEXT NOT NULL,
        auction_id TEXT NOT NULL,
        bidder_id TEXT NOT NULL,
        amount_myr INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        PRIMARY KEY (id, scope)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS bid_cache_scope_idx
        ON bid_cache (scope, auction_id, user_id, sort_order)
    ''');
  }
}
