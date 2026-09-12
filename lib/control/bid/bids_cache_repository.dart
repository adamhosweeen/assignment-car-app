import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/model/listing/listing.dart';

/// Which feed a cached row belongs to. The same auction can sit in several at
/// once — a seller's own auction is both [live] and [mine] — each with its own
/// position, which is why scope is part of the primary key rather than a
/// filter applied afterwards.
abstract final class AuctionScope {
  static const String live = 'live';
  static const String mine = 'mine';

  /// The auction behind one of my bids, kept so "My bids" can be rebuilt
  /// offline: a BidWithAuction is a bid joined to its auction.
  static const String bid = 'bid';

  /// Opened on its own detail page. Cached even when no list contains it.
  static const String one = 'one';

  /// Everything tied to a particular person, as opposed to the public feed.
  static const List<String> perUser = [mine, bid, one];
}

abstract final class BidScope {
  /// Every bid on one auction, as the auction page lists them.
  static const String auction = 'auction';

  /// My own bids across all auctions.
  static const String mine = 'mine';
}

/// The bidding module's local copy, so the Bid tab and an auction page still
/// render without a network.
///
/// Read-only by intention: nothing here authorises a write. Auction data is
/// contended — a stale `minimum_next_bid` would have the bidder type an amount
/// `place_bid` then rejects — so cached rows are for display, and the UI blocks
/// writes while offline rather than sending one against them.
class BidsCacheRepository {
  BidsCacheRepository(this._db);

  final Database _db;

  // ─── Create ──────────────────────────────────────────────────────────────

