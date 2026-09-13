import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';

class BidWithAuction {
  const BidWithAuction({required this.bid, required this.auction});

  final Bid bid;
  final AuctionWithListing auction;

  bool get isWinning =>
      auction.auction.highestBidMyr != null &&
      auction.auction.highestBidMyr == bid.amountMyr;

  bool get hasOutcome => auction.auction.status != AuctionStatus.cancelled;

  BidWithAuction copyWith({Bid? bid, AuctionWithListing? auction}) =>
      BidWithAuction(bid: bid ?? this.bid, auction: auction ?? this.auction);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidWithAuction && bid == other.bid && auction == other.auction;

  @override
  int get hashCode => Object.hash(bid, auction);

  @override
  String toString() => 'BidWithAuction(bid: $bid, auction: $auction)';
}
