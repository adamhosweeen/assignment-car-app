import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/user/other_users_cache.dart';
import 'package:assignment/control/user/users_remote.dart';
import 'package:assignment/control/user/users_repository_impl.dart';
import 'package:assignment/model/user/app_user.dart';

final _seller = AppUser(
  id: 's1',
  email: 'siti@example.com',
  firstName: 'Siti',
  lastName: 'Nur',
  displayName: 'Siti Nur',
  createdAt: DateTime.utc(2026, 2, 2),
);

class _FakeRemote implements UsersRemote {
  _FakeRemote({this.user, this.offline = false});

  final AppUser? user;
  final bool offline;
  final queries = <String>[];

  @override
  Future<AppUser?> fetchById(String id) async {
    if (offline) throw const SocketException('offline');
    return user;
  }

  @override
  Future<List<AppUser>> searchByName(String query, {required int limit}) async {
    queries.add(query);
    if (offline) throw const SocketException('offline');
    return [?user];
  }
}

class _FakeCache implements OtherUsersCache {
  final stored = <String, AppUser>{};
  final saved = <String>[];

  @override
  Future<AppUser?> getById(String id) async => stored[id];

  @override
  Future<void> save(AppUser user) async {
    saved.add(user.id);
    stored[user.id] = user;
  }

  @override
  Future<void> clear() async => stored.clear();
}

void main() {
  group('getById', () {
    test('online: returns the seller and keeps a copy', () async {
      final cache = _FakeCache();
      final res = await UsersRepositoryImpl(
        _FakeRemote(user: _seller),
        cache,
      ).getById('s1');

      expect(res.valueOrNull, _seller);
      expect(cache.saved, ['s1']);
    });

    test('offline: the saved copy still opens the page', () async {
      final cache = _FakeCache()..stored['s1'] = _seller;
      final res = await UsersRepositoryImpl(
        _FakeRemote(offline: true),
        cache,
      ).getById('s1');

      expect(res.valueOrNull, _seller);
      expect(cache.saved, isEmpty);
    });

    test('offline and never opened before: an error', () async {
      final res = await UsersRepositoryImpl(
        _FakeRemote(offline: true),
        _FakeCache(),
      ).getById('s1');

      expect(res.isOk, isFalse);
    });

    test('not found or banned: null, and nothing is cached', () async {
      final cache = _FakeCache();
      final res = await UsersRepositoryImpl(_FakeRemote(), cache).getById('s1');

      expect(res.isOk, isTrue);
      expect(res.valueOrNull, isNull);
      expect(cache.saved, isEmpty);
    });
  });

  group('search', () {
    test('a blank or symbol-only query sends no request', () async {
      final remote = _FakeRemote(user: _seller);
      final repo = UsersRepositoryImpl(remote, _FakeCache());

      expect((await repo.search('   ')).valueOrNull, isEmpty);
      expect((await repo.search('%,()')).valueOrNull, isEmpty);
      expect(remote.queries, isEmpty);
    });

    test('the query is cleaned before it reaches Supabase', () async {
      final remote = _FakeRemote(user: _seller);
      await UsersRepositoryImpl(remote, _FakeCache()).search('  siti%  ');

      expect(remote.queries, ['siti']);
    });

    test('results are never written to the cache', () async {
      final cache = _FakeCache();
      await UsersRepositoryImpl(
        _FakeRemote(user: _seller),
        cache,
      ).search('siti');

      expect(cache.saved, isEmpty);
    });
  });
}
