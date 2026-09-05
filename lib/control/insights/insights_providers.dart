import 'package:assignment/control/insights/insights_repository.dart';
import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/utils/result.dart';

Future<CarPopularity?> fetchCarPopularity(InsightsRepository insights) async {
  final res = await insights.getCarPopularity();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw InsightsException(message),
  };
}

class InsightsException implements Exception {
  const InsightsException(this.message);

  final String message;

  @override
  String toString() => message;
}
