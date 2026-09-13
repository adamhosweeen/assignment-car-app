// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      kind: $enumDecode(_$NotificationKindEnumMap, json['kind']),
      title: json['title'] as String,
      body: json['body'] as String,
      listingId: json['listing_id'] as String?,
      route: json['route'] as String?,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'kind': _$NotificationKindEnumMap[instance.kind]!,
      'title': instance.title,
      'body': instance.body,
      'listing_id': instance.listingId,
      'route': instance.route,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$NotificationKindEnumMap = {
  NotificationKind.welcome: 'welcome',
  NotificationKind.listingMatch: 'listing_match',
  NotificationKind.insightsUpdated: 'insights_updated',
  NotificationKind.bidPlaced: 'bid_placed',
  NotificationKind.bidAccepted: 'bid_accepted',
  NotificationKind.bidRejected: 'bid_rejected',
};
