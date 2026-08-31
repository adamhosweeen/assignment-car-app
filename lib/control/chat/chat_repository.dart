import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/result.dart';

/// Chat data contract. Backed by `conversations`/`messages` (RLS restricts
/// both to their two participants; `0001_init.sql`).
abstract interface class ChatRepository {
  /// The signed-in user's threads, most recent activity first, each carrying
  /// its last message and unread count (realtime).
  Stream<List<ConversationThread>> watchConversations();

  /// Messages in one thread, oldest first (realtime).
  Stream<List<Message>> watchMessages(String conversationId);

  /// Find or create the thread between the signed-in buyer and a listing's
  /// seller.
  Future<Result<Conversation>> openConversation(String listingId);

  /// One conversation by id — used to rebuild the thread screen when it
  /// wasn't reached with the [Conversation] already in hand (e.g. after
  /// Android kills and restores the app process, where go_router's `extra`
  /// doesn't survive).
  Future<Result<Conversation>> getById(String id);

  /// Send a text message, or an offer when [offerAmountMyr] is given.
  Future<Result<Message>> send(
    String conversationId,
    String body, {
    int? offerAmountMyr,
  });

  /// Mark every message the other participant sent as read.
  Future<Result<void>> markRead(String conversationId);

  /// Accept an offer's price — only the message's recipient may call this,
  /// and never the buyer (they confirm-and-buy in one step via [buyAtOffer]).
  /// Used when the buyer sent the offer and the seller is accepting it.
  Future<Result<void>> confirmOffer(String messageId);

  /// Complete the sale at an offer's price — only the conversation's buyer
  /// may call this. Confirms the offer first if nobody has (the seller sent
  /// it); if the buyer sent it themselves, it must already be confirmed by
  /// the seller.
  Future<Result<void>> buyAtOffer(String messageId);
}
