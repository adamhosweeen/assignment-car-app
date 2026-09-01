import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/utils/result.dart';

/// Queries the bid screens run against [BidsRepository]. Each is called once
/// from a screen's `initState` and held in its [State]; a `StreamBuilder` /
/// `FutureBuilder` turns it into loading, error and data.

/// Bids the signed-in user has placed, newest first, live over realtime.
/// Empty when signed out.
Stream<List<BidWithListing>> watchMyBids(
  AuthRepository auth,
  BidsRepository bids,
) {
  if (auth.currentUser == null) return Stream.value(const <BidWithListing>[]);
  return bids.watchMyBids();
}

/// Bids other people have placed on the signed-in user's cars, newest first.
Stream<List<BidWithListing>> watchBidsReceived(
  AuthRepository auth,
  BidsRepository bids,
) {
  if (auth.currentUser == null) return Stream.value(const <BidWithListing>[]);
  return bids.watchBidsReceived();
}

/// Every bid on one listing (seller's per-car view on Listing Detail).
Stream<List<Bid>> watchBidsForListing(BidsRepository bids, String listingId) =>
    bids.watchBidsForListing(listingId);

/// The signed-in user's live bid on [listingId], or null when they have none.
/// The bid form reads this to switch between "Place your bid" and "Update
/// your bid", and Listing Detail to label its button.
Future<Bid?> fetchMyPendingBid(
  AuthRepository auth,
  BidsRepository bids,
  String listingId,
) async {
  if (auth.currentUser == null) return null;
  final res = await bids.myPendingBidFor(listingId);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}

/// How many bids on the signed-in user's cars are still waiting on them —
/// drives the count on the Bid tab's "On my cars" segment.
int pendingBidsReceivedCount(List<BidWithListing>? received) =>
    received?.where((b) => b.bid.status.isLive).length ?? 0;
