import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Kind of message; `offer` carries [Message.offerAmountMyr].
enum MessageType { text, offer }

/// One message in a [Conversation] — a row of `messages` (V1_SPEC §1).
/// Model only for now: the Chat tab is a placeholder in v1.
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

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
