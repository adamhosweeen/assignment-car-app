import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/malaysian_states.dart';

void main() {
  group('MalaysianStates.nearestTo', () {
    test('central KL maps to WP Kuala Lumpur', () {
      expect(MalaysianStates.nearestTo(3.1390, 101.6869), 'WP Kuala Lumpur');
    });

    test('Kota Kinabalu maps to Sabah', () {
      expect(MalaysianStates.nearestTo(5.9804, 116.0735), 'Sabah');
    });

    test('Kuching maps to Sarawak', () {
      expect(MalaysianStates.nearestTo(1.56, 110.35), 'Sarawak');
    });

    test('every centroid maps back to its own state', () {
      for (final entry in MalaysianStates.centroids.entries) {
        final (lat, lng) = entry.value;
        expect(MalaysianStates.nearestTo(lat, lng), entry.key);
      }
    });
  });
}
