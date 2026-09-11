import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/user/app_user.dart';

List<Listing> recommendedListings(AppUser? profile, List<Listing>? listings) {
  if (profile == null) return const [];
  return rankRecommended(listings ?? const <Listing>[], profile);
}

List<Listing> rankRecommended(
  List<Listing> listings,
  AppUser profile, {
  int limit = 10,
}) {
  final interests = profile.interests;
  final min = interests.budgetMinMyr;
  final max = interests.budgetMaxMyr;
  final hasBudget = min != null || max != null;
  final hasPrimary =
      interests.makes.isNotEmpty || interests.bodyTypes.isNotEmpty || hasBudget;
  if (!hasPrimary) return const [];

  final scored = <(Listing, int)>[];
  for (final listing in listings) {
    if (listing.sellerId == profile.id) continue;

    if (interests.makes.isNotEmpty && !interests.makes.contains(listing.make)) {
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

    final sameState = profile.state != null && listing.state == profile.state;
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
