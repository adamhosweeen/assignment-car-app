import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/model/listing/listing_enums.dart';

part 'listing_draft.freezed.dart';
part 'listing_draft.g.dart';

/// Maximum asking price (RM). Above this we reject in-app rather than let the
/// Postgres `int` column (max ~2.15 billion) overflow when publishing.
const int kMaxPriceMyr = 100000000; // RM 100,000,000

/// An in-progress sell form, persisted to sqflite after every step so a crash
/// or app kill never loses input (CLAUDE.md §3, V1_SPEC §4.5).
///
/// Every field is nullable because the form is filled in incrementally. [id]
/// doubles as the listing id when the draft is published.
@freezed
abstract class ListingDraft with _$ListingDraft {
  const factory ListingDraft({
    required String id,

    /// Local file paths of picked/compressed photos; index 0 is the cover.
    @Default(<String>[]) List<String> photoPaths,
    String? videoPath,

    // Step 2 — identity
    String? make,
    String? model,
    String? variant,
    int? year,

    // Step 3 — specs
    int? mileageKm,
    Transmission? transmission,
    FuelType? fuelType,
    BodyType? bodyType,
    String? colour,

    // Step 4 — condition
    int? ownersCount,
    bool? accidentFree,
    DateTime? roadTaxExpiry,

    // Step 5 — registration & location
    RegistrationRegion? registrationRegion,
    String? state,
    String? city,

    // Step 6 — price
    int? priceMyr,
    @Default(true) bool negotiable,

    // Shared
    String? description,

    /// Furthest step the user has reached (0-based), for resume.
    @Default(0) int currentStep,
    required DateTime updatedAt,
  }) = _ListingDraft;

  const ListingDraft._();

  factory ListingDraft.fromJson(Map<String, dynamic> json) =>
      _$ListingDraftFromJson(json);

  /// Photo count satisfies the §3 minimum.
  bool get hasEnoughPhotos => photoPaths.length >= 3;
}
