import 'dart:async';
import 'dart:io';

import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/control/user/auth/auth_remote.dart';
import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/user/auth/user_cache.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/utils/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remote,
    this._cache, {
    required this._clearLocalData,
  }) {
    _refreshEnriched();
    _remote.changes.listen((_) => _refreshEnriched());
  }

  final AuthRemote _remote;
  final UserCache _cache;
  final Future<void> Function() _clearLocalData;

  AppUser? _enriched;

  int _generation = 0;

  final StreamController<AppUser?> _profileChanges =
      StreamController<AppUser?>.broadcast();

  AppUser? _resolve(AppUser? session) {
    if (session == null) return null;
    final enriched = _enriched;
    if (enriched != null && enriched.id == session.id) return enriched;
    final cached = _cache.cached;
    if (cached != null && cached.id == session.id) return cached;
    return session;
  }

  Future<void> _refreshEnriched({bool newSession = false}) async {
    final generation = ++_generation;
    final session = _remote.sessionUser;
    if (session == null) {
      _enriched = null;
      _emit();
      return;
    }
    try {
      final user = await _remote.fetchUser(session.id);
      if (generation != _generation) return;
      await _adopt(user, newSession ? _cache.insert : _cache.update);
    } catch (_) {
      if (generation == _generation) _emit();
    }
  }

  Future<void> _adopt(
    AppUser user,
    Future<void> Function(AppUser) writeCache,
  ) async {
    _generation++;
    _enriched = user;
    try {
      await writeCache(user);
    } catch (_) {}
    _emit();
  }

  void _emit() {
    if (!_profileChanges.isClosed) _profileChanges.add(currentUser);
  }

  Future<void> _removeAvatarQuietly(String? publicUrl) async {
    try {
      await _remote.removeAvatarFile(publicUrl);
    } catch (_) {}
  }

  @override
  AppUser? get currentUser => _resolve(_remote.sessionUser);

  @override
  Stream<AppUser?> authState() async* {
    yield currentUser;
    yield* _profileChanges.stream;
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _remote.signIn(email: email, password: password);
      await _refreshEnriched(newSession: true);
      final user = currentUser;
      if (user == null) {
        return const Err('Sign-in failed. Please try again.');
      }
      return Ok(user);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String phoneE164,
    required String state,
    required CarInterests interests,
  }) async {
    try {
      final hasSession = await _remote.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        dob: dob,
        phoneE164: phoneE164,
        state: state,
        interests: interests,
      );
      if (!hasSession) {
        return const Err(
          'Your account was created but needs email confirmation. '
          'Check your inbox, then log in.',
        );
      }
      await _refreshEnriched(newSession: true);
      final user = currentUser;
      if (user == null) {
        return const Err('Sign-up failed. Please try again.');
      }
      return Ok(user);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async {
    final session = _remote.sessionUser;
    if (session == null) {
      return const Err('You need to be signed in to update your profile.');
    }
    try {
      final updated = await _remote.updateProfile(
        session.id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        state: state,
        interests: interests,
        avatarUrl: avatarUrl,
      );
      await _adopt(updated, _cache.update);
      return Ok(updated);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> updateAvatar(String localPath) async {
    final session = _remote.sessionUser;
    if (session == null) {
      return const Err('You need to be signed in to change your photo.');
    }
    final file = File(localPath);
    if (!file.existsSync()) {
      return const Err('That photo could not be read. Please pick it again.');
    }
    try {
      final previousUrl = currentUser?.avatarUrl;
      final url = await _remote.uploadAvatar(session.id, file);
      final res = await updateProfile(avatarUrl: url);
      if (res.isOk) await _removeAvatarQuietly(previousUrl);
      return res;
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> removeAvatar() async {
    final session = _remote.sessionUser;
    if (session == null) {
      return const Err('You need to be signed in to change your photo.');
    }
    try {
      final previousUrl = currentUser?.avatarUrl;
      final updated = await _remote.clearAvatarUrl(session.id);
      await _adopt(updated, _cache.update);
      await _removeAvatarQuietly(previousUrl);
      return Ok(updated);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    final session = _remote.sessionUser;
    if (session == null) {
      return const Err('You need to be signed in to delete your account.');
    }
    try {
      await _removeAvatarQuietly(currentUser?.avatarUrl);
      try {
        await _remote.removeListingPhotos(session.id);
      } catch (_) {}

      await _remote.deleteAccount();

      _generation++;
      await _cache.delete(session.id);
      await _clearLocalData();
      try {
        await _remote.signOut();
      } catch (_) {}
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<void> signOut() async {
    _generation++;
    await _cache.clear();
    await _clearLocalData();
    await _remote.signOut();
  }
}
