// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicProfile _$PublicProfileFromJson(Map<String, dynamic> json) =>
    _PublicProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      state: json['state'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PublicProfileToJson(_PublicProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'state': instance.state,
      'created_at': instance.createdAt.toIso8601String(),
    };
