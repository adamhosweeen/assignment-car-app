// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bid _$BidFromJson(Map<String, dynamic> json) => _Bid(
  id: json['id'] as String,
  listingId: json['listing_id'] as String,
  bidderId: json['bidder_id'] as String,
  amountMyr: (json['amount_myr'] as num).toInt(),
  status:
      $enumDecodeNullable(_$BidStatusEnumMap, json['status']) ??
      BidStatus.pending,
  contactPhone: json['contact_phone'] as String?,
  notifyWhatsapp: json['notify_whatsapp'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BidToJson(_Bid instance) => <String, dynamic>{
  'id': instance.id,
  'listing_id': instance.listingId,
  'bidder_id': instance.bidderId,
  'amount_myr': instance.amountMyr,
  'status': _$BidStatusEnumMap[instance.status]!,
  'contact_phone': instance.contactPhone,
  'notify_whatsapp': instance.notifyWhatsapp,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$BidStatusEnumMap = {
  BidStatus.pending: 'pending',
  BidStatus.accepted: 'accepted',
  BidStatus.rejected: 'rejected',
  BidStatus.withdrawn: 'withdrawn',
};
