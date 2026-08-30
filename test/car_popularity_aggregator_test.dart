import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/insights/car_popularity.dart';

// The aggregator is dev tooling under tool/, outside lib/, so it can only be
// reached with a relative import.
import '../tool/car_popularity_aggregator.dart';

const _header = 'date_reg,type,maker,model,colour,fuel,state';

CarPopularityAggregator _feed(List<String> lines) {
  final agg = CarPopularityAggregator();
  agg.add(parseCsvLine(_header));
  for (final line in lines) {
    agg.add(parseCsvLine(line));
  }
  return agg;
}

final _now = DateTime.utc(2026, 8, 30);

void main() {
  group('parseCsvLine', () {
    test('splits plain fields', () {
      expect(parseCsvLine('2026-01-01,motokar,Honda,Civic,blue,petrol,Kedah'), [
        '2026-01-01',
        'motokar',
        'Honda',
        'Civic',
        'blue',
        'petrol',
        'Kedah',
      ]);
    });

    test('keeps commas and escaped quotes inside quoted fields', () {
      expect(parseCsvLine('a,"x, y","say ""hi""",b'), [
        'a',
        'x, y',
        'say "hi"',
        'b',
      ]);
    });
  });

  group('buckets', () {
    test('fuel folds every hybrid variant and greendiesel', () {
      expect(fuelBucket('hybrid_petrol'), 'Hybrid');
      expect(fuelBucket('hybrid_diesel'), 'Hybrid');
      expect(fuelBucket('greendiesel'), 'Diesel');
      expect(fuelBucket('electric'), 'Electric');
      expect(fuelBucket('ng'), 'Other');
    });

    test('type maps JPJ codes to display buckets', () {
      expect(typeBucket('motokar'), 'Car');
      expect(typeBucket('jip'), 'SUV & 4WD');
      expect(typeBucket('motokar_pelbagai_utiliti'), 'MPV');
      expect(typeBucket('MPV'), 'MPV');
      expect(typeBucket('window_van'), 'Van');
      expect(typeBucket('pick_up'), 'Pickup');
    });

    test('state normalises W.P. spellings and drops Rakan Niaga', () {
      expect(normaliseState('W.P. Kuala Lumpur'), 'WP Kuala Lumpur');
      expect(normaliseState('Pulau Pinang'), 'Pulau Pinang');
      expect(normaliseState('Rakan Niaga'), isNull);
      expect(normaliseState(''), isNull);
    });
  });

  group('CarPopularityAggregator', () {
    test('counts nationally, ranks makers/models, and keys states', () {
      final agg = _feed([
        '2026-07-01,motokar,Perodua,Myvi,white,petrol,Selangor',
        '2026-07-02,motokar,Perodua,Myvi,black,petrol,Rakan Niaga',
        '2026-07-03,motokar,Perodua,Axia,white,petrol,W.P. Kuala Lumpur',
        '2026-07-04,jip,Great Wall,Haval H6,grey,hybrid_petrol,Rakan Niaga',
        '2026-07-05,motokar,Proton,Saga,red,petrol,Johor',
      ]);
      final s = agg.build(generatedAt: _now, sourceUrl: 'src');

      expect(s.totalRegistrations, 5);
      expect(s.topMakers.first, const RankedCount(name: 'Perodua', count: 3));
      expect(
        s.topModels.first,
        const RankedModel(name: 'Myvi', maker: 'Perodua', count: 2),
      );
      // Multi-word maker and model survive the maker/model split.
      expect(
        s.topModels.firstWhere((m) => m.maker == 'Great Wall').name,
        'Haval H6',
      );
      // Rakan Niaga rows count nationally but never appear per state.
      expect(
        s.byState.keys,
        unorderedEquals(['Selangor', 'WP Kuala Lumpur', 'Johor']),
      );
      expect(s.topMakersIn('Selangor').single.count, 1);
      expect(
        s.fuelSplit,
        contains(const RankedCount(name: 'Hybrid', count: 1)),
      );
      expect(s.typeSplit.first, const RankedCount(name: 'Car', count: 4));
      expect(s.periodLabel, 'Jul 2026');
      expect(s.monthly.single, const MonthCount(month: '2026-07', count: 5));
      expect(agg.skipped, 0);
    });

    test('keeps only the last 12 months, ending at the latest month seen', () {
      final lines = <String>[];
      // 14 consecutive months: Jun 2025 … Jul 2026, one row each.
      for (var i = 0; i < 14; i++) {
        final d = DateTime.utc(2025, 6 + i, 1);
        final mm = d.month.toString().padLeft(2, '0');
        lines.add('${d.year}-$mm-15,motokar,Proton,Saga,red,petrol,Johor');
      }
      final s = _feed(lines).build(generatedAt: _now, sourceUrl: 'src');

      expect(s.monthly.length, windowMonths);
      expect(s.monthly.first.month, '2025-08');
      expect(s.monthly.last.month, '2026-07');
      expect(s.periodLabel, 'Aug 2025 – Jul 2026');
      expect(s.periodStart, DateTime.utc(2025, 8));
      expect(s.periodEnd, DateTime.utc(2026, 7));
      expect(s.totalRegistrations, 12);
    });

    test('skips short or malformed rows and rejects a bad header', () {
      final agg = _feed([
        '2026-07-01,motokar',
        ',motokar,Proton,Saga,red,petrol,Johor',
      ]);
      expect(agg.skipped, 2);
      expect(
        () => CarPopularityAggregator().add(['date_reg', 'maker']),
        throwsFormatException,
      );
    });

    test('ties are broken alphabetically for stable output', () {
      final s = _feed([
        '2026-07-01,motokar,Toyota,Vios,white,petrol,Johor',
        '2026-07-01,motokar,Honda,City,white,petrol,Johor',
      ]).build(generatedAt: _now, sourceUrl: 'src');
      expect(s.topMakers.map((m) => m.name), ['Honda', 'Toyota']);
    });
  });
}
