import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/async_snapshots.dart';
import 'package:assignment/utils/restartable_stream.dart';
import 'package:assignment/utils/switch_latest.dart';

class InboxFeed
    extends RestartableStream<AsyncSnapshot<List<AppNotification>>> {
  InboxFeed(AuthRepository auth, NotificationsRepository notifications)
    : super(() => _watchInbox(auth, notifications));
}

final notificationsProviders = <SingleChildWidget>[
  Provider<InboxFeed>(
    create: (c) =>
        InboxFeed(c.read<AuthRepository>(), c.read<NotificationsRepository>()),
    dispose: (_, feed) => feed.dispose(),
  ),
  StreamProvider<AsyncSnapshot<List<AppNotification>>>(
    lazy: false,
    initialData: const AsyncSnapshot<List<AppNotification>>.waiting(),
    create: (c) => c.read<InboxFeed>().stream,
  ),
];

Stream<AsyncSnapshot<List<AppNotification>>> _watchInbox(
  AuthRepository auth,
  NotificationsRepository notifications,
) => auth
    .authState()
    .map((profile) => profile?.id)
    .distinct()
    .switchMap((userId) => _inboxFor(userId, notifications));

Stream<AsyncSnapshot<List<AppNotification>>> _inboxFor(
  String? userId,
  NotificationsRepository notifications,
) async* {
  if (userId == null) {
    yield const AsyncSnapshot<List<AppNotification>>.withData(
      ConnectionState.active,
      <AppNotification>[],
    );
    return;
  }
  yield const AsyncSnapshot<List<AppNotification>>.waiting();
  yield* snapshots(notifications.watchInbox());
}

int unreadCountOf(AsyncSnapshot<List<AppNotification>> inbox) =>
    inbox.data?.where((n) => !n.isRead).length ?? 0;
