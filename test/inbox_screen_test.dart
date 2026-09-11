import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/inbox/inbox_repository.dart';
import 'package:assignment/model/user/inbox_message.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/user/inbox/inbox_screen.dart';

InboxMessage _message(String id, {DateTime? readAt}) => InboxMessage(
  id: id,
  userId: 'u1',
  kind: InboxKind.listingMatch,
  title: 'Message $id',
  body: 'body $id',
  readAt: readAt,
  createdAt: DateTime.utc(2026, 9, 1),
);

class _FakeInbox implements InboxRepository {
  _FakeInbox(this._messages, {this.deleteFails = false});

  List<InboxMessage> _messages;
  final bool deleteFails;
  int listCalls = 0;
  final deleted = <String>[];
  final read = <String>[];

  @override
  Future<Result<List<InboxMessage>>> list() async {
    listCalls++;
    return Ok(List.of(_messages));
  }

  @override
  Future<Result<void>> delete(String id) async {
    if (deleteFails) return const Err('Could not delete that message.');
    deleted.add(id);
    _messages = _messages.where((m) => m.id != id).toList();
    return const Ok(null);
  }

  @override
  Future<Result<void>> markRead(String id) async {
    read.add(id);
    _messages = [
      for (final m in _messages)
        if (m.id == id) m.copyWith(readAt: DateTime.utc(2026, 9, 2)) else m,
    ];
    return const Ok(null);
  }
}

Widget _app(InboxRepository inbox) => MultiProvider(
  providers: [Provider<InboxRepository>.value(value: inbox)],
  child: MaterialApp(theme: AppTheme.light, home: const InboxScreen()),
);

Future<void> _swipeAway(WidgetTester tester, String text) async {
  await tester.drag(find.text(text), const Offset(-500, 0));
  await tester
      .pumpAndSettle(); // finish the dismiss animation, fire onDismissed
}

void main() {
  testWidgets('a swiped message goes and stays gone, with no assertion', (
    tester,
  ) async {
    final inbox = _FakeInbox([_message('a'), _message('b')]);
    await tester.pumpWidget(_app(inbox));
    await tester.pumpAndSettle();
    expect(find.text('Message a'), findsOneWidget);

    await _swipeAway(tester, 'Message a');

    // The row must not be rebuilt after Dismissible removed it — that is what
    // trips "A dismissed Dismissible widget is still part of the tree".
    expect(tester.takeException(), isNull);
    expect(find.text('Message a'), findsNothing);
    expect(find.text('Message b'), findsOneWidget);
    expect(inbox.deleted, ['a']);

    // and it does not flicker back on later frames
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Message a'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting the last message falls through to the empty state', (
    tester,
  ) async {
    final inbox = _FakeInbox([_message('only')]);
    await tester.pumpWidget(_app(inbox));
    await tester.pumpAndSettle();

    await _swipeAway(tester, 'Message only');

    expect(find.textContaining('Nothing here yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed delete puts the message back and says so', (
    tester,
  ) async {
    final inbox = _FakeInbox([_message('a')], deleteFails: true);
    await tester.pumpWidget(_app(inbox));
    await tester.pumpAndSettle();

    await _swipeAway(tester, 'Message a');

    expect(find.text('Could not delete that message.'), findsOneWidget);
    expect(find.text('Message a'), findsOneWidget, reason: 'reloaded');
    expect(inbox.deleted, isEmpty);
  });

  testWidgets('an empty inbox shows its empty state, not a spinner', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeInbox([])));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing here yet'), findsOneWidget);
  });
}
