import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/listing/listing.dart';

class ListingsCacheRepository {
  ListingsCacheRepository(
    this._db,
    List<Map<String, Object?>> initialListingRows,
    List<Map<String, Object?>> initialMediaRows,
  ) : _cachedActive = decodeCachedFeed(initialListingRows, initialMediaRows);

  final Database _db;
  List<Listing> _cachedActive;

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

Map<String, Object?> listingToRow(Listing listing, int sortOrder) {
  final json = listing.toJson()
    ..remove('media')
    ..['sort_order'] = sortOrder;
  json['accident_free'] = (json['accident_free'] as bool) ? 1 : 0;
  json['negotiable'] = (json['negotiable'] as bool) ? 1 : 0;
  return json;
}

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
    return const [];
  }
}
