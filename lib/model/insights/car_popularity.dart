import 'package:flutter/foundation.dart';

import 'package:assignment/utils/json.dart';

class RankedCount {
  const RankedCount({required this.name, required this.count});

  factory RankedCount.fromJson(Map<String, dynamic> json) =>
      RankedCount(name: json['name'] as String, count: asInt(json['count']));

  final String name;
  final int count;

  Map<String, dynamic> toJson() => {'name': name, 'count': count};

  RankedCount copyWith({String? name, int? count}) =>
      RankedCount(name: name ?? this.name, count: count ?? this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankedCount && name == other.name && count == other.count;

  @override
  int get hashCode => Object.hash(name, count);

  @override
  String toString() => 'RankedCount(name: $name, count: $count)';
}

class RankedModel {
  const RankedModel({
    required this.name,
    required this.maker,
    required this.count,
  });

  factory RankedModel.fromJson(Map<String, dynamic> json) => RankedModel(
    name: json['name'] as String,
    maker: json['maker'] as String,
    count: asInt(json['count']),
  );

  final String name;
  final String maker;
  final int count;

  Map<String, dynamic> toJson() => {
    'name': name,
    'maker': maker,
    'count': count,
  };

  String get title => '$maker $name';

  RankedModel copyWith({String? name, String? maker, int? count}) =>
      RankedModel(
        name: name ?? this.name,
        maker: maker ?? this.maker,
        count: count ?? this.count,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankedModel &&
          name == other.name &&
          maker == other.maker &&
          count == other.count;

  @override
  int get hashCode => Object.hash(name, maker, count);

  @override
  String toString() => 'RankedModel(name: $name, maker: $maker, count: $count)';
}

class StateInsights {
  const StateInsights({
    this.makers = const <RankedCount>[],
    this.models = const <RankedModel>[],
  });

  factory StateInsights.fromJson(Map<String, dynamic> json) => StateInsights(
    makers: asModelList(json['makers'], RankedCount.fromJson),
    models: asModelList(json['models'], RankedModel.fromJson),
  );

  final List<RankedCount> makers;
  final List<RankedModel> models;

  Map<String, dynamic> toJson() => {
    'makers': [for (final m in makers) m.toJson()],
    'models': [for (final m in models) m.toJson()],
  };

  bool get isEmpty => makers.isEmpty && models.isEmpty;

  StateInsights copyWith({
    List<RankedCount>? makers,
    List<RankedModel>? models,
  }) => StateInsights(
    makers: makers ?? this.makers,
    models: models ?? this.models,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateInsights &&
          listEquals(makers, other.makers) &&
          listEquals(models, other.models);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(makers), Object.hashAll(models));

  @override
  String toString() => 'StateInsights(makers: $makers, models: $models)';
}

class CarPopularity {
  const CarPopularity({
    required this.periodLabel,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.sourceUrl,
    required this.totalRegistrations,
    this.topMakers = const <RankedCount>[],
    this.topModels = const <RankedModel>[],
    this.byState = const <String, StateInsights>{},
  });

  factory CarPopularity.fromJson(Map<String, dynamic> json) => CarPopularity(
    periodLabel: json['period_label'] as String,
    periodStart: asDate(json['period_start']),
    periodEnd: asDate(json['period_end']),
    generatedAt: asDate(json['generated_at']),
    sourceUrl: json['source_url'] as String,
    totalRegistrations: asInt(json['total_registrations']),
    topMakers: asModelList(json['top_makers'], RankedCount.fromJson),
    topModels: asModelList(json['top_models'], RankedModel.fromJson),
    byState:
        (json['by_state'] as Map<String, dynamic>?)?.map(
          (state, value) => MapEntry(
            state,
            StateInsights.fromJson(value as Map<String, dynamic>),
          ),
        ) ??
        const <String, StateInsights>{},
  );

  final String periodLabel;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String sourceUrl;
  final int totalRegistrations;
  final List<RankedCount> topMakers;
  final List<RankedModel> topModels;
  final Map<String, StateInsights> byState;

  Map<String, dynamic> toJson() => {
    'period_label': periodLabel,
    'period_start': periodStart.toIso8601String(),
    'period_end': periodEnd.toIso8601String(),
    'generated_at': generatedAt.toIso8601String(),
    'source_url': sourceUrl,
    'total_registrations': totalRegistrations,
    'top_makers': [for (final m in topMakers) m.toJson()],
    'top_models': [for (final m in topModels) m.toJson()],
    'by_state': byState.map((state, v) => MapEntry(state, v.toJson())),
  };

  List<RankedCount> topMakersIn(String state) =>
      byState[state]?.makers ?? const <RankedCount>[];

  List<RankedModel> topModelsIn(String state) =>
      byState[state]?.models ?? const <RankedModel>[];

  bool hasDataFor(String? state) =>
      state != null && !(byState[state]?.isEmpty ?? true);

  CarPopularity copyWith({
    String? periodLabel,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? generatedAt,
    String? sourceUrl,
    int? totalRegistrations,
    List<RankedCount>? topMakers,
    List<RankedModel>? topModels,
    Map<String, StateInsights>? byState,
  }) => CarPopularity(
    periodLabel: periodLabel ?? this.periodLabel,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    generatedAt: generatedAt ?? this.generatedAt,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    totalRegistrations: totalRegistrations ?? this.totalRegistrations,
    topMakers: topMakers ?? this.topMakers,
    topModels: topModels ?? this.topModels,
    byState: byState ?? this.byState,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarPopularity &&
          periodLabel == other.periodLabel &&
          periodStart == other.periodStart &&
          periodEnd == other.periodEnd &&
          generatedAt == other.generatedAt &&
          sourceUrl == other.sourceUrl &&
          totalRegistrations == other.totalRegistrations &&
          listEquals(topMakers, other.topMakers) &&
          listEquals(topModels, other.topModels) &&
          _byStateEquals(byState, other.byState);

  @override
  int get hashCode => Object.hash(
    periodLabel,
    periodStart,
    periodEnd,
    generatedAt,
    sourceUrl,
    totalRegistrations,
    Object.hashAll(topMakers),
    Object.hashAll(topModels),
    Object.hashAll(byState.keys),
  );

  @override
  String toString() =>
      'CarPopularity(periodLabel: $periodLabel, '
      'totalRegistrations: $totalRegistrations, '
      'topMakers: ${topMakers.length}, topModels: ${topModels.length}, '
      'states: ${byState.length})';

  static bool _byStateEquals(
    Map<String, StateInsights> a,
    Map<String, StateInsights> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (entry.value != b[entry.key]) return false;
    }
    return true;
  }
}
