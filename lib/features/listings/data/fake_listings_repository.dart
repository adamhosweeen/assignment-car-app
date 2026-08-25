import 'dart:async';

import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../domain/listing.dart';
import '../domain/listing_draft.dart';
import '../domain/listing_enums.dart';
import '../domain/listing_media.dart';
import '../domain/listings_repository.dart';

/// In-memory [ListingsRepository] for the fake backend.
///
/// Seeded with sample active listings from other sellers so the Buy feed has
/// content. A broadcast stream emulates Supabase Realtime — every mutation
/// re-emits to all listeners.
///
/// NOTE: data lives only in memory, so published listings do not survive an app
/// restart (that is Supabase's job in the real build). Drafts DO survive, via
/// [DraftRepository] + sqflite.
class FakeListingsRepository implements ListingsRepository {
  FakeListingsRepository() {
    _seed();
  }

  final List<Listing> _listings = [];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void _emit() => _changes.add(null);

  List<Listing> _active() =>
      _listings.where((l) => l.status == ListingStatus.active).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Listing> _bySeller(String sellerId) =>
      _listings
          .where(
            (l) => l.sellerId == sellerId && l.status != ListingStatus.deleted,
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Stream<List<Listing>> watchActive() async* {
    yield _active();
    yield* _changes.stream.map((_) => _active());
  }

  @override
  Stream<List<Listing>> watchBySeller(String sellerId) async* {
    yield _bySeller(sellerId);
    yield* _changes.stream.map((_) => _bySeller(sellerId));
  }

  @override
  Future<Result<Listing>> getById(String id) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index == -1) return const Err('This listing is no longer available.');
    return Ok(_listings[index]);
  }

  @override
  Future<Result<Listing>> publish(ListingDraft draft, String sellerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final missing = _firstMissingField(draft);
    if (missing != null) {
      return Err('$missing is missing. Go back and complete every step.');
    }
    if ((draft.priceMyr ?? 0) > kMaxPriceMyr) {
      return const Err(
        'That price is too high to publish. Enter a smaller amount.',
      );
    }

    final now = DateTime.now().toUtc();
    final media = <ListingMedia>[
      for (var i = 0; i < draft.photoPaths.length; i++)
        ListingMedia(
          id: newId(),
          listingId: draft.id,
          storagePath: draft.photoPaths[i],
          position: i,
          createdAt: now,
        ),
      if (draft.videoPath != null)
        ListingMedia(
          id: newId(),
          listingId: draft.id,
          storagePath: draft.videoPath!,
          mediaType: MediaType.video,
          position: draft.photoPaths.length,
          createdAt: now,
        ),
    ];

    final listing = Listing(
      id: draft.id,
      sellerId: sellerId,
      status: ListingStatus.active,
      make: draft.make!,
      model: draft.model!,
      variant: draft.variant,
      year: draft.year!,
      mileageKm: draft.mileageKm!,
      transmission: draft.transmission!,
      fuelType: draft.fuelType!,
      bodyType: draft.bodyType!,
      colour: draft.colour!,
      ownersCount: draft.ownersCount!,
      accidentFree: draft.accidentFree ?? false,
      roadTaxExpiry: draft.roadTaxExpiry,
      registrationRegion: draft.registrationRegion!,
      state: draft.state!,
      city: draft.city!,
      priceMyr: draft.priceMyr!,
      negotiable: draft.negotiable,
      description: draft.description,
      createdAt: now,
      updatedAt: now,
      media: media,
    );

    _listings.removeWhere((l) => l.id == listing.id); // replace if re-published
    _listings.add(listing);
    _emit();
    return Ok(listing);
  }

  @override
  Future<Result<void>> markSold(String id) =>
      _setStatus(id, ListingStatus.sold);

  @override
  Future<Result<void>> softDelete(String id) =>
      _setStatus(id, ListingStatus.deleted);

  Future<Result<void>> _setStatus(String id, ListingStatus status) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index == -1) return const Err('This listing no longer exists.');
    _listings[index] = _listings[index].copyWith(
      status: status,
      updatedAt: DateTime.now().toUtc(),
    );
    _emit();
    return const Ok(null);
  }

  String? _firstMissingField(ListingDraft d) {
    if (!d.hasEnoughPhotos) return 'At least 3 photos';
    if (d.make == null) return 'Make';
    if (d.model == null) return 'Model';
    if (d.year == null) return 'Year';
    if (d.mileageKm == null) return 'Mileage';
    if (d.transmission == null) return 'Transmission';
    if (d.fuelType == null) return 'Fuel type';
    if (d.bodyType == null) return 'Body type';
    if (d.colour == null || d.colour!.isEmpty) return 'Colour';
    if (d.ownersCount == null) return 'Owners count';
    if (d.registrationRegion == null) return 'Registration region';
    if (d.state == null) return 'State';
    if (d.city == null || d.city!.isEmpty) return 'City';
    if (d.priceMyr == null) return 'Price';
    return null;
  }

  void _seed() {
    final now = DateTime.now().toUtc();
    Listing s({
      required String sellerId,
      required String make,
      required String model,
      String? variant,
      required int year,
      required int mileageKm,
      required Transmission transmission,
      required FuelType fuelType,
      required BodyType bodyType,
      required String colour,
      required int owners,
      required bool accidentFree,
      required RegistrationRegion region,
      required String state,
      required String city,
      required int price,
      required bool negotiable,
      required String description,
      required Duration ago,
      required String photoUrl,
    }) {
      final ts = now.subtract(ago);
      final listingId = newId();
      return Listing(
        id: listingId,
        sellerId: sellerId,
        status: ListingStatus.active,
        make: make,
        model: model,
        variant: variant,
        year: year,
        mileageKm: mileageKm,
        transmission: transmission,
        fuelType: fuelType,
        bodyType: bodyType,
        colour: colour,
        ownersCount: owners,
        accidentFree: accidentFree,
        registrationRegion: region,
        state: state,
        city: city,
        priceMyr: price,
        negotiable: negotiable,
        description: description,
        createdAt: ts,
        updatedAt: ts,
        media: [
          ListingMedia(
            id: newId(),
            listingId: listingId,
            storagePath: photoUrl,
            position: 0,
            createdAt: ts,
          ),
        ],
      );
    }

    _listings.addAll([
      s(
        sellerId: 'seed-1',
        make: 'Perodua',
        model: 'Myvi',
        variant: '1.5 AV',
        year: 2021,
        mileageKm: 38000,
        transmission: Transmission.automatic,
        fuelType: FuelType.petrol,
        bodyType: BodyType.hatchback,
        colour: 'White',
        owners: 1,
        accidentFree: true,
        region: RegistrationRegion.peninsular,
        state: 'Selangor',
        city: 'Petaling Jaya',
        price: 48800,
        negotiable: true,
        description:
            'One careful owner, full service record, tip-top condition.',
        ago: const Duration(hours: 2),
        photoUrl:
            'https://commons.wikimedia.org/wiki/Special:FilePath/2021_Perodua_Myvi_1.3G_silver_front_view_in_Brunei.jpg',
      ),
      s(
        sellerId: 'seed-2',
        make: 'Honda',
        model: 'City',
        variant: '1.5 V',
        year: 2019,
        mileageKm: 62000,
        transmission: Transmission.automatic,
        fuelType: FuelType.petrol,
        bodyType: BodyType.sedan,
        colour: 'Silver',
        owners: 2,
        accidentFree: true,
        region: RegistrationRegion.peninsular,
        state: 'WP Kuala Lumpur',
        city: 'Cheras',
        price: 62500,
        negotiable: false,
        description: 'Well kept family sedan, low mileage for the year.',
        ago: const Duration(hours: 9),
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/6/61/Honda_City_GN2_FL_1.5_E_Lunar_Silver_Metallic.jpg',
      ),
      s(
        sellerId: 'seed-3',
        make: 'Toyota',
        model: 'Hilux',
        variant: '2.4G',
        year: 2020,
        mileageKm: 88000,
        transmission: Transmission.automatic,
        fuelType: FuelType.diesel,
        bodyType: BodyType.pickup,
        colour: 'Black',
        owners: 1,
        accidentFree: true,
        region: RegistrationRegion.sabah,
        state: 'Sabah',
        city: 'Kota Kinabalu',
        price: 98000,
        negotiable: true,
        description: '4x4, strong engine, ready for work or off-road.',
        ago: const Duration(days: 1, hours: 3),
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/f/fd/2020_Toyota_Hilux_Revo_4x4_Double-Cab_2.8_Rocco.jpg',
      ),
      s(
        sellerId: 'seed-1',
        make: 'Tesla',
        model: 'Model 3',
        year: 2023,
        mileageKm: 21000,
        transmission: Transmission.automatic,
        fuelType: FuelType.electric,
        bodyType: BodyType.sedan,
        colour: 'Blue',
        owners: 1,
        accidentFree: true,
        region: RegistrationRegion.peninsular,
        state: 'Selangor',
        city: 'Subang Jaya',
        price: 175000,
        negotiable: false,
        description: 'Long range, under warranty, free charging balance.',
        ago: const Duration(days: 2),
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/46/Blue_Tesla_Model_3_at_night.jpg',
      ),
      s(
        sellerId: 'seed-2',
        make: 'Proton',
        model: 'X50',
        variant: 'Flagship',
        year: 2022,
        mileageKm: 34000,
        transmission: Transmission.automatic,
        fuelType: FuelType.petrol,
        bodyType: BodyType.suv,
        colour: 'Grey',
        owners: 1,
        accidentFree: true,
        region: RegistrationRegion.sarawak,
        state: 'Sarawak',
        city: 'Kuching',
        price: 89800,
        negotiable: true,
        description: 'Turbocharged, loaded with features, still like new.',
        ago: const Duration(days: 3, hours: 6),
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/45/2021_Proton_X50_1.5_Standard_7AT_silver_front_view_in_Brunei.jpg',
      ),
    ]);
  }
}
