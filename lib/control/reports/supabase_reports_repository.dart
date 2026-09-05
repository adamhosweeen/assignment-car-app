import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/reports/reports_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/utils/result.dart';

class SupabaseReportsRepository implements ReportsRepository {
  SupabaseReportsRepository(this._client);

  final SupabaseClient _client;
  static const Duration _writeTimeout = Duration(seconds: 8);

  @override
  Future<Result<void>> submit({
    required String reportedId,
    required String title,
    required String description,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to report a user.');
    }
    try {
      await _client
          .from('reports')
          .insert({
            'reporter_id': user.id,
            'reported_id': reportedId,
            'title': title.trim(),
            'description': description.trim(),
          })
          .timeout(_writeTimeout);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
