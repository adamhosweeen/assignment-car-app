import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/result.dart';

/// Read-only access to other users' public profiles (the `public_profiles`
/// view). The signed-in user's own full profile comes from `AuthRepository`.
abstract interface class ProfilesRepository {
  /// One user's public profile, `Ok(null)` if there is no such user.
  Future<Result<PublicProfile?>> getById(String id);

  /// Users whose display name contains [query] (case-insensitive), sorted by
  /// name. An empty query yields an empty list without a request.
  Future<Result<List<PublicProfile>>> search(String query, {int limit = 30});
}
