import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/model/user/inbox_message.dart';

class InboxRemote {
  InboxRemote(this._client);

  final SupabaseClient _client;

  static const String _table = 'inbox';
  static const Duration _timeout = Duration(seconds: 8);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<InboxMessage>> list(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .timeout(_timeout);
    return [
      for (final row in rows)
        InboxMessage.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  Future<void> markRead(String id, DateTime readAt) async {
    await _client
        .from(_table)
        .update({'read_at': readAt.toIso8601String()})
        .eq('id', id)
        .timeout(_timeout);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id).timeout(_timeout);
  }
}
