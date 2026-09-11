import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/result.dart';

class UsersException implements Exception {
  const UsersException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<AppUser?> fetchUser(UsersRepository users, String id) async {
  final res = await users.getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw UsersException(message),
  };
}

Future<List<AppUser>> searchSellers(UsersRepository users, String query) async {
  if (query.trim().isEmpty) return const [];
  final res = await users.search(query);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw UsersException(message),
  };
}
