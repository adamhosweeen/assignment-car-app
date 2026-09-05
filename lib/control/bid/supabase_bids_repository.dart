import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';

class SupabaseBidsRepository implements BidsRepository {
  SupabaseBidsRepository(this._client);

  final SupabaseClient _client;
  static const Duration _fetchTimeout = Duration(seconds: 8);
  static const String _auctionSelect = '*, listings(*, listing_media(*))';
  static const String _bidSelect =
      '*, auctions(*, listings(*, listing_media(*)))';

  Future<void> _settleDue() async {
    try {
      await _client.rpc<void>('settle_due_auctions').timeout(_fetchTimeout);
    } catch (_) {
      // Settlement is opportunistic; a failure here must not block the read.
    }
  }

  Listing _listingFrom(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['media'] = (map.remove('listing_media') as List?) ?? const [];
    return Listing.fromJson(map);
  }

  AuctionWithListing _auctionFrom(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    final listingRow = map.remove('listings') as Map<String, dynamic>;
    return AuctionWithListing(
      auction: Auction.fromJson(map),
      listing: _listingFrom(listingRow),
    );
  }

  BidWithAuction _bidFrom(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    final auctionRow = map.remove('auctions') as Map<String, dynamic>;
    return BidWithAuction(
      bid: Bid.fromJson(map),
      auction: _auctionFrom(auctionRow),
    );
  }

  Future<List<AuctionWithListing>> _fetchLive() async {
    final rows = await _client
        .from('auctions')
        .select(_auctionSelect)
        .eq('status', 'running')
        .order('ends_at', ascending: true)
        .limit(50);
    return rows.map(_auctionFrom).toList();
  }

  Future<List<AuctionWithListing>> _fetchMyAuctions(String uid) async {
    final rows = await _client
        .from('auctions')
        .select(_auctionSelect)
        .eq('seller_id', uid)
        .order('created_at', ascending: false);
    return rows.map(_auctionFrom).toList();
  }

  Future<List<BidWithAuction>> _fetchMyBids(String uid) async {
    final rows = await _client
        .from('bids')
        .select(_bidSelect)
        .eq('bidder_id', uid)
        .order('created_at', ascending: false);
    return rows.map(_bidFrom).toList();
  }

  @override
  Stream<List<AuctionWithListing>> watchLiveAuctions() =>
      _watch(_fetchLive, 'auctions-live');

  @override
  Stream<List<AuctionWithListing>> watchMyAuctions() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);
    return _watch(() => _fetchMyAuctions(uid), 'auctions-mine-$uid');
  }

  @override
  Stream<List<BidWithAuction>> watchMyBids() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);
    return _watch(() => _fetchMyBids(uid), 'bids-mine-$uid');
  }

  @override
  Stream<AuctionWithListing> watchAuction(String auctionId) => _watch(() async {
    final row = await _client
        .from('auctions')
        .select(_auctionSelect)
        .eq('id', auctionId)
        .single();
    return _auctionFrom(row);
  }, 'auction-$auctionId');

  @override
  Stream<List<Bid>> watchBidsForAuction(String auctionId) => _watch(
    () async {
      final rows = await _client
          .from('bids')
          .select()
          .eq('auction_id', auctionId)
          .order('amount_myr', ascending: false);
      return rows.map(Bid.fromJson).toList();
    },
    'auction-bids-$auctionId',
    settle: false,
  );

  Stream<T> _watch<T>(
    Future<T> Function() fetch,
    String channelName, {
    bool settle = true,
  }) {
    final controller = StreamController<T>();
    RealtimeChannel? channel;
    var emitted = false;

    Future<void> push() async {
      try {
        if (settle) await _settleDue();
        final data = await fetch().timeout(_fetchTimeout);
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
        channel = _client.channel('$channelName-${newId()}')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'auctions',
            callback: (_) => push(),
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'bids',
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
  Future<Result<String>> startAuction({
    required String listingId,
    required int startingPriceMyr,
    required int minIncrementMyr,
    required DateTime endsAt,
  }) async {
    try {
      final id = await _client
          .rpc<String>(
            'start_auction',
            params: {
              'p_listing_id': listingId,
              'p_starting_price': startingPriceMyr,
              'p_min_increment': minIncrementMyr,
              'p_ends_at': endsAt.toUtc().toIso8601String(),
            },
          )
          .timeout(_fetchTimeout);
      return Ok(id);
    } catch (e) {
      return Err(_message(e));
    }
  }

  @override
  Future<Result<void>> placeBid(String auctionId, int amountMyr) async {
    try {
      await _client
          .rpc<String>(
            'place_bid',
            params: {'p_auction_id': auctionId, 'p_amount': amountMyr},
          )
          .timeout(_fetchTimeout);
      return const Ok(null);
    } catch (e) {
      return Err(_message(e));
    }
  }

  @override
  Future<Result<void>> cancelAuction(String auctionId) async {
    try {
      await _client
          .rpc<void>('cancel_auction', params: {'p_auction_id': auctionId})
          .timeout(_fetchTimeout);
      return const Ok(null);
    } catch (e) {
      return Err(_message(e));
    }
  }

  static const List<String> _passThrough = [
    'Bid at least',
    'auction has ended',
    'no longer available',
    'your own car',
    'Only the seller',
    'has to run its course',
    'Only a car that is on sale',
    'at most 7 days',
    'end in the future',
    'starting price',
    'minimum increment',
  ];

  String _message(Object error) {
    if (error is PostgrestException) {
      for (final fragment in _passThrough) {
        if (error.message.contains(fragment)) return error.message;
      }
    }
    return mapError(error);
  }
}
