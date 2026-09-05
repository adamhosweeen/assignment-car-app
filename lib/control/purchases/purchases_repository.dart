import 'package:assignment/model/purchase/purchase_with_listing.dart';
import 'package:assignment/utils/result.dart';

abstract interface class PurchasesRepository {
  Future<Result<List<PurchaseWithListing>>> listMine();
}
