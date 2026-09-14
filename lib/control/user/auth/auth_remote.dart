import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/utils/ids.dart';

class AuthRemote {
  AuthRemote(this._client);

  final SupabaseClient _client;

  static const String _table = 'users';
  static const String _columns = '*';
  static const String _avatarBucket = 'avatars';
  static const String _listingBucket = 'listing-media';
  static const Duration _timeout = Duration(seconds: 8);

  Stream<void> get changes => _client.auth.onAuthStateChange.map<void>((_) {});

  AppUser? get sessionUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
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

  Future<AppUser> fetchUser(String id) async {
    final row = await _client
        .from(_table)
        .select(_columns)
        .eq('id', id)
        .single()
        .timeout(_timeout);
    return AppUser.fromJson(row);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String phoneE164,
    required String state,
    required CarInterests interests,
  }) async {
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
    return res.session != null;
  }

  Future<AppUser> updateProfile(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async {
    final updates = <String, Object?>{};
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (phone != null) updates['phone'] = phone;
    if (state != null) updates['state'] = state;
    if (interests != null) updates['interests'] = interests.toJson();
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (updates.isEmpty) return fetchUser(id);
    final row = await _client
        .from(_table)
        .update(updates)
        .eq('id', id)
        .select(_columns)
        .single()
        .timeout(_timeout);
    return AppUser.fromJson(row);
  }

  Future<AppUser> clearAvatarUrl(String id) async {
    final row = await _client
        .from(_table)
        .update({'avatar_url': null})
        .eq('id', id)
        .select(_columns)
        .single()
        .timeout(_timeout);
    return AppUser.fromJson(row);
  }

  Future<String> uploadAvatar(String userId, File file) async {
    final objectPath = '$userId/${newId()}.jpg';
    await _client.storage
        .from(_avatarBucket)
        .upload(
          objectPath,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _client.storage.from(_avatarBucket).getPublicUrl(objectPath);
  }

  Future<void> removeAvatarFile(String? publicUrl) async {
    final path = avatarObjectPath(publicUrl);
    if (path == null) return;
    await _client.storage.from(_avatarBucket).remove([path]);
  }

  Future<void> removeListingPhotos(String userId) async {
    final listingRows = await _client
        .from('listings')
        .select('id')
        .eq('seller_id', userId);
    final ids = [for (final r in listingRows) r['id'] as String];
    if (ids.isEmpty) return;
    final mediaRows = await _client
        .from('listing_media')
        .select('storage_path')
        .inFilter('listing_id', ids);
    final paths = [for (final r in mediaRows) r['storage_path'] as String];
    if (paths.isNotEmpty) {
      await _client.storage.from(_listingBucket).remove(paths);
    }
  }

  Future<void> deleteAccount() => _client.rpc<void>('delete_account');

  Future<void> signOut() => _client.auth.signOut();
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
