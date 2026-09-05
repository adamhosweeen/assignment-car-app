import 'package:assignment/control/purchases/purchases_repository.dart';
import 'package:assignment/model/purchase/purchase_with_listing.dart';
import 'package:assignment/utils/result.dart';

class PurchasesException implements Exception {
  const PurchasesException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<List<PurchaseWithListing>> fetchMyPurchases(
  PurchasesRepository purchases,
) async {
  final res = await purchases.listMine();
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw PurchasesException(message),
  };
}

int totalSpentMyr(List<PurchaseWithListing> purchases) =>
    purchases.fold(0, (sum, p) => sum + p.purchase.priceMyr);
