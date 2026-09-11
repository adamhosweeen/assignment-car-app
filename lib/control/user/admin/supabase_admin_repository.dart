import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/user/admin/admin_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/report.dart';
import 'package:assignment/utils/result.dart';

class SupabaseAdminRepository implements AdminRepository {
  SupabaseAdminRepository(this._client);

  final SupabaseClient _client;
  static const Duration _fetchTimeout = Duration(seconds: 8);

  @override
  Future<Result<List<AppUser>>> listUsers() async {
    try {
      final rows = await _client
          .rpc<List<dynamic>>('admin_user_stats')
          .timeout(_fetchTimeout);
      return Ok([
        for (final row in rows) AppUser.fromJson(row as Map<String, dynamic>),
      ]);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<List<Report>>> listReports() async {
    try {
      final rows = await _client
          .rpc<List<dynamic>>('admin_reports')
          .timeout(_fetchTimeout);
      return Ok([
        for (final row in rows) Report.fromJson(row as Map<String, dynamic>),
      ]);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> resolveReport(String reportId) async {
    try {
      await _client
          .rpc<void>('admin_resolve_report', params: {'report_id': reportId})
          .timeout(_fetchTimeout);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> setBanned(String userId, bool banned) async {
    try {
      await _client
          .rpc<void>(
            'admin_set_banned',
            params: {'target': userId, 'ban': banned},
          )
          .timeout(_fetchTimeout);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }
}
