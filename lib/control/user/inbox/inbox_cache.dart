import 'package:sqflite/sqflite.dart';

import 'package:assignment/model/user/inbox_message.dart';

class InboxCache {
  InboxCache(this._db);

  final Database _db;

  Future<List<InboxMessage>> getForUser(String userId) async {
    final rows = await _db.query(
      'inbox_cache',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return [for (final row in rows) inboxFromRow(row)];
  }

  Future<void> replaceForUser(
    String userId,
    List<InboxMessage> messages,
  ) async {
    final batch = _db.batch();
    batch.delete('inbox_cache', where: 'user_id = ?', whereArgs: [userId]);
    for (final message in messages) {
      batch.insert('inbox_cache', inboxToRow(message));
    }
    await batch.commit(noResult: true);
  }

  Future<void> markRead(String id, DateTime readAt) => _db.update(
    'inbox_cache',
    {'read_at': readAt.toIso8601String()},
    where: 'id = ?',
    whereArgs: [id],
  );

  Future<void> delete(String id) =>
      _db.delete('inbox_cache', where: 'id = ?', whereArgs: [id]);

  Future<void> clear() async {
    await _db.delete('inbox_cache');
  }
}

Map<String, Object?> inboxToRow(InboxMessage message) => {
  'id': message.id,
  'user_id': message.userId,
  'kind': inboxKindValues[message.kind],
  'title': message.title,
  'body': message.body,
  'listing_id': message.listingId,
  'route': message.route,
  'read_at': message.readAt?.toIso8601String(),
  'created_at': message.createdAt.toIso8601String(),
};

InboxMessage inboxFromRow(Map<String, Object?> row) => InboxMessage(
  id: row['id']! as String,
  userId: row['user_id']! as String,
  kind: inboxKindFromValue(row['kind']),
  title: row['title']! as String,
  body: row['body']! as String,
  listingId: row['listing_id'] as String?,
  route: row['route'] as String?,
  readAt: DateTime.tryParse(row['read_at'] as String? ?? ''),
  createdAt: DateTime.parse(row['created_at']! as String),
);
