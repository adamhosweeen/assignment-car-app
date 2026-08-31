import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/result.dart';

part 'chat_providers.g.dart';

/// The signed-in user's threads, most recent activity first, live over
/// realtime. Empty stream when signed out; re-created when the user changes.
@riverpod
Stream<List<ConversationThread>> conversations(Ref ref) {
  ref.watch(authStateProvider); // rebuild when the signed-in user changes
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(const <ConversationThread>[]);
  return ref.watch(chatRepositoryProvider).watchConversations();
}

/// Messages in one thread, oldest first, live over realtime.
@riverpod
Stream<List<Message>> messages(Ref ref, String conversationId) =>
    ref.watch(chatRepositoryProvider).watchMessages(conversationId);

/// One conversation by id — rebuilds the thread screen when it wasn't
/// reached with the [Conversation] already in hand (route `extra` doesn't
/// survive Android killing and restoring the app process).
@riverpod
Future<Conversation> conversationById(Ref ref, String id) async {
  final res = await ref.watch(chatRepositoryProvider).getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}

/// Total unread messages across every thread, for the Chat tab badge.
@riverpod
int unreadChatCount(Ref ref) =>
    ref
        .watch(conversationsProvider)
        .value
        ?.fold<int>(0, (sum, t) => sum + t.unreadCount) ??
    0;
