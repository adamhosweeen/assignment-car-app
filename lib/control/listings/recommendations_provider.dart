import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/profile/profile.dart';

/// Listings recommended for the signed-in user, matched client-side against
/// their saved car interests and location — no extra backend query; it reuses
/// the active listings the Buy feed is already streaming.
List<Listing> recommendedListings(Profile? profile, List<Listing>? listings) {
  if (profile == null) return const [];
  return rankRecommended(listings ?? const <Listing>[], profile);
}

/// Deterministic matching. A listing is recommended only when it satisfies
/// **every** preference the buyer has actually set — brands, body types,
/// budget — so the row never shows a brand or a price the buyer ruled out.
/// Buyers who set none of those get listings in their own state instead.
///
/// Among the matches, location (+2), fuel type (+1) and transmission (+1)
/// decide the order, then newest-first, then id. Fuel and transmission never
/// qualify a car on their own (almost every car is automatic petrol). The
/// buyer's own listings never appear. Top-level so tests can call it directly.
List<Listing> rankRecommended(
  List<Listing> listings,
  Profile profile, {
  int limit = 10,
}) {
  final interests = profile.interests;
  final min = interests.budgetMinMyr;
  final max = interests.budgetMaxMyr;
  final hasBudget = min != null || max != null;
  // "Primary" preferences describe the car itself. Without any, fall back to
  // "near you"; without a state either there is nothing to recommend on.
  final hasPrimary =
      interests.makes.isNotEmpty || interests.bodyTypes.isNotEmpty || hasBudget;
  if (!hasPrimary && profile.state == null) return const [];

  final scored = <(Listing, int)>[];
  for (final listing in listings) {
    if (listing.sellerId == profile.id) continue;

    final sameState = profile.state != null && listing.state == profile.state;
    if (hasPrimary) {
      if (interests.makes.isNotEmpty &&
          !interests.makes.contains(listing.make)) {
        continue;
      }
      if (interests.bodyTypes.isNotEmpty &&
          !interests.bodyTypes.contains(listing.bodyType)) {
        continue;
      }
      if (hasBudget &&
          ((min != null && listing.priceMyr < min) ||
              (max != null && listing.priceMyr > max))) {
        continue;
      }
    } else if (!sameState) {
      continue;
    }

    var score = 0;
    if (sameState) score += 2;
    if (interests.fuelType != null && interests.fuelType == listing.fuelType) {
      score += 1;
    }
    if (interests.transmission != null &&
        interests.transmission == listing.transmission) {
      score += 1;
    }
    scored.add((listing, score));
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
