import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_popularity.freezed.dart';
part 'car_popularity.g.dart';

/// A name with a registration count (a brand, a fuel type, a vehicle type).
@freezed
abstract class RankedCount with _$RankedCount {
  const factory RankedCount({required String name, required int count}) =
      _RankedCount;

  factory RankedCount.fromJson(Map<String, dynamic> json) =>
      _$RankedCountFromJson(json);
}

/// A car model with its maker and registration count.
@freezed
abstract class RankedModel with _$RankedModel {
  const factory RankedModel({
    required String name,
    required String maker,
    required int count,
  }) = _RankedModel;

  factory RankedModel.fromJson(Map<String, dynamic> json) =>
      _$RankedModelFromJson(json);
}

/// Registrations in one calendar month; [month] is `YYYY-MM`.
@freezed
abstract class MonthCount with _$MonthCount {
  const factory MonthCount({required String month, required int count}) =
      _MonthCount;

  factory MonthCount.fromJson(Map<String, dynamic> json) =>
      _$MonthCountFromJson(json);
}

/// A precomputed snapshot of Malaysian new-car registrations (JPJ data via
/// data.gov.my, CC BY 4.0), covering a rolling 12-month window.
///
/// Built offline by `tool/build_car_popularity.dart` and stored as one row in
/// the Supabase `car_popularity` table. The app only ever reads it; nothing in
/// the app talks to data.gov.my directly.
@freezed
abstract class CarPopularity with _$CarPopularity {
  const CarPopularity._();

  const factory CarPopularity({
    /// Human-readable window, e.g. "Aug 2025 – Jul 2026".
    required String periodLabel,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime generatedAt,
    required String sourceUrl,
    required int totalRegistrations,
    @Default(<RankedCount>[]) List<RankedCount> topMakers,
    @Default(<RankedModel>[]) List<RankedModel> topModels,

    /// Top makers per Malaysian state (dealer-portal registrations carry no
    /// state and are excluded here, though they count nationally).
    @Default(<String, List<RankedCount>>{})
    Map<String, List<RankedCount>> byState,
    @Default(<RankedCount>[]) List<RankedCount> fuelSplit,
    @Default(<RankedCount>[]) List<RankedCount> typeSplit,
    @Default(<MonthCount>[]) List<MonthCount> monthly,
  }) = _CarPopularity;

  factory CarPopularity.fromJson(Map<String, dynamic> json) =>
      _$CarPopularityFromJson(json);

  /// Top makers in [state], or an empty list when the snapshot has none.
  List<RankedCount> topMakersIn(String state) =>
      byState[state] ?? const <RankedCount>[];
}
