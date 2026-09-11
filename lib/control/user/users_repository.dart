import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/result.dart';

abstract interface class UsersRepository {
  Future<Result<AppUser?>> getById(String id);

  Future<Result<List<AppUser>>> search(String query, {int limit = 30});
}
