import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/async_snapshots.dart';
import 'package:assignment/utils/restartable_stream.dart';

/// The signed-in user's inbox, newest first, live over realtime.
///
/// App-scoped because two places read it: the Profile tab's badge in the
/// shell and the Inbox screen itself. The repository stream is
/// single-subscription and opens a realtime channel per listen, so it has to
/// be one shared subscription rather than a [StreamBuilder] in each.
///
/// [restart] backs the Inbox screen's "Retry".
class InboxFeed extends RestartableStream<AsyncSnapshot<List<AppNotification>>> {
  InboxFeed(AuthRepository auth, NotificationsRepository notifications)
    : super(() => _watchInbox(auth, notifications));
}

final notificationsProviders = <SingleChildWidget>[
  Provider<InboxFeed>(
    create: (c) => InboxFeed(
      c.read<AuthRepository>(),
      c.read<NotificationsRepository>(),
    ),
    dispose: (_, feed) => feed.dispose(),
  ),
  StreamProvider<AsyncSnapshot<List<AppNotification>>>(
    lazy: false,
    initialData: const AsyncSnapshot<List<AppNotification>>.waiting(),
    create: (c) => c.read<InboxFeed>().stream,
  ),
];

/// Empty when signed out; torn down and re-subscribed when the user changes.
/// Opens on `waiting` so a restart returns the screen to its loading state.
Stream<AsyncSnapshot<List<AppNotification>>> _watchInbox(
  AuthRepository auth,
  NotificationsRepository notifications,
) async* {
  yield const AsyncSnapshot<List<AppNotification>>.waiting();
  yield* auth
      .authState()
      .map((profile) => profile?.id)
      .distinct()
      .asyncExpand(
        (userId) => userId == null
            ? Stream.value(
                const AsyncSnapshot<List<AppNotification>>.withData(
                  ConnectionState.active,
                  <AppNotification>[],
                ),
              )
            : snapshots(notifications.watchInbox()),
      );
}

/// Unread count for the hub row and the Profile tab badge (0 while loading).
int unreadCountOf(AsyncSnapshot<List<AppNotification>> inbox) =>
    inbox.data?.where((n) => !n.isRead).length ?? 0;
