import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/bid/bids_cache_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/model/bid/bids_sync_status.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';

class SupabaseBidsRepository implements BidsRepository {
  SupabaseBidsRepository(this._client, this._cache);

  final SupabaseClient _client;
  final BidsCacheRepository _cache;
  static const Duration _fetchTimeout = Duration(seconds: 8);

  final ValueNotifier<BidsSyncStatus> _sync = ValueNotifier(
    const BidsSyncStatus.unknown(),
  );

  @override
  ValueListenable<BidsSyncStatus> get syncStatus => _sync;

  void _markOnline() =>
      _sync.value = BidsSyncStatus(
        online: true,
        lastSyncedAt: DateTime.now().toUtc(),
      );

  void _markOffline() =>
      _sync.value = _sync.value.copyWith(online: false);
  static const String _auctionSelect = '*, listings(*, listing_media(*))';
  static const String _bidSelect =
      '*, auctions(*, listings(*, listing_media(*)))';

  Future<void> _settleDue() async {
    try {
      await _client.rpc<void>('settle_due_auctions').timeout(_fetchTimeout);
    } catch (_) {
    }
  }

  Listing _listingFrom(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['media'] = (map.remove('listing_media') as List?) ?? const [];
    return Listing.fromJson(map);
  }

  AuctionWithListing? _auctionFrom(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    final listingRow = map.remove('listings');
    if (listingRow is! Map<String, dynamic>) return null;
    return AuctionWithListing(
      auction: Auction.fromJson(map),
      listing: _listingFrom(listingRow),
    );
  }

  BidWithAuction? _bidFrom(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    final auctionRow = map.remove('auctions');
    if (auctionRow is! Map<String, dynamic>) return null;
    final auction = _auctionFrom(auctionRow);
    if (auction == null) return null;
    return BidWithAuction(bid: Bid.fromJson(map), auction: auction);
  }

  Future<List<AuctionWithListing>> _fetchLive() async {
    final rows = await _client
        .from('auctions')
        .select(_auctionSelect)
        .eq('status', 'running')
        .order('ends_at', ascending: true)
        .limit(50);
    return rows.map(_auctionFrom).nonNulls.toList();
  }

  Future<List<AuctionWithListing>> _fetchMyAuctions(String uid) async {
    final rows = await _client
        .from('auctions')
        .select(_auctionSelect)
        .eq('seller_id', uid)
        .order('created_at', ascending: false);
    return rows.map(_auctionFrom).nonNulls.toList();
  }

  Future<List<BidWithAuction>> _fetchMyBids(String uid) async {
    final rows = await _client
        .from('bids')
        .select(_bidSelect)
        .eq('bidder_id', uid)
        .order('created_at', ascending: false);
    return rows.map(_bidFrom).nonNulls.toList();
  }

  static List<T>? _orNull<T>(List<T> rows) => rows.isEmpty ? null : rows;

  @override
  Stream<List<AuctionWithListing>> watchLiveAuctions() => _watch(
    _fetchLive,
    'auctions-live',
    readCache: () async =>
        _orNull(await _cache.getAuctions(AuctionScope.live, null)),
    writeCache: (data) => _cache.saveAuctions(AuctionScope.live, null, data),
  );

