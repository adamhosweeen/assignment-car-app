import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/listing/listing.dart';

part 'bid_with_listing.freezed.dart';

/// A bid plus the car it is on — what every row in the Bid tab needs to
/// render (title, cover photo, list price) without a second lookup per row.
///
/// Composed in Dart from an embedded `listings` select, not a table mirror,
/// so there is no `fromJson`/`toJson` (same shape as `ConversationThread`).
@freezed
abstract class BidWithListing with _$BidWithListing {
  const factory BidWithListing({required Bid bid, required Listing listing}) =
      _BidWithListing;

  const BidWithListing._();

  /// How the bid compares to the asking price — negative means below asking.
  int get differenceMyr => bid.amountMyr - listing.priceMyr;
}
