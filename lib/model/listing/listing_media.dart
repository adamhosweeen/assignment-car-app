import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/json.dart';

/// Sentinel for [ListingMedia.copyWith] — see `CarInterests`.
const Object _unset = Object();

/// A single photo or video attached to a listing.
///
/// In the Supabase build [storagePath] is a path in the private `listing-media`
/// bucket served via signed URL. In the current fake backend it holds a local
/// file path (displayed with `Image.file`).
class ListingMedia {
  const ListingMedia({
    required this.id,
    required this.listingId,
    required this.storagePath,
    this.mediaType = MediaType.photo,
    required this.position,
    this.createdAt,
  });

  factory ListingMedia.fromJson(Map<String, dynamic> json) => ListingMedia(
    id: json['id'] as String,
    listingId: json['listing_id'] as String,
    storagePath: json['storage_path'] as String,
    mediaType:
        asEnumOrNull(MediaType.values, json['media_type']) ?? MediaType.photo,
    position: asInt(json['position']),
    createdAt: asDateOrNull(json['created_at']),
  );

  final String id;
  final String listingId;
  final String storagePath;
  final MediaType mediaType;

  /// 0 = cover.
  final int position;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'listing_id': listingId,
    'storage_path': storagePath,
    'media_type': mediaType.name,
    'position': position,
    'created_at': createdAt?.toIso8601String(),
  };

  ListingMedia copyWith({
    String? id,
    String? listingId,
    String? storagePath,
    MediaType? mediaType,
    int? position,
    Object? createdAt = _unset,
  }) => ListingMedia(
    id: id ?? this.id,
    listingId: listingId ?? this.listingId,
    storagePath: storagePath ?? this.storagePath,
    mediaType: mediaType ?? this.mediaType,
    position: position ?? this.position,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingMedia &&
          id == other.id &&
          listingId == other.listingId &&
          storagePath == other.storagePath &&
          mediaType == other.mediaType &&
          position == other.position &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, listingId, storagePath, mediaType, position, createdAt);

  @override
  String toString() =>
      'ListingMedia(id: $id, listingId: $listingId, '
      'storagePath: $storagePath, mediaType: $mediaType, '
      'position: $position, createdAt: $createdAt)';
}
