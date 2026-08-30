import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/result.dart';

part 'profiles_providers.g.dart';

/// Carries a repository's user-facing message through Riverpod's error
/// channel without exposing a raw backend exception to the UI.
class ProfilesException implements Exception {
  const ProfilesException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One user's public profile (seller page, seller row on Listing Detail).
/// Null when the account no longer exists.
@riverpod
Future<PublicProfile?> publicProfile(Ref ref, String id) async {
  final res = await ref.watch(profilesRepositoryProvider).getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw ProfilesException(message),
  };
}

/// Seller-name search. Empty query → empty list, no request.
@riverpod
Future<List<PublicProfile>> sellerSearch(Ref ref, String query) async {
  if (query.trim().isEmpty) return const [];
  final res = await ref.watch(profilesRepositoryProvider).search(query);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw ProfilesException(message),
  };
}
