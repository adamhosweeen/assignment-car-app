import 'package:assignment/utils/json.dart';

/// Sentinel for [Bid.copyWith] — see `CarInterests`.
const Object _unset = Object();

/// Where a bid stands. Constant names map 1:1 to the `bids.status` text
/// values, so `asEnum` round-trips them by name (same convention as the
/// listing enums).
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
class Bid {
  const Bid({
    required this.id,
    required this.listingId,
    required this.bidderId,
    required this.amountMyr,
    this.status = BidStatus.pending,
    this.contactPhone,
    this.notifyWhatsapp = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bid.fromJson(Map<String, dynamic> json) => Bid(
    id: json['id'] as String,
    listingId: json['listing_id'] as String,
    bidderId: json['bidder_id'] as String,
    amountMyr: asInt(json['amount_myr']),
    status: asEnumOrNull(BidStatus.values, json['status']) ?? BidStatus.pending,
    contactPhone: json['contact_phone'] as String?,
    notifyWhatsapp: json['notify_whatsapp'] as bool? ?? false,
    createdAt: asDate(json['created_at']),
    updatedAt: asDate(json['updated_at']),
  );

  final String id;
  final String listingId;
  final String bidderId;
  final int amountMyr;
  final BidStatus status;

  /// Contact number captured on the bid form, so the seller can reach the
  /// bidder without seeing their (RLS-protected) profile row.
  final String? contactPhone;
  final bool notifyWhatsapp;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'listing_id': listingId,
    'bidder_id': bidderId,
    'amount_myr': amountMyr,
    'status': status.name,
    'contact_phone': contactPhone,
    'notify_whatsapp': notifyWhatsapp,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Whether [currentUserId] placed this bid (as opposed to receiving it).
  bool isMine(String currentUserId) => bidderId == currentUserId;

  Bid copyWith({
    String? id,
    String? listingId,
    String? bidderId,
    int? amountMyr,
    BidStatus? status,
    Object? contactPhone = _unset,
    bool? notifyWhatsapp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Bid(
    id: id ?? this.id,
    listingId: listingId ?? this.listingId,
    bidderId: bidderId ?? this.bidderId,
    amountMyr: amountMyr ?? this.amountMyr,
    status: status ?? this.status,
    contactPhone: identical(contactPhone, _unset)
        ? this.contactPhone
        : contactPhone as String?,
    notifyWhatsapp: notifyWhatsapp ?? this.notifyWhatsapp,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bid &&
          id == other.id &&
          listingId == other.listingId &&
          bidderId == other.bidderId &&
          amountMyr == other.amountMyr &&
          status == other.status &&
          contactPhone == other.contactPhone &&
          notifyWhatsapp == other.notifyWhatsapp &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    listingId,
    bidderId,
    amountMyr,
    status,
    contactPhone,
    notifyWhatsapp,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Bid(id: $id, listingId: $listingId, bidderId: $bidderId, '
      'amountMyr: $amountMyr, status: $status, createdAt: $createdAt)';
}
