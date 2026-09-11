import 'package:assignment/control/user/inbox/inbox_repository.dart';
import 'package:assignment/model/user/inbox_message.dart';
import 'package:assignment/utils/result.dart';

class InboxException implements Exception {
  const InboxException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<List<InboxMessage>> fetchInbox(InboxRepository inbox) async {
  final res = await inbox.list();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw InboxException(message),
  };
}
