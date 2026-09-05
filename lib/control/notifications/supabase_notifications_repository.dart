import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client);

  final SupabaseClient _client;
  static const String _table = 'notifications';
  static const Duration _fetchTimeout = Duration(seconds: 8);
  static const int _limit = 100;

  Future<List<AppNotification>> _fetch(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(_limit);
    return rows.map(AppNotification.fromJson).toList();
  }

  @override
  Stream<List<AppNotification>> watchInbox() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(const []);

    final controller = StreamController<List<AppNotification>>();
    RealtimeChannel? channel;

    Future<void> push() async {
      try {
        final data = await _fetch(userId).timeout(_fetchTimeout);
        if (!controller.isClosed) controller.add(data);
      } catch (e) {
        if (!controller.isClosed && !controller.hasListener) return;
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller
      ..onListen = () {
        push();
        channel = _client.channel('notifications-$userId-${newId()}')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _table,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (_) => push(),
          )
          ..subscribe();
      }
      ..onCancel = () async {
        final ch = channel;
        if (ch != null) await _client.removeChannel(ch);
        if (!controller.isClosed) await controller.close();
      };

    return controller.stream;
  }

  @override
  Future<Result<void>> markRead(String id) async {
    try {
      await _client
          .from(_table)
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', id)
          .isFilter('read_at', null);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> markAllRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Err('You need to be signed in.');
    try {
      await _client
          .from(_table)
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('user_id', userId)
          .isFilter('read_at', null);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
