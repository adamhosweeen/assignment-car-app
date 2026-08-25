import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../core/supabase/error_mapper.dart';
import '../domain/listing.dart';
import '../domain/listing_draft.dart';
import '../domain/listings_repository.dart';

/// Real [ListingsRepository] backed by Supabase Postgres + Storage + Realtime.
///
/// Reads join `listing_media`; `storage_path` is kept as the bucket path and
/// resolved to a signed URL at display time (see `signedImageUrlProvider`).
class SupabaseListingsRepository implements ListingsRepository {
  SupabaseListingsRepository(this._client);

  final SupabaseClient _client;
  static const String _bucket = 'listing-media';
  static const String _select = '*, listing_media(*)';

  // ── Reads ───────────────────────────────────────────────────────────────
  Future<List<Listing>> _fetchActive() async {
    final rows = await _client
        .from('listings')
        .select(_select)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map(_fromRow).toList();
  }

  Future<List<Listing>> _fetchBySeller(String sellerId) async {
    final rows = await _client
        .from('listings')
        .select(_select)
        .eq('seller_id', sellerId)
        .neq('status', 'deleted')
        .order('created_at', ascending: false);
    return rows.map(_fromRow).toList();
  }

  Listing _fromRow(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['media'] = (map.remove('listing_media') as List?) ?? const [];
    return Listing.fromJson(map);
  }

  @override
  Stream<List<Listing>> watchActive() =>
      _watch(_fetchActive, 'listings-active');

  @override
  Stream<List<Listing>> watchBySeller(String sellerId) =>
      _watch(() => _fetchBySeller(sellerId), 'listings-seller-$sellerId');

  /// Emit an initial fetch, then re-fetch whenever `listings` changes (realtime).
  Stream<List<Listing>> _watch(
    Future<List<Listing>> Function() fetch,
    String channelName,
  ) {
    final controller = StreamController<List<Listing>>();
    RealtimeChannel? channel;

    Future<void> push() async {
      try {
        final data = await fetch();
        if (!controller.isClosed) controller.add(data);
      } catch (_) {
        // Keep the last good value on a transient error.
      }
    }

    controller
      ..onListen = () {
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
          .maybeSingle();
      if (row == null) {
        return const Err('This listing is no longer available.');
      }
      return Ok(_fromRow(row));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  // ── Writes ────────────────────────────────────────────────────────────────
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
      // 1. Insert (or update, when editing) as draft.
      await _client.from('listings').upsert(_payload(draft, sellerId, 'draft'));

      // 2. Replace media: upload new local photos, reuse already-uploaded ones.
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
          objectPath = path; // already a bucket path (edit)
        }
        await _client.from('listing_media').insert({
          'listing_id': id,
          'storage_path': objectPath,
          'media_type': 'photo',
          'position': i,
        });
      }

      // 3. Flip to active only after every upload succeeded.
      await _client.from('listings').update({'status': 'active'}).eq('id', id);

      return getById(id);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> markSold(String id) => _setStatus(id, 'sold');

  @override
  Future<Result<void>> softDelete(String id) => _setStatus(id, 'deleted');

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
