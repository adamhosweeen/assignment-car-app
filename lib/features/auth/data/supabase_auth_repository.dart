import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result.dart';
import '../../../core/supabase/error_mapper.dart';
import '../../profile/domain/profile.dart';
import '../domain/auth_repository.dart';

/// Real phone-OTP auth via Supabase. Supabase persists its own session, so a
/// returning user is not asked to log in again (V1_SPEC §5.2).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  Profile? _toProfile(User? user) {
    if (user == null) return null;
    final phone = user.phone ?? '';
    final e164 = phone.startsWith('+') ? phone : '+$phone';
    return Profile(
      id: user.id,
      phone: e164,
      displayName: _mask(phone),
      createdAt: DateTime.tryParse(user.createdAt)?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }

  String _mask(String phone) =>
      phone.length <= 4 ? phone : 'User ••${phone.substring(phone.length - 4)}';

  @override
  Profile? get currentUser => _toProfile(_client.auth.currentUser);

  @override
  Stream<Profile?> authState() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map((s) => _toProfile(s.session?.user));
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
  Future<void> signOut() => _client.auth.signOut();
}
