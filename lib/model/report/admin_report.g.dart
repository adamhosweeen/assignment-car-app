// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminReport _$AdminReportFromJson(Map<String, dynamic> json) => _AdminReport(
  id: json['id'] as String,
  reporterId: json['reporter_id'] as String,
  reportedId: json['reported_id'] as String,
  reporterName: json['reporter_name'] as String?,
  reportedName: json['reported_name'] as String?,
  reportedBanned: json['reported_banned'] as bool? ?? false,
  title: json['title'] as String,
  description: json['description'] as String,
  status: json['status'] as String? ?? 'open',
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AdminReportToJson(_AdminReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporter_id': instance.reporterId,
      'reported_id': instance.reportedId,
      'reporter_name': instance.reporterName,
      'reported_name': instance.reportedName,
      'reported_banned': instance.reportedBanned,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
