import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/listing/listing.dart';

/// sqflite read-cache of the active-listings feed (`listing_cache` +
/// `listing_cache_media`). Written after every successful Supabase fetch so
/// the Buy feed renders instantly on cold start and stays browsable offline.
/// Never authoritative — Supabase is the source of truth (CLAUDE.md §3).
class ListingsCacheRepository {
  ListingsCacheRepository(
    this._db,
    List<Map<String, Object?>> initialListingRows,
    List<Map<String, Object?>> initialMediaRows,
  ) : _cachedActive = decodeCachedFeed(initialListingRows, initialMediaRows);

  final Database _db;
  List<Listing> _cachedActive;

  /// The feed cached on disk at launch (or saved since), in feed order.
  List<Listing> get cachedActive => _cachedActive;

  Listing? getById(String id) =>
      _cachedActive.where((l) => l.id == id).firstOrNull;

  Future<void> saveActive(List<Listing> listings) async {
    _cachedActive = List.unmodifiable(listings);
    await _db.transaction((txn) async {
      await txn.delete('listing_cache');
      await txn.delete('listing_cache_media');
      for (var i = 0; i < listings.length; i++) {
        final listing = listings[i];
        await txn.insert('listing_cache', listingToRow(listing, i));
        for (final media in listing.media) {
          await txn.insert('listing_cache_media', media.toJson());
        }
      }
    });
  }
}

/// Flatten a [Listing] into a `listing_cache` row: its snake_case JSON with
/// the media list split off and bools stored as 0/1 (SQLite has no bool).
Map<String, Object?> listingToRow(Listing listing, int sortOrder) {
  final json = listing.toJson()
    ..remove('media')
    ..['sort_order'] = sortOrder;
  json['accident_free'] = (json['accident_free'] as bool) ? 1 : 0;
  json['negotiable'] = (json['negotiable'] as bool) ? 1 : 0;
  return json;
}

/// Rebuild a [Listing] from a `listing_cache` row plus its media rows.
Listing listingFromRow(
  Map<String, Object?> row,
  List<Map<String, Object?>> mediaRows,
) {
  final json = Map<String, dynamic>.from(row)
    ..remove('sort_order')
    ..['media'] = mediaRows.map(Map<String, dynamic>.from).toList();
  json['accident_free'] = (row['accident_free'] as int) != 0;
  json['negotiable'] = (row['negotiable'] as int) != 0;
  return Listing.fromJson(json);
}

/// Decode the rows pre-loaded by `AppStorage.init()` into an ordered feed.
List<Listing> decodeCachedFeed(
  List<Map<String, Object?>> listingRows,
  List<Map<String, Object?>> mediaRows,
) {
  try {
    return List.unmodifiable(
      listingRows.map(
        (row) => listingFromRow(
          row,
          mediaRows.where((m) => m['listing_id'] == row['id']).toList(),
        ),
      ),
    );
  } catch (_) {
    // A corrupt cache is worth less than an empty one.
    return const [];
  }
}
