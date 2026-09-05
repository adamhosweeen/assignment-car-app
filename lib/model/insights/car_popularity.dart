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

class MonthCount {
  const MonthCount({required this.month, required this.count});

  factory MonthCount.fromJson(Map<String, dynamic> json) =>
      MonthCount(month: json['month'] as String, count: asInt(json['count']));

  final String month;
  final int count;

  Map<String, dynamic> toJson() => {'month': month, 'count': count};

  MonthCount copyWith({String? month, int? count}) =>
      MonthCount(month: month ?? this.month, count: count ?? this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthCount && month == other.month && count == other.count;

  @override
  int get hashCode => Object.hash(month, count);

  @override
  String toString() => 'MonthCount(month: $month, count: $count)';
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
    this.byState = const <String, List<RankedCount>>{},
    this.fuelSplit = const <RankedCount>[],
    this.typeSplit = const <RankedCount>[],
    this.monthly = const <MonthCount>[],
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
          (state, ranked) =>
              MapEntry(state, asModelList(ranked, RankedCount.fromJson)),
        ) ??
        <String, List<RankedCount>>{},
    fuelSplit: asModelList(json['fuel_split'], RankedCount.fromJson),
    typeSplit: asModelList(json['type_split'], RankedCount.fromJson),
    monthly: asModelList(json['monthly'], MonthCount.fromJson),
  );

  final String periodLabel;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String sourceUrl;
  final int totalRegistrations;
  final List<RankedCount> topMakers;
  final List<RankedModel> topModels;

  final Map<String, List<RankedCount>> byState;
  final List<RankedCount> fuelSplit;
  final List<RankedCount> typeSplit;
  final List<MonthCount> monthly;

  Map<String, dynamic> toJson() => {
    'period_label': periodLabel,
    'period_start': periodStart.toIso8601String(),
    'period_end': periodEnd.toIso8601String(),
    'generated_at': generatedAt.toIso8601String(),
    'source_url': sourceUrl,
    'total_registrations': totalRegistrations,
    'top_makers': [for (final m in topMakers) m.toJson()],
    'top_models': [for (final m in topModels) m.toJson()],
    'by_state': byState.map(
      (state, ranked) => MapEntry(state, [for (final r in ranked) r.toJson()]),
    ),
    'fuel_split': [for (final f in fuelSplit) f.toJson()],
    'type_split': [for (final t in typeSplit) t.toJson()],
    'monthly': [for (final m in monthly) m.toJson()],
  };

  List<RankedCount> topMakersIn(String state) =>
      byState[state] ?? const <RankedCount>[];

  CarPopularity copyWith({
    String? periodLabel,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? generatedAt,
    String? sourceUrl,
    int? totalRegistrations,
    List<RankedCount>? topMakers,
    List<RankedModel>? topModels,
    Map<String, List<RankedCount>>? byState,
    List<RankedCount>? fuelSplit,
    List<RankedCount>? typeSplit,
    List<MonthCount>? monthly,
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
    fuelSplit: fuelSplit ?? this.fuelSplit,
    typeSplit: typeSplit ?? this.typeSplit,
    monthly: monthly ?? this.monthly,
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
          _byStateEquals(byState, other.byState) &&
          listEquals(fuelSplit, other.fuelSplit) &&
          listEquals(typeSplit, other.typeSplit) &&
          listEquals(monthly, other.monthly);

  @override
  int get hashCode => Object.hashAll([
    periodLabel,
    periodStart,
    periodEnd,
    generatedAt,
    sourceUrl,
    totalRegistrations,
    Object.hashAll(topMakers),
    Object.hashAll(topModels),
    Object.hashAllUnordered([
      for (final e in byState.entries)
        Object.hash(e.key, Object.hashAll(e.value)),
    ]),
    Object.hashAll(fuelSplit),
    Object.hashAll(typeSplit),
    Object.hashAll(monthly),
  ]);

  @override
  String toString() =>
      'CarPopularity(periodLabel: $periodLabel, '
      'totalRegistrations: $totalRegistrations, '
      'generatedAt: $generatedAt)';
}

bool _byStateEquals(
  Map<String, List<RankedCount>> a,
  Map<String, List<RankedCount>> b,
) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    final other = b[entry.key];
    if (other == null || !listEquals(entry.value, other)) return false;
  }
  return true;
}
