import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/malaysian_states.dart';

void main() {
  group('MalaysianStates.inRegion', () {
    test('East Malaysia is only the Borneo states/territory', () {
      expect(
        MalaysianStates.inRegion(RegistrationRegion.east),
        ['Sabah', 'Sarawak', 'WP Labuan'],
      );
    });

    test('West Malaysia excludes Sabah, Sarawak and Labuan', () {
      final west = MalaysianStates.inRegion(RegistrationRegion.west);
      expect(west, contains('Selangor'));
      expect(west, contains('WP Kuala Lumpur'));
      expect(west, isNot(contains('Sabah')));
      expect(west, isNot(contains('Sarawak')));
      expect(west, isNot(contains('WP Labuan')));
    });

    test('the two regions partition every state exactly once', () {
      final combined = [
        ...MalaysianStates.inRegion(RegistrationRegion.west),
        ...MalaysianStates.inRegion(RegistrationRegion.east),
      ]..sort();
      expect(combined, [...MalaysianStates.all]..sort());
    });
  });

  group('MalaysianStates.regionOf', () {
    test('classifies Borneo as east, everything else west', () {
      expect(MalaysianStates.regionOf('Sarawak'), RegistrationRegion.east);
      expect(MalaysianStates.regionOf('WP Labuan'), RegistrationRegion.east);
      expect(MalaysianStates.regionOf('Johor'), RegistrationRegion.west);
    });
  });

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
