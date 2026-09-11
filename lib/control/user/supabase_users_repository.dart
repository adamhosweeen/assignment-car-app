import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/user/other_users_cache_repository.dart';
import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/search.dart';

class SupabaseProfilesRepository implements UsersRepository {
  SupabaseProfilesRepository(this._client, this._cache);

  final SupabaseClient _client;
  final OtherUsersCacheRepository _cache;
  static const String _table = 'users';
  static const Duration _fetchTimeout = Duration(seconds: 8);

  @override
  Future<Result<AppUser?>> getById(String id) async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle()
          .timeout(_fetchTimeout);
      if (row == null) return const Ok(null);
      final profile = AppUser.fromJson(row);
      await _cache.save(profile);
      return Ok(profile);
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
      final rows = await _client
          .from(_table)
          .select()
          .ilike('display_name', '%$q%')
          .order('display_name', ascending: true)
          .limit(limit)
          .timeout(_fetchTimeout);
      return Ok(rows.map(AppUser.fromJson).toList());
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
