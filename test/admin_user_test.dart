import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/admin/admin_providers.dart';
import 'package:assignment/model/admin/admin_user.dart';
import 'package:assignment/model/profile/profile.dart';

AdminUser _user(
  String id, {
  String? firstName,
  String? lastName,
  String email = '',
  String? phone,
  String? state,
  DateTime? created,
  int active = 0,
  int sold = 0,
}) => AdminUser(
  profile: Profile(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    state: state,
    createdAt: created ?? DateTime.utc(2026, 1, 1),
  ),
  activeCount: active,
  soldCount: sold,
);

void main() {
  group('AdminUser', () {
    test('decodes the admin_user_stats row through Profile', () {
      final json = {
        'id': 'u1',
        'email': 'aiman@example.com',
        'first_name': 'Aiman',
        'last_name': 'Rahman',
        'display_name': 'Aiman Rahman',
        'avatar_url': 'https://x/y.jpg',
        'phone': '+60123456789',
        'dob': '1999-04-12',
        'state': 'Selangor',
        'role': 'admin',
        'banned': true,
        'created_at': '2026-03-01T08:00:00Z',
        'active_count': 3,
        'sold_count': 5,
      };
      final u = AdminUser.fromJson(json);
      expect(u.name, 'Aiman Rahman');
      expect(u.isAdmin, isTrue);
      expect(u.banned, isTrue);
      expect(u.profile.dob, DateTime(1999, 4, 12));
      expect(u.profile.phone, '+60123456789');
      expect(u.activeCount, 3);
      expect(u.soldCount, 5);
      expect(AdminUser.fromJson(u.toJson()), u);
    });

    test('a row with no names, a null email and no flags still decodes', () {
      final u = AdminUser.fromJson({
        'id': 'u2',
        'email': null,
        'created_at': '2026-03-01T08:00:00Z',
        'active_count': 0,
        'sold_count': 0,
      });
      expect(u.profile.email, '');
      expect(u.profile.role, 'user');
      expect(u.isAdmin, isFalse);
      expect(u.banned, isFalse);
      expect(u.name, 'User');
    });

    test('name falls back to the email prefix, then to User', () {
      expect(_user('a', email: 'siti@mail.my').name, 'siti');
      expect(_user('b', firstName: '  ').name, 'User');
    });
  });

  group('filterAdminUsers', () {
    final aiman = _user(
      'a',
      firstName: 'Aiman',
      lastName: 'Rahman',
      email: 'aiman@example.com',
      phone: '+60123456789',
      state: 'Selangor',
    );
    final siti = _user(
      'b',
      firstName: 'Siti',
      lastName: 'Nur',
      email: 'siti@mail.my',
      state: 'Johor',
    );
    final all = [aiman, siti];

    test('blank query returns everyone', () {
      expect(filterAdminUsers(all, ''), all);
      expect(filterAdminUsers(all, '   '), all);
    });

    test('matches name, email, phone, and state, case-insensitively', () {
      expect(filterAdminUsers(all, 'RAHMAN'), [aiman]);
      expect(filterAdminUsers(all, 'mail.my'), [siti]);
      expect(filterAdminUsers(all, '0123456'), [aiman]);
      expect(filterAdminUsers(all, 'johor'), [siti]);
    });

    test('no match is empty; null fields never match', () {
      expect(filterAdminUsers(all, 'perodua'), isEmpty);
      expect(filterAdminUsers([_user('c')], 'x'), isEmpty);
    });
  });

  group('sortAdminUsers', () {
    final a = _user('a', created: DateTime.utc(2026, 1, 1), active: 1, sold: 9);
    final b = _user('b', created: DateTime.utc(2026, 2, 1), active: 5, sold: 2);
    final c = _user('c', created: DateTime.utc(2026, 3, 1), active: 5, sold: 0);
    final input = [a, b, c];

    test('newest orders by joined date descending', () {
      expect(sortAdminUsers(input, AdminSort.newest), [c, b, a]);
    });

    test('listed orders by active count, newest breaks ties', () {
      expect(sortAdminUsers(input, AdminSort.listed), [c, b, a]);
      expect(
        sortAdminUsers([a, c, b], AdminSort.listed).map((u) => u.id).toList(),
        ['c', 'b', 'a'],
      );
    });

    test('sold orders by sold count descending', () {
      expect(sortAdminUsers(input, AdminSort.sold), [a, b, c]);
    });

    test('does not mutate the input list', () {
      final copy = [...input];
      sortAdminUsers(input, AdminSort.sold);
      expect(input, copy);
    });
  });
}
