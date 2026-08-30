import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// What produced a notification. Names map 1:1 to the `notifications.kind`
/// text values (`welcome`, `listing_match`, `insights_updated`).
enum NotificationKind {
  @JsonValue('welcome')
  welcome,
  @JsonValue('listing_match')
  listingMatch,
  @JsonValue('insights_updated')
  insightsUpdated,
}

/// One row of the user's in-app inbox (`notifications` table). Rows are
/// created only by Postgres triggers; the app reads, marks read, and deletes.
@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    required String userId,
    required NotificationKind kind,
    required String title,
    required String body,

    /// Listing this is about, if any (deep link + cascade-deleted with it).
    String? listingId,

    /// In-app route to open on tap, e.g. `/listing/<id>` or `/profile/insights`.
    String? route,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  bool get isRead => readAt != null;
}
