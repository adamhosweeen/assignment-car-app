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
import 'package:assignment/utils/switch_latest.dart';
import 'package:assignment/utils/result.dart';

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

Stream<AsyncSnapshot<List<ConversationThread>>> _watchConversations(
  AuthRepository auth,
  ChatRepository chat,
) => auth
    .authState()
    .map((profile) => profile?.id)
    .distinct()
    .switchMap((userId) => _conversationsFor(userId, chat));

Stream<AsyncSnapshot<List<ConversationThread>>> _conversationsFor(
  String? userId,
  ChatRepository chat,
) async* {
  if (userId == null) {
    yield const AsyncSnapshot<List<ConversationThread>>.withData(
      ConnectionState.active,
      <ConversationThread>[],
    );
    return;
  }
  yield const AsyncSnapshot<List<ConversationThread>>.waiting();
  yield* snapshots(chat.watchConversations());
}

int unreadChatCountOf(AsyncSnapshot<List<ConversationThread>> conversations) =>
    conversations.data?.fold<int>(0, (sum, t) => sum + t.unreadCount) ?? 0;

Stream<List<Message>> watchMessages(
  ChatRepository chat,
  String conversationId,
) => chat.watchMessages(conversationId);

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
