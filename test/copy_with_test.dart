import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';

void main() {
  final now = DateTime.utc(2026, 9, 5);

  group('copyWith omits vs. clears', () {
    test('an omitted argument keeps the current value', () {
      final draft = ListingDraft(
        id: 'd1',
        make: 'Perodua',
        model: 'Myvi',
        updatedAt: now,
      );
      expect(draft.copyWith(year: 2020).make, 'Perodua');
      expect(draft.copyWith(year: 2020).model, 'Myvi');
    });

    test('an explicit null clears a nullable field', () {
      final draft = ListingDraft(
        id: 'd1',
        make: 'Perodua',
        model: 'Myvi',
        updatedAt: now,
      );
      expect(draft.copyWith(model: null).model, isNull);
      expect(draft.copyWith(model: null).make, 'Perodua');
    });

    test('changing the make clears the dependent model', () {
      final draft = ListingDraft(
        id: 'd1',
        make: 'Perodua',
        model: 'Myvi',
        updatedAt: now,
      );
      final next = draft.copyWith(make: 'Proton', model: null);
      expect(next.make, 'Proton');
      expect(next.model, isNull);
    });

    test('changing the region can clear the state', () {
      final draft = ListingDraft(
        id: 'd1',
        registrationRegion: RegistrationRegion.east,
        state: 'Sabah',
        updatedAt: now,
      );
      final next = draft.copyWith(
        registrationRegion: RegistrationRegion.west,
        state: null,
      );
      expect(next.registrationRegion, RegistrationRegion.west);
      expect(next.state, isNull);
    });

    test('clearing the budget box clears the budget', () {
      const interests = CarInterests(budgetMinMyr: 20000, budgetMaxMyr: 80000);
      final cleared = interests.copyWith(budgetMinMyr: null);
      expect(cleared.budgetMinMyr, isNull);
      expect(cleared.budgetMaxMyr, 80000);
    });

    test('deselecting a picker clears the enum', () {
      const interests = CarInterests(transmission: Transmission.automatic);
      expect(interests.copyWith(transmission: null).transmission, isNull);
    });

    test('registration state clears the date of birth', () {
      final state = RegistrationState(dob: DateTime.utc(2000, 1, 1));
      expect(state.copyWith(dob: null).dob, isNull);
      expect(state.copyWith(phoneInput: '0123').dob, isNotNull);
    });
  });

  group('value equality', () {
    test('two identically-built models are equal', () {
      final a = Profile(id: 'u1', email: 'a@b.my', createdAt: now);
      final b = Profile(id: 'u1', email: 'a@b.my', createdAt: now);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a copyWith that changes a field is not equal', () {
      final a = Profile(id: 'u1', email: 'a@b.my', createdAt: now);
      expect(a.copyWith(role: 'admin'), isNot(a));
    });

    test('collections compare by content, not identity', () {
      const a = CarInterests(makes: ['Perodua', 'Proton']);
      const b = CarInterests(makes: ['Perodua', 'Proton']);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const CarInterests(makes: ['Proton', 'Perodua'])));
    });
  });
}
