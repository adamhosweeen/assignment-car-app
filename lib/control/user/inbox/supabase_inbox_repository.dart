import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/control/user/inbox/inbox_cache_repository.dart';
import 'package:assignment/control/user/inbox/inbox_repository.dart';
import 'package:assignment/model/user/inbox_message.dart';
import 'package:assignment/utils/result.dart';

const Duration _timeout = Duration(seconds: 8);

class SupabaseInboxRepository implements InboxRepository {
  SupabaseInboxRepository(this._client, this._cache);

  final SupabaseClient _client;
  final InboxCacheRepository _cache;

  static const String _table = 'inbox';

  @override
  Future<Result<List<InboxMessage>>> list() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Ok([]);
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .timeout(_timeout);
      final messages = [
        for (final row in rows)
          InboxMessage.fromJson(Map<String, dynamic>.from(row)),
      ];
      await _cache.replaceForUser(uid, messages);
      return Ok(messages);
    } catch (e) {
      final cached = await _cache.getForUser(uid);
      if (cached.isNotEmpty) return Ok(cached);
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> markRead(String id) async {
    final readAt = DateTime.now().toUtc();
    try {
      await _client
          .from(_table)
          .update({'read_at': readAt.toIso8601String()})
          .eq('id', id)
          .timeout(_timeout);
      await _cache.markRead(id, readAt);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id).timeout(_timeout);
      await _cache.delete(id);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
