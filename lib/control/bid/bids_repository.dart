import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/utils/result.dart';

/// The bids data contract (migration 0009). The UI depends only on this.
///
/// Every status transition goes through a SECURITY DEFINER function rather
/// than a client-side update — `bids` has SELECT and INSERT policies only, so
/// a direct update would silently match zero rows.
abstract interface class BidsRepository {
  /// Bids the signed-in user has placed, newest first, with the car each one
  /// is on. Live over realtime. Empty stream when signed out.
  Stream<List<BidWithListing>> watchMyBids();

  /// Bids other people have placed on the signed-in user's listings, newest
  /// first, with the car each one is on. Live over realtime.
  Stream<List<BidWithListing>> watchBidsReceived();

  /// Every bid on one listing, newest first (seller's per-car view). Live
  /// over realtime. RLS limits this to the listing's seller and the caller's
  /// own bids.
  Stream<List<Bid>> watchBidsForListing(String listingId);

  /// The signed-in user's current `pending` bid on [listingId], or null when
  /// they have none. Used to switch the bid form between "place" and "update".
  Future<Result<Bid?>> myPendingBidFor(String listingId);

  /// Place a bid on [listingId] for [amountMyr] whole Ringgit.
  ///
  /// Rejects, without a round trip, a bid on your own car, on a listing that
  /// isn't active, or an amount that fails [validateBidAmount]. If the caller
  /// already has a pending bid on this car it is withdrawn first, so the
  /// `bids_one_pending_per_bidder` unique index can't trip.
  Future<Result<Bid>> placeBid(
    String listingId,
    int amountMyr, {
    required String contactPhone,
    bool notifyWhatsapp,
  });

  /// Pull back your own still-pending bid (`withdraw_bid`).
  Future<Result<void>> withdrawBid(String bidId);

  /// Seller's decision on a pending bid (`respond_to_bid`). Accepting also
  /// rejects every other pending bid on that car and sells it at this bid's
  /// amount.
  Future<Result<void>> respondToBid(String bidId, {required bool accept});
}
