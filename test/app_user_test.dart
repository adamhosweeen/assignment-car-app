import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/user/admin/admin_providers.dart';
import 'package:assignment/model/user/app_user.dart';

AppUser _user(
  String id, {
  String? firstName,
  String? lastName,
  String email = '',
  String? phone,
  String? state,
  DateTime? created,
  int active = 0,
  int sold = 0,
}) => AppUser(
  id: id,
  email: email,
  firstName: firstName,
  lastName: lastName,
  phone: phone,
  state: state,
  createdAt: created ?? DateTime.utc(2026, 1, 1),
  activeCount: active,
  soldCount: sold,
);

void main() {
  group('AppUser', () {
    test('decodes the admin_user_stats row, counts and all', () {
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
      final u = AppUser.fromJson(json);
      expect(u.name, 'Aiman Rahman');
      expect(u.isAdmin, isTrue);
      expect(u.banned, isTrue);
      expect(u.dob, DateTime(1999, 4, 12));
      expect(u.phone, '+60123456789');
      expect(u.activeCount, 3);
      expect(u.soldCount, 5);
      expect(AppUser.fromJson(u.toJson()), u);
    });

    test('a row with no names, a null email and no flags still decodes', () {
      final u = AppUser.fromJson({
        'id': 'u2',
        'email': null,
        'created_at': '2026-03-01T08:00:00Z',
        'active_count': 0,
        'sold_count': 0,
      });
      expect(u.email, '');
      expect(u.role, UserRole.customer);
      expect(u.isAdmin, isFalse);
      expect(u.banned, isFalse);
      expect(u.name, 'User');
    });

    test('name falls back to the email prefix, then to User', () {
      expect(_user('a', email: 'siti@mail.my').name, 'siti');
      expect(_user('b', firstName: '  ').name, 'User');
    });

    test('name prefers the stored display_name over first/last', () {
      final base = {'id': 'u1', 'created_at': '2026-03-01T00:00:00.000Z'};
      expect(
        AppUser.fromJson({
          ...base,
          'display_name': 'Ken',
          'first_name': 'Kenneth',
        }).name,
        'Ken',
      );
      expect(AppUser.fromJson({...base, 'display_name': '   '}).name, 'User');
      expect(
        AppUser.fromJson({...base, 'first_name': 'Aisyah'}).name,
        'Aisyah',
      );
    });

    test('counts are null on an ordinary users row', () {
      final u = AppUser.fromJson({
        'id': 'u3',
        'email': 'a@b.my',
        'created_at': '2026-03-01T00:00:00.000Z',
      });
      expect(u.activeCount, isNull);
      expect(u.soldCount, isNull);
    });
  });

  group('filterUsers', () {
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
      expect(filterUsers(all, ''), all);
      expect(filterUsers(all, '   '), all);
    });

    test('matches name, email, phone, and state, case-insensitively', () {
      expect(filterUsers(all, 'RAHMAN'), [aiman]);
      expect(filterUsers(all, 'mail.my'), [siti]);
      expect(filterUsers(all, '0123456'), [aiman]);
      expect(filterUsers(all, 'johor'), [siti]);
    });

    test('no match is empty; null fields never match', () {
      expect(filterUsers(all, 'perodua'), isEmpty);
      expect(filterUsers([_user('c')], 'x'), isEmpty);
    });
  });

  group('sortUsers', () {
    final a = _user('a', created: DateTime.utc(2026, 1, 1), active: 1, sold: 9);
    final b = _user('b', created: DateTime.utc(2026, 2, 1), active: 5, sold: 2);
    final c = _user('c', created: DateTime.utc(2026, 3, 1), active: 5, sold: 0);
    final input = [a, b, c];

    test('newest orders by joined date descending', () {
      expect(sortUsers(input, AdminSort.newest), [c, b, a]);
    });

    test('listed orders by active count, newest breaks ties', () {
      expect(sortUsers(input, AdminSort.listed), [c, b, a]);
      expect(sortUsers([a, c, b], AdminSort.listed).map((u) => u.id).toList(), [
        'c',
        'b',
        'a',
      ]);
    });

    test('sold orders by sold count descending', () {
      expect(sortUsers(input, AdminSort.sold), [a, b, c]);
    });

    test('does not mutate the input list', () {
      final copy = [...input];
      sortUsers(input, AdminSort.sold);
      expect(input, copy);
    });
  });
}
