import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/utils/result.dart';

abstract interface class InsightsRepository {
  Future<Result<CarPopularity?>> getCarPopularity();
}
