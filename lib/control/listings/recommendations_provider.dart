import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/profile/profile.dart';

part 'recommendations_provider.g.dart';

/// Listings recommended for the signed-in user, scored client-side against
/// their saved car interests and location — no extra backend query; it reuses
/// the already-streamed active listings.
@riverpod
List<Listing> recommendedListings(Ref ref) {
  final profile = ref.watch(authStateProvider).value;
  if (profile == null) return const [];
  final listings = ref.watch(activeListingsProvider).value ?? const <Listing>[];
  return rankRecommended(listings, profile);
}

/// Deterministic interest scoring: brand +3, body type +2, within budget +2,
/// same state +2, fuel +1, transmission +1. Listings scoring at least 1 are
/// returned best-first (ties broken newest-first, then by id); the user's own
/// listings never appear. Top-level so tests can call it directly.
List<Listing> rankRecommended(
  List<Listing> listings,
  Profile profile, {
  int limit = 10,
}) {
  final interests = profile.interests;
  if (interests.isEmpty && profile.state == null) return const [];

  final scored = <(Listing, int)>[];
  for (final listing in listings) {
    if (listing.sellerId == profile.id) continue;
    var score = 0;
    if (interests.makes.contains(listing.make)) score += 3;
    if (interests.bodyTypes.contains(listing.bodyType)) score += 2;
    final min = interests.budgetMinMyr;
    final max = interests.budgetMaxMyr;
    if ((min != null || max != null) &&
        (min == null || listing.priceMyr >= min) &&
        (max == null || listing.priceMyr <= max)) {
      score += 2;
    }
    if (profile.state != null && listing.state == profile.state) score += 2;
    if (interests.fuelType == listing.fuelType) score += 1;
    if (interests.transmission == listing.transmission) score += 1;
    if (score >= 1) scored.add((listing, score));
  }

  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    if (byScore != 0) return byScore;
    final byDate = b.$1.createdAt.compareTo(a.$1.createdAt);
    if (byDate != 0) return byDate;
    return a.$1.id.compareTo(b.$1.id);
  });

  return [for (final (listing, _) in scored.take(limit)) listing];
}
