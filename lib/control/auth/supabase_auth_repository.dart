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

/// Real email+password auth via Supabase. Supabase persists its own session,
/// so a returning user is not asked to log in again (V1_SPEC §5.2). The last
/// fetched profile is mirrored into the sqflite [ProfileCacheRepository] so
/// identity renders fully on cold start and offline. Signing out also wipes
/// [_chatCache] — chat messages are private to the account, unlike the
/// public listings cache, so a shared device must not leave them behind for
/// the next person to sign in.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, this._cache, this._chatCache) {
    _refreshEnriched();
    _client.auth.onAuthStateChange.listen((_) => _refreshEnriched());
  }

  final SupabaseClient _client;
  final ProfileCacheRepository _cache;
  final ChatCacheRepository _chatCache;

  static const String _profileColumns =
      'id, email, first_name, last_name, dob, phone, state, interests, '
      'avatar_url, created_at';

  /// Public bucket for profile photos; `avatar_url` stores the object's
  /// public URL so it renders straight through `MediaImage` with no signing.
  static const String _avatarBucket = 'avatars';

  /// The `profiles` row, layered over what `auth.users` alone provides.
  /// Registration extras (name, DOB, state, interests) live only there, so
  /// without this an edited profile would never show up on the read side.
  Profile? _enriched;

  /// Fires whenever [_enriched] is re-fetched — after sign-in/out *and* after
  /// any profile write — so [authState] listeners (Profile tab, router)
  /// re-render without waiting for the next Supabase auth event.
  final StreamController<Profile?> _profileChanges =
      StreamController<Profile?>.broadcast();

  Profile? _toProfile(User? user) {
    if (user == null) return null;
    final enriched = _enriched != null && _enriched!.id == user.id
        ? _enriched
        : null;
    if (enriched != null) return enriched;
    // No fresh row yet (cold start, offline) — the sqflite cache has the last
    // successfully fetched profile.
    final cached = _cache.cached;
    if (cached != null && cached.id == user.id) return cached;
    // Nothing cached either — build a minimal profile from the auth user and
    // the metadata sent at sign-up.
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
        // Mirror the fresh profile into sqflite for the next cold start.
        await _cache.save(_enriched!);
      } catch (_) {
        // Fetch failed (offline, or row not there yet) — keep the cache as the
        // fallback and fall through to it / metadata on the read side.
        _enriched = null;
      }
    }
    if (!_profileChanges.isClosed) _profileChanges.add(currentUser);
  }

  @override
  Profile? get currentUser => _toProfile(_client.auth.currentUser);

  /// Current profile now, then a new value on every auth event and every
  /// profile write — both go through [_refreshEnriched] (the constructor
  /// already subscribes to Supabase's auth events for that).
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
      // The security-definer `handle_new_user` trigger inserts the profiles
      // row from this metadata — the client has no INSERT policy by design.
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
      // Unique object per upload so image caches never show a stale photo.
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
      // updateProfile treats null as "unchanged", so clear the column here.
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

  /// Best-effort delete of a previous avatar object; an orphaned file is
  /// harmless, so failures are swallowed.
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
      // 1. Best-effort: delete uploaded photos via the Storage API (SQL
      //    cannot touch storage rows; orphans are harmless if this fails).
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
      } catch (_) {
        // Continue — row cleanup below is what matters.
      }

      // 2. Server-side cascade: messages, conversations, listings (+media
      //    rows), then the auth user (+profile). SECURITY DEFINER function;
      //    it only ever deletes auth.uid()'s own data.
      await _client.rpc<void>('delete_account');

      // 3. Local cleanup. The session token now points at a deleted user, so
      //    the server may reject sign-out — clear what we can regardless.
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

/// Extract the bucket object path from an `avatars` public URL, e.g.
/// `https://x.supabase.co/storage/v1/object/public/avatars/<uid>/<id>.jpg`
/// → `<uid>/<id>.jpg`. Null for anything else (including null input).
/// Top-level so it can be unit-tested without a client.
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
