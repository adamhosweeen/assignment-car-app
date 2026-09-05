import 'package:assignment/utils/json.dart';

const Object _unset = Object();

class Conversation {
  const Conversation({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as String,
    listingId: json['listing_id'] as String,
    buyerId: json['buyer_id'] as String,
    sellerId: json['seller_id'] as String,
    createdAt: asDate(json['created_at']),
    lastMessageAt: asDateOrNull(json['last_message_at']),
  );

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'listing_id': listingId,
    'buyer_id': buyerId,
    'seller_id': sellerId,
    'created_at': createdAt.toIso8601String(),
    'last_message_at': lastMessageAt?.toIso8601String(),
  };

  String otherParticipantId(String currentUserId) =>
      currentUserId == buyerId ? sellerId : buyerId;

  Conversation copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    String? sellerId,
    DateTime? createdAt,
    Object? lastMessageAt = _unset,
  }) => Conversation(
    id: id ?? this.id,
    listingId: listingId ?? this.listingId,
    buyerId: buyerId ?? this.buyerId,
    sellerId: sellerId ?? this.sellerId,
    createdAt: createdAt ?? this.createdAt,
    lastMessageAt: identical(lastMessageAt, _unset)
        ? this.lastMessageAt
        : lastMessageAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          id == other.id &&
          listingId == other.listingId &&
          buyerId == other.buyerId &&
          sellerId == other.sellerId &&
          createdAt == other.createdAt &&
          lastMessageAt == other.lastMessageAt;

  @override
  int get hashCode =>
      Object.hash(id, listingId, buyerId, sellerId, createdAt, lastMessageAt);

  @override
  String toString() =>
      'Conversation(id: $id, listingId: $listingId, buyerId: $buyerId, '
      'sellerId: $sellerId, createdAt: $createdAt, '
      'lastMessageAt: $lastMessageAt)';
}
