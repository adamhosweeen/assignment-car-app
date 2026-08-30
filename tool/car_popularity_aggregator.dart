/// Pure aggregation for `build_car_popularity.dart`, kept separate so it can
/// be unit-tested without network access.
///
/// Input rows come from the data.gov.my "Car Registration Transactions" CSV
/// (`date_reg,type,maker,model,colour,fuel,state`). The output is a
/// [CarPopularity] covering the rolling 12 months ending at the latest month
/// present in the data.
library;

import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/model/malaysian_states.dart';

const int topMakersLimit = 15;
const int topModelsLimit = 20;
const int perStateLimit = 5;
const int windowMonths = 12;

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Joins maker and model into one map key. A control character, because
/// spaces occur inside real names ("Great Wall" / "Haval H6").
final String _sep = String.fromCharCode(1); // U+0001

/// Split one CSV line. Handles the (currently unused) RFC 4180 quoting so a
/// future model name with a comma does not corrupt the counts.
List<String> parseCsvLine(String line) {
  final fields = <String>[];
  final buf = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        buf.write(ch);
      }
    } else if (ch == '"') {
      inQuotes = true;
    } else if (ch == ',') {
      fields.add(buf.toString());
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  fields.add(buf.toString());
  return fields;
}

/// JPJ fuel codes → display buckets. Every `hybrid_*` variant folds into
/// Hybrid; the rare alternative fuels (NG, LNG, hydrogen) become Other.
String fuelBucket(String raw) {
  final f = raw.trim().toLowerCase();
  if (f.startsWith('hybrid')) return 'Hybrid';
  return switch (f) {
    'petrol' => 'Petrol',
    'diesel' || 'greendiesel' => 'Diesel',
    'electric' => 'Electric',
    _ => 'Other',
  };
}

/// JPJ vehicle-type codes → display buckets.
String typeBucket(String raw) => switch (raw.trim().toLowerCase()) {
  'motokar' => 'Car',
  'jip' => 'SUV & 4WD',
  'pick_up' => 'Pickup',
  'mpv' || 'motokar_pelbagai_utiliti' => 'MPV',
  'window_van' => 'Van',
  _ => 'Other',
};

/// JPJ state spelling → the app's `MalaysianStates.all` spelling, or null for
/// rows with no state (the "Rakan Niaga" dealer portal) or an unknown value.
String? normaliseState(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  if (s.startsWith('W.P. ')) s = 'WP ${s.substring(5)}';
  return MalaysianStates.all.contains(s) ? s : null;
}

/// Per-month partial counts. Kept per month so the 12-month window can be
/// chosen after a single streaming pass over multiple yearly files.
class _MonthBucket {
  int total = 0;
  final makers = <String, int>{};
  final models = <String, int>{}; // key: maker + _sep + model
  final byState = <String, Map<String, int>>{};
  final fuel = <String, int>{};
  final type = <String, int>{};
}

/// Accumulates rows; call [build] once every file has been fed in.
class CarPopularityAggregator {
  final Map<String, _MonthBucket> _months = {};
  Map<String, int>? _columns;
  int skipped = 0;

  /// Feed one parsed line. The first line fed must be the CSV header (it is
  /// used to locate columns, so column order does not matter).
  void add(List<String> fields) {
    final cols = _columns;
    if (cols == null) {
      final map = {for (var i = 0; i < fields.length; i++) fields[i].trim(): i};
      for (final required in const [
        'date_reg',
        'type',
        'maker',
        'model',
        'fuel',
        'state',
      ]) {
        if (!map.containsKey(required)) {
          throw FormatException('CSV header is missing "$required" column');
        }
      }
      _columns = map;
      return;
    }
    if (fields.length < cols.length) {
      skipped++;
      return;
    }
    final date = fields[cols['date_reg']!].trim();
    if (date.length < 7) {
      skipped++;
      return;
    }
    final month = date.substring(0, 7); // YYYY-MM
    final maker = fields[cols['maker']!].trim();
    final model = fields[cols['model']!].trim();
    if (maker.isEmpty) {
      skipped++;
      return;
    }

    final b = _months.putIfAbsent(month, _MonthBucket.new);
    b.total++;
    b.makers.update(maker, (n) => n + 1, ifAbsent: () => 1);
    b.models.update('$maker$_sep$model', (n) => n + 1, ifAbsent: () => 1);
    b.fuel.update(
      fuelBucket(fields[cols['fuel']!]),
      (n) => n + 1,
      ifAbsent: () => 1,
    );
    b.type.update(
      typeBucket(fields[cols['type']!]),
      (n) => n + 1,
      ifAbsent: () => 1,
    );
    final state = normaliseState(fields[cols['state']!]);
    if (state != null) {
      b.byState
          .putIfAbsent(state, () => <String, int>{})
          .update(maker, (n) => n + 1, ifAbsent: () => 1);
    }
  }

