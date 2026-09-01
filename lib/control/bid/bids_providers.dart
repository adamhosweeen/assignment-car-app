import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/utils/result.dart';

part 'bids_providers.g.dart';

/// Bids the signed-in user has placed, newest first, live over realtime.
/// Empty stream when signed out; re-created when the user changes.
@riverpod
Stream<List<BidWithListing>> myBids(Ref ref) {
  ref.watch(authStateProvider); // rebuild when the signed-in user changes
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(const <BidWithListing>[]);
  return ref.watch(bidsRepositoryProvider).watchMyBids();
}

/// Bids other people have placed on the signed-in user's cars, newest first.
@riverpod
Stream<List<BidWithListing>> bidsReceived(Ref ref) {
  ref.watch(authStateProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(const <BidWithListing>[]);
  return ref.watch(bidsRepositoryProvider).watchBidsReceived();
}

/// Every bid on one listing (seller's per-car view on Listing Detail).
@riverpod
Stream<List<Bid>> bidsForListing(Ref ref, String listingId) =>
    ref.watch(bidsRepositoryProvider).watchBidsForListing(listingId);

/// The signed-in user's live bid on [listingId], or null when they have none.
/// The bid form reads this to switch between "Place your bid" and "Update
/// your bid", and Listing Detail to label its button.
@riverpod
Future<Bid?> myPendingBid(Ref ref, String listingId) async {
  ref.watch(authStateProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;
  final res = await ref
      .watch(bidsRepositoryProvider)
      .myPendingBidFor(listingId);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}

/// How many bids on the signed-in user's cars are still waiting on them —
/// drives the count on the Bid tab's "On my cars" segment.
@riverpod
int pendingBidsReceivedCount(Ref ref) =>
    ref
        .watch(bidsReceivedProvider)
        .value
        ?.where((b) => b.bid.status.isLive)
        .length ??
    0;
