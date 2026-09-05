import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/utils/result.dart';

Stream<List<BidWithListing>> watchMyBids(
  AuthRepository auth,
  BidsRepository bids,
) {
  if (auth.currentUser == null) return Stream.value(const <BidWithListing>[]);
  return bids.watchMyBids();
}

Stream<List<BidWithListing>> watchBidsReceived(
  AuthRepository auth,
  BidsRepository bids,
) {
  if (auth.currentUser == null) return Stream.value(const <BidWithListing>[]);
  return bids.watchBidsReceived();
}

Stream<List<Bid>> watchBidsForListing(BidsRepository bids, String listingId) =>
    bids.watchBidsForListing(listingId);

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

int pendingBidsReceivedCount(List<BidWithListing>? received) =>
    received?.where((b) => b.bid.status.isLive).length ?? 0;
