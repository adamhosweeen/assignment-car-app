import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';

part 'conversation_thread.freezed.dart';

/// A conversation plus what the thread-list row needs to render: the last
/// message (for the preview line) and how many are unread. Composed in Dart
/// from two queries — not a table mirror, so no `fromJson`/`toJson`.
@freezed
abstract class ConversationThread with _$ConversationThread {
  const factory ConversationThread({
    required Conversation conversation,
    Message? lastMessage,
    @Default(0) int unreadCount,
  }) = _ConversationThread;
}
