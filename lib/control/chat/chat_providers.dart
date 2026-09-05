import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/async_snapshots.dart';
import 'package:assignment/utils/restartable_stream.dart';
import 'package:assignment/utils/result.dart';

/// The signed-in user's chat threads, most recent activity first, live over
/// realtime.
///
/// App-scoped for the same reason as the inbox: the Chat tab's badge in the
/// shell and the Chat screen both read it, and the repository stream is
/// single-subscription. [restart] backs the Chat screen's retry and its
/// pull-to-refresh.
class ConversationsFeed
    extends RestartableStream<AsyncSnapshot<List<ConversationThread>>> {
  ConversationsFeed(AuthRepository auth, ChatRepository chat)
    : super(() => _watchConversations(auth, chat));
}

final chatProviders = <SingleChildWidget>[
  Provider<ConversationsFeed>(
    create: (c) =>
        ConversationsFeed(c.read<AuthRepository>(), c.read<ChatRepository>()),
    dispose: (_, feed) => feed.dispose(),
  ),
  StreamProvider<AsyncSnapshot<List<ConversationThread>>>(
    lazy: false,
    initialData: const AsyncSnapshot<List<ConversationThread>>.waiting(),
    create: (c) => c.read<ConversationsFeed>().stream,
  ),
];

/// Empty when signed out; torn down and re-subscribed when the user changes.
/// Opens on `waiting` so a restart returns the screen to its loading state.
Stream<AsyncSnapshot<List<ConversationThread>>> _watchConversations(
  AuthRepository auth,
  ChatRepository chat,
) async* {
  yield const AsyncSnapshot<List<ConversationThread>>.waiting();
  yield* auth
      .authState()
      .map((profile) => profile?.id)
      .distinct()
      .asyncExpand(
        (userId) => userId == null
            ? Stream.value(
                const AsyncSnapshot<List<ConversationThread>>.withData(
                  ConnectionState.active,
                  <ConversationThread>[],
                ),
              )
            : snapshots(chat.watchConversations()),
      );
}

/// Total unread messages across every thread, for the Chat tab badge.
int unreadChatCountOf(AsyncSnapshot<List<ConversationThread>> conversations) =>
    conversations.data?.fold<int>(0, (sum, t) => sum + t.unreadCount) ?? 0;

/// Messages in one thread, oldest first, live over realtime.
Stream<List<Message>> watchMessages(
  ChatRepository chat,
  String conversationId,
) => chat.watchMessages(conversationId);

/// One conversation by id — the thread screen falls back to this when it
/// wasn't reached with the [Conversation] already in hand (route `extra`
/// doesn't survive Android killing and restoring the app process).
Future<Conversation> fetchConversationById(
  ChatRepository chat,
  String id,
) async {
  final res = await chat.getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}
