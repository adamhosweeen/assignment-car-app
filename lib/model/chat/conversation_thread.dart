import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';

const Object _unset = Object();

class ConversationThread {
  const ConversationThread({
    required this.conversation,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final Conversation conversation;
  final Message? lastMessage;
  final int unreadCount;

  ConversationThread copyWith({
    Conversation? conversation,
    Object? lastMessage = _unset,
    int? unreadCount,
  }) => ConversationThread(
    conversation: conversation ?? this.conversation,
    lastMessage: identical(lastMessage, _unset)
        ? this.lastMessage
        : lastMessage as Message?,
    unreadCount: unreadCount ?? this.unreadCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationThread &&
          conversation == other.conversation &&
          lastMessage == other.lastMessage &&
          unreadCount == other.unreadCount;

  @override
  int get hashCode => Object.hash(conversation, lastMessage, unreadCount);

  @override
  String toString() =>
      'ConversationThread(conversation: $conversation, '
      'lastMessage: $lastMessage, unreadCount: $unreadCount)';
}
