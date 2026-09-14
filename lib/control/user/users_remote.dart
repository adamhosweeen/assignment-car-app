import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/model/user/app_user.dart';

class UsersRemote {
  UsersRemote(this._client);

  final SupabaseClient _client;

  static const String _table = 'users';
  static const Duration _timeout = Duration(seconds: 8);

  Future<AppUser?> fetchById(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle()
        .timeout(_timeout);
    return row == null ? null : AppUser.fromJson(row);
  }

  Future<List<AppUser>> searchByName(String query, {required int limit}) async {
    final rows = await _client
        .from(_table)
        .select()
        .ilike('display_name', '%$query%')
        .order('display_name', ascending: true)
        .limit(limit)
        .timeout(_timeout);
    return rows.map(AppUser.fromJson).toList();
  }
}
