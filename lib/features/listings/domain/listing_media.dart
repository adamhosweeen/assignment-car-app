import 'package:freezed_annotation/freezed_annotation.dart';

import 'listing_enums.dart';

part 'listing_media.freezed.dart';
part 'listing_media.g.dart';

/// A single photo or video attached to a listing.
///
/// In the Supabase build [storagePath] is a path in the private `listing-media`
/// bucket served via signed URL. In the current fake backend it holds a local
/// file path (displayed with `Image.file`).
@freezed
abstract class ListingMedia with _$ListingMedia {
  const factory ListingMedia({
    required String id,
    required String listingId,
    required String storagePath,
    @Default(MediaType.photo) MediaType mediaType,

    /// 0 = cover.
    required int position,
    DateTime? createdAt,
  }) = _ListingMedia;

  factory ListingMedia.fromJson(Map<String, dynamic> json) =>
      _$ListingMediaFromJson(json);
}
