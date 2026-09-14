import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/control/user/other_users_cache.dart';
import 'package:assignment/control/user/users_remote.dart';
import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/search.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl(this._remote, this._cache);

  final UsersRemote _remote;
  final OtherUsersCache _cache;

  @override
  Future<Result<AppUser?>> getById(String id) async {
    try {
      final user = await _remote.fetchById(id);
      if (user == null) return const Ok(null);
      await _cache.save(user);
      return Ok(user);
    } catch (e) {
      final cached = await _cache.getById(id);
      if (cached != null) return Ok(cached);
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<List<AppUser>>> search(String query, {int limit = 30}) async {
    final q = sanitizeSearchQuery(query);
    if (q.isEmpty) return const Ok([]);
    try {
      return Ok(await _remote.searchByName(q, limit: limit));
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
