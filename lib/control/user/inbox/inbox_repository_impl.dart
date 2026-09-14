import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/control/user/inbox/inbox_cache.dart';
import 'package:assignment/control/user/inbox/inbox_remote.dart';
import 'package:assignment/control/user/inbox/inbox_repository.dart';
import 'package:assignment/model/user/inbox_message.dart';
import 'package:assignment/utils/result.dart';

class InboxRepositoryImpl implements InboxRepository {
  InboxRepositoryImpl(this._remote, this._cache);

  final InboxRemote _remote;
  final InboxCache _cache;

  @override
  Future<Result<List<InboxMessage>>> list() async {
    final uid = _remote.currentUserId;
    if (uid == null) return const Ok([]);
    try {
      final messages = await _remote.list(uid);
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
      await _remote.markRead(id, readAt);
      await _cache.markRead(id, readAt);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _remote.delete(id);
      await _cache.delete(id);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
