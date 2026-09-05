import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/bid/bids_cache_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_validation.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';

class SupabaseBidsRepository implements BidsRepository {
  SupabaseBidsRepository(this._client, this._cache);

  final SupabaseClient _client;
  final BidsCacheRepository _cache;

  static const Duration _fetchTimeout = Duration(seconds: 8);

  static const String _selectWithListing = '*, listings(*, listing_media(*))';

  static BidWithListing? _fromJoinedRow(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    final listingJson = map.remove('listings');
    if (listingJson is! Map) return null;
    final listing = Map<String, dynamic>.from(listingJson);
    listing['media'] = (listing.remove('listing_media') as List?) ?? const [];
    return BidWithListing(
      bid: Bid.fromJson(map),
      listing: Listing.fromJson(listing),
    );
  }

  Future<List<BidWithListing>> _fetchMyBids(String uid) async {
    final rows = await _client
        .from('bids')
        .select(_selectWithListing)
        .eq('bidder_id', uid)
        .order('created_at', ascending: false);
    return rows.map(_fromJoinedRow).nonNulls.toList();
  }

  Future<List<BidWithListing>> _fetchReceived(String uid) async {
    final rows = await _client
        .from('bids')
        .select('*, listings!inner(*, listing_media(*))')
        .eq('listings.seller_id', uid)
        .order('created_at', ascending: false);
    return rows.map(_fromJoinedRow).nonNulls.toList();
  }

  @override
  Stream<List<BidWithListing>> watchMyBids() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);
    return _watchList(
      () => _fetchMyBids(uid),
      'bids-mine-$uid',
      side: BidSide.mine,
    );
  }

  @override
  Stream<List<BidWithListing>> watchBidsReceived() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);
    return _watchList(
      () => _fetchReceived(uid),
      'bids-received-$uid',
      side: BidSide.received,
    );
  }

  Stream<List<BidWithListing>> _watchList(
    Future<List<BidWithListing>> Function() fetch,
    String channelName, {
    required BidSide side,
  }) {
    final controller = StreamController<List<BidWithListing>>();
    RealtimeChannel? channel;
    var emitted = false;

    Future<void> push() async {
      try {
        final data = await fetch().timeout(_fetchTimeout);
        debugPrint('[bid] ${side.name} push: ${data.length} bid(s)');
        if (!controller.isClosed) {
          controller.add(data);
          emitted = true;
        }
        await _cache.save(side, data);
      } catch (e) {
        debugPrint('[bid] ${side.name} push FAILED: $e');
        if (!emitted && !controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () {
        final cached = _cache.cached(side);
        if (cached.isNotEmpty) {
          controller.add(cached);
          emitted = true;
        }
        push();
        channel = _client.channel('$channelName-${newId()}')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'bids',
            callback: (payload) {
              debugPrint('[bid] ${side.name}: bids ${payload.eventType}');
              push();
            },
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'listings',
            callback: (payload) {
              debugPrint('[bid] ${side.name}: listings ${payload.eventType}');
              push();
            },
          )
          ..subscribe(
            (status, error) => debugPrint(
              '[bid] $channelName channel: $status'
              '${error == null ? '' : ' ($error)'}',
            ),
          );
      }
      ..onCancel = () async {
        final ch = channel;
        if (ch != null) await _client.removeChannel(ch);
        if (!controller.isClosed) await controller.close();
      };

    return controller.stream;
  }

  @override
  Stream<List<Bid>> watchBidsForListing(String listingId) {
    final controller = StreamController<List<Bid>>();
    RealtimeChannel? channel;
    var emitted = false;

    Future<void> push() async {
      try {
        final rows = await _client
            .from('bids')
            .select()
            .eq('listing_id', listingId)
            .order('created_at', ascending: false)
            .timeout(_fetchTimeout);
        final data = rows.map(Bid.fromJson).toList();
        if (!controller.isClosed) {
          controller.add(data);
          emitted = true;
        }
      } catch (e) {
        if (!emitted && !controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () {
        push();
        channel = _client.channel('bids-listing-$listingId-${newId()}')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'bids',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'listing_id',
              value: listingId,
            ),
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
  Future<Result<Bid?>> myPendingBidFor(String listingId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Err('You need to be signed in.');
    try {
      final row = await _client
          .from('bids')
          .select()
          .eq('listing_id', listingId)
          .eq('bidder_id', uid)
          .eq('status', 'pending')
          .maybeSingle()
          .timeout(_fetchTimeout);
      return Ok(row == null ? null : Bid.fromJson(row));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Bid>> placeBid(
    String listingId,
    int amountMyr, {
    required String contactPhone,
    bool notifyWhatsapp = false,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Err('You need to be signed in.');

    final phoneError = validateBidPhone(contactPhone);
    if (phoneError != null) return Err(phoneError);

    try {
      final listingRow = await _client
          .from('listings')
          .select('seller_id, status, price_myr')
          .eq('id', listingId)
          .maybeSingle()
          .timeout(_fetchTimeout);
      if (listingRow == null) {
        return const Err('This listing is no longer available.');
      }
      if (listingRow['seller_id'] as String == uid) {
        return const Err("You can't bid on your own car.");
      }
      if (listingRow['status'] as String != ListingStatus.active.name) {
        return const Err('This car is no longer available to bid on.');
      }

      final amountError = validateBidAmount(
        amountMyr.toString(),
        askingPriceMyr: listingRow['price_myr'] as int,
      );
      if (amountError != null) return Err(amountError);

      final existing = await myPendingBidFor(listingId);
      if (existing case Ok(value: final previous?)) {
        final withdrawn = await withdrawBid(previous.id);
        if (withdrawn case Err(:final message)) return Err(message);
      }

      final row = await _client
          .from('bids')
          .insert({
            'listing_id': listingId,
            'bidder_id': uid,
            'amount_myr': amountMyr,
            'contact_phone': contactPhone.trim(),
            'notify_whatsapp': notifyWhatsapp,
          })
          .select()
          .single()
          .timeout(_fetchTimeout);
      return Ok(Bid.fromJson(row));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> withdrawBid(String bidId) =>
      _transition('withdraw_bid', {'p_bid_id': bidId});

  @override
  Future<Result<void>> respondToBid(String bidId, {required bool accept}) =>
      _transition('respond_to_bid', {'p_bid_id': bidId, 'p_accept': accept});

  Future<Result<void>> _transition(
    String function,
    Map<String, dynamic> params,
  ) async {
    try {
      await _client.rpc<void>(function, params: params).timeout(_fetchTimeout);
      return const Ok(null);
    } on PostgrestException catch (e) {
      const passThrough = [
        'Bid not found.',
        'no longer pending',
        'no longer available',
        'Only the bidder',
        'Only the seller',
      ];
      if (passThrough.any(e.message.contains)) return Err(e.message);
      return Err(mapError(e));
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
