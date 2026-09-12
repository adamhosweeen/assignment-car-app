import 'package:flutter/foundation.dart';

import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/model/bid/bids_sync_status.dart';
import 'package:assignment/utils/result.dart';

abstract interface class BidsRepository {
  /// Whether the streams below are currently serving live data or a local
  /// copy, and when live data last arrived.
  ///
  /// The screens use it for two things: labelling stale data, and refusing to
  /// start a write that would be priced against it. An auction moves under
  /// you, so a bid composed offline is a bid against a price that may already
  /// be gone.
  ValueListenable<BidsSyncStatus> get syncStatus;

  Stream<List<AuctionWithListing>> watchLiveAuctions();

  Stream<List<BidWithAuction>> watchMyBids();

  Stream<List<AuctionWithListing>> watchMyAuctions();

  Stream<AuctionWithListing> watchAuction(String auctionId);

  Stream<List<Bid>> watchBidsForAuction(String auctionId);

  /// The most recent auction for a listing, whatever its status.
  /// `Ok(null)` means the listing has never been auctioned.
  Future<Result<String?>> latestAuctionIdForListing(String listingId);

  Future<Result<String>> startAuction({
    required String listingId,
    required int startingPriceMyr,
    required int minIncrementMyr,
    required DateTime endsAt,
  });

  Future<Result<void>> placeBid(String auctionId, int amountMyr);

  /// Pushes a running auction's deadline back to [endsAt]. Extending is the
  /// only edit an auction accepts, and only ever forwards in time.
  Future<Result<void>> extendAuction(String auctionId, DateTime endsAt);

  Future<Result<void>> cancelAuction(String auctionId);

  Future<Result<void>> deleteAuction(String auctionId);
}
