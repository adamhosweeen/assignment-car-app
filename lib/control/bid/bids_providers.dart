import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';

Stream<List<AuctionWithListing>> watchLiveAuctions(BidsRepository bids) =>
    bids.watchLiveAuctions();

Stream<List<BidWithAuction>> watchMyBids(
  AuthRepository auth,
  BidsRepository bids,
) {
  if (auth.currentUser == null) return Stream.value(const []);
  return bids.watchMyBids();
}

Stream<List<AuctionWithListing>> watchMyAuctions(
  AuthRepository auth,
  BidsRepository bids,
) {
  if (auth.currentUser == null) return Stream.value(const []);
  return bids.watchMyAuctions();
}

int liveBidsCount(List<BidWithAuction>? myBids) =>
    myBids?.where((b) => b.auction.auction.isLive()).length ?? 0;

List<BidWithAuction> latestBidPerAuction(List<BidWithAuction> bids) {
  final seen = <String>{};
  return [
    for (final b in bids)
      if (seen.add(b.bid.auctionId)) b,
  ];
}
