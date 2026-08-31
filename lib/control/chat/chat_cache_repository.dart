import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';

/// sqflite read-cache of the signed-in user's chat threads
/// (`conversation_cache`) and, per thread, its message history
/// (`message_cache`). Written after every successful Supabase fetch so the
/// Chat tab and an already-opened thread render instantly on cold start and
/// stay browsable offline. Never authoritative — Supabase is the source of
/// truth (CLAUDE.md §3).
class ChatCacheRepository {
  ChatCacheRepository(this._db, List<Map<String, Object?>> initialThreadRows)
    : _cachedConversations = initialThreadRows
          .map(conversationThreadFromRow)
          .toList();

  final Database _db;
  List<ConversationThread> _cachedConversations;

  /// The thread list cached on disk at launch (or saved since), in the same
  /// most-recent-activity-first order it was fetched in.
  List<ConversationThread> get cachedConversations => _cachedConversations;

  Future<void> saveConversations(List<ConversationThread> threads) async {
    _cachedConversations = List.unmodifiable(threads);
    await _db.transaction((txn) async {
      await txn.delete('conversation_cache');
      for (var i = 0; i < threads.length; i++) {
        await txn.insert(
          'conversation_cache',
          conversationThreadToRow(threads[i], i),
        );
      }
    });
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final rows = await _db.query(
      'message_cache',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    return rows
        .map((r) => Message.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<void> saveMessages(String conversationId, List<Message> messages) =>
      _db.transaction((txn) async {
        await txn.delete(
          'message_cache',
          where: 'conversation_id = ?',
          whereArgs: [conversationId],
        );
        for (final message in messages) {
          await txn.insert('message_cache', message.toJson());
        }
      });

  /// Wipes every cached thread and message — called on sign-out so a shared
  /// device doesn't leave one user's chats readable to the next.
  Future<void> clear() async {
    _cachedConversations = const [];
    await _db.delete('conversation_cache');
    await _db.delete('message_cache');
  }
}

/// Flatten a [ConversationThread] into a `conversation_cache` row: the
/// conversation's own snake_case JSON plus its last message's fields
/// prefixed `last_msg_` (null when the thread has no messages yet).
Map<String, Object?> conversationThreadToRow(
  ConversationThread thread,
  int sortOrder,
) {
  final last = thread.lastMessage;
  return {
    ...thread.conversation.toJson(),
    'unread_count': thread.unreadCount,
    'sort_order': sortOrder,
    'last_msg_id': last?.id,
    'last_msg_sender_id': last?.senderId,
    'last_msg_body': last?.body,
    'last_msg_type': last?.messageType.name,
    'last_msg_offer_amount_myr': last?.offerAmountMyr,
    'last_msg_created_at': last?.createdAt.toIso8601String(),
    'last_msg_read_at': last?.readAt?.toIso8601String(),
  };
}

/// Rebuild a [ConversationThread] from a `conversation_cache` row.
ConversationThread conversationThreadFromRow(Map<String, Object?> row) {
  final conversation = Conversation.fromJson(
    Map<String, dynamic>.from(row)
      ..remove('unread_count')
      ..remove('sort_order')
      ..removeWhere((key, _) => key.startsWith('last_msg_')),
  );
  final lastMsgId = row['last_msg_id'] as String?;
  final lastMessage = lastMsgId == null
      ? null
      : Message(
          id: lastMsgId,
          conversationId: conversation.id,
          senderId: row['last_msg_sender_id']! as String,
          body: row['last_msg_body']! as String,
          messageType: MessageType.values.byName(
            row['last_msg_type']! as String,
          ),
          offerAmountMyr: row['last_msg_offer_amount_myr'] as int?,
          createdAt: DateTime.parse(row['last_msg_created_at']! as String),
          readAt: DateTime.tryParse(row['last_msg_read_at'] as String? ?? ''),
        );
  return ConversationThread(
    conversation: conversation,
    lastMessage: lastMessage,
    unreadCount: row['unread_count']! as int,
  );
}
