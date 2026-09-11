import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/purchases/purchases_providers.dart';
import 'package:assignment/control/purchases/purchases_repository.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/purchase/purchase.dart';
import 'package:assignment/model/purchase/purchase_with_listing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/views/purchases/purchases_screen.dart';

Purchase _purchase({
  String id = 'p1',
  String? listingId = 'l1',
  int priceMyr = 42000,
  PurchaseMethod method = PurchaseMethod.buyNow,
}) => Purchase(
  id: id,
  buyerId: 'b1',
  sellerId: 's1',
  listingId: listingId,
  priceMyr: priceMyr,
  method: method,
  make: 'Perodua',
  model: 'Myvi',
  year: 2020,
  createdAt: DateTime.utc(2026, 9, 1),
);

final _listing = Listing(
  id: 'l1',
  sellerId: 's1',
  status: ListingStatus.sold,
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
  city: 'Shah Alam',
  priceMyr: 45000,
  createdAt: DateTime.utc(2026, 3, 12),
  updatedAt: DateTime.utc(2026, 9, 1),
);

class _FakePurchases implements PurchasesRepository {
  _FakePurchases(this._result);

  final Result<List<PurchaseWithListing>> _result;

  @override
  Future<Result<List<PurchaseWithListing>>> listMine() async => _result;
}

Widget _app(PurchasesRepository repo) => Provider<PurchasesRepository>.value(
  value: repo,
  child: MaterialApp(theme: AppTheme.light, home: const PurchasesScreen()),
);

void main() {
  group('Purchase model', () {
    test('round-trips through snake_case JSON', () {
      final p = _purchase(method: PurchaseMethod.chatOffer);
      final json = p.toJson();
      expect(json['buyer_id'], 'b1');
      expect(json['price_myr'], 42000);
      expect(json['method'], 'chat_offer');
      expect(json['created_at'], '2026-09-01T00:00:00.000Z');
      expect(Purchase.fromJson(json), p);
    });

    test('title reads year make model', () {
      expect(_purchase().title, '2020 Perodua Myvi');
    });

    test('every method has a wire value and a label', () {
      for (final method in PurchaseMethod.values) {
        expect(method.value, isNotEmpty);
        expect(method.label, isNotEmpty);
        expect(purchaseMethodFromValue(method.value), method);
      }
    });

    test('an unknown method is rejected rather than guessed', () {
      expect(() => purchaseMethodFromValue('barter'), throwsArgumentError);
    });

    test('a deleted listing leaves listingId null', () {
      final p = Purchase.fromJson(_purchase(listingId: null).toJson());
      expect(p.listingId, isNull);
      expect(p.title, '2020 Perodua Myvi');
    });
  });

  group('totalSpentMyr', () {
    test('sums what was actually paid', () {
      final items = [
        PurchaseWithListing(purchase: _purchase(id: 'a', priceMyr: 42000)),
        PurchaseWithListing(purchase: _purchase(id: 'b', priceMyr: 18000)),
      ];
      expect(totalSpentMyr(items), 60000);
    });

    test('is zero with nothing bought', () {
      expect(totalSpentMyr(const []), 0);
    });
  });

  group('PurchasesScreen', () {
    testWidgets('shows an empty state before anything is bought', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_FakePurchases(const Ok([]))));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nothing bought yet'), findsOneWidget);
    });

    testWidgets('lists a purchase with what was paid and how', (tester) async {
      await tester.pumpWidget(
        _app(
          _FakePurchases(
            Ok([
              PurchaseWithListing(
                purchase: _purchase(method: PurchaseMethod.bid),
                listing: _listing,
              ),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2020 Perodua Myvi'), findsOneWidget);
      expect(find.text('RM 42,000'), findsOneWidget);
      expect(find.textContaining('Winning bid'), findsOneWidget);
      expect(find.textContaining('RM 42,000 total'), findsOneWidget);
    });

    testWidgets('a purchase whose listing is gone still renders', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _FakePurchases(
            Ok([PurchaseWithListing(purchase: _purchase(listingId: null))]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2020 Perodua Myvi'), findsOneWidget);
      expect(
        find.textContaining('no longer available'),
        findsOneWidget,
        reason: 'the snapshot keeps the receipt readable',
      );
    });

    testWidgets('surfaces an error with a retry', (tester) async {
      await tester.pumpWidget(
        _app(_FakePurchases(const Err('You are offline.'))),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('You are offline.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
