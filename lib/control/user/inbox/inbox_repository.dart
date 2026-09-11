import 'package:assignment/model/user/inbox_message.dart';
import 'package:assignment/utils/result.dart';

abstract interface class InboxRepository {
  Future<Result<List<InboxMessage>>> list();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> delete(String id);
}
