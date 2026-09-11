import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/user/report.dart';

void main() {
  group('Report', () {
    test('round-trips through snake_case JSON', () {
      final json = {
        'id': 'r1',
        'reporter_id': 'u1',
        'reported_id': 'u2',
        'reporter_name': 'Aiman Rahman',
        'reported_name': 'Siti Nur',
        'reported_banned': true,
        'title': 'Fake listing',
        'description': 'Car in the photos is not the car being sold.',
        'status': 'open',
        'created_at': '2026-08-30T02:00:00Z',
      };
      final r = Report.fromJson(json);
      expect(r.reporter, 'Aiman Rahman');
      expect(r.reported, 'Siti Nur');
      expect(r.reportedBanned, isTrue);
      expect(r.isOpen, isTrue);
      expect(Report.fromJson(r.toJson()), r);
    });

    test('defaults and fallbacks', () {
      final r = Report.fromJson({
        'id': 'r2',
        'reporter_id': 'u1',
        'reported_id': 'u2',
        'title': 't',
        'description': 'd',
        'created_at': '2026-08-30T02:00:00Z',
      });
      expect(r.status, 'open');
      expect(r.isOpen, isTrue);
      expect(r.reportedBanned, isFalse);
      expect(r.reporter, 'User');
      expect(r.reported, 'User');
      expect(r.copyWith(status: 'resolved').isOpen, isFalse);
      expect(r.copyWith(reporterName: '  ').reporter, 'User');
    });
  });
}
