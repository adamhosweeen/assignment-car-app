import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the on-device sqflite database. Schema is intentionally relational —
/// one table per entity, not a generic key-value blob store (CLAUDE.md §3).
class AppDatabase {
  static Future<Database> open() async {
    final path = join(await getDatabasesPath(), 'assignment.db');
    return openDatabase(
      path,
      version: 10,
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
          // v6 caches the profile's role (admin gate on Profile hub).
          await db.execute('ALTER TABLE profile_cache ADD COLUMN role TEXT');
          // v6 also collapses registration_region to west/east (migration
          // 0005). Map any in-progress draft; the feed cache just re-fetches.
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
          // v7 adds the chat read-cache (offline/cold-start Chat tab + thread).
          await _createChatCache(db);
        }
        if (oldVersion < 8) {
          // v8 adds the public-profile read-cache (offline names/avatars for
          // the other person in a chat thread, seller rows, seller pages).
          await _createPublicProfileCache(db);
        }
        if (oldVersion < 9) {
          // v9 caches an offer message's confirm state (migration 0008).
          await db.execute(
            'ALTER TABLE message_cache ADD COLUMN offer_confirmed_at TEXT',
          );
          await db.execute(
            'ALTER TABLE conversation_cache ADD COLUMN last_msg_offer_confirmed_at TEXT',
          );
        }
        if (oldVersion < 10) {
          // v10 adds the bid read-cache (offline/cold-start Bid tab,
          // migration 0009).
          await _createBidCache(db);
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

  /// Read-cache of the signed-in user's bids — both the ones they placed
  /// (`side = 'mine'`) and the ones received on their own listings
  /// (`side = 'received'`) — plus a snapshot of each bid's car, so the Bid tab
  /// renders instantly on cold start and stays readable offline. Written only
  /// after successful Supabase fetches; never authoritative (CLAUDE.md §3).
  ///
  /// The car is kept in its own table rather than denormalised onto the bid
  /// row because several bids can share one listing (a seller's car with three
  /// bids on it), and because it lets the listing columns stay identical to
  /// `listing_cache` and reuse the same encode/decode helpers.
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
    // Same columns as `listing_cache` so `listingToRow` / `listingFromRow`
    // encode and decode both.
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

  /// Read-cache of the signed-in user's chat threads (`conversation_cache`,
  /// one denormalised row per thread with its last-message preview) and, per
  /// thread, its full message history (`message_cache`). So the Chat tab and
  /// an already-opened thread render instantly on cold start and stay
  /// browsable offline. Written only after successful Supabase reads; never
  /// authoritative (CLAUDE.md §3).
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

  /// Read-cache of other users' `public_profiles` rows (`public_profile_cache`,
  /// one row per id ever looked up) — the other participant's name/avatar in
  /// a chat thread, a seller row on Listing Detail, a seller page. Written
  /// after every successful Supabase lookup; never authoritative (CLAUDE.md
  /// §3).
  static Future<void> _createPublicProfileCache(Database db) => db.execute('''
        CREATE TABLE public_profile_cache (
          id TEXT PRIMARY KEY,
          display_name TEXT,
          avatar_url TEXT,
          state TEXT,
          created_at TEXT NOT NULL
        )
      ''');

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
