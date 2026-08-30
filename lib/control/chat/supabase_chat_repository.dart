import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';

/// [ChatRepository] over `conversations`/`messages`, with the same
/// fetch-on-realtime-change shape as `SupabaseListingsRepository._watch` /
/// `SupabaseNotificationsRepository.watchInbox`.
class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository(this._client);

  final SupabaseClient _client;
  static const Duration _fetchTimeout = Duration(seconds: 8);
  static const int _messageLimit = 200;

  // ── Conversations (thread list) ──────────────────────────────────────────
  Future<List<ConversationThread>> _fetchConversations(String uid) async {
    final rows = await _client
        .from('conversations')
        .select('*, messages(*)')
        .or('buyer_id.eq.$uid,seller_id.eq.$uid')
        .order('last_message_at', ascending: false, nullsFirst: false)
        .order('created_at', referencedTable: 'messages', ascending: false)
        .limit(1, referencedTable: 'messages');

    // Unread counts per conversation: RLS already scopes `messages` to rows
    // the caller can see, so this only ever returns their own threads.
    final unreadRows = await _client
        .from('messages')
        .select('conversation_id')
        .isFilter('read_at', null)
        .neq('sender_id', uid);
    final unreadCounts = <String, int>{};
    for (final row in unreadRows) {
      final id = row['conversation_id'] as String;
      unreadCounts[id] = (unreadCounts[id] ?? 0) + 1;
    }

    return rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      final messages = (map.remove('messages') as List?) ?? const [];
      final conversation = Conversation.fromJson(map);
      return ConversationThread(
        conversation: conversation,
        lastMessage: messages.isEmpty
            ? null
            : Message.fromJson(messages.first as Map<String, dynamic>),
        unreadCount: unreadCounts[conversation.id] ?? 0,
      );
    }).toList();
  }

  @override
  Stream<List<ConversationThread>> watchConversations() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);

    final controller = StreamController<List<ConversationThread>>();
    RealtimeChannel? channel;
    var loadedOnce = false;

    Future<void> push() async {
      try {
        final data = await _fetchConversations(uid).timeout(_fetchTimeout);
        loadedOnce = true;
        debugPrint('[chat] threads push: ${data.length} thread(s)');
        if (!controller.isClosed) controller.add(data);
      } catch (e) {
        debugPrint('[chat] threads push FAILED: $e');
        // A transient refresh failure keeps the last good list; a failed
        // first load is a real error state.
        if (!loadedOnce && !controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () {
        push();
        // A new message bumps `conversations.last_message_at` (caught by the
        // first listener); `markRead` only touches `messages.read_at`
        // (needs the second) to keep unread counts live.
        channel = _client.channel('chat-threads-$uid-${newId()}')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'conversations',
            callback: (payload) {
              debugPrint('[chat] threads: conversations ${payload.eventType}');
              push();
            },
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              debugPrint('[chat] threads: messages ${payload.eventType}');
              push();
            },
          )
          ..subscribe(
            (status, error) => debugPrint(
              '[chat] threads channel: $status${error == null ? '' : ' ($error)'}',
            ),
          );
      }
      ..onCancel = () async {
        final ch = channel;
        if (ch != null) await _client.removeChannel(ch);
        if (!controller.isClosed) await controller.close();
      };

    return controller.stream;
  }

  // ── Messages (one thread) ────────────────────────────────────────────────
  Future<List<Message>> _fetchMessages(String conversationId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(_messageLimit);
    return rows.reversed.map(Message.fromJson).toList();
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final controller = StreamController<List<Message>>();
    RealtimeChannel? channel;
    var loadedOnce = false;

    Future<void> push() async {
      try {
        final data = await _fetchMessages(
          conversationId,
        ).timeout(_fetchTimeout);
        loadedOnce = true;
        debugPrint(
          '[chat] messages push ($conversationId): ${data.length} message(s)',
        );
        if (!controller.isClosed) controller.add(data);
      } catch (e) {
        debugPrint('[chat] messages push FAILED ($conversationId): $e');
        if (!loadedOnce && !controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () {
        push();
        channel = _client.channel('chat-messages-$conversationId-${newId()}')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: conversationId,
            ),
            callback: (payload) {
              debugPrint(
                '[chat] messages ($conversationId): ${payload.eventType}',
              );
              push();
            },
          )
          ..subscribe(
            (status, error) => debugPrint(
              '[chat] messages channel ($conversationId): $status'
              '${error == null ? '' : ' ($error)'}',
            ),
          );
      }
      ..onCancel = () async {
        final ch = channel;
        if (ch != null) await _client.removeChannel(ch);
        if (!controller.isClosed) await controller.close();
      };

    return controller.stream;
  }

  // ── Writes ────────────────────────────────────────────────────────────────
  @override
  Future<Result<Conversation>> openConversation(String listingId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Err('You need to be signed in.');
    try {
      final listing = await _client
          .from('listings')
          .select('seller_id')
          .eq('id', listingId)
          .single()
          .timeout(_fetchTimeout);
      final sellerId = listing['seller_id'] as String;
      if (sellerId == uid) {
        return const Err("You can't message yourself about your own listing.");
      }
      // Atomic find-or-create on the (listing_id, buyer_id) unique constraint
      // — no race between two taps opening the same thread twice.
      final row = await _client
          .from('conversations')
          .upsert({
            'listing_id': listingId,
            'buyer_id': uid,
            'seller_id': sellerId,
          }, onConflict: 'listing_id,buyer_id')
          .select()
          .single()
          .timeout(_fetchTimeout);
      return Ok(Conversation.fromJson(row));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Message>> send(
    String conversationId,
    String body, {
    int? offerAmountMyr,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Err('You need to be signed in.');
    try {
      final row = await _client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': uid,
            'body': body,
            'message_type': offerAmountMyr != null ? 'offer' : 'text',
            'offer_amount_myr': ?offerAmountMyr,
          })
          .select()
          .single()
          .timeout(_fetchTimeout);
      // No DB trigger keeps this in sync (chat is schema-only in 0001) — the
      // sender bumps it themselves so thread ordering and previews update.
      await _client
          .from('conversations')
          .update({'last_message_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', conversationId)
          .timeout(_fetchTimeout);
      return Ok(Message.fromJson(row));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> markRead(String conversationId) async {
    try {
      await _client
          .rpc(
            'mark_conversation_read',
            params: {'p_conversation_id': conversationId},
          )
          .timeout(_fetchTimeout);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
