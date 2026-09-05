import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/result.dart';

abstract interface class NotificationsRepository {
  Stream<List<AppNotification>> watchInbox();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();

  Future<Result<void>> delete(String id);
}
