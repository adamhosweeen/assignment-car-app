/// Listing domain enums.
///
/// Each enum constant name maps 1:1 to the Postgres text value (e.g.
/// `FuelType.petrol` <-> `'petrol'`), so json_serializable round-trips them by
/// name with no `@JsonValue` annotations.
library;

enum ListingStatus { draft, active, sold, deleted }

enum Transmission { automatic, manual }

enum FuelType { petrol, diesel, hybrid, electric }

enum BodyType { sedan, hatchback, suv, mpv, pickup, coupe, other }

enum RegistrationRegion { west, east }

enum MediaType { photo, video }

// ── Display labels ───────────────────────────────────────────────────────────
// User-facing English for each enum, kept beside the source of truth.

extension TransmissionLabel on Transmission {
  String get label => switch (this) {
    Transmission.automatic => 'Automatic',
    Transmission.manual => 'Manual',
  };
}

extension FuelTypeLabel on FuelType {
  String get label => switch (this) {
    FuelType.petrol => 'Petrol',
    FuelType.diesel => 'Diesel',
    FuelType.hybrid => 'Hybrid',
    FuelType.electric => 'Electric',
  };
}

extension BodyTypeLabel on BodyType {
  String get label => switch (this) {
    BodyType.sedan => 'Sedan',
    BodyType.hatchback => 'Hatchback',
    BodyType.suv => 'SUV',
    BodyType.mpv => 'MPV',
    BodyType.pickup => 'Pickup',
    BodyType.coupe => 'Coupe',
    BodyType.other => 'Other',
  };
}

extension RegistrationRegionLabel on RegistrationRegion {
  String get label => switch (this) {
    RegistrationRegion.west => 'West Malaysia',
    RegistrationRegion.east => 'East Malaysia',
  };
}

extension ListingStatusLabel on ListingStatus {
  String get label => switch (this) {
    ListingStatus.draft => 'Draft',
    ListingStatus.active => 'Active',
    ListingStatus.sold => 'Sold',
    ListingStatus.deleted => 'Deleted',
  };
}
