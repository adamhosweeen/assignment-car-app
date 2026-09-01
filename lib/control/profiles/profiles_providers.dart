import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/result.dart';

/// Carries a repository's user-facing message through a `FutureBuilder`'s
/// error channel without exposing a raw backend exception to the UI.
class ProfilesException implements Exception {
  const ProfilesException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One user's public profile (seller page, seller row on Listing Detail).
/// Null when the account no longer exists.
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

/// Seller-name search. Empty query → empty list, no request.
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
