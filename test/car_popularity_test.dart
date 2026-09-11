import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/insights/car_popularity.dart';

void main() {
  final snapshot = CarPopularity(
    periodLabel: '2025–2026 to date',
    periodStart: DateTime.utc(2025),
    periodEnd: DateTime.utc(2026, 12),
    generatedAt: DateTime.utc(2026, 9, 11, 12),
    sourceUrl: 'https://data.gov.my/x',
    totalRegistrations: 1410000,
    topMakers: const [
      RankedCount(name: 'Perodua', count: 50000),
      RankedCount(name: 'Proton', count: 30000),
    ],
    topModels: const [
      RankedModel(name: 'Myvi', maker: 'Perodua', count: 20000),
    ],
    byState: const {
      'Selangor': StateInsights(
        makers: [RankedCount(name: 'Perodua', count: 5000)],
        models: [RankedModel(name: 'Bezza', maker: 'Perodua', count: 2000)],
      ),
    },
  );

  test('round-trips through snake_case JSON', () {
    final json = snapshot.toJson();
    expect(json['period_label'], '2025–2026 to date');
    expect(json['total_registrations'], 1410000);
    expect(json['top_makers'], isA<List<dynamic>>());
    expect(json['by_state'], isA<Map<String, dynamic>>());

    final back = CarPopularity.fromJson(json);
    expect(back, snapshot);
    expect(back.generatedAt.isUtc, isTrue);
  });

  test('a state carries both its makers and its models', () {
    expect(snapshot.topMakersIn('Selangor').single.name, 'Perodua');
    expect(snapshot.topModelsIn('Selangor').single.name, 'Bezza');
    expect(snapshot.topMakersIn('Johor'), isEmpty);
    expect(snapshot.topModelsIn('Johor'), isEmpty);
  });

  test('hasDataFor decides whether the screen scopes to a state', () {
    expect(snapshot.hasDataFor('Selangor'), isTrue);
    expect(snapshot.hasDataFor('Johor'), isFalse);
    expect(snapshot.hasDataFor(null), isFalse);
  });

  test('a state present but empty is treated as no data', () {
    final empty = snapshot.copyWith(byState: const {'Perlis': StateInsights()});
    expect(empty.hasDataFor('Perlis'), isFalse);
  });

  test('missing list fields default to empty', () {
    final minimal = CarPopularity.fromJson({
      'period_label': '2026',
      'period_start': '2026-01-01T00:00:00.000Z',
      'period_end': '2026-12-01T00:00:00.000Z',
      'generated_at': '2026-09-11T00:00:00.000Z',
      'source_url': 'x',
      'total_registrations': 0,
    });
    expect(minimal.topMakers, isEmpty);
    expect(minimal.topModels, isEmpty);
    expect(minimal.byState, isEmpty);
  });

  test('RankedModel.title reads maker then model', () {
    expect(snapshot.topModels.single.title, 'Perodua Myvi');
  });
}
