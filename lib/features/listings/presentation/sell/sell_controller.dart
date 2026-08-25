import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/providers.dart';
import '../../../../core/ids.dart';
import '../../domain/listing_draft.dart';
import '../../domain/listing_enums.dart';

part 'sell_controller.g.dart';

/// Owns the in-progress [ListingDraft] and persists it to sqflite after every
/// change, so a crash or force-quit never loses input (V1_SPEC §4.5). The
/// controller is ephemeral; the draft survives on-device and is reloaded on
/// re-entry.
@riverpod
class SellController extends _$SellController {
  @override
  ListingDraft build() => ref.read(draftRepositoryProvider).load() ?? _fresh();

  ListingDraft _fresh() =>
      ListingDraft(id: newId(), updatedAt: DateTime.now().toUtc());

  Future<void> _commit(ListingDraft draft) async {
    final next = draft.copyWith(updatedAt: DateTime.now().toUtc());
    state = next;
    await ref.read(draftRepositoryProvider).save(next);
  }

  // ── Photos ────────────────────────────────────────────────────────────────
  Future<void> addPhotos(List<String> paths) {
    final combined = [...state.photoPaths, ...paths];
    final capped = combined.length > 12 ? combined.sublist(0, 12) : combined;
    return _commit(state.copyWith(photoPaths: capped));
  }

  Future<void> removePhotoAt(int index) {
    final list = [...state.photoPaths]..removeAt(index);
    return _commit(state.copyWith(photoPaths: list));
  }

  Future<void> makeCover(int index) {
    final list = [...state.photoPaths];
    list.insert(0, list.removeAt(index));
    return _commit(state.copyWith(photoPaths: list));
  }

  // newIndex is already adjusted for the removed item (onReorderItem semantics).
  Future<void> reorderPhoto(int oldIndex, int newIndex) {
    final list = [...state.photoPaths];
    list.insert(newIndex, list.removeAt(oldIndex));
    return _commit(state.copyWith(photoPaths: list));
  }

  Future<void> setVideo(String? path) =>
      _commit(state.copyWith(videoPath: path));

  // ── Identity ────────────────────────────────────────────────────────────
  // Changing make clears the dependent model.
  Future<void> setMake(String? make) =>
      _commit(state.copyWith(make: make, model: null));
  Future<void> setModel(String? model) => _commit(state.copyWith(model: model));
  Future<void> setVariant(String? variant) =>
      _commit(state.copyWith(variant: variant));
  Future<void> setYear(int? year) => _commit(state.copyWith(year: year));

  // ── Specs ─────────────────────────────────────────────────────────────────
  Future<void> setMileage(int? km) => _commit(state.copyWith(mileageKm: km));
  Future<void> setTransmission(Transmission? t) =>
      _commit(state.copyWith(transmission: t));
  Future<void> setFuel(FuelType? f) => _commit(state.copyWith(fuelType: f));
  Future<void> setBody(BodyType? b) => _commit(state.copyWith(bodyType: b));
  Future<void> setColour(String? c) => _commit(state.copyWith(colour: c));

  // ── Condition ─────────────────────────────────────────────────────────────
  Future<void> setOwners(int? n) => _commit(state.copyWith(ownersCount: n));
  Future<void> setAccidentFree(bool v) =>
      _commit(state.copyWith(accidentFree: v));
  Future<void> setRoadTaxExpiry(DateTime? d) =>
      _commit(state.copyWith(roadTaxExpiry: d));

  // ── Registration & location ─────────────────────────────────────────────
  Future<void> setRegion(RegistrationRegion? r) =>
      _commit(state.copyWith(registrationRegion: r));
  Future<void> setStateName(String? s) => _commit(state.copyWith(state: s));
  Future<void> setCity(String? c) => _commit(state.copyWith(city: c));

  // ── Price ─────────────────────────────────────────────────────────────────
  Future<void> setPrice(int? p) => _commit(state.copyWith(priceMyr: p));
  Future<void> setNegotiable(bool v) => _commit(state.copyWith(negotiable: v));

  // ── Shared ────────────────────────────────────────────────────────────────
  Future<void> setDescription(String? d) =>
      _commit(state.copyWith(description: d));
  Future<void> setStep(int step) => _commit(state.copyWith(currentStep: step));

  /// Throw the draft away and start fresh.
  Future<void> discard() async {
    await ref.read(draftRepositoryProvider).clear();
    state = _fresh();
  }
}
