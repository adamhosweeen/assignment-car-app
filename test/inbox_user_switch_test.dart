import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/notifications/notifications_providers.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/model/auth/registration_data.dart';
import 'package:assignment/utils/result.dart';

Profile _profile(String id) =>
    Profile(id: id, email: '$id@example.com', createdAt: DateTime.utc(2026));

AppNotification _n(String userId) => AppNotification(
  id: '$userId-n1',
  userId: userId,
  kind: NotificationKind.welcome,
  title: 'inbox of $userId',
  body: 'body',
  createdAt: DateTime.utc(2026, 9, 5),
);

class _FakeAuth implements AuthRepository {
  final _controller = StreamController<Profile?>.broadcast();
  Profile? _current;

  void emit(Profile? profile) {
    _current = profile;
    _controller.add(profile);
  }

  Future<void> close() => _controller.close();

  @override
  Profile? get currentUser => _current;

  @override
  Stream<Profile?> authState() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<Result<Profile>> signIn({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Profile>> signUp({
    required String email,
    required String password,
    required RegistrationData data,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Profile>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? state,
    CarInterests? interests,
    String? avatarUrl,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Profile>> updateAvatar(String localPath) async =>
      throw UnimplementedError();

  @override
  Future<Result<Profile>> removeAvatar() async => throw UnimplementedError();

  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();

  @override
  Future<void> signOut() async => emit(null);
}

class _FakeNotifications implements NotificationsRepository {
  _FakeNotifications(this._auth);

  final _FakeAuth _auth;
  int opened = 0;
  int cancelled = 0;

  @override
  Stream<List<AppNotification>> watchInbox() {
    final userId = _auth.currentUser?.id;
    opened++;
    late StreamController<List<AppNotification>> controller;
    controller = StreamController<List<AppNotification>>(
      onListen: () => controller.add([if (userId != null) _n(userId)]),
      onCancel: () => cancelled++,
    );
    return controller.stream;
  }

  @override
  Future<Result<void>> markRead(String id) async => const Ok(null);

  @override
  Future<Result<void>> markAllRead() async => const Ok(null);

  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

class _FakeChat implements ChatRepository {
  _FakeChat(this._auth);

  final _FakeAuth _auth;
  int opened = 0;

  @override
  Stream<List<ConversationThread>> watchConversations() {
    final userId = _auth.currentUser?.id;
    opened++;
    late StreamController<List<ConversationThread>> controller;
    controller = StreamController<List<ConversationThread>>(
      onListen: () => controller.add([
        if (userId != null)
          ConversationThread(
            conversation: Conversation(
              id: '$userId-c1',
              listingId: 'l1',
              buyerId: userId,
              sellerId: 's1',
              createdAt: DateTime.utc(2026),
            ),
          ),
      ]),
    );
    return controller.stream;
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('inbox follows the signed-in user across a switch', () async {
    final auth = _FakeAuth();
    final notifications = _FakeNotifications(auth);
    addTearDown(auth.close);

    final feed = InboxFeed(auth, notifications);
    addTearDown(feed.dispose);

    final seen = <List<AppNotification>>[];
    final sub = feed.stream.listen((s) {
      if (s.hasData) seen.add(s.data!);
    });
    addTearDown(sub.cancel);

    auth.emit(_profile('alice'));
    await _settle();
    expect(seen.last.single.title, 'inbox of alice');

    auth.emit(null);
    await _settle();
    expect(seen.last, isEmpty, reason: 'signing out empties the inbox');

    auth.emit(_profile('bob'));
    await _settle();
    expect(
      seen.last.single.title,
      'inbox of bob',
      reason: 'the next user must not inherit the previous inbox',
    );
    expect(
      notifications.cancelled,
      greaterThan(0),
      reason: 'the old subscription must be torn down',
    );
  });

  test(
    'a direct user switch without signing out also swaps the inbox',
    () async {
      final auth = _FakeAuth();
      final notifications = _FakeNotifications(auth);
      addTearDown(auth.close);

      final feed = InboxFeed(auth, notifications);
      addTearDown(feed.dispose);

      final seen = <List<AppNotification>>[];
      final sub = feed.stream.listen((s) {
        if (s.hasData) seen.add(s.data!);
      });
      addTearDown(sub.cancel);

      auth.emit(_profile('alice'));
      await _settle();
      auth.emit(_profile('bob'));
      await _settle();

      expect(seen.last.single.title, 'inbox of bob');
    },
  );

  test('chat threads follow the signed-in user across a switch', () async {
    final auth = _FakeAuth();
    final chat = _FakeChat(auth);
    addTearDown(auth.close);

    final feed = ConversationsFeed(auth, chat);
    addTearDown(feed.dispose);

    final seen = <List<ConversationThread>>[];
    final sub = feed.stream.listen((s) {
      if (s.hasData) seen.add(s.data!);
    });
    addTearDown(sub.cancel);

    auth.emit(_profile('alice'));
    await _settle();
    expect(seen.last.single.conversation.buyerId, 'alice');

    auth.emit(_profile('bob'));
    await _settle();
    expect(seen.last.single.conversation.buyerId, 'bob');
  });
}
