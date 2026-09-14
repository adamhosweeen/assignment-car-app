import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/user/inbox/inbox_cache.dart';
import 'package:assignment/control/user/inbox/inbox_remote.dart';
import 'package:assignment/control/user/inbox/inbox_repository_impl.dart';
import 'package:assignment/model/user/inbox_message.dart';
import 'package:assignment/utils/result.dart';

const _offline = 'No internet connection. Check your network and try again.';

InboxMessage _message(String id) => InboxMessage(
  id: id,
  userId: 'u1',
  kind: InboxKind.welcome,
  title: 'Title $id',
  body: 'Body $id',
  createdAt: DateTime.utc(2026, 9, 1),
);

class _FakeRemote implements InboxRemote {
  _FakeRemote({this.currentUserId = 'u1', this.offline = false});

  @override
  final String? currentUserId;
  final bool offline;
  List<InboxMessage> server = [_message('a'), _message('b')];
  int listCalls = 0;

  void _check() {
    if (offline) throw const SocketException('offline');
  }

  @override
  Future<List<InboxMessage>> list(String userId) async {
    listCalls++;
    _check();
    return List.of(server);
  }

  @override
  Future<void> markRead(String id, DateTime readAt) async => _check();

  @override
  Future<void> delete(String id) async {
    _check();
    server = server.where((m) => m.id != id).toList();
  }
}

class _FakeCache implements InboxCache {
  List<InboxMessage> rows = [];
  final log = <String>[];

  @override
  Future<List<InboxMessage>> getForUser(String userId) async => List.of(rows);

  @override
  Future<void> replaceForUser(
    String userId,
    List<InboxMessage> messages,
  ) async {
    log.add('replace');
    rows = List.of(messages);
  }

  @override
  Future<void> markRead(String id, DateTime readAt) async =>
      log.add('markRead $id');

  @override
  Future<void> delete(String id) async {
    log.add('delete $id');
    rows = rows.where((m) => m.id != id).toList();
  }

  @override
  Future<void> clear() async => log.add('clear');
}

Matcher _errWith(String message) =>
    isA<Err<Object?>>().having((e) => e.message, 'message', message);

void main() {
  group('list', () {
    test('online: returns Supabase rows and replaces the cache', () async {
      final cache = _FakeCache()..rows = [_message('old')];
      final res = await InboxRepositoryImpl(_FakeRemote(), cache).list();

      expect(res.valueOrNull!.map((m) => m.id), ['a', 'b']);
      expect(cache.rows.map((m) => m.id), ['a', 'b']);
    });

    test('offline: serves the cached messages and writes nothing', () async {
      final cache = _FakeCache()..rows = [_message('cached')];
      final res = await InboxRepositoryImpl(
        _FakeRemote(offline: true),
        cache,
      ).list();

      expect(res.valueOrNull!.single.id, 'cached');
      expect(cache.log, isEmpty);
    });

    test('offline with nothing cached: a plain-English error', () async {
      final res = await InboxRepositoryImpl(
        _FakeRemote(offline: true),
        _FakeCache(),
      ).list();

      expect(res, _errWith(_offline));
    });

    test('signed out: no request, empty list', () async {
      final remote = _FakeRemote(currentUserId: null);
      final res = await InboxRepositoryImpl(remote, _FakeCache()).list();

      expect(res.valueOrNull, isEmpty);
      expect(remote.listCalls, 0);
    });
  });

  group('the cache only changes after Supabase succeeds', () {
    test('delete: Supabase first, then the cache', () async {
      final remote = _FakeRemote();
      final cache = _FakeCache()..rows = [_message('a')];
      final res = await InboxRepositoryImpl(remote, cache).delete('a');

      expect(res.isOk, isTrue);
      expect(remote.server.map((m) => m.id), ['b']);
      expect(cache.log, ['delete a']);
    });

    test('a failed delete leaves the cache untouched', () async {
      final cache = _FakeCache()..rows = [_message('a')];
      final res = await InboxRepositoryImpl(
        _FakeRemote(offline: true),
        cache,
      ).delete('a');

      expect(res, _errWith(_offline));
      expect(cache.log, isEmpty);
      expect(cache.rows.single.id, 'a');
    });

    test('a failed mark-as-read leaves the cache untouched', () async {
      final cache = _FakeCache();
      final res = await InboxRepositoryImpl(
        _FakeRemote(offline: true),
        cache,
      ).markRead('a');

      expect(res.isOk, isFalse);
      expect(cache.log, isEmpty);
    });
  });
}
