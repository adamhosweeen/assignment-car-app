import 'package:sqflite/sqflite.dart';

import 'package:assignment/control/listings/listings_cache_repository.dart'
    show listingFromRow, listingToRow;
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';

enum BidSide { mine, received }

class BidsCacheRepository {
  BidsCacheRepository(
    this._db,
    List<Map<String, Object?>> initialBidRows,
    List<Map<String, Object?>> initialListingRows,
    List<Map<String, Object?>> initialMediaRows,
  ) : _cached = {
        for (final side in BidSide.values)
          side: decodeCachedBids(
            initialBidRows.where((r) => r['side'] == side.name).toList(),
            initialListingRows,
            initialMediaRows,
          ),
      };

  final Database _db;
  final Map<BidSide, List<BidWithListing>> _cached;

  List<BidWithListing> cached(BidSide side) => _cached[side] ?? const [];

  Future<void> save(BidSide side, List<BidWithListing> bids) async {
    _cached[side] = List.unmodifiable(bids);
    await _db.transaction((txn) async {
      await txn.delete('bid_cache', where: 'side = ?', whereArgs: [side.name]);
      for (var i = 0; i < bids.length; i++) {
        await txn.insert('bid_cache', bidToRow(bids[i].bid, side, i));
      }

      final referenced = <String, BidWithListing>{
        for (final list in _cached.values)
          for (final entry in list) entry.listing.id: entry,
      };
      await txn.delete('bid_cache_listing');
      await txn.delete('bid_cache_listing_media');
      for (final entry in referenced.values) {
        await txn.insert('bid_cache_listing', listingToRow(entry.listing, 0));
        for (final media in entry.listing.media) {
          await txn.insert('bid_cache_listing_media', media.toJson());
        }
      }
    });
  }

  Future<void> clear() async {
    for (final side in BidSide.values) {
      _cached[side] = const [];
    }
    await _db.delete('bid_cache');
    await _db.delete('bid_cache_listing');
    await _db.delete('bid_cache_listing_media');
  }
}

Map<String, Object?> bidToRow(Bid bid, BidSide side, int sortOrder) {
  final json = bid.toJson()
    ..['side'] = side.name
    ..['sort_order'] = sortOrder;
  json['notify_whatsapp'] = (json['notify_whatsapp'] as bool) ? 1 : 0;
  return json;
}

Bid bidFromRow(Map<String, Object?> row) {
  final json = Map<String, dynamic>.from(row)
    ..remove('side')
    ..remove('sort_order');
  json['notify_whatsapp'] = (row['notify_whatsapp'] as int) != 0;
  return Bid.fromJson(json);
}

List<BidWithListing> decodeCachedBids(
  List<Map<String, Object?>> bidRows,
  List<Map<String, Object?>> listingRows,
  List<Map<String, Object?>> mediaRows,
) {
  try {
    final out = <BidWithListing>[];
    for (final row in bidRows) {
      final listingRow = listingRows
          .where((l) => l['id'] == row['listing_id'])
          .firstOrNull;
      if (listingRow == null) continue;
      out.add(
        BidWithListing(
          bid: bidFromRow(row),
          listing: listingFromRow(
            listingRow,
            mediaRows
                .where((m) => m['listing_id'] == listingRow['id'])
                .toList(),
          ),
        ),
      );
    }
    return List.unmodifiable(out);
  } catch (_) {
    return const [];
  }
}
