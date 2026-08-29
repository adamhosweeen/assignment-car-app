import 'package:sqflite/sqflite.dart';

import 'package:assignment/control/services/app_storage.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';

/// Persists the single in-progress sell draft to sqflite's `listing_draft` /
/// `listing_draft_photo` tables, so a crash or force-quit never loses input
/// (V1_SPEC §4.5).
///
/// Reads are served from an in-memory cache seeded at construction (from rows
/// [AppStorage] already fetched during startup) — sqflite has no synchronous
/// API, but callers like `SellController.build()` need a synchronous answer.
/// Writes update the cache immediately and persist to sqflite underneath.
class DraftRepository {
  DraftRepository(
    this._db,
    Map<String, Object?>? initialRow,
    List<String> initialPhotoPaths,
  ) : _cached = initialRow == null
          ? null
          : _fromRow(initialRow, initialPhotoPaths);

  final Database _db;
  ListingDraft? _cached;

  bool get hasDraft => _cached != null;

  ListingDraft? load() => _cached;

  Future<void> save(ListingDraft draft) async {
    _cached = draft;
    await _db.transaction((txn) async {
      await txn.delete(
        'listing_draft',
        where: 'id != ?',
        whereArgs: [draft.id],
      );
      await txn.insert(
        'listing_draft',
        _toRow(draft),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'listing_draft_photo',
        where: 'draft_id = ?',
        whereArgs: [draft.id],
      );
      for (var i = 0; i < draft.photoPaths.length; i++) {
        await txn.insert('listing_draft_photo', {
          'draft_id': draft.id,
          'position': i,
          'path': draft.photoPaths[i],
        });
      }
    });
  }

  Future<void> clear() async {
    _cached = null;
    await _db.delete('listing_draft');
  }

  static Map<String, Object?> _toRow(ListingDraft draft) => {
    'id': draft.id,
    'video_path': draft.videoPath,
    'make': draft.make,
    'model': draft.model,
    'variant': draft.variant,
    'year': draft.year,
    'mileage_km': draft.mileageKm,
    'transmission': draft.transmission?.name,
    'fuel_type': draft.fuelType?.name,
    'body_type': draft.bodyType?.name,
    'colour': draft.colour,
    'owners_count': draft.ownersCount,
    'accident_free': draft.accidentFree == null
        ? null
        : (draft.accidentFree! ? 1 : 0),
    'road_tax_expiry': draft.roadTaxExpiry?.toIso8601String(),
    'registration_region': draft.registrationRegion?.name,
    'state': draft.state,
    'city': draft.city,
    'price_myr': draft.priceMyr,
    'negotiable': draft.negotiable ? 1 : 0,
    'description': draft.description,
    'current_step': draft.currentStep,
    'updated_at': draft.updatedAt.toIso8601String(),
  };

  static ListingDraft _fromRow(
    Map<String, Object?> row,
    List<String> photoPaths,
  ) {
    return ListingDraft(
      id: row['id']! as String,
      photoPaths: photoPaths,
      videoPath: row['video_path'] as String?,
      make: row['make'] as String?,
      model: row['model'] as String?,
      variant: row['variant'] as String?,
      year: row['year'] as int?,
      mileageKm: row['mileage_km'] as int?,
      transmission: _enumByName(Transmission.values, row['transmission']),
      fuelType: _enumByName(FuelType.values, row['fuel_type']),
      bodyType: _enumByName(BodyType.values, row['body_type']),
      colour: row['colour'] as String?,
      ownersCount: row['owners_count'] as int?,
      accidentFree: (row['accident_free'] as int?) == null
          ? null
          : (row['accident_free']! as int) == 1,
      roadTaxExpiry: (row['road_tax_expiry'] as String?) == null
          ? null
          : DateTime.parse(row['road_tax_expiry']! as String),
      registrationRegion: _enumByName(
        RegistrationRegion.values,
        row['registration_region'],
      ),
      state: row['state'] as String?,
      city: row['city'] as String?,
      priceMyr: row['price_myr'] as int?,
      negotiable: (row['negotiable']! as int) == 1,
      description: row['description'] as String?,
      currentStep: row['current_step']! as int,
      updatedAt: DateTime.parse(row['updated_at']! as String),
    );
  }

  static T? _enumByName<T extends Enum>(List<T> values, Object? name) {
    if (name == null) return null;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
