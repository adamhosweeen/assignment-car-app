import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/notifications/app_notification.dart';

part 'notifications_providers.g.dart';

/// The signed-in user's inbox, newest first, live over realtime. Empty
/// stream when signed out; re-created when the user changes.
@riverpod
Stream<List<AppNotification>> inbox(Ref ref) {
  ref.watch(authStateProvider); // rebuild when the signed-in user changes
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(const <AppNotification>[]);
  return ref.watch(notificationsRepositoryProvider).watchInbox();
}

/// Unread count for the hub row and the Profile tab badge (0 while loading).
@riverpod
int unreadCount(Ref ref) =>
    ref.watch(inboxProvider).value?.where((n) => !n.isRead).length ?? 0;
