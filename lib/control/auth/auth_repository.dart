import 'package:assignment/utils/result.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/model/auth/registration_data.dart';

/// The auth data contract. The fake implementation is a dev bypass; the
/// Supabase email+password implementation drops in behind the same interface.
abstract interface class AuthRepository {
  /// The currently signed-in profile, or null.
  Profile? get currentUser;

  /// Emits the current profile, then on every sign-in / sign-out.
  Stream<Profile?> authState();

  /// Sign in with email and password.
  Future<Result<Profile>> signIn({
    required String email,
    required String password,
  });

  /// Create an account with email and password plus everything collected by
  /// the registration flow, and sign in.
  Future<Result<Profile>> signUp({
    required String email,
    required String password,
    required RegistrationData data,
  });

  /// Update the signed-in user's editable profile fields. Fields left null are
  /// unchanged. Email and date of birth are not editable.
  Future<Result<Profile>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  });

  /// Permanently delete the signed-in user's account: their listings, photos,
  /// chats, profile, and login. Irreversible.
  Future<Result<void>> deleteAccount();

  Future<void> signOut();
}
