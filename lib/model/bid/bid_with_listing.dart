import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/listing/listing.dart';

class BidWithListing {
  const BidWithListing({required this.bid, required this.listing});

  final Bid bid;
  final Listing listing;

  int get differenceMyr => bid.amountMyr - listing.priceMyr;

  BidWithListing copyWith({Bid? bid, Listing? listing}) =>
      BidWithListing(bid: bid ?? this.bid, listing: listing ?? this.listing);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidWithListing && bid == other.bid && listing == other.listing;

  @override
  int get hashCode => Object.hash(bid, listing);

  @override
  String toString() => 'BidWithListing(bid: $bid, listing: $listing)';
}
