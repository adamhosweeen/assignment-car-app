import 'package:assignment/utils/json.dart';

const Object _unset = Object();

enum BidStatus { pending, accepted, rejected, withdrawn }

extension BidStatusLabel on BidStatus {
  String get label => switch (this) {
    BidStatus.pending => 'Pending',
    BidStatus.accepted => 'Accepted',
    BidStatus.rejected => 'Rejected',
    BidStatus.withdrawn => 'Withdrawn',
  };

  bool get isLive => this == BidStatus.pending;
}

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
