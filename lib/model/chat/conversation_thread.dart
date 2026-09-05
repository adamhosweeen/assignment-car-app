import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';

/// Sentinel for [ConversationThread.copyWith] — see `CarInterests`.
const Object _unset = Object();

/// A conversation plus what the thread-list row needs to render: the last
/// message (for the preview line) and how many are unread. Composed in Dart
/// from two queries — not a table mirror, so no `fromJson`/`toJson`.
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
