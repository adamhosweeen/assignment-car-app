import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/listing/listing_card.dart';
import 'package:assignment/widgets/listing/listing_card_compact.dart';

final _listing = Listing(
  id: 'l1',
  sellerId: 's1',
  status: ListingStatus.active,
  make: 'Perodua',
  model: 'Myvi',
  variant: '1.5 AV',
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
  createdAt: DateTime.utc(2026, 3, 12),
  updatedAt: DateTime.utc(2026, 3, 12),
);

/// A stand-in cover with the real cover height so layout matches the app.
Widget _cover(double height) => SizedBox(
  width: double.infinity,
  height: height,
  child: const ColoredBox(color: Colors.grey),
);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: child,
    ),
  ),
);

void main() {
  testWidgets('ListingCard shows price, title, mileage · state, date', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ListingCard(
          listing: _listing,
          cover: _cover(AppSpacing.coverHeight),
          trailing: const Icon(Icons.more_horiz),
        ),
      ),
    );

    expect(find.text('RM 45,000'), findsOneWidget);
    expect(find.text('2020 Perodua Myvi 1.5 AV'), findsOneWidget);
    expect(find.text('38,000 km · Selangor'), findsOneWidget);
    expect(find.text('12 Mar 2026'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ListingCardCompact fits inside the recommended row height', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SizedBox(
          height: AppSpacing.recommendRowHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ListingCardCompact(
                listing: _listing,
                cover: _cover(AppSpacing.recommendCoverHeight),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('RM 45,000'), findsOneWidget);
    expect(find.text('2020 Perodua Myvi 1.5 AV'), findsOneWidget);
    // A RenderFlex overflow would surface here as a FlutterError.
    expect(tester.takeException(), isNull);

    final card = tester.getSize(find.byType(ListingCardCompact));
    expect(card.width, AppSpacing.recommendCardWidth);
    expect(card.height, lessThanOrEqualTo(AppSpacing.recommendRowHeight));
  });
}
