// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminUserStats _$AdminUserStatsFromJson(Map<String, dynamic> json) =>
    _AdminUserStats(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      state: json['state'] as String?,
      role: json['role'] as String? ?? 'user',
      banned: json['banned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      activeCount: (json['active_count'] as num).toInt(),
      soldCount: (json['sold_count'] as num).toInt(),
    );

Map<String, dynamic> _$AdminUserStatsToJson(_AdminUserStats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'email': instance.email,
      'phone': instance.phone,
      'dob': instance.dob?.toIso8601String(),
      'state': instance.state,
      'role': instance.role,
      'banned': instance.banned,
      'created_at': instance.createdAt.toIso8601String(),
      'active_count': instance.activeCount,
      'sold_count': instance.soldCount,
    };
