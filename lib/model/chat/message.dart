import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Kind of message; `offer` carries [Message.offerAmountMyr].
enum MessageType { text, offer }

/// One message in a [Conversation] — a row of `messages`.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String body,
    @Default(MessageType.text) MessageType messageType,
    int? offerAmountMyr,
    required DateTime createdAt,
    DateTime? readAt,
  }) = _Message;

  const Message._();

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Whether [currentUserId] sent this message (right-aligned bubble).
  bool isMine(String currentUserId) => senderId == currentUserId;
}
