import 'package:assignment/utils/json.dart';

const Object _unset = Object();

enum NotificationKind {
  welcome,
  listingMatch,
  insightsUpdated,

  bidPlaced,

  bidAccepted,

  bidRejected,
}

const Map<NotificationKind, String> kindValues = {
  NotificationKind.welcome: 'welcome',
  NotificationKind.listingMatch: 'listing_match',
  NotificationKind.insightsUpdated: 'insights_updated',
  NotificationKind.bidPlaced: 'bid_placed',
  NotificationKind.bidAccepted: 'bid_accepted',
  NotificationKind.bidRejected: 'bid_rejected',
};

extension NotificationKindValue on NotificationKind {
  String get value => kindValues[this]!;
}

NotificationKind notificationKindFromValue(Object? raw) {
  for (final entry in kindValues.entries) {
    if (entry.value == raw) return entry.key;
  }
  throw ArgumentError.value(raw, 'kind', 'Unknown notification kind');
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    this.listingId,
    this.route,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        kind: notificationKindFromValue(json['kind']),
        title: json['title'] as String,
        body: json['body'] as String,
        listingId: json['listing_id'] as String?,
        route: json['route'] as String?,
        readAt: asDateOrNull(json['read_at']),
        createdAt: asDate(json['created_at']),
      );

  final String id;
  final String userId;
  final NotificationKind kind;
  final String title;
  final String body;

  final String? listingId;

  final String? route;
  final DateTime? readAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'kind': kind.value,
    'title': title,
    'body': body,
    'listing_id': listingId,
    'route': route,
    'read_at': readAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  bool get isRead => readAt != null;

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationKind? kind,
    String? title,
    String? body,
    Object? listingId = _unset,
    Object? route = _unset,
    Object? readAt = _unset,
    DateTime? createdAt,
  }) => AppNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    body: body ?? this.body,
    listingId: identical(listingId, _unset)
        ? this.listingId
        : listingId as String?,
    route: identical(route, _unset) ? this.route : route as String?,
    readAt: identical(readAt, _unset) ? this.readAt : readAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          id == other.id &&
          userId == other.userId &&
          kind == other.kind &&
          title == other.title &&
          body == other.body &&
          listingId == other.listingId &&
          route == other.route &&
          readAt == other.readAt &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    kind,
    title,
    body,
    listingId,
    route,
    readAt,
    createdAt,
  );

  @override
  String toString() =>
      'AppNotification(id: $id, userId: $userId, kind: $kind, '
      'title: $title, route: $route, readAt: $readAt, '
      'createdAt: $createdAt)';
}
