import 'package:assignment/utils/json.dart';

const Object _unset = Object();

enum AuctionStatus { running, settled, cancelled }

extension AuctionStatusLabel on AuctionStatus {
  String get label => switch (this) {
    AuctionStatus.running => 'Live',
    AuctionStatus.settled => 'Ended',
    AuctionStatus.cancelled => 'Cancelled',
  };
}

class Auction {
  const Auction({
    required this.id,
    required this.listingId,
    required this.sellerId,
    required this.startingPriceMyr,
    required this.minIncrementMyr,
    required this.endsAt,
    this.status = AuctionStatus.running,
    this.highestBidMyr,
    this.bidCount = 0,
    this.winningBidId,
    this.settledAt,
    required this.createdAt,
  });

  factory Auction.fromJson(Map<String, dynamic> json) => Auction(
    id: json['id'] as String,
    listingId: json['listing_id'] as String,
    sellerId: json['seller_id'] as String,
    startingPriceMyr: asInt(json['starting_price_myr']),
    minIncrementMyr: asInt(json['min_increment_myr']),
    endsAt: asDate(json['ends_at']),
    status:
        asEnumOrNull(AuctionStatus.values, json['status']) ??
        AuctionStatus.running,
    highestBidMyr: asIntOrNull(json['highest_bid_myr']),
    bidCount: asIntOrNull(json['bid_count']) ?? 0,
    winningBidId: json['winning_bid_id'] as String?,
    settledAt: asDateOrNull(json['settled_at']),
    createdAt: asDate(json['created_at']),
  );

  final String id;
  final String listingId;
  final String sellerId;
  final int startingPriceMyr;
  final int minIncrementMyr;
  final DateTime endsAt;
  final AuctionStatus status;
  final int? highestBidMyr;
  final int bidCount;
  final String? winningBidId;
  final DateTime? settledAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'listing_id': listingId,
    'seller_id': sellerId,
    'starting_price_myr': startingPriceMyr,
    'min_increment_myr': minIncrementMyr,
    'ends_at': endsAt.toIso8601String(),
    'status': status.name,
    'highest_bid_myr': highestBidMyr,
    'bid_count': bidCount,
    'winning_bid_id': winningBidId,
    'settled_at': settledAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  int get minimumNextBidMyr => highestBidMyr == null
      ? startingPriceMyr
      : highestBidMyr! + minIncrementMyr;

  bool hasEnded({DateTime? now}) =>
      !endsAt.isAfter(now ?? DateTime.now().toUtc());

  bool isLive({DateTime? now}) =>
      status == AuctionStatus.running && !hasEnded(now: now);

  Duration remaining({DateTime? now}) {
    final left = endsAt.difference(now ?? DateTime.now().toUtc());
    return left.isNegative ? Duration.zero : left;
  }

  bool isSeller(String userId) => sellerId == userId;

  bool canCancel(String userId, {DateTime? now}) =>
      isSeller(userId) && isLive(now: now) && bidCount == 0;

  Auction copyWith({
    String? id,
    String? listingId,
    String? sellerId,
    int? startingPriceMyr,
    int? minIncrementMyr,
    DateTime? endsAt,
    AuctionStatus? status,
    Object? highestBidMyr = _unset,
    int? bidCount,
    Object? winningBidId = _unset,
    Object? settledAt = _unset,
    DateTime? createdAt,
  }) => Auction(
    id: id ?? this.id,
    listingId: listingId ?? this.listingId,
    sellerId: sellerId ?? this.sellerId,
    startingPriceMyr: startingPriceMyr ?? this.startingPriceMyr,
    minIncrementMyr: minIncrementMyr ?? this.minIncrementMyr,
    endsAt: endsAt ?? this.endsAt,
    status: status ?? this.status,
    highestBidMyr: identical(highestBidMyr, _unset)
        ? this.highestBidMyr
        : highestBidMyr as int?,
    bidCount: bidCount ?? this.bidCount,
    winningBidId: identical(winningBidId, _unset)
        ? this.winningBidId
        : winningBidId as String?,
    settledAt: identical(settledAt, _unset)
        ? this.settledAt
        : settledAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Auction &&
          id == other.id &&
          listingId == other.listingId &&
          sellerId == other.sellerId &&
          startingPriceMyr == other.startingPriceMyr &&
          minIncrementMyr == other.minIncrementMyr &&
          endsAt == other.endsAt &&
          status == other.status &&
          highestBidMyr == other.highestBidMyr &&
          bidCount == other.bidCount &&
          winningBidId == other.winningBidId &&
          settledAt == other.settledAt &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    listingId,
    sellerId,
    startingPriceMyr,
    minIncrementMyr,
    endsAt,
    status,
    highestBidMyr,
    bidCount,
    winningBidId,
    settledAt,
    createdAt,
  );

  @override
  String toString() =>
      'Auction(id: $id, listingId: $listingId, status: $status, '
      'highestBidMyr: $highestBidMyr, bidCount: $bidCount, endsAt: $endsAt)';
}
