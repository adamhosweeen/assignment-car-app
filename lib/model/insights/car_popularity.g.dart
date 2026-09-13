// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_popularity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RankedCount _$RankedCountFromJson(Map<String, dynamic> json) => _RankedCount(
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$RankedCountToJson(_RankedCount instance) =>
    <String, dynamic>{'name': instance.name, 'count': instance.count};

_RankedModel _$RankedModelFromJson(Map<String, dynamic> json) => _RankedModel(
  name: json['name'] as String,
  maker: json['maker'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$RankedModelToJson(_RankedModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'maker': instance.maker,
      'count': instance.count,
    };

_MonthCount _$MonthCountFromJson(Map<String, dynamic> json) => _MonthCount(
  month: json['month'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$MonthCountToJson(_MonthCount instance) =>
    <String, dynamic>{'month': instance.month, 'count': instance.count};

_CarPopularity _$CarPopularityFromJson(Map<String, dynamic> json) =>
    _CarPopularity(
      periodLabel: json['period_label'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      sourceUrl: json['source_url'] as String,
      totalRegistrations: (json['total_registrations'] as num).toInt(),
      topMakers:
          (json['top_makers'] as List<dynamic>?)
              ?.map((e) => RankedCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RankedCount>[],
      topModels:
          (json['top_models'] as List<dynamic>?)
              ?.map((e) => RankedModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RankedModel>[],
      byState:
          (json['by_state'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>)
                  .map((e) => RankedCount.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ),
          ) ??
          const <String, List<RankedCount>>{},
      fuelSplit:
          (json['fuel_split'] as List<dynamic>?)
              ?.map((e) => RankedCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RankedCount>[],
      typeSplit:
          (json['type_split'] as List<dynamic>?)
              ?.map((e) => RankedCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RankedCount>[],
      monthly:
          (json['monthly'] as List<dynamic>?)
              ?.map((e) => MonthCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MonthCount>[],
    );

Map<String, dynamic> _$CarPopularityToJson(_CarPopularity instance) =>
    <String, dynamic>{
      'period_label': instance.periodLabel,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'generated_at': instance.generatedAt.toIso8601String(),
      'source_url': instance.sourceUrl,
      'total_registrations': instance.totalRegistrations,
      'top_makers': instance.topMakers.map((e) => e.toJson()).toList(),
      'top_models': instance.topModels.map((e) => e.toJson()).toList(),
      'by_state': instance.byState.map(
        (k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()),
      ),
      'fuel_split': instance.fuelSplit.map((e) => e.toJson()).toList(),
      'type_split': instance.typeSplit.map((e) => e.toJson()).toList(),
      'monthly': instance.monthly.map((e) => e.toJson()).toList(),
    };
