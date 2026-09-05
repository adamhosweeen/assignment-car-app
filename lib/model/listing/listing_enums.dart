library;

enum ListingStatus { selling, bidding, hidden, sold }

enum Transmission { automatic, manual }

enum FuelType { petrol, diesel, hybrid, electric }

enum BodyType { sedan, hatchback, suv, mpv, pickup, coupe, other }

enum RegistrationRegion { west, east }

enum MediaType { photo, video }

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

ListingStatus listingStatusFromValue(Object? raw) => switch (raw) {
  'selling' => ListingStatus.selling,
  'bidding' => ListingStatus.bidding,
  'hidden' => ListingStatus.hidden,
  'sold' => ListingStatus.sold,
  'active' => ListingStatus.selling,
  'draft' || 'deleted' => ListingStatus.hidden,
  _ => ListingStatus.hidden,
};

extension ListingStatusLabel on ListingStatus {
  String get label => switch (this) {
    ListingStatus.selling => 'Selling',
    ListingStatus.bidding => 'Bidding',
    ListingStatus.hidden => 'Hidden',
    ListingStatus.sold => 'Sold',
  };

  bool get isVisibleToBuyers =>
      this == ListingStatus.selling || this == ListingStatus.bidding;
}
