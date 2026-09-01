import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid.freezed.dart';
part 'bid.g.dart';

/// Where a bid stands. Constant names map 1:1 to the `bids.status` text values,
/// so json_serializable round-trips them by name with no `@JsonValue`
/// annotations (same convention as the listing enums).
///
/// Only [pending] is live. The other three are terminal: the seller sets
/// [accepted] / [rejected] via `respond_to_bid`, the bidder sets [withdrawn]
/// via `withdraw_bid` (migration 0009).
enum BidStatus { pending, accepted, rejected, withdrawn }

extension BidStatusLabel on BidStatus {
  String get label => switch (this) {
    BidStatus.pending => 'Pending',
    BidStatus.accepted => 'Accepted',
    BidStatus.rejected => 'Rejected',
    BidStatus.withdrawn => 'Withdrawn',
  };

  /// Whether this bid can still be acted on — the only state in which the
  /// seller may accept/reject and the bidder may withdraw.
  bool get isLive => this == BidStatus.pending;
}

/// One bid on a listing — a row of `bids` (migration 0009).
///
/// Money is integer MYR and timestamps are UTC, per the repo convention.
@freezed
abstract class Bid with _$Bid {
  const factory Bid({
    required String id,
    required String listingId,
    required String bidderId,
    required int amountMyr,
    @Default(BidStatus.pending) BidStatus status,

    /// Contact number captured on the bid form, so the seller can reach the
    /// bidder without seeing their (RLS-protected) profile row.
    String? contactPhone,
    @Default(false) bool notifyWhatsapp,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Bid;

  const Bid._();

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

  /// Whether [currentUserId] placed this bid (as opposed to receiving it).
  bool isMine(String currentUserId) => bidderId == currentUserId;
}
