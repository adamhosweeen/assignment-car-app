import 'package:flutter/foundation.dart';

import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/malaysian_states.dart';

class SellController extends ChangeNotifier {
  SellController(this._drafts) : _draft = _drafts.load() ?? _fresh();

  final DraftRepository _drafts;
  ListingDraft _draft;

  ListingDraft get draft => _draft;

  static ListingDraft _fresh() =>
      ListingDraft(id: newId(), updatedAt: DateTime.now().toUtc());

  void reload() {
    _draft = _drafts.load() ?? _fresh();
    notifyListeners();
  }

  Future<void> _commit(ListingDraft draft) async {
    _draft = draft.copyWith(updatedAt: DateTime.now().toUtc());
    notifyListeners();
    await _drafts.save(_draft);
  }

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

  Future<void> reorderPhoto(int oldIndex, int newIndex) {
    final list = [..._draft.photoPaths];
    list.insert(newIndex, list.removeAt(oldIndex));
    return _commit(_draft.copyWith(photoPaths: list));
  }

  Future<void> setVideo(String? path) =>
      _commit(_draft.copyWith(videoPath: path));

  Future<void> setMake(String? make) =>
      _commit(_draft.copyWith(make: make, model: null));
  Future<void> setModel(String? model) =>
      _commit(_draft.copyWith(model: model));
  Future<void> setVariant(String? variant) =>
      _commit(_draft.copyWith(variant: variant));
  Future<void> setYear(int? year) => _commit(_draft.copyWith(year: year));

  Future<void> setMileage(int? km) => _commit(_draft.copyWith(mileageKm: km));
  Future<void> setTransmission(Transmission? t) =>
      _commit(_draft.copyWith(transmission: t));
  Future<void> setFuel(FuelType? f) => _commit(_draft.copyWith(fuelType: f));
  Future<void> setBody(BodyType? b) => _commit(_draft.copyWith(bodyType: b));
  Future<void> setColour(String? c) => _commit(_draft.copyWith(colour: c));

  Future<void> setOwners(int? n) => _commit(_draft.copyWith(ownersCount: n));
  Future<void> setAccidentFree(bool v) =>
      _commit(_draft.copyWith(accidentFree: v));
  Future<void> setRoadTaxExpiry(DateTime? d) =>
      _commit(_draft.copyWith(roadTaxExpiry: d));

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

  Future<void> setPrice(int? p) => _commit(_draft.copyWith(priceMyr: p));
  Future<void> setNegotiable(bool v) => _commit(_draft.copyWith(negotiable: v));

  Future<void> setDescription(String? d) =>
      _commit(_draft.copyWith(description: d));
  Future<void> setStep(int step) => _commit(_draft.copyWith(currentStep: step));

  Future<void> discard() async {
    await _drafts.clear();
    _draft = _fresh();
    notifyListeners();
  }
}
