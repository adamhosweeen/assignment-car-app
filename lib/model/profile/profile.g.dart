// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
  phone: json['phone'] as String?,
  state: json['state'] as String?,
  interests: json['interests'] == null
      ? const CarInterests()
      : CarInterests.fromJson(json['interests'] as Map<String, dynamic>),
  avatarUrl: json['avatar_url'] as String?,
  role: json['role'] as String? ?? 'user',
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'dob': instance.dob?.toIso8601String(),
  'phone': instance.phone,
  'state': instance.state,
  'interests': instance.interests.toJson(),
  'avatar_url': instance.avatarUrl,
  'role': instance.role,
  'created_at': instance.createdAt.toIso8601String(),
};
