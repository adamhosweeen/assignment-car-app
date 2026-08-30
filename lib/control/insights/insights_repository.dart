import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/utils/result.dart';

/// Read-only market data contract. The app never computes these figures; it
/// only reads the snapshot published to Supabase by `tool/build_car_popularity.dart`.
abstract interface class InsightsRepository {
  /// The latest published snapshot, `Ok(null)` when none has been published
  /// yet, or an [Err] with a user-facing message when the fetch fails.
  Future<Result<CarPopularity?>> getCarPopularity();
}
