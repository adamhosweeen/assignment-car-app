import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/profile/profile.dart';

Profile _user(String id) =>
    Profile(id: id, email: '$id@example.com', createdAt: DateTime.utc(2026));

ListingDraft _seededDraft() => ListingDraft(
  id: 'draft-A',
  make: 'Perodua',
  model: 'Myvi',
  currentStep: 3,
  updatedAt: DateTime.utc(2026, 9, 1),
);

/// Mutable in-memory stand-in: `clear()` really empties it so `discard()` /
/// `reload()` fall back to a fresh draft.
class _FakeDraftRepo implements DraftRepository {
  _FakeDraftRepo(this._draft);

  ListingDraft? _draft;
  int clearCalls = 0;

  @override
  bool get hasDraft => _draft != null;

  @override
  ListingDraft? load() => _draft;

  @override
  Future<void> save(ListingDraft draft) async => _draft = draft;

  @override
  Future<void> clear() async {
    clearCalls++;
    _draft = null;
  }
}

void main() {
  test('draft survives the first auth emission (same session resume)', () async {
    final repo = _FakeDraftRepo(_seededDraft());
    final auth = StreamController<Profile?>();
    addTearDown(auth.close);

    final sut = SellController(repo, authChanges: auth.stream);
    addTearDown(sut.dispose);

    auth.add(_user('A'));
    await pumpEventQueue();

    expect(repo.clearCalls, 0);
    expect(sut.draft.id, 'draft-A');
    expect(sut.draft.make, 'Perodua');
  });

  test('switching to another account drops the previous draft', () async {
    final repo = _FakeDraftRepo(_seededDraft());
    final auth = StreamController<Profile?>();
    addTearDown(auth.close);

    final sut = SellController(repo, authChanges: auth.stream);
    addTearDown(sut.dispose);

    auth.add(_user('A'));
    await pumpEventQueue();
    auth.add(_user('B'));
    await pumpEventQueue();

    expect(repo.clearCalls, 1);
    expect(sut.draft.id, isNot('draft-A'));
    expect(sut.draft.make, isNull);
    expect(sut.draft.currentStep, 0);
  });

  test('signing out (auth -> null) also drops the draft', () async {
    final repo = _FakeDraftRepo(_seededDraft());
    final auth = StreamController<Profile?>();
    addTearDown(auth.close);

    final sut = SellController(repo, authChanges: auth.stream);
    addTearDown(sut.dispose);

    auth.add(_user('A'));
    await pumpEventQueue();
    auth.add(null);
    await pumpEventQueue();

    expect(repo.clearCalls, 1);
    expect(sut.draft.make, isNull);
  });

  test('re-emitting the same user does not touch the draft', () async {
    final repo = _FakeDraftRepo(_seededDraft());
    final auth = StreamController<Profile?>();
    addTearDown(auth.close);

    final sut = SellController(repo, authChanges: auth.stream);
    addTearDown(sut.dispose);

    auth.add(_user('A'));
    await pumpEventQueue();
    auth.add(_user('A')); // e.g. a token refresh
    await pumpEventQueue();

    expect(repo.clearCalls, 0);
    expect(sut.draft.id, 'draft-A');
  });
}
