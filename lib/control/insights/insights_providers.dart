import 'package:assignment/control/insights/insights_repository.dart';
import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/utils/result.dart';

/// The published car-popularity snapshot, or null when none exists yet.
/// Fetch failures surface as the `FutureBuilder`'s error state (plain-English
/// message from the repository) so the screen can offer a retry.
Future<CarPopularity?> fetchCarPopularity(InsightsRepository insights) async {
  final res = await insights.getCarPopularity();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw InsightsException(message),
  };
}

/// Carries the repository's user-facing message through a `FutureBuilder`'s
/// error channel without exposing a raw backend exception to the UI.
class InsightsException implements Exception {
  const InsightsException(this.message);

  final String message;

  @override
  String toString() => message;
}
