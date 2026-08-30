import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/insights/insights_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/utils/result.dart';

/// [InsightsRepository] backed by the single-row `car_popularity` table.
/// Online-only: there is no local cache for this screen.
class SupabaseInsightsRepository implements InsightsRepository {
  SupabaseInsightsRepository(this._client);

  final SupabaseClient _client;
  static const Duration _fetchTimeout = Duration(seconds: 8);
  static const String _rowId = 'latest';

  @override
  Future<Result<CarPopularity?>> getCarPopularity() async {
    try {
      final row = await _client
          .from('car_popularity')
          .select()
          .eq('id', _rowId)
          .maybeSingle()
          .timeout(_fetchTimeout);
      if (row == null) return const Ok(null);
      return Ok(_fromRow(row));
    } catch (e) {
      return Err(mapError(e));
    }
  }

  /// The jsonb `data` column holds the full snapshot; the scalar columns are
  /// authoritative for the metadata and override anything inside it.
  CarPopularity _fromRow(Map<String, dynamic> row) {
    final data = Map<String, dynamic>.from(
      (row['data'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    for (final column in const [
      'period_label',
      'generated_at',
      'source_url',
      'total_registrations',
    ]) {
      if (row[column] != null) data[column] = row[column];
    }
    return CarPopularity.fromJson(data);
  }
}
