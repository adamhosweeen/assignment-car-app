import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/user/auth/auth_remote.dart';
import 'package:assignment/control/user/auth/auth_repository_impl.dart';
import 'package:assignment/control/user/auth/user_cache.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/utils/result.dart';

AppUser _user(String first) => AppUser(
  id: 'u1',
  email: 'aiman@example.com',
  firstName: first,
  lastName: 'Rahman',
  displayName: '$first Rahman',
  createdAt: DateTime.utc(2026, 1, 1),
);

class _FakeRemote implements AuthRemote {
  _FakeRemote(this.log, {this.sessionUser});

  final List<String> log;
  final _changes = StreamController<void>.broadcast();

  @override
  AppUser? sessionUser;
  AppUser server = _user('Aiman');
  bool offline = false;
  bool refuseDelete = false;
  Completer<AppUser>? slowFetch;

  void _check() {
    if (offline) throw const SocketException('offline');
  }

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<AppUser> fetchUser(String id) {
    final slow = slowFetch;
    if (slow != null) return slow.future;
    _check();
    return Future.value(server);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _check();
    sessionUser = AppUser(
      id: 'u1',
      email: email,
      createdAt: DateTime.utc(2026),
    );
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String phoneE164,
    required String state,
    required CarInterests interests,
  }) async => true;

  @override
  Future<AppUser> updateProfile(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async {
    _check();
    final first = firstName ?? server.firstName!;
    server = server.copyWith(firstName: first, displayName: '$first Rahman');
    return server;
  }

  @override
  Future<AppUser> clearAvatarUrl(String id) async {
    _check();
    return server = server.copyWith(avatarUrl: null);
  }

  @override
  Future<String> uploadAvatar(String userId, File file) async => 'url';

  @override
  Future<void> removeAvatarFile(String? publicUrl) async =>
      log.add('remote.removeAvatarFile');

  @override
  Future<void> removeListingPhotos(String userId) async =>
      log.add('remote.removeListingPhotos');

  @override
  Future<void> deleteAccount() async {
    if (refuseDelete) throw const SocketException('offline');
    log.add('remote.deleteAccount');
  }

  @override
  Future<void> signOut() async {
    log.add('remote.signOut');
    sessionUser = null;
    _changes.add(null);
  }
}

class _FakeCache implements UserCache {
  _FakeCache(this.log, [this.cached]);

  final List<String> log;

  @override
  AppUser? cached;

  @override
  Future<void> insert(AppUser user) async {
    cached = user;
    log.add('cache.insert ${user.firstName}');
  }

  @override
  Future<void> update(AppUser user) async {
    cached = user;
    log.add('cache.update ${user.firstName}');
  }

  @override
  Future<void> delete(String id) async {
    cached = null;
    log.add('cache.delete $id');
  }

  @override
  Future<void> clear() async {
    cached = null;
    log.add('cache.clear');
  }
}

AuthRepositoryImpl _repo(_FakeRemote remote, _FakeCache cache) =>
    AuthRepositoryImpl(
      remote,
      cache,
      clearLocalData: () async => remote.log.add('clearLocalData'),
    );

Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late List<String> log;
  setUp(() => log = <String>[]);

  group('start-up', () {
    test('the fresh Supabase row replaces the cached one', () async {
      final remote = _FakeRemote(log, sessionUser: _user('Aiman'))
        ..server = _user('Fresh');
      final repo = _repo(remote, _FakeCache(log, _user('Old')));
      await _settle();

      expect(repo.currentUser!.firstName, 'Fresh');
      expect(log, ['cache.update Fresh']);
    });

    test('offline: the cached user is shown and nothing is written', () async {
      final remote = _FakeRemote(log, sessionUser: _user('Aiman'))
        ..offline = true;
      final repo = _repo(remote, _FakeCache(log, _user('Cached')));
      await _settle();

      expect(repo.currentUser!.firstName, 'Cached');
      expect(log, isEmpty);
    });
  });

  test('signing in creates the cached row', () async {
    final remote = _FakeRemote(log);
    final repo = _repo(remote, _FakeCache(log));
    await _settle();

    final res = await repo.signIn(email: 'aiman@example.com', password: 'x');

    expect(res.isOk, isTrue);
    expect(log, ['cache.insert Aiman']);
  });

  group('editing', () {
    test(
      'the row Supabase returned goes to the cache and the stream',
      () async {
        final remote = _FakeRemote(log, sessionUser: _user('Aiman'));
        final repo = _repo(remote, _FakeCache(log));
        await _settle();
        log.clear();
        final emitted = <AppUser?>[];
        final sub = repo.authState().listen(emitted.add);

        final res = await repo.updateProfile(firstName: 'Ali');
        await _settle();

        expect(res.valueOrNull!.name, 'Ali Rahman');
        expect(log, ['cache.update Ali']);
        expect(emitted.last!.name, 'Ali Rahman');
        await sub.cancel();
      },
    );

    test('a failed edit leaves the cache untouched', () async {
      final remote = _FakeRemote(log, sessionUser: _user('Aiman'));
      final repo = _repo(remote, _FakeCache(log));
      await _settle();
      log.clear();
      remote.offline = true;

      final res = await repo.updateProfile(firstName: 'Ali');

      expect(res.isOk, isFalse);
      expect(log, isEmpty);
      expect(repo.currentUser!.firstName, 'Aiman');
    });

    test('a slow start-up read cannot overwrite a newer edit', () async {
      final slow = Completer<AppUser>();
      final remote = _FakeRemote(log, sessionUser: _user('Aiman'))
        ..slowFetch = slow;
      final repo = _repo(remote, _FakeCache(log));
      await _settle();

      await repo.updateProfile(firstName: 'Ali');
      slow.complete(_user('Stale'));
      await _settle();

      expect(repo.currentUser!.firstName, 'Ali');
      expect(log, ['cache.update Ali']);
    });
  });

  test('signing out: cache, then other modules, then the session', () async {
    final remote = _FakeRemote(log, sessionUser: _user('Aiman'));
    final repo = _repo(remote, _FakeCache(log));
    await _settle();
    log.clear();

    await repo.signOut();
    await _settle();

    expect(log, ['cache.clear', 'clearLocalData', 'remote.signOut']);
    expect(repo.currentUser, isNull);
  });

  group('deleting the account', () {
    test('the server deletes first, then local data, then sign-out', () async {
      final remote = _FakeRemote(log, sessionUser: _user('Aiman'));
      final repo = _repo(remote, _FakeCache(log));
      await _settle();
      log.clear();

      final res = await repo.deleteAccount();

      expect(res.isOk, isTrue);
      expect(log, [
        'remote.removeAvatarFile',
        'remote.removeListingPhotos',
        'remote.deleteAccount',
        'cache.delete u1',
        'clearLocalData',
        'remote.signOut',
      ]);
    });

    test('if the server refuses, nothing local is deleted', () async {
      final remote = _FakeRemote(log, sessionUser: _user('Aiman'))
        ..refuseDelete = true;
      final cache = _FakeCache(log);
      final repo = _repo(remote, cache);
      await _settle();
      log.clear();

      final res = await repo.deleteAccount();

      expect(res, isA<Err<void>>());
      expect(log, ['remote.removeAvatarFile', 'remote.removeListingPhotos']);
      expect(cache.cached, isNotNull);
    });
  });
}
