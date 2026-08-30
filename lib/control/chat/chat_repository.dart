import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/result.dart';

/// Chat data contract — **not implemented in v1**. The Chat tab shows a
/// placeholder. The Postgres schema (`conversations`, `messages`, RLS for
/// participants only) already exists in `0001_init.sql`, so a Supabase
/// implementation can be added without a migration.
///
/// Planned shape, to be confirmed when chat is scoped:
abstract interface class ChatRepository {
  /// The signed-in user's threads, most recent activity first (realtime).
  Stream<List<Conversation>> watchConversations();

  /// Messages in one thread, oldest first (realtime).
  Stream<List<Message>> watchMessages(String conversationId);

  /// Find or create the thread between the signed-in buyer and a listing's
  /// seller.
  Future<Result<Conversation>> openConversation(String listingId);

  /// Send a text message, or an offer when [offerAmountMyr] is given.
  Future<Result<Message>> send(
    String conversationId,
    String body, {
    int? offerAmountMyr,
  });

  /// Mark everything in the thread as read by the signed-in user.
  Future<Result<void>> markRead(String conversationId);
}
