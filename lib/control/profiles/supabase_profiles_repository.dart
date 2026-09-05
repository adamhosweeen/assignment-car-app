import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/profiles/profiles_cache_repository.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/search.dart';

class SupabaseProfilesRepository implements ProfilesRepository {
  SupabaseProfilesRepository(this._client, this._cache);

  final SupabaseClient _client;
  final ProfilesCacheRepository _cache;
  static const String _view = 'public_profiles';
  static const Duration _fetchTimeout = Duration(seconds: 8);

  @override
  Future<Result<PublicProfile?>> getById(String id) async {
    try {
      final row = await _client
          .from(_view)
          .select()
          .eq('id', id)
          .maybeSingle()
          .timeout(_fetchTimeout);
      if (row == null) return const Ok(null);
      final profile = PublicProfile.fromJson(row);
      await _cache.save(profile);
      return Ok(profile);
    } catch (e) {
      final cached = await _cache.getById(id);
      if (cached != null) return Ok(cached);
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<List<PublicProfile>>> search(
    String query, {
    int limit = 30,
  }) async {
    final q = sanitizeSearchQuery(query);
    if (q.isEmpty) return const Ok([]);
    try {
      final rows = await _client
          .from(_view)
          .select()
          .ilike('display_name', '%$q%')
          .order('display_name', ascending: true)
          .limit(limit)
          .timeout(_fetchTimeout);
      return Ok(rows.map(PublicProfile.fromJson).toList());
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
