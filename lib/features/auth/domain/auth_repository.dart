import '../../../core/result.dart';
import '../../profile/domain/profile.dart';

/// The auth data contract. The fake implementation is a dev bypass; a Supabase
/// phone-OTP implementation drops in later behind the same interface.
abstract interface class AuthRepository {
  /// The currently signed-in profile, or null.
  Profile? get currentUser;

  /// Emits the current profile, then on every sign-in / sign-out.
  Stream<Profile?> authState();

  /// Request an OTP for a phone number in E.164 form (e.g. `+60123456789`).
  Future<Result<void>> sendOtp(String phoneE164);

  /// Verify the OTP and sign in, upserting a profile.
  Future<Result<Profile>> verifyOtp({
    required String phoneE164,
    required String code,
  });

  Future<void> signOut();
}
