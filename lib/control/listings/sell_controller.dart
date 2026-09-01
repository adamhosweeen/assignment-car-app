import 'package:flutter/foundation.dart';

import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/malaysian_states.dart';

/// Owns the in-progress [ListingDraft] and persists it to sqflite after every
/// change, so a crash or force-quit never loses input (V1_SPEC §4.5). The
/// controller is app-scoped; the draft survives on-device and is reloaded on
/// re-entry.
class SellController extends ChangeNotifier {
  SellController(this._drafts) : _draft = _drafts.load() ?? _fresh();

  final DraftRepository _drafts;
  ListingDraft _draft;

  /// The draft as it stands. Watch this to rebuild a step on every edit.
  ListingDraft get draft => _draft;

  static ListingDraft _fresh() =>
      ListingDraft(id: newId(), updatedAt: DateTime.now().toUtc());

  /// Re-read the draft from storage. Called after publishing a listing, which
  /// clears the stored draft from outside the sell flow.
  void reload() {
    _draft = _drafts.load() ?? _fresh();
    notifyListeners();
  }

  Future<void> _commit(ListingDraft draft) async {
    _draft = draft.copyWith(updatedAt: DateTime.now().toUtc());
    notifyListeners();
    await _drafts.save(_draft);
  }

  // ── Photos ────────────────────────────────────────────────────────────────
  Future<void> addPhotos(List<String> paths) {
    final combined = [..._draft.photoPaths, ...paths];
    final capped = combined.length > 12 ? combined.sublist(0, 12) : combined;
    return _commit(_draft.copyWith(photoPaths: capped));
  }

  Future<void> removePhotoAt(int index) {
    final list = [..._draft.photoPaths]..removeAt(index);
    return _commit(_draft.copyWith(photoPaths: list));
  }

  Future<void> makeCover(int index) {
    final list = [..._draft.photoPaths];
    list.insert(0, list.removeAt(index));
    return _commit(_draft.copyWith(photoPaths: list));
  }

  // newIndex is already adjusted for the removed item (onReorderItem semantics).
  Future<void> reorderPhoto(int oldIndex, int newIndex) {
    final list = [..._draft.photoPaths];
    list.insert(newIndex, list.removeAt(oldIndex));
    return _commit(_draft.copyWith(photoPaths: list));
  }

  Future<void> setVideo(String? path) =>
      _commit(_draft.copyWith(videoPath: path));

  // ── Identity ────────────────────────────────────────────────────────────
  // Changing make clears the dependent model.
  Future<void> setMake(String? make) =>
      _commit(_draft.copyWith(make: make, model: null));
  Future<void> setModel(String? model) =>
      _commit(_draft.copyWith(model: model));
  Future<void> setVariant(String? variant) =>
      _commit(_draft.copyWith(variant: variant));
  Future<void> setYear(int? year) => _commit(_draft.copyWith(year: year));

  // ── Specs ─────────────────────────────────────────────────────────────────
  Future<void> setMileage(int? km) => _commit(_draft.copyWith(mileageKm: km));
  Future<void> setTransmission(Transmission? t) =>
      _commit(_draft.copyWith(transmission: t));
  Future<void> setFuel(FuelType? f) => _commit(_draft.copyWith(fuelType: f));
  Future<void> setBody(BodyType? b) => _commit(_draft.copyWith(bodyType: b));
  Future<void> setColour(String? c) => _commit(_draft.copyWith(colour: c));

  // ── Condition ─────────────────────────────────────────────────────────────
  Future<void> setOwners(int? n) => _commit(_draft.copyWith(ownersCount: n));
  Future<void> setAccidentFree(bool v) =>
      _commit(_draft.copyWith(accidentFree: v));
  Future<void> setRoadTaxExpiry(DateTime? d) =>
      _commit(_draft.copyWith(roadTaxExpiry: d));

  // ── Registration & location ─────────────────────────────────────────────
  // The state picker is filtered by region, so a region change that no longer
  // fits the chosen state clears it.
  Future<void> setRegion(RegistrationRegion? r) {
    final draft = _draft;
    final keepState =
        r != null &&
        draft.state != null &&
        MalaysianStates.inRegion(r).contains(draft.state);
    return _commit(
      draft.copyWith(
        registrationRegion: r,
        state: keepState ? draft.state : null,
      ),
    );
  }

  Future<void> setStateName(String? s) => _commit(_draft.copyWith(state: s));
  Future<void> setCity(String? c) => _commit(_draft.copyWith(city: c));

  // ── Price ─────────────────────────────────────────────────────────────────
  Future<void> setPrice(int? p) => _commit(_draft.copyWith(priceMyr: p));
  Future<void> setNegotiable(bool v) =>
      _commit(_draft.copyWith(negotiable: v));

  // ── Shared ────────────────────────────────────────────────────────────────
  Future<void> setDescription(String? d) =>
      _commit(_draft.copyWith(description: d));
  Future<void> setStep(int step) => _commit(_draft.copyWith(currentStep: step));

  /// Throw the draft away and start fresh.
  Future<void> discard() async {
    await _drafts.clear();
    _draft = _fresh();
    notifyListeners();
  }
}
