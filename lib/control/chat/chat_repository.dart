import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/result.dart';

abstract interface class ChatRepository {
  Stream<List<ConversationThread>> watchConversations();

  Stream<List<Message>> watchMessages(String conversationId);

  Future<Result<Conversation>> openConversation(String listingId);

  Future<Result<Conversation>> getById(String id);

  Future<Result<Message>> send(
    String conversationId,
    String body, {
    int? offerAmountMyr,
  });

  Future<Result<void>> markRead(String conversationId);

  Future<Result<void>> confirmOffer(String messageId);

  Future<Result<void>> buyAtOffer(String messageId);
}
