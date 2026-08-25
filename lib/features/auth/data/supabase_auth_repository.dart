import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result.dart';
import '../../../core/supabase/error_mapper.dart';
import '../../profile/domain/profile.dart';
import '../domain/auth_repository.dart';

/// Real phone-OTP auth via Supabase. Supabase persists its own session, so a
/// returning user is not asked to log in again (V1_SPEC §5.2).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client) {
    _refreshEnriched();
    _client.auth.onAuthStateChange.listen((_) => _refreshEnriched());
  }

  final SupabaseClient _client;

  /// `display_name`/`avatar_url` from the `profiles` table, layered over the
  /// masked-phone default. `auth.users` alone has no display name, so without
  /// this an edited profile would never show up on the read side.
  Profile? _enriched;

  Profile? _toProfile(User? user) {
    if (user == null) return null;
    final phone = user.phone ?? '';
    final e164 = phone.startsWith('+') ? phone : '+$phone';
    final createdAt =
        DateTime.tryParse(user.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final enriched = _enriched != null && _enriched!.id == user.id
        ? _enriched
        : null;
    return Profile(
      id: user.id,
      phone: e164,
      displayName: enriched?.displayName ?? _mask(phone),
      avatarUrl: enriched?.avatarUrl,
      createdAt: createdAt,
    );
  }

  String _mask(String phone) =>
      phone.length <= 4 ? phone : 'User ••${phone.substring(phone.length - 4)}';

  Future<void> _refreshEnriched() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _enriched = null;
      return;
    }
    try {
      final row = await _client
          .from('profiles')
          .select('id, display_name, avatar_url, phone, created_at')
          .eq('id', user.id)
          .single();
      _enriched = Profile(
        id: row['id'] as String,
        phone: row['phone'] as String? ?? '',
        displayName: row['display_name'] as String?,
        avatarUrl: row['avatar_url'] as String?,
        createdAt:
            DateTime.tryParse(row['created_at'] as String? ?? '')?.toUtc() ??
            DateTime.now().toUtc(),
      );
    } catch (_) {
      // Row not there yet (e.g. trigger hasn't run) — fall back to masked phone.
      _enriched = null;
    }
  }

  @override
  Profile? get currentUser => _toProfile(_client.auth.currentUser);

  @override
  Stream<Profile?> authState() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.asyncMap((s) async {
      await _refreshEnriched();
      return _toProfile(s.session?.user);
    });
  }

  @override
  Future<Result<void>> sendOtp(String phoneE164) async {
    try {
      await _client.auth.signInWithOtp(phone: phoneE164);
      return const Ok(null);
    } catch (e) {
      return Err(mapError(e));
    }
  }

  @override
  Future<Result<Profile>> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    try {
      final res = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phoneE164,
        token: code,
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
  Future<Result<Profile>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Err('You need to be signed in to update your profile.');
    }
    try {
      final updates = <String, Object?>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
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
  Future<void> signOut() => _client.auth.signOut();
}
