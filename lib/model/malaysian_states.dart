import 'package:assignment/model/listing/listing_enums.dart';

/// The 16 Malaysian states and federal territories (V1_SPEC §2), for the state
/// dropdown. In the sell flow the picker is filtered by the chosen
/// [RegistrationRegion] (West / East Malaysia) via [inRegion].
abstract final class MalaysianStates {
  static const List<String> all = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Pulau Pinang',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'WP Kuala Lumpur',
    'WP Labuan',
    'WP Putrajaya',
  ];

  /// The Borneo states and territory. Everything else is West (Peninsular).
  static const Set<String> _east = {'Sabah', 'Sarawak', 'WP Labuan'};

  /// The states in [region], in [all] order — used to filter the state picker
  /// once a region is chosen in the sell flow.
  static List<String> inRegion(RegistrationRegion region) {
    final wantEast = region == RegistrationRegion.east;
    return [
      for (final s in all)
        if (_east.contains(s) == wantEast) s,
    ];
  }

  /// The region a state belongs to.
  static RegistrationRegion regionOf(String state) =>
      _east.contains(state) ? RegistrationRegion.east : RegistrationRegion.west;

  /// Approximate centre of population for each state (state capital), used to
  /// map a GPS fix to a state without a geocoding service. Precision beyond
  /// "which state is closest" is not needed.
  static const Map<String, (double, double)> centroids = {
    'Johor': (1.4854, 103.7618),
    'Kedah': (6.1184, 100.3685),
    'Kelantan': (6.1254, 102.2381),
    'Melaka': (2.1896, 102.2501),
    'Negeri Sembilan': (2.7258, 101.9424),
    'Pahang': (3.8077, 103.3260),
    'Perak': (4.5975, 101.0901),
    'Perlis': (6.4414, 100.1986),
    'Pulau Pinang': (5.4141, 100.3288),
    'Sabah': (5.9804, 116.0735),
    'Sarawak': (1.5533, 110.3592),
    'Selangor': (3.0738, 101.5183),
    'Terengganu': (5.3302, 103.1408),
    'WP Kuala Lumpur': (3.1390, 101.6869),
    'WP Labuan': (5.2831, 115.2308),
    'WP Putrajaya': (2.9264, 101.6964),
  };

  /// The state whose centroid is nearest to the given coordinates.
  static String nearestTo(double latitude, double longitude) {
    var best = all.first;
    var bestDistance = double.infinity;
    for (final entry in centroids.entries) {
      final (lat, lng) = entry.value;
      final dLat = lat - latitude;
      final dLng = lng - longitude;
      final distance = dLat * dLat + dLng * dLng;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = entry.key;
      }
    }
    return best;
  }
}
