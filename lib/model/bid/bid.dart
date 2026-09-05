import 'package:assignment/utils/json.dart';

enum BidStatus { placed, won, lost }

extension BidStatusLabel on BidStatus {
  String get label => switch (this) {
    BidStatus.placed => 'Placed',
    BidStatus.won => 'Won',
    BidStatus.lost => 'Lost',
  };

  bool get isLive => this == BidStatus.placed;
}

class Bid {
  const Bid({
    required this.id,
    required this.listingId,
    required this.auctionId,
    required this.bidderId,
    required this.amountMyr,
    this.status = BidStatus.placed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bid.fromJson(Map<String, dynamic> json) => Bid(
    id: json['id'] as String,
    listingId: json['listing_id'] as String,
    auctionId: json['auction_id'] as String,
    bidderId: json['bidder_id'] as String,
    amountMyr: asInt(json['amount_myr']),
    status: asEnumOrNull(BidStatus.values, json['status']) ?? BidStatus.placed,
    createdAt: asDate(json['created_at']),
    updatedAt: asDate(json['updated_at']),
  );

  final String id;
  final String listingId;
  final String auctionId;
  final String bidderId;
  final int amountMyr;
  final BidStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'listing_id': listingId,
    'auction_id': auctionId,
    'bidder_id': bidderId,
    'amount_myr': amountMyr,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  bool isMine(String currentUserId) => bidderId == currentUserId;

  Bid copyWith({
    String? id,
    String? listingId,
    String? auctionId,
    String? bidderId,
    int? amountMyr,
    BidStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Bid(
    id: id ?? this.id,
    listingId: listingId ?? this.listingId,
    auctionId: auctionId ?? this.auctionId,
    bidderId: bidderId ?? this.bidderId,
    amountMyr: amountMyr ?? this.amountMyr,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bid &&
          id == other.id &&
          listingId == other.listingId &&
          auctionId == other.auctionId &&
          bidderId == other.bidderId &&
          amountMyr == other.amountMyr &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    listingId,
    auctionId,
    bidderId,
    amountMyr,
    status,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Bid(id: $id, auctionId: $auctionId, amountMyr: $amountMyr, '
      'status: $status, createdAt: $createdAt)';
}
