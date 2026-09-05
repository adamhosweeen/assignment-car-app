import 'package:assignment/utils/json.dart';

const Object _unset = Object();

enum MessageType { text, offer }

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.messageType = MessageType.text,
    this.offerAmountMyr,
    required this.createdAt,
    this.readAt,
    this.offerConfirmedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    conversationId: json['conversation_id'] as String,
    senderId: json['sender_id'] as String,
    body: json['body'] as String,
    messageType:
        asEnumOrNull(MessageType.values, json['message_type']) ??
        MessageType.text,
    offerAmountMyr: asIntOrNull(json['offer_amount_myr']),
    createdAt: asDate(json['created_at']),
    readAt: asDateOrNull(json['read_at']),
    offerConfirmedAt: asDateOrNull(json['offer_confirmed_at']),
  );

  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final MessageType messageType;
  final int? offerAmountMyr;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? offerConfirmedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'sender_id': senderId,
    'body': body,
    'message_type': messageType.name,
    'offer_amount_myr': offerAmountMyr,
    'created_at': createdAt.toIso8601String(),
    'read_at': readAt?.toIso8601String(),
    'offer_confirmed_at': offerConfirmedAt?.toIso8601String(),
  };

  bool isMine(String currentUserId) => senderId == currentUserId;

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? body,
    MessageType? messageType,
    Object? offerAmountMyr = _unset,
    DateTime? createdAt,
    Object? readAt = _unset,
    Object? offerConfirmedAt = _unset,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    body: body ?? this.body,
    messageType: messageType ?? this.messageType,
    offerAmountMyr: identical(offerAmountMyr, _unset)
        ? this.offerAmountMyr
        : offerAmountMyr as int?,
    createdAt: createdAt ?? this.createdAt,
    readAt: identical(readAt, _unset) ? this.readAt : readAt as DateTime?,
    offerConfirmedAt: identical(offerConfirmedAt, _unset)
        ? this.offerConfirmedAt
        : offerConfirmedAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          id == other.id &&
          conversationId == other.conversationId &&
          senderId == other.senderId &&
          body == other.body &&
          messageType == other.messageType &&
          offerAmountMyr == other.offerAmountMyr &&
          createdAt == other.createdAt &&
          readAt == other.readAt &&
          offerConfirmedAt == other.offerConfirmedAt;

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    senderId,
    body,
    messageType,
    offerAmountMyr,
    createdAt,
    readAt,
    offerConfirmedAt,
  );

  @override
  String toString() =>
      'Message(id: $id, conversationId: $conversationId, '
      'senderId: $senderId, messageType: $messageType, '
      'offerAmountMyr: $offerAmountMyr, createdAt: $createdAt)';
}
