import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/model/user/car_interests.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/user/car_interest_fields.dart';

const _tooHigh = 'That’s too high. Enter an amount under RM 100,000,000.';
const _belowMinimum = 'Enter an amount more than RM 1,000.';
const _maxBelowMin = 'The maximum can’t be lower than the minimum.';

CarInterests _budget({int? min, int? max}) =>
    CarInterests(budgetMinMyr: min, budgetMaxMyr: max);

void main() {
  group('rules', () {
    test('no budget at all is fine: it is optional', () {
      expect(CarInterestFields.isBudgetValid(const CarInterests()), isTrue);
    });

    test('only a minimum or only a maximum is fine', () {
      expect(CarInterestFields.isBudgetValid(_budget(min: 30000)), isTrue);
      expect(CarInterestFields.isBudgetValid(_budget(max: 80000)), isTrue);
    });

    test('equal minimum and maximum is fine', () {
      expect(
        CarInterestFields.isBudgetValid(_budget(min: 50000, max: 50000)),
        isTrue,
      );
    });

    test('RM 1,000 or less is refused on either side, even alone', () {
      expect(CarInterestFields.budgetMinError(_budget(min: 0)), _belowMinimum);
      expect(
        CarInterestFields.budgetMinError(_budget(min: 1000)),
        _belowMinimum,
      );
      expect(
        CarInterestFields.budgetMaxError(_budget(max: 1000)),
        _belowMinimum,
      );
      expect(CarInterestFields.isBudgetValid(_budget(min: 1000)), isFalse);
    });

    test('anything above RM 1,000 is allowed', () {
      expect(CarInterestFields.budgetMinError(_budget(min: 1001)), isNull);
      expect(CarInterestFields.budgetMaxError(_budget(max: 1001)), isNull);
    });

    test('the same ceiling as a listing price', () {
      expect(
        CarInterestFields.budgetMinError(_budget(min: kMaxPriceMyr)),
        isNull,
      );
      expect(
        CarInterestFields.budgetMinError(_budget(min: kMaxPriceMyr + 1)),
        _tooHigh,
      );
      expect(
        CarInterestFields.budgetMaxError(_budget(max: kMaxPriceMyr + 1)),
        _tooHigh,
      );
    });

    test('a maximum below the minimum is flagged on the maximum', () {
      final i = _budget(min: 80000, max: 30000);
      expect(CarInterestFields.budgetMinError(i), isNull);
      expect(CarInterestFields.budgetMaxError(i), _maxBelowMin);
      expect(CarInterestFields.isBudgetValid(i), isFalse);
    });

    test('an invalid minimum is reported once, not also on the maximum', () {
      final i = _budget(min: kMaxPriceMyr + 1, max: 30000);
      expect(CarInterestFields.budgetMinError(i), _tooHigh);
      expect(CarInterestFields.budgetMaxError(i), isNull);
    });
  });

  group('CarInterestFields', () {
    Future<List<CarInterests>> pump(WidgetTester tester) async {
      final emitted = <CarInterests>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) => CarInterestFields(
                  value: emitted.isEmpty ? const CarInterests() : emitted.last,
                  onChanged: (v) => setState(() => emitted.add(v)),
                ),
              ),
            ),
          ),
        ),
      );
      return emitted;
    }

    Finder budgetField(String hint) =>
        find.byType(TextField).at(hint == 'Min' ? 0 : 1);

    testWidgets('errors appear under the field as you type', (tester) async {
      await pump(tester);

      await tester.enterText(budgetField('Min'), '80000');
      await tester.enterText(budgetField('Max'), '30000');
      await tester.pump();
      expect(find.text(_maxBelowMin), findsOneWidget);

      await tester.enterText(budgetField('Max'), '90000');
      await tester.pump();
      expect(find.text(_maxBelowMin), findsNothing);

      await tester.enterText(budgetField('Min'), '0');
      await tester.pump();
      expect(find.text(_belowMinimum), findsOneWidget);
    });

    testWidgets('shows RM on both fields, like the listing price', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('RM'), findsNWidgets(2));
    });

    testWidgets('a huge number is capped, never silently cleared', (
      tester,
    ) async {
      final emitted = await pump(tester);

      await tester.enterText(budgetField('Min'), '99999999999999999999');
      await tester.pump();

      final field = tester.widget<TextField>(budgetField('Min'));
      expect(field.controller!.text.length, 9);
      expect(emitted.last.budgetMinMyr, 999999999);
      expect(find.text(_tooHigh), findsOneWidget);
    });

    testWidgets('only digits can be typed', (tester) async {
      await pump(tester);
      final field = tester.widget<TextField>(budgetField('Min'));
      expect(
        field.inputFormatters!.whereType<FilteringTextInputFormatter>(),
        isNotEmpty,
      );
    });
  });
}
