import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/chat/chat_cache_repository.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';

class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository(this._client, this._cache);

  final SupabaseClient _client;
  final ChatCacheRepository _cache;
  static const Duration _fetchTimeout = Duration(seconds: 8);
  static const int _messageLimit = 200;
  static const String _mediaBucket = 'chat-media';
  static const String _imagePlaceholderBody = '📷 Photo';

  Future<List<ConversationThread>> _fetchConversations(String uid) async {
    final rows = await _client
        .from('conversations')
        .select('*, messages(*)')
        .or('buyer_id.eq.$uid,seller_id.eq.$uid')
        .order('last_message_at', ascending: false, nullsFirst: false)
        .order('created_at', referencedTable: 'messages', ascending: false)
        .limit(1, referencedTable: 'messages');

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

    return rows
        .map(Map<String, dynamic>.from)
        .where((row) => !_isHiddenForMe(row, uid))
        .map((map) {
          final messages = (map.remove('messages') as List?) ?? const [];
          final conversation = Conversation.fromJson(map);
          return ConversationThread(
            conversation: conversation,
            lastMessage: messages.isEmpty
                ? null
                : Message.fromJson(messages.first as Map<String, dynamic>),
            unreadCount: unreadCounts[conversation.id] ?? 0,
          );
        })
        .toList();
  }

  // True if `uid` has hidden this conversation and there's no newer message.
  bool _isHiddenForMe(Map<String, dynamic> row, String uid) {
    final isBuyer = row['buyer_id'] == uid;
    final deletedAtRaw =
        row[isBuyer ? 'buyer_deleted_at' : 'seller_deleted_at'] as String?;
    if (deletedAtRaw == null) return false;
    final deletedAt = DateTime.parse(deletedAtRaw);
    final lastMessageAtRaw = row['last_message_at'] as String?;
    if (lastMessageAtRaw == null) return true;
    return !DateTime.parse(lastMessageAtRaw).isAfter(deletedAt);
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
        await _cache.saveConversations(data);
      } catch (e) {
        debugPrint('[chat] threads push FAILED: $e');
        if (!loadedOnce && !controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () {
        final cached = _cache.cachedConversations;
        if (cached.isNotEmpty) {
          loadedOnce = true;
          controller.add(cached);
        }
        push();
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
        await _cache.saveMessages(conversationId, data);
      } catch (e) {
        debugPrint('[chat] messages push FAILED ($conversationId): $e');
        if (!loadedOnce && !controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () async {
        final cached = await _cache.getMessages(conversationId);
        if (cached.isNotEmpty && !controller.isClosed) {
          loadedOnce = true;
          controller.add(cached);
        }
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
  Future<Result<Conversation>> getById(String id) async {
    try {
      final row = await _client
          .from('conversations')
          .select()
          .eq('id', id)
          .maybeSingle()
          .timeout(_fetchTimeout);
      if (row == null) {
        return const Err('This conversation is no longer available.');
      }
      return Ok(Conversation.fromJson(row));
    } catch (e) {
      final cached = _cache.cachedConversations
          .map((t) => t.conversation)
          .where((c) => c.id == id)
          .firstOrNull;
      if (cached != null) return Ok(cached);
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
      // last_message_at is updated server-side by a trigger.
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
      return Ok(Message.fromJson(row));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Message>> sendImage(
    String conversationId,
    String localImagePath,
  ) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Err('You need to be signed in.');
    try {
      // Uploads the photo, then sends it as an image message.
      final objectPath = '$conversationId/${newId()}.jpg';
      await _client.storage
          .from(_mediaBucket)
          .upload(
            objectPath,
            File(localImagePath),
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          )
          .timeout(_fetchTimeout);
      final row = await _client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': uid,
            'body': _imagePlaceholderBody,
            'message_type': 'image',
            'image_path': objectPath,
          })
          .select()
          .single()
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

  @override
  Future<Result<void>> confirmOffer(String messageId) async {
    try {
      await _client
          .rpc('confirm_offer', params: {'p_message_id': messageId})
          .timeout(_fetchTimeout);
      return const Ok(null);
    } on PostgrestException catch (e) {
      if (e.message.contains('cannot confirm your own offer') ||
          e.message.contains('not a participant') ||
          e.message.contains('not an offer')) {
        return Err(e.message);
      }
      return Err(mapError(e));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> buyAtOffer(String messageId) async {
    try {
      await _client
          .rpc('buy_at_offer', params: {'p_message_id': messageId})
          .timeout(_fetchTimeout);
      return const Ok(null);
    } on PostgrestException catch (e) {
      if (e.message.contains('no longer available') ||
          e.message.contains('Only the buyer') ||
          e.message.contains('Waiting for the seller') ||
          e.message.contains('not an offer')) {
        return Err(e.message);
      }
      return Err(mapError(e));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> recallMessage(String messageId) async {
    try {
      await _client
          .rpc('recall_message', params: {'p_message_id': messageId})
          .timeout(_fetchTimeout);
      return const Ok(null);
    } on PostgrestException catch (e) {
      if (e.message.contains('own messages') ||
          e.message.contains('already been recalled') ||
          e.message.contains('no longer be recalled') ||
          e.message.contains('already been confirmed')) {
        return Err(e.message);
      }
      return Err(mapError(e));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> hideConversation(String conversationId) async {
    try {
      await _client
          .rpc(
            'hide_conversation',
            params: {'p_conversation_id': conversationId},
          )
          .timeout(_fetchTimeout);
      return const Ok(null);
    } on PostgrestException catch (e) {
      if (e.message.contains('not a participant') ||
          e.message.contains('no longer available')) {
        return Err(e.message);
      }
      return Err(mapError(e));
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
