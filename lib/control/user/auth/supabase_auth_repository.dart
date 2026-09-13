import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/control/user/auth/user_cache_repository.dart';
import 'package:assignment/control/user/inbox/inbox_cache_repository.dart';
import 'package:assignment/control/user/other_users_cache_repository.dart';
import 'package:assignment/control/bid/bids_cache_repository.dart';
import 'package:assignment/control/chat/chat_cache_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/control/user/auth/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(
    this._client,
    this._cache,
    this._otherUsers,
    this._inboxCache,
    this._chatCache,
    this._bidsCache,
    this._drafts,
  ) {
    _refreshEnriched();
    _client.auth.onAuthStateChange.listen((_) => _refreshEnriched());
  }

  final SupabaseClient _client;
  final UserCacheRepository _cache;
  final OtherUsersCacheRepository _otherUsers;
  final InboxCacheRepository _inboxCache;
  final ChatCacheRepository _chatCache;
  final BidsCacheRepository _bidsCache;
  final DraftRepository _drafts;

  static const String _profileColumns = '*';

  static const String _avatarBucket = 'avatars';

  static const Duration _timeout = Duration(seconds: 8);

  AppUser? _enriched;

  int _generation = 0;

  final StreamController<AppUser?> _profileChanges =
      StreamController<AppUser?>.broadcast();

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final enriched = _enriched != null && _enriched!.id == user.id
        ? _enriched
        : null;
    if (enriched != null) return enriched;
    final cached = _cache.cached;
    if (cached != null && cached.id == user.id) return cached;
    final meta = user.userMetadata ?? const <String, dynamic>{};
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      firstName: meta['first_name'] as String?,
      lastName: meta['last_name'] as String?,
      dob: DateTime.tryParse(meta['dob'] as String? ?? ''),
      phone: meta['phone'] as String?,
      state: meta['state'] as String?,
      interests: _decodeInterests(meta['interests']),
      createdAt:
          DateTime.tryParse(user.createdAt)?.toUtc() ?? DateTime.now().toUtc(),
    );
  }

  static CarInterests _decodeInterests(Object? value) {
    if (value is Map<String, dynamic>) {
      try {
        return CarInterests.fromJson(value);
      } catch (_) {
        return const CarInterests();
      }
    }
    return const CarInterests();
  }

  Future<void> _refreshEnriched({bool newSession = false}) async {
    final generation = ++_generation;
    final user = _client.auth.currentUser;
    if (user == null) {
      _enriched = null;
      _emit();
      return;
    }
    try {
      final row = await _client
          .from('users')
          .select(_profileColumns)
          .eq('id', user.id)
          .single()
          .timeout(_timeout);
      if (generation != _generation) return;
      await _adopt(
        AppUser.fromJson(row),
        newSession ? _cache.insert : _cache.update,
      );
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

  @override
  AppUser? get currentUser => _toAppUser(_client.auth.currentUser);

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
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _refreshEnriched(newSession: true);
      final profile = _toAppUser(res.user);
      if (profile == null) {
        return const Err('Sign-in failed. Please try again.');
      }
      return Ok(profile);
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
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'dob': dob.toIso8601String().substring(0, 10),
          'phone': phoneE164,
          'state': state,
          'interests': interests.toJson(),
        },
      );
      if (res.session == null) {
        return const Err(
          'Your account was created but needs email confirmation. '
          'Check your inbox, then log in.',
        );
      }
      await _refreshEnriched(newSession: true);
      final profile = _toAppUser(res.user);
      if (profile == null) {
        return const Err('Sign-up failed. Please try again.');
      }
      return Ok(profile);
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
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to update your profile.');
    }
    try {
      final updates = <String, Object?>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (phone != null) updates['phone'] = phone;
      if (state != null) updates['state'] = state;
      if (interests != null) updates['interests'] = interests.toJson();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      final row = updates.isEmpty
          ? await _client
                .from('users')
                .select(_profileColumns)
                .eq('id', user.id)
                .single()
                .timeout(_timeout)
          : await _client
                .from('users')
                .update(updates)
                .eq('id', user.id)
                .select(_profileColumns)
                .single()
                .timeout(_timeout);
      final updated = AppUser.fromJson(row);
      await _adopt(updated, _cache.update);
      return Ok(updated);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> updateAvatar(String localPath) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to change your photo.');
    }
    final file = File(localPath);
    if (!file.existsSync()) {
      return const Err('That photo could not be read. Please pick it again.');
    }
    try {
      final previousUrl = _toAppUser(user)?.avatarUrl;
      final objectPath = '${user.id}/${newId()}.jpg';
      await _client.storage
          .from(_avatarBucket)
          .upload(
            objectPath,
            file,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      final url = _client.storage.from(_avatarBucket).getPublicUrl(objectPath);
      final res = await updateProfile(avatarUrl: url);
      if (res.isOk) await _removeAvatarObject(previousUrl);
      return res;
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> removeAvatar() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to change your photo.');
    }
    try {
      final previousUrl = _toAppUser(user)?.avatarUrl;
      final row = await _client
          .from('users')
          .update({'avatar_url': null})
          .eq('id', user.id)
          .select(_profileColumns)
          .single()
          .timeout(_timeout);
      final updated = AppUser.fromJson(row);
      await _adopt(updated, _cache.update);
      await _removeAvatarObject(previousUrl);
      return Ok(updated);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  Future<void> _removeAvatarObject(String? publicUrl) async {
    final path = avatarObjectPath(publicUrl);
    if (path == null) return;
    try {
      await _client.storage.from(_avatarBucket).remove([path]);
    } catch (_) {}
  }

  @override
  Future<Result<void>> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to delete your account.');
    }
    try {
      await _removeAvatarObject(_toAppUser(user)?.avatarUrl);
      try {
        final listingRows = await _client
            .from('listings')
            .select('id')
            .eq('seller_id', user.id);
        final ids = [for (final r in listingRows) r['id'] as String];
        if (ids.isNotEmpty) {
          final mediaRows = await _client
              .from('listing_media')
              .select('storage_path')
              .inFilter('listing_id', ids);
          final paths = [
            for (final r in mediaRows) r['storage_path'] as String,
          ];
          if (paths.isNotEmpty) {
            await _client.storage.from('listing-media').remove(paths);
          }
        }
      } catch (_) {}

      await _client.rpc<void>('delete_account');

      _generation++;
      await _cache.delete(user.id);
      await _otherUsers.clear();
      await _inboxCache.clear();
      await _chatCache.clear();
      await _bidsCache.clearForUser();
      await _drafts.clear();
      try {
        await _client.auth.signOut();
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
    await _otherUsers.clear();
    await _inboxCache.clear();
    await _chatCache.clear();
    await _bidsCache.clearForUser();
    await _drafts.clear();
    await _client.auth.signOut();
  }
}

String? avatarObjectPath(String? publicUrl) {
  if (publicUrl == null) return null;
  const marker = '/object/public/avatars/';
  final i = publicUrl.indexOf(marker);
  if (i < 0) return null;
  var rest = publicUrl.substring(i + marker.length);
  final q = rest.indexOf('?');
  if (q >= 0) rest = rest.substring(0, q);
  return rest.isEmpty ? null : Uri.decodeComponent(rest);
}
