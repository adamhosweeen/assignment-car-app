// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  senderId: json['sender_id'] as String,
  body: json['body'] as String,
  messageType:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['message_type']) ??
      MessageType.text,
  offerAmountMyr: (json['offer_amount_myr'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
  offerConfirmedAt: json['offer_confirmed_at'] == null
      ? null
      : DateTime.parse(json['offer_confirmed_at'] as String),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender_id': instance.senderId,
  'body': instance.body,
  'message_type': _$MessageTypeEnumMap[instance.messageType]!,
  'offer_amount_myr': instance.offerAmountMyr,
  'created_at': instance.createdAt.toIso8601String(),
  'read_at': instance.readAt?.toIso8601String(),
  'offer_confirmed_at': instance.offerConfirmedAt?.toIso8601String(),
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.offer: 'offer',
};
