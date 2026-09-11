import 'package:assignment/utils/result.dart';
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/model/user/app_user.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authState();

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String phoneE164,
    required String state,
    required CarInterests interests,
  });

  Future<Result<AppUser>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  });

  Future<Result<AppUser>> updateAvatar(String localPath);

  Future<Result<AppUser>> removeAvatar();

  Future<Result<void>> deleteAccount();

  Future<void> signOut();
}
