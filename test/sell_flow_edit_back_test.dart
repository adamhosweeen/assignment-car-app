import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/sell/sell_flow_screen.dart';

class _SeededDraftRepo implements DraftRepository {
  _SeededDraftRepo(this._draft);

  final ListingDraft _draft;

  @override
  bool get hasDraft => true;

  @override
  ListingDraft? load() => _draft;

  @override
  Future<void> save(ListingDraft draft) async {}

  @override
  Future<void> clear() async {}
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
  registrationRegion: RegistrationRegion.west,
  state: 'Selangor',
  city: 'Petaling Jaya',
  priceMyr: 45000,
  currentStep: 6,
  updatedAt: DateTime.utc(2026, 3, 12),
);

Future<void> _pumpEditFlow(WidgetTester tester) async {
  final navigator = AppNavigator();

  await tester.pumpWidget(
    ChangeNotifierProvider<SellController>(
      create: (_) => SellController(_SeededDraftRepo(_draftAtReview())),
      child: MaterialApp(
        theme: AppTheme.light,
        navigatorKey: navigator.key,
        navigatorObservers: [navigator.tracker],
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => SellFlowScreen(editing: settings.arguments == true),
        ),
        home: const Scaffold(body: Text('LISTING PAGE')),
      ),
    ),
  );
  await tester.pumpAndSettle();

  navigator.key.currentState!.pushNamed('/sell/new', arguments: true);
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

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    expect(find.text('Review & publish'), findsNothing);
    expect(find.text('Car identity'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.text('Review & publish'), findsOneWidget);
    expect(find.text('LISTING PAGE'), findsNothing);
  });
}
