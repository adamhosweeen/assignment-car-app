// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingMedia _$ListingMediaFromJson(Map<String, dynamic> json) =>
    _ListingMedia(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      storagePath: json['storage_path'] as String,
      mediaType:
          $enumDecodeNullable(_$MediaTypeEnumMap, json['media_type']) ??
          MediaType.photo,
      position: (json['position'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ListingMediaToJson(_ListingMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listing_id': instance.listingId,
      'storage_path': instance.storagePath,
      'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
      'position': instance.position,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$MediaTypeEnumMap = {MediaType.photo: 'photo', MediaType.video: 'video'};
