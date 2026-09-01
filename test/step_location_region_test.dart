import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/model/listing/listing_draft.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/views/sell/steps/step_location.dart';

/// Seeds the draft and swallows persistence, so the real [SellController]
/// mutation logic can run in a widget test without sqflite.
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

Widget _app(ListingDraft draft) {
  return ChangeNotifierProvider<SellController>(
    create: (_) => SellController(_SeededDraftRepo(draft)),
    child: MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: StepLocation()),
    ),
  );
}

ListingDraft _draft({RegistrationRegion? region, String? state}) =>
    ListingDraft(
      id: 'l1',
      registrationRegion: region,
      state: state,
      updatedAt: DateTime.utc(2026, 3, 12),
    );

GroupedRow _row(WidgetTester tester, String label) => tester.widget<GroupedRow>(
  find.byWidgetPredicate((w) => w is GroupedRow && w.label == label),
);

void main() {
  testWidgets('State row is disabled until a region is chosen', (tester) async {
    await tester.pumpWidget(_app(_draft()));
    await tester.pumpAndSettle();

    expect(_row(tester, 'Region').onTap, isNotNull);
    expect(_row(tester, 'State').onTap, isNull);
  });

  testWidgets('East Malaysia filters the state list', (tester) async {
    await tester.pumpWidget(_app(_draft(region: RegistrationRegion.east)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select')); // the State row
    await tester.pumpAndSettle();

    expect(find.text('Sabah'), findsOneWidget);
    expect(find.text('Sarawak'), findsOneWidget);
    expect(find.text('Selangor'), findsNothing);
    expect(find.text('WP Kuala Lumpur'), findsNothing);
  });

  testWidgets('switching to East clears a West-only state', (tester) async {
    await tester.pumpWidget(
      _app(_draft(region: RegistrationRegion.west, state: 'Selangor')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Selangor'), findsOneWidget); // shown as the State value

    await tester.tap(find.text('West Malaysia')); // open the Region sheet
    await tester.pumpAndSettle();
    await tester.tap(find.text('East Malaysia'));
    await tester.pumpAndSettle();

    // Region updated, incompatible state cleared back to the placeholder.
    expect(find.text('East Malaysia'), findsOneWidget);
    expect(find.text('Selangor'), findsNothing);
    expect(_row(tester, 'State').value, 'Select');
  });
}
