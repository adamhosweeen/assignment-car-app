import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/utils/result.dart';

part 'insights_providers.g.dart';

/// The published car-popularity snapshot, or null when none exists yet.
/// Fetch failures surface as the provider's error state (plain-English
/// message from the repository) so the screen can offer a retry.
@riverpod
Future<CarPopularity?> carPopularity(Ref ref) async {
  final res = await ref.watch(insightsRepositoryProvider).getCarPopularity();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw InsightsException(message),
  };
}

/// Carries the repository's user-facing message through Riverpod's error
/// channel without exposing a raw backend exception to the UI.
class InsightsException implements Exception {
  const InsightsException(this.message);

  final String message;

  @override
  String toString() => message;
}