  /// Fold the last [windowMonths] months (ending at the latest month seen)
  /// into a snapshot.
  CarPopularity build({
    required DateTime generatedAt,
    required String sourceUrl,
  }) {
    if (_months.isEmpty) {
      throw StateError('No registration rows were read');
    }
    final months = _months.keys.toList()..sort();
    final window = months.length > windowMonths
        ? months.sublist(months.length - windowMonths)
        : months;

    var total = 0;
    final makers = <String, int>{};
    final models = <String, int>{};
    final byState = <String, Map<String, int>>{};
    final fuel = <String, int>{};
    final type = <String, int>{};
    final monthly = <MonthCount>[];

    for (final m in window) {
      final b = _months[m]!;
      total += b.total;
      monthly.add(MonthCount(month: m, count: b.total));
      _merge(makers, b.makers);
      _merge(models, b.models);
      _merge(fuel, b.fuel);
      _merge(type, b.type);
      for (final entry in b.byState.entries) {
        _merge(
          byState.putIfAbsent(entry.key, () => <String, int>{}),
          entry.value,
        );
      }
    }

    final stateRanked = <String, List<RankedCount>>{};
    for (final state in MalaysianStates.all) {
      final counts = byState[state];
      if (counts == null || counts.isEmpty) continue;
      stateRanked[state] = _rank(counts, perStateLimit);
    }

    return CarPopularity(
      periodLabel: _periodLabel(window.first, window.last),
      periodStart: _monthStart(window.first),
      periodEnd: _monthStart(window.last),
      generatedAt: generatedAt.toUtc(),
      sourceUrl: sourceUrl,
      totalRegistrations: total,
      topMakers: _rank(makers, topMakersLimit),
      topModels: _rankModels(models, topModelsLimit),
      byState: stateRanked,
      fuelSplit: _rank(fuel, fuel.length),
      typeSplit: _rank(type, type.length),
      monthly: monthly,
    );
  }

  static void _merge(Map<String, int> into, Map<String, int> from) {
    for (final e in from.entries) {
      into.update(e.key, (n) => n + e.value, ifAbsent: () => e.value);
    }
  }

  static List<MapEntry<String, int>> _sorted(Map<String, int> counts) =>
      counts.entries.toList()..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });

  static List<RankedCount> _rank(Map<String, int> counts, int limit) => [
    for (final e in _sorted(counts).take(limit))
      RankedCount(name: e.key, count: e.value),
  ];

  static List<RankedModel> _rankModels(Map<String, int> counts, int limit) => [
    for (final e in _sorted(counts).take(limit))
      RankedModel(
        maker: e.key.substring(0, e.key.indexOf(_sep)),
        name: e.key.substring(e.key.indexOf(_sep) + 1),
        count: e.value,
      ),
  ];

  static DateTime _monthStart(String yyyyMm) => DateTime.utc(
    int.parse(yyyyMm.substring(0, 4)),
    int.parse(yyyyMm.substring(5, 7)),
  );

  static String _periodLabel(String first, String last) {
    String label(String m) {
      final d = _monthStart(m);
      return '${_monthNames[d.month - 1]} ${d.year}';
    }

    return first == last ? label(first) : '${label(first)} – ${label(last)}';
  }
}
