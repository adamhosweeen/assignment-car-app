import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/model/listing/listing.dart';

/// Queries the listings screens run against [ListingsRepository].
///
/// Each one is called from a screen's `initState` and held in its [State], so
/// a rebuild never re-issues the request; a `StreamBuilder`/`FutureBuilder`
/// turns it into loading, error and data. The `Result` unwrapping lives here
/// so every screen surfaces the same repository message.

/// All active listings, newest first (Buy feed). Backed by the realtime
/// stream.
Stream<List<Listing>> watchActiveListings(ListingsRepository listings) =>
    listings.watchActive();

/// The signed-in user's own listings (My Listings). Empty when signed out.
Stream<List<Listing>> watchMyListings(
  AuthRepository auth,
  ListingsRepository listings,
) {
  final user = auth.currentUser;
  if (user == null) return Stream.value(const <Listing>[]);
  return listings.watchBySeller(user.id);
}

/// Another seller's active listings (public seller page). Realtime-backed.
Stream<List<Listing>> watchSellerListings(
  ListingsRepository listings,
  String sellerId,
) => listings.watchActiveBySeller(sellerId);

/// Car search on the Buy tab. Empty query → empty list, no request.
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

/// A single listing by id (Listing detail).
Future<Listing> fetchListingById(
  ListingsRepository listings,
  String id,
) async {
  final res = await listings.getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}
