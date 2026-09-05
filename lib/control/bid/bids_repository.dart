import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/utils/result.dart';

abstract interface class BidsRepository {
  Stream<List<BidWithListing>> watchMyBids();

  Stream<List<BidWithListing>> watchBidsReceived();

  Stream<List<Bid>> watchBidsForListing(String listingId);

  Future<Result<Bid?>> myPendingBidFor(String listingId);

  Future<Result<Bid>> placeBid(
    String listingId,
    int amountMyr, {
    required String contactPhone,
    bool notifyWhatsapp,
  });

  Future<Result<void>> withdrawBid(String bidId);

  Future<Result<void>> respondToBid(String bidId, {required bool accept});
}
