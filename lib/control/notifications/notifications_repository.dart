import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/result.dart';

/// The signed-in user's inbox. Rows are written only by database triggers
/// (welcome, listing matches your interests, market insights refreshed);
/// the client can read, mark read, and delete its own rows.
abstract interface class NotificationsRepository {
  /// Newest first; re-emits on any change (realtime).
  Stream<List<AppNotification>> watchInbox();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();

  Future<Result<void>> delete(String id);
}
