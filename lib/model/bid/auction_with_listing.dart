import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/listing/listing.dart';

class AuctionWithListing {
  const AuctionWithListing({required this.auction, required this.listing});

  final Auction auction;
  final Listing listing;

  String get title => listing.title;

  int get currentPriceMyr => auction.highestBidMyr ?? auction.startingPriceMyr;

  AuctionWithListing copyWith({Auction? auction, Listing? listing}) =>
      AuctionWithListing(
        auction: auction ?? this.auction,
        listing: listing ?? this.listing,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuctionWithListing &&
          auction == other.auction &&
          listing == other.listing;

  @override
  int get hashCode => Object.hash(auction, listing);

  @override
  String toString() =>
      'AuctionWithListing(auction: $auction, listing: $listing)';
}
