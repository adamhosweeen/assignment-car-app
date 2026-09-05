import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/search.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/control/listings/listings_cache_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';

class SupabaseListingsRepository implements ListingsRepository {
  SupabaseListingsRepository(this._client, this._cache);

  final SupabaseClient _client;
  final ListingsCacheRepository _cache;
  static const String _bucket = 'listing-media';
  static const String _select = '*, listing_media(*)';
  static const List<String> _visibleStatuses = ['selling', 'bidding'];
  static const Duration _fetchTimeout = Duration(seconds: 8);

  Future<List<Listing>> _fetchActive() async {
    final rows = await _client
        .from('listings')
        .select(_select)
        .inFilter('status', _visibleStatuses)
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map(_fromRow).toList();
  }

  Future<List<Listing>> _fetchBySeller(String sellerId) async {
    final rows = await _client
        .from('listings')
        .select(_select)
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);
    return rows.map(_fromRow).toList();
  }

  Listing _fromRow(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['media'] = (map.remove('listing_media') as List?) ?? const [];
    return Listing.fromJson(map);
  }

  @override
  Stream<List<Listing>> watchActive() => _watch(
    _fetchActive,
    'listings-active',
    initial: _cache.cachedActive,
    onFetched: _cache.saveActive,
  );

  @override
  Stream<List<Listing>> watchBySeller(String sellerId) =>
      _watch(() => _fetchBySeller(sellerId), 'listings-seller-$sellerId');

  Future<List<Listing>> _fetchActiveBySeller(String sellerId) async {
    final rows = await _client
        .from('listings')
        .select(_select)
        .eq('seller_id', sellerId)
        .eq('status', 'selling')
        .order('created_at', ascending: false);
    return rows.map(_fromRow).toList();
  }

  @override
  Stream<List<Listing>> watchActiveBySeller(String sellerId) => _watch(
    () => _fetchActiveBySeller(sellerId),
    'listings-seller-active-$sellerId',
  );

  @override
  Future<Result<List<Listing>>> searchActive(String query) async {
    final q = sanitizeSearchQuery(query);
    if (q.isEmpty) return const Ok([]);
    try {
      final rows = await _client
          .from('listings')
          .select(_select)
          .inFilter('status', _visibleStatuses)
          .or('make.ilike.%$q%,model.ilike.%$q%,variant.ilike.%$q%')
          .order('created_at', ascending: false)
          .limit(50)
          .timeout(_fetchTimeout);
      return Ok(rows.map(_fromRow).toList());
    } catch (e) {
      return Err(mapError(e));
    }
  }

  Stream<List<Listing>> _watch(
    Future<List<Listing>> Function() fetch,
    String channelName, {
    List<Listing>? initial,
    Future<void> Function(List<Listing>)? onFetched,
  }) {
    final controller = StreamController<List<Listing>>();
    RealtimeChannel? channel;
    var emitted = false;

    Future<void> push() async {
      try {
        final data = await fetch().timeout(_fetchTimeout);
        if (!controller.isClosed) {
          controller.add(data);
          emitted = true;
        }
        await onFetched?.call(data);
      } catch (e) {
        if (!emitted && !controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () {
        if (initial != null && initial.isNotEmpty) {
          controller.add(initial);
          emitted = true;
        }
        push();
        channel = _client.channel('$channelName-${newId()}')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'listings',
            callback: (_) => push(),
          )
          ..subscribe();
      }
      ..onCancel = () async {
        final ch = channel;
        if (ch != null) await _client.removeChannel(ch);
        if (!controller.isClosed) await controller.close();
      };

    return controller.stream;
  }

  @override
  Future<Result<Listing>> getById(String id) async {
    try {
      final row = await _client
          .from('listings')
          .select(_select)
          .eq('id', id)
          .maybeSingle()
          .timeout(_fetchTimeout);
      if (row == null) {
        return const Err('This listing is no longer available.');
      }
      return Ok(_fromRow(row));
    } catch (e) {
      final cached = _cache.getById(id);
      if (cached != null) return Ok(cached);
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Listing>> publish(ListingDraft draft, String sellerId) async {
    final missing = _firstMissingField(draft);
    if (missing != null) {
      return Err('$missing is missing. Go back and complete every step.');
    }
    if ((draft.priceMyr ?? 0) > kMaxPriceMyr) {
      return const Err(
        'That price is too high to publish. Enter a smaller amount.',
      );
    }
    final id = draft.id;
    try {
      await _client
          .from('listings')
          .upsert(_payload(draft, sellerId, 'hidden'));

      await _client.from('listing_media').delete().eq('listing_id', id);
      for (var i = 0; i < draft.photoPaths.length; i++) {
        final path = draft.photoPaths[i];
        final file = File(path);
        final String objectPath;
        if (file.existsSync()) {
          objectPath = '$sellerId/$id/${newId()}.jpg';
          await _client.storage
              .from(_bucket)
              .upload(
                objectPath,
                file,
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
        } else {
          objectPath = path;
        }
        await _client.from('listing_media').insert({
          'listing_id': id,
          'storage_path': objectPath,
          'media_type': 'photo',
          'position': i,
        });
      }

      await _client.from('listings').update({'status': 'selling'}).eq('id', id);

      return getById(id);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> markSold(String id) => _setStatus(id, 'sold');

  @override
  Future<Result<void>> buy(String id) async {
    try {
      await _client.rpc('buy_listing', params: {'p_listing_id': id});
      return const Ok(null);
    } on PostgrestException catch (e) {
      if (e.message.contains('no longer available')) return Err(e.message);
      return Err(mapError(e));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> hide(String id) => _setStatus(id, 'hidden');

  @override
  Future<Result<void>> unhide(String id) => _setStatus(id, 'selling');

  @override
  Future<Result<void>> deleteListing(String id) async {
    try {
      await _client.from('listings').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  Future<Result<void>> _setStatus(String id, String status) async {
    try {
      await _client.from('listings').update({'status': status}).eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  Map<String, dynamic> _payload(
    ListingDraft d,
    String sellerId,
    String status,
  ) => {
    'id': d.id,
    'seller_id': sellerId,
    'status': status,
    'make': d.make,
    'model': d.model,
    'variant': d.variant,
    'year': d.year,
    'mileage_km': d.mileageKm,
    'transmission': d.transmission!.name,
    'fuel_type': d.fuelType!.name,
    'body_type': d.bodyType!.name,
    'colour': d.colour,
    'owners_count': d.ownersCount,
    'accident_free': d.accidentFree ?? false,
    'road_tax_expiry': d.roadTaxExpiry?.toIso8601String().substring(0, 10),
    'registration_region': d.registrationRegion!.name,
    'state': d.state,
    'city': d.city,
    'price_myr': d.priceMyr,
    'negotiable': d.negotiable,
    'description': d.description,
  };

  String? _firstMissingField(ListingDraft d) {
    if (d.photoPaths.length < 3) return 'At least 3 photos';
    if (d.make == null) return 'Make';
    if (d.model == null) return 'Model';
    if (d.year == null) return 'Year';
    if (d.mileageKm == null) return 'Mileage';
    if (d.transmission == null) return 'Transmission';
    if (d.fuelType == null) return 'Fuel type';
    if (d.bodyType == null) return 'Body type';
    if (d.colour == null || d.colour!.isEmpty) return 'Colour';
    if (d.ownersCount == null) return 'Owners count';
    if (d.registrationRegion == null) return 'Registration region';
    if (d.state == null) return 'State';
    if (d.city == null || d.city!.isEmpty) return 'City';
    if (d.priceMyr == null) return 'Price';
    return null;
  }
}
