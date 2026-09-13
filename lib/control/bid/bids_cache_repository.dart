import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/model/listing/listing.dart';

abstract final class AuctionScope {
  static const String live = 'live';
  static const String mine = 'mine';
  static const String bid = 'bid';

  static const String one = 'one';

  static const List<String> perUser = [mine, bid, one];
}

abstract final class BidScope {
  static const String auction = 'auction';

  static const String mine = 'mine';
}

class BidsCacheRepository {
  BidsCacheRepository(this._db);

  final Database _db;

  // ─── Create ──────────────────────────────────────────────────────────────
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
  Future<void> deleteAuction(String id) async {
    await _db.transaction((txn) async {
      await txn.delete('auction_cache', where: 'id = ?', whereArgs: [id]);
      await txn.delete('bid_cache', where: 'auction_id = ?', whereArgs: [id]);
    });
  }

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

List<AuctionWithListing> decodeCachedAuctions(List<Map<String, Object?>> rows) {
  try {
    return List.unmodifiable(rows.map(auctionFromRow));
  } catch (_) {
    return const [];
  }
}

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
