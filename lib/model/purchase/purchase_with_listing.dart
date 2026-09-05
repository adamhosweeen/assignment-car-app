import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/purchase/purchase.dart';

const Object _unset = Object();

class PurchaseWithListing {
  const PurchaseWithListing({required this.purchase, this.listing});

  final Purchase purchase;

  final Listing? listing;

  PurchaseWithListing copyWith({
    Purchase? purchase,
    Object? listing = _unset,
  }) => PurchaseWithListing(
    purchase: purchase ?? this.purchase,
    listing: identical(listing, _unset) ? this.listing : listing as Listing?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseWithListing &&
          purchase == other.purchase &&
          listing == other.listing;

  @override
  int get hashCode => Object.hash(purchase, listing);

  @override
  String toString() =>
      'PurchaseWithListing(purchase: $purchase, listing: $listing)';
}
