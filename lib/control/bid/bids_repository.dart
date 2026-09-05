import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/utils/result.dart';

abstract interface class BidsRepository {
  Stream<List<AuctionWithListing>> watchLiveAuctions();

  Stream<List<BidWithAuction>> watchMyBids();

  Stream<List<AuctionWithListing>> watchMyAuctions();

  Stream<AuctionWithListing> watchAuction(String auctionId);

  Stream<List<Bid>> watchBidsForAuction(String auctionId);

  Future<Result<String>> startAuction({
    required String listingId,
    required int startingPriceMyr,
    required int minIncrementMyr,
    required DateTime endsAt,
  });

  Future<Result<void>> placeBid(String auctionId, int amountMyr);

  Future<Result<void>> cancelAuction(String auctionId);
}
