import 'package:assignment/utils/result.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/model/auth/registration_data.dart';

abstract interface class AuthRepository {
  Profile? get currentUser;

  Stream<Profile?> authState();

  Future<Result<Profile>> signIn({
    required String email,
    required String password,
  });

  Future<Result<Profile>> signUp({
    required String email,
    required String password,
    required RegistrationData data,
  });

  Future<Result<Profile>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  });

  Future<Result<Profile>> updateAvatar(String localPath);

  Future<Result<Profile>> removeAvatar();

  Future<Result<void>> deleteAccount();

  Future<void> signOut();
}
