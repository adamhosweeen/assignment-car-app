import 'package:assignment/utils/result.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart';

abstract interface class ListingsRepository {
  Stream<List<Listing>> watchActive();

  Stream<List<Listing>> watchBySeller(String sellerId);

  Stream<List<Listing>> watchActiveBySeller(String sellerId);

  Future<Result<List<Listing>>> searchActive(String query);

  Future<Result<Listing>> getById(String id);

  Future<Result<Listing>> publish(ListingDraft draft, String sellerId);

  Future<Result<void>> markSold(String id);

  Future<Result<void>> buy(String id);

  Future<Result<void>> hide(String id);

  Future<Result<void>> unhide(String id);

  Future<Result<void>> deleteListing(String id);
}
