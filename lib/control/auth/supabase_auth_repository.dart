import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/control/auth/profile_cache_repository.dart';
import 'package:assignment/control/chat/chat_cache_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/model/auth/registration_data.dart';
import 'package:assignment/control/auth/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, this._cache, this._chatCache) {
    _refreshEnriched();
    _client.auth.onAuthStateChange.listen((_) => _refreshEnriched());
  }

  final SupabaseClient _client;
  final ProfileCacheRepository _cache;
  final ChatCacheRepository _chatCache;

  static const String _profileColumns = '*';

  static const String _avatarBucket = 'avatars';

  Profile? _enriched;

  final StreamController<Profile?> _profileChanges =
      StreamController<Profile?>.broadcast();

  Profile? _toProfile(User? user) {
    if (user == null) return null;
    final enriched = _enriched != null && _enriched!.id == user.id
        ? _enriched
        : null;
    if (enriched != null) return enriched;
    final cached = _cache.cached;
    if (cached != null && cached.id == user.id) return cached;
    final meta = user.userMetadata ?? const <String, dynamic>{};
    return Profile(
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

  static Profile _rowToProfile(Map<String, dynamic> row) => Profile(
    id: row['id'] as String,
    email: row['email'] as String? ?? '',
    firstName: row['first_name'] as String?,
    lastName: row['last_name'] as String?,
    dob: DateTime.tryParse(row['dob'] as String? ?? ''),
    phone: row['phone'] as String?,
    state: row['state'] as String?,
    interests: _decodeInterests(row['interests']),
    avatarUrl: row['avatar_url'] as String?,
    role: row['role'] as String? ?? 'user',
    createdAt:
        DateTime.tryParse(row['created_at'] as String? ?? '')?.toUtc() ??
        DateTime.now().toUtc(),
  );

  Future<void> _refreshEnriched() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _enriched = null;
    } else {
      try {
        final row = await _client
            .from('profiles')
            .select(_profileColumns)
            .eq('id', user.id)
            .single();
        _enriched = _rowToProfile(row);
        await _cache.save(_enriched!);
      } catch (_) {
        _enriched = null;
      }
    }
    if (!_profileChanges.isClosed) _profileChanges.add(currentUser);
  }

  @override
  Profile? get currentUser => _toProfile(_client.auth.currentUser);

  @override
  Stream<Profile?> authState() async* {
    yield currentUser;
    yield* _profileChanges.stream;
  }

  @override
  Future<Result<Profile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _refreshEnriched();
      final profile = _toProfile(res.user);
      if (profile == null) {
        return const Err('Sign-in failed. Please try again.');
      }
      return Ok(profile);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Profile>> signUp({
    required String email,
    required String password,
    required RegistrationData data,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': data.firstName,
          'last_name': data.lastName,
          'dob': data.dob.toIso8601String().substring(0, 10),
          'phone': data.phoneE164,
          'state': data.state,
          'interests': data.interests.toJson(),
        },
      );
      if (res.session == null) {
        return const Err(
          'Your account was created but needs email confirmation. '
          'Check your inbox, then log in.',
        );
      }
      await _refreshEnriched();
      final profile = _toProfile(res.user);
      if (profile == null) {
        return const Err('Sign-up failed. Please try again.');
      }
      return Ok(profile);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Profile>> updateProfile({
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
      final current = _toProfile(user);
      final updates = <String, Object?>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (phone != null) updates['phone'] = phone;
      if (state != null) updates['state'] = state;
      if (interests != null) updates['interests'] = interests.toJson();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (firstName != null || lastName != null) {
        updates['display_name'] = [
          firstName ?? current?.firstName,
          lastName ?? current?.lastName,
        ].whereType<String>().join(' ').trim();
      }
      await _client.from('profiles').update(updates).eq('id', user.id);
      await _refreshEnriched();
      final profile = _toProfile(user);
      if (profile == null) {
        return const Err('Could not save your profile. Please try again.');
      }
      return Ok(profile);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Profile>> updateAvatar(String localPath) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to change your photo.');
    }
    final file = File(localPath);
    if (!file.existsSync()) {
      return const Err('That photo could not be read. Please pick it again.');
    }
    try {
      final previousUrl = _toProfile(user)?.avatarUrl;
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
  Future<Result<Profile>> removeAvatar() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to change your photo.');
    }
    try {
      final previousUrl = _toProfile(user)?.avatarUrl;
      await _client
          .from('profiles')
          .update({'avatar_url': null})
          .eq('id', user.id);
      await _removeAvatarObject(previousUrl);
      await _refreshEnriched();
      final profile = _toProfile(user);
      if (profile == null) {
        return const Err('Could not update your photo. Please try again.');
      }
      return Ok(profile);
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
      await _removeAvatarObject(_toProfile(user)?.avatarUrl);
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

      await _cache.clear();
      await _chatCache.clear();
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
    await _cache.clear();
    await _chatCache.clear();
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
