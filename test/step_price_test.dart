import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/sell/steps/step_price.dart';

class _FakeSellController extends SellController {
  _FakeSellController(this._draft);

  final ListingDraft _draft;

  @override
  ListingDraft build() => _draft;

  @override
  Future<void> setPrice(int? p) async {
    state = state.copyWith(priceMyr: p);
  }
}

Future<void> _pump(WidgetTester tester, {int? price}) {
  final draft = ListingDraft(
    id: 'l1',
    priceMyr: price,
    updatedAt: DateTime.utc(2026, 3, 12),
  );
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        sellControllerProvider.overrideWith(() => _FakeSellController(draft)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: StepPrice()),
      ),
    ),
  );
}

void main() {
  testWidgets('RM prefix shows on an empty, unfocused price field', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'RM'), findsOneWidget);
  });

  testWidgets('RM prefix stays once a price is typed', (tester) async {
    await _pump(tester, price: 48000);
    await tester.pumpAndSettle();

    final priceField = tester.widget<TextField>(find.byType(TextField).first);
    expect(priceField.controller?.text, '48000');
    expect(find.widgetWithText(TextField, 'RM'), findsOneWidget);
  });
}