  /// Replaces everything cached under [scope], in the order given: the server
  /// decides the order, so it is written down rather than recomputed on read.
  Future<void> saveAuctions(
    String scope,
    String? userId,
    List<AuctionWithListing> entries, {
    DateTime? cachedAt,
  }) async {
    final at = cachedAt ?? DateTime.now().toUtc();
    await _db.transaction((txn) async {
      await txn.delete('auction_cache', where: 'scope = ?', whereArgs: [scope]);
      for (var i = 0; i < entries.length; i++) {
        await txn.insert(
          'auction_cache',
          auctionToRow(
            entries[i],
            scope: scope,
            userId: userId,
            sortOrder: i,
            cachedAt: at,
          ),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Caches one auction on its own, under [AuctionScope.one], leaving every
  /// other cached auction alone — unlike [saveAuctions], which owns its whole
  /// scope. Visiting a second auction page must not evict the first.
  Future<void> saveAuction(AuctionWithListing entry, {DateTime? cachedAt}) =>
      _db.insert(
        'auction_cache',
        auctionToRow(
          entry,
          scope: AuctionScope.one,
          userId: null,
          sortOrder: 0,
          cachedAt: cachedAt ?? DateTime.now().toUtc(),
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  /// Replaces the bids cached under [scope]. For [BidScope.auction] the delete
  /// is narrowed to one auction so the other auctions' bids survive.
  Future<void> saveBids(
    String scope,
    String? userId,
    List<Bid> bids, {
    String? auctionId,
    DateTime? cachedAt,
  }) async {
    final at = cachedAt ?? DateTime.now().toUtc();
    await _db.transaction((txn) async {
      if (auctionId != null) {
        await txn.delete(
          'bid_cache',
          where: 'scope = ? AND auction_id = ?',
          whereArgs: [scope, auctionId],
        );
      } else {
        await txn.delete('bid_cache', where: 'scope = ?', whereArgs: [scope]);
      }
      for (var i = 0; i < bids.length; i++) {
        await txn.insert(
          'bid_cache',
          bidToRow(
            bids[i],
            scope: scope,
            userId: userId,
            sortOrder: i,
            cachedAt: at,
          ),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ─── Read ────────────────────────────────────────────────────────────────

  Future<List<AuctionWithListing>> getAuctions(
    String scope,
    String? userId,
  ) async {
    final rows = await _db.query(
      'auction_cache',
      where: userId == null ? 'scope = ?' : 'scope = ? AND user_id = ?',
      whereArgs: userId == null ? [scope] : [scope, userId],
      orderBy: 'sort_order ASC',
    );
    return decodeCachedAuctions(rows);
  }

  /// Whichever scope happens to hold it — a detail page does not care how the
  /// auction was reached.
  Future<AuctionWithListing?> getAuctionById(String id) async {
    final rows = await _db.query(
      'auction_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return decodeCachedAuctions(rows).firstOrNull;
  }

  Future<List<Bid>> getBidsForAuction(String auctionId) async {
    final rows = await _db.query(
      'bid_cache',
      where: 'scope = ? AND auction_id = ?',
      whereArgs: [BidScope.auction, auctionId],
      orderBy: 'sort_order ASC',
    );
    return decodeCachedBids(rows);
  }

  /// Rebuilds `BidWithAuction`, which has no serialised form of its own: the
  /// bids come from one table and their auctions from the other, paired in
  /// Dart. A bid whose auction is missing is dropped rather than guessed at.
  Future<List<BidWithAuction>> getMyBids(String userId) async {
    final bidRows = await _db.query(
      'bid_cache',
      where: 'scope = ? AND user_id = ?',
      whereArgs: [BidScope.mine, userId],
      orderBy: 'sort_order ASC',
    );
    if (bidRows.isEmpty) return const [];

    final auctionRows = await _db.query(
      'auction_cache',
      where: 'scope = ?',
      whereArgs: [AuctionScope.bid],
    );
    return joinBidsToAuctions(
      decodeCachedBids(bidRows),
      decodeCachedAuctions(auctionRows),
    );
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  /// Patches one auction wherever it is already cached, leaving each copy's
  /// position alone. Used after a write the server accepted — an extended
  /// deadline or a new highest bid — so the cached copy does not contradict
  /// what the user just did.
  Future<void> upsertAuction(AuctionWithListing entry) async {
    final existing = await _db.query(
      'auction_cache',
      columns: ['scope', 'user_id', 'sort_order'],
      where: 'id = ?',
      whereArgs: [entry.auction.id],
    );
    if (existing.isEmpty) return;

    final at = DateTime.now().toUtc();
    final batch = _db.batch();
    for (final row in existing) {
      batch.insert(
        'auction_cache',
        auctionToRow(
          entry,
          scope: row['scope']! as String,
          userId: row['user_id'] as String?,
          sortOrder: row['sort_order']! as int,
          cachedAt: at,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  /// Mirrors a `delete_auction` the server accepted, in every scope at once,
  /// along with the bids that only existed to describe it.
  Future<void> deleteAuction(String id) async {
    await _db.transaction((txn) async {
      await txn.delete('auction_cache', where: 'id = ?', whereArgs: [id]);
      await txn.delete('bid_cache', where: 'auction_id = ?', whereArgs: [id]);
    });
  }

  /// Drops everything belonging to a person, keeping the public live feed.
  /// Called on sign-out: the next person on this device must not find the
  /// previous one's bids sitting in the Bid tab.
  Future<void> clearForUser() async {
    await _db.transaction((txn) async {
      await txn.delete(
        'auction_cache',
        where: 'scope IN (?, ?, ?)',
        whereArgs: AuctionScope.perUser,
      );
      await txn.delete('bid_cache');
    });
  }

  Future<void> clear() async {
    await _db.transaction((txn) async {
      await txn.delete('auction_cache');
      await txn.delete('bid_cache');
    });
  }
}

// ─── Row mapping ───────────────────────────────────────────────────────────
// Free functions, not methods, so they can be tested without a database — no
// test in this project opens one.

/// The columns `auction_cache` is declared with in `AppDatabase`.
///
/// Named here so a test can check the mapper emits exactly these. Without a
/// database in the test suite, a column added to one side and not the other
/// would otherwise surface only as a DatabaseException on a real device, on
/// the first tap of the Bid tab. **Keep in step with `AppDatabase`.**
const List<String> auctionCacheColumns = [
  'id',
  'scope',
  'user_id',
  'sort_order',
  'listing_id',
  'seller_id',
  'starting_price_myr',
  'min_increment_myr',
  'ends_at',
  'status',
  'highest_bid_myr',
  'bid_count',
  'winning_bid_id',
  'settled_at',
  'created_at',
  'listing_json',
  'cached_at',
];

/// The columns `bid_cache` is declared with. See [auctionCacheColumns].
const List<String> bidCacheColumns = [
  'id',
  'scope',
  'user_id',
  'sort_order',
  'listing_id',
  'auction_id',
  'bidder_id',
  'amount_myr',
  'status',
  'created_at',
  'updated_at',
  'cached_at',
];

/// The embedded listing rides along as JSON rather than in its own table.
/// `Listing.toJson` is already all-scalar down through its media list, so a
/// blob round-trips it whole with no bool-to-integer patching, and the auction
/// cache stays independent of `listing_cache` — which the buy feed wipes
/// wholesale on every refresh.
Map<String, Object?> auctionToRow(
  AuctionWithListing entry, {
  required String scope,
  required String? userId,
  required int sortOrder,
  required DateTime cachedAt,
}) {
  final row = entry.auction.toJson();
  row['scope'] = scope;
  row['user_id'] = userId;
  row['sort_order'] = sortOrder;
  row['listing_json'] = jsonEncode(entry.listing.toJson());
  row['cached_at'] = cachedAt.toIso8601String();
  return row;
}

AuctionWithListing auctionFromRow(Map<String, Object?> row) {
  final json = Map<String, dynamic>.from(row)
    ..remove('scope')
    ..remove('user_id')
    ..remove('sort_order')
    ..remove('listing_json')
    ..remove('cached_at');
  return AuctionWithListing(
    auction: Auction.fromJson(json),
    listing: Listing.fromJson(
      jsonDecode(row['listing_json']! as String) as Map<String, dynamic>,
    ),
  );
}

Map<String, Object?> bidToRow(
  Bid bid, {
  required String scope,
  required String? userId,
  required int sortOrder,
  required DateTime cachedAt,
}) {
  final row = bid.toJson();
  row['scope'] = scope;
  row['user_id'] = userId;
  row['sort_order'] = sortOrder;
  row['cached_at'] = cachedAt.toIso8601String();
  return row;
}

Bid bidFromRow(Map<String, Object?> row) => Bid.fromJson(
  Map<String, dynamic>.from(row)
    ..remove('scope')
    ..remove('user_id')
    ..remove('sort_order')
    ..remove('cached_at'),
);

/// A cache that cannot be read is the same as no cache: the app falls back to
/// the network rather than failing to start. Decoding is all-or-nothing so a
/// single unreadable row can never leave a half-built feed on screen.
List<AuctionWithListing> decodeCachedAuctions(List<Map<String, Object?>> rows) {
  try {
    return List.unmodifiable(rows.map(auctionFromRow));
  } catch (_) {
    return const [];
  }
}

/// Rebuilds `BidWithAuction`, which is stored as two rows because it has no
/// serialised form of its own, keeping [bids] in the order they were cached.
///
/// A bid whose auction is missing is dropped rather than guessed at: the card
/// is built almost entirely out of the auction — the car, its photo, the
/// countdown, the current price — so there would be nothing to draw.
List<BidWithAuction> joinBidsToAuctions(
  List<Bid> bids,
  List<AuctionWithListing> auctions,
) {
  final byId = {for (final entry in auctions) entry.auction.id: entry};
  return List.unmodifiable([
    for (final bid in bids)
      if (byId[bid.auctionId] case final auction?)
        BidWithAuction(bid: bid, auction: auction),
  ]);
}

List<Bid> decodeCachedBids(List<Map<String, Object?>> rows) {
  try {
    return List.unmodifiable(rows.map(bidFromRow));
  } catch (_) {
    return const [];
  }
}