  @override
  Stream<List<AuctionWithListing>> watchMyAuctions() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);
    return _watch(
      () => _fetchMyAuctions(uid),
      'auctions-mine-$uid',
      readCache: () async =>
          _orNull(await _cache.getAuctions(AuctionScope.mine, uid)),
      writeCache: (data) => _cache.saveAuctions(AuctionScope.mine, uid, data),
    );
  }

  @override
  Stream<List<BidWithAuction>> watchMyBids() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);
    return _watch(
      () => _fetchMyBids(uid),
      'bids-mine-$uid',
      readCache: () async => _orNull(await _cache.getMyBids(uid)),
      writeCache: (data) async {
        await _cache.saveAuctions(AuctionScope.bid, uid, [
          for (final entry in data) entry.auction,
        ]);
        await _cache.saveBids(BidScope.mine, uid, [
          for (final entry in data) entry.bid,
        ]);
      },
    );
  }

  @override
  Stream<AuctionWithListing> watchAuction(String auctionId) => _watch(
    () async {
      final row = await _client
          .from('auctions')
          .select(_auctionSelect)
          .eq('id', auctionId)
          .single();
      final entry = _auctionFrom(row);
      if (entry == null) throw StateError('Auction $auctionId has no car.');
      return entry;
    },
    'auction-$auctionId',
    readCache: () => _cache.getAuctionById(auctionId),
    writeCache: _cache.saveAuction,
  );

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
    readCache: () async => _orNull(await _cache.getBidsForAuction(auctionId)),
    writeCache: (data) => _cache.saveBids(
      BidScope.auction,
      null,
      data,

      auctionId: auctionId,
    ),
  );

  Stream<T> _watch<T>(
    Future<T> Function() fetch,
    String channelName, {
    bool settle = true,
    Future<T?> Function()? readCache,
    Future<void> Function(T)? writeCache,
  }) {
    final controller = StreamController<T>();
    RealtimeChannel? channel;

    var emitted = false;
    var servedCache = false;

    Future<void> push({bool withSettle = false}) async {
      try {
        if (withSettle) await _settleDue();
        final data = await fetch().timeout(_fetchTimeout);
        if (!controller.isClosed) {
          controller.add(data);
          emitted = true;
        }
        _markOnline();
        try {
          await writeCache?.call(data);
        } catch (_) {
        }
      } catch (e) {
        _markOffline();
        if (!emitted && !servedCache && !controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    controller
      ..onListen = () async {
        if (readCache != null) {
          try {
            final cached = await readCache();
            if (cached != null && !controller.isClosed) {
              controller.add(cached);
              servedCache = true;
            }
          } catch (_) {
          }
        }
        push(withSettle: settle);
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

          ..subscribe((status, _) {
            if (status == RealtimeSubscribeStatus.subscribed &&
                !_sync.value.online) {
              push();
            }
          });
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
  Future<Result<void>> extendAuction(String auctionId, DateTime endsAt) async {
    try {
      await _client
          .rpc<String>(
            'extend_auction',
            params: {
              'p_auction_id': auctionId,
              'p_ends_at': endsAt.toUtc().toIso8601String(),
            },
          )
          .timeout(_fetchTimeout);
      await _patchCachedAuction(
        auctionId,
        (auction) => auction.copyWith(endsAt: endsAt),
      );
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
      await _patchCachedAuction(
        auctionId,
        (auction) => auction.copyWith(
          status: AuctionStatus.cancelled,
          settledAt: DateTime.now().toUtc(),
        ),
      );
      return const Ok(null);
    } catch (e) {
      return Err(_message(e));
    }
  }

  @override
  Future<Result<void>> deleteAuction(String auctionId) async {
    try {
      await _client
          .rpc<void>('delete_auction', params: {'p_auction_id': auctionId})
          .timeout(_fetchTimeout);
      await _cache.deleteAuction(auctionId);
      return const Ok(null);
    } catch (e) {
      return Err(_message(e));
    }
  }

  Future<void> _patchCachedAuction(
    String auctionId,
    Auction Function(Auction) change,
  ) async {
    try {
      final cached = await _cache.getAuctionById(auctionId);
      if (cached == null) return;
      await _cache.upsertAuction(
        AuctionWithListing(
          auction: change(cached.auction),
          listing: cached.listing,
        ),
      );
    } catch (_) {
    }
  }

  @override
  Future<Result<String?>> latestAuctionIdForListing(String listingId) async {
    try {
      final row = await _client
          .from('auctions')
          .select('id')
          .eq('listing_id', listingId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle()
          .timeout(_fetchTimeout);
      return Ok(row?['id'] as String?);
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
    'already ended',
    'later than the current end',
    'before deleting',
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
