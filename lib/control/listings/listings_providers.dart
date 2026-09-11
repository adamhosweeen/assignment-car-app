import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/model/listing/listing.dart';

Stream<List<Listing>> watchActiveListings(ListingsRepository listings) =>
    listings.watchActive();

Stream<List<Listing>> watchMyListings(
  AuthRepository auth,
  ListingsRepository listings,
) {
  final user = auth.currentUser;
  if (user == null) return Stream.value(const <Listing>[]);
  return listings.watchBySeller(user.id);
}

Stream<List<Listing>> watchSellerListings(
  ListingsRepository listings,
  String sellerId,
) => listings.watchActiveBySeller(sellerId);

Future<List<Listing>> searchListings(
  ListingsRepository listings,
  String query,
) async {
  if (query.trim().isEmpty) return const [];
  final res = await listings.searchActive(query);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}

Future<Listing> fetchListingById(ListingsRepository listings, String id) async {
  final res = await listings.getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}
