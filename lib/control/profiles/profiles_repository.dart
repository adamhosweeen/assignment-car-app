import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/result.dart';

abstract interface class ProfilesRepository {
  Future<Result<PublicProfile?>> getById(String id);

  Future<Result<List<PublicProfile>>> search(String query, {int limit = 30});
}
