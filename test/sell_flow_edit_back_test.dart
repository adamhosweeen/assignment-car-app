import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/sell/sell_flow_screen.dart';

/// A [SellController] that skips sqflite persistence: [build] returns a fixed
/// draft and [setStep] just moves the in-memory step.
class _FakeSellController extends SellController {
  _FakeSellController(this._draft);

  final ListingDraft _draft;

  @override
  ListingDraft build() => _draft;

  @override
  Future<void> setStep(int step) async {
    state = state.copyWith(currentStep: step);
  }
}

ListingDraft _draftAtReview() => ListingDraft(
  id: 'l1',
  make: 'Perodua',
  model: 'Myvi',
  year: 2020,
  mileageKm: 38000,
  transmission: Transmission.automatic,
  fuelType: FuelType.petrol,
  bodyType: BodyType.hatchback,
  colour: 'White',
  ownersCount: 1,
  accidentFree: true,
  registrationRegion: RegistrationRegion.peninsular,
  state: 'Selangor',
  city: 'Petaling Jaya',
  priceMyr: 45000,
  currentStep: 6,
  updatedAt: DateTime.utc(2026, 3, 12),
);

Future<void> _pumpEditFlow(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/listing',
    routes: [
      GoRoute(
        path: '/listing',
        builder: (_, _) => const Scaffold(body: Text('LISTING PAGE')),
      ),
      GoRoute(
        path: '/sell/new',
        builder: (_, state) => SellFlowScreen(editing: state.extra == true),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sellControllerProvider.overrideWith(
          () => _FakeSellController(_draftAtReview()),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  router.push('/sell/new', extra: true);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('edit mode opens on the review step', (tester) async {
    await _pumpEditFlow(tester);
    expect(find.text('Review & publish'), findsOneWidget);
  });

  testWidgets('Back from review leaves the flow (returns to the listing)', (
    tester,
  ) async {
    await _pumpEditFlow(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.text('LISTING PAGE'), findsOneWidget);
    expect(find.text('Review & publish'), findsNothing);
  });

  testWidgets('Back from a jumped-to section returns to review, not the '
      'previous step', (tester) async {
    await _pumpEditFlow(tester);

    // Jump into a section from the review screen (the first "Edit" → Car).
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    expect(find.text('Review & publish'), findsNothing);
    expect(find.text('Car identity'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // Back on review — did not walk to step 4/step 3/etc. and did not exit.
    expect(find.text('Review & publish'), findsOneWidget);
    expect(find.text('LISTING PAGE'), findsNothing);
  });
}
