import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/insights/car_popularity.dart';

void main() {
  final snapshot = CarPopularity(
    periodLabel: 'Aug 2025 – Jul 2026',
    periodStart: DateTime.utc(2025, 8),
    periodEnd: DateTime.utc(2026, 7),
    generatedAt: DateTime.utc(2026, 8, 30, 12),
    sourceUrl: 'https://data.gov.my/x',
    totalRegistrations: 123456,
    topMakers: const [
      RankedCount(name: 'Perodua', count: 50000),
      RankedCount(name: 'Proton', count: 30000),
    ],
    topModels: const [
      RankedModel(name: 'Myvi', maker: 'Perodua', count: 20000),
    ],
    byState: const {
      'Selangor': [RankedCount(name: 'Perodua', count: 5000)],
    },
    fuelSplit: const [RankedCount(name: 'Petrol', count: 100000)],
    typeSplit: const [RankedCount(name: 'Car', count: 90000)],
    monthly: const [MonthCount(month: '2025-08', count: 10000)],
  );

  test('round-trips through snake_case JSON', () {
    final json = snapshot.toJson();
    expect(json['period_label'], 'Aug 2025 – Jul 2026');
    expect(json['total_registrations'], 123456);
    expect(json['top_makers'], isA<List<dynamic>>());
    expect(json['by_state'], isA<Map<String, dynamic>>());

    final back = CarPopularity.fromJson(json);
    expect(back, snapshot);
    expect(back.generatedAt.isUtc, isTrue);
  });

  test('topMakersIn returns the ranked list or empty for unknown states', () {
    expect(snapshot.topMakersIn('Selangor').single.name, 'Perodua');
    expect(snapshot.topMakersIn('Johor'), isEmpty);
  });

  test('missing list fields default to empty', () {
    final minimal = CarPopularity.fromJson({
      'period_label': 'Jul 2026',
      'period_start': '2026-07-01T00:00:00.000Z',
      'period_end': '2026-07-01T00:00:00.000Z',
      'generated_at': '2026-08-30T00:00:00.000Z',
      'source_url': 'x',
      'total_registrations': 0,
    });
    expect(minimal.topMakers, isEmpty);
    expect(minimal.byState, isEmpty);
    expect(minimal.monthly, isEmpty);
  });
}
