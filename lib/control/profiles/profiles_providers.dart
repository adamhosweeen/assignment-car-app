import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/result.dart';

class ProfilesException implements Exception {
  const ProfilesException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<PublicProfile?> fetchPublicProfile(
  ProfilesRepository profiles,
  String id,
) async {
  final res = await profiles.getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw ProfilesException(message),
  };
}

Future<List<PublicProfile>> searchSellers(
  ProfilesRepository profiles,
  String query,
) async {
  if (query.trim().isEmpty) return const [];
  final res = await profiles.search(query);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw ProfilesException(message),
  };
}
