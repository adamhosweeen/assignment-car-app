library;

import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/utils/formatters.dart';

const int kMinBidMyr = 100;

const int kMinIncrementMyr = 100;

const List<Duration> kAuctionDurations = [
  Duration(hours: 1),
  Duration(hours: 6),
  Duration(hours: 12),
  Duration(days: 1),
  Duration(days: 3),
  Duration(days: 7),
];

String auctionDurationLabel(Duration d) {
  if (d.inHours < 24) return '${d.inHours} hour${d.inHours == 1 ? '' : 's'}';
  final days = d.inDays;
  return '$days day${days == 1 ? '' : 's'}';
}

/// The longest an auction may run, counted from when it started. Mirrors the
/// 7-day cap enforced by `start_auction` and `extend_auction`.
const Duration kMaxAuctionRun = Duration(days: 7);

/// What a seller may add to a running auction's deadline. No 7-day entry:
/// nothing can be extended by the whole cap.
const List<Duration> kAuctionExtensions = [
  Duration(hours: 1),
  Duration(hours: 6),
  Duration(hours: 12),
  Duration(days: 1),
  Duration(days: 3),
];

/// How much further this auction's deadline may still be pushed before the
/// run hits [kMaxAuctionRun]. Zero once there is no room left.
Duration extensionHeadroom(Auction auction) {
  final latest = auction.createdAt.add(kMaxAuctionRun);
  final room = latest.difference(auction.endsAt);
  return room.isNegative ? Duration.zero : room;
}

/// The extensions still on offer: those that fit inside [extensionHeadroom].
/// Empty means the auction is already running for as long as it is allowed to.
List<Duration> extensionOptions(Auction auction) {
  final room = extensionHeadroom(auction);
  return [
    for (final d in kAuctionExtensions)
      if (d <= room) d,
  ];
}

/// Extending is the one change a seller may make to a running auction, and
/// only forwards — see `extend_auction`. It needs a live auction with room
/// left inside the 7-day cap.
bool canExtendAuction(Auction auction, String userId, {DateTime? now}) =>
    auction.isSeller(userId) &&
    auction.isLive(now: now) &&
    extensionOptions(auction).isNotEmpty;

String auctionExtensionLabel(Duration d) => '+${auctionDurationLabel(d)}';

int? parseBidAmount(String raw) {
  final digits = raw.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return null;
  final value = int.tryParse(digits);
  if (value == null || value <= 0) return null;
  return value;
}

String? validateBidAmount(String raw, {required int minimumMyr}) {
  if (raw.trim().isEmpty) return 'Enter how much you want to bid.';

  final value = parseBidAmount(raw);
  if (value == null) return 'Enter a valid amount in Ringgit, e.g. 45000.';

  if (value > kMaxPriceMyr) {
    return 'That’s too high. Enter an amount under ${formatPrice(kMaxPriceMyr)}.';
  }
  if (value < minimumMyr) {
    return 'Bid at least ${formatPrice(minimumMyr)}.';
  }
  return null;
}

String? validateStartingPrice(String raw) {
  if (raw.trim().isEmpty) return 'Enter a starting price.';
  final value = parseBidAmount(raw);
  if (value == null) return 'Enter a valid amount in Ringgit, e.g. 30000.';
  if (value < kMinBidMyr) {
    return 'Start at ${formatPrice(kMinBidMyr)} or more.';
  }
  if (value > kMaxPriceMyr) {
    return 'That’s too high. Enter an amount under ${formatPrice(kMaxPriceMyr)}.';
  }
  return null;
}

String? validateIncrement(String raw) {
  if (raw.trim().isEmpty) return 'Enter a minimum increment.';
  final value = parseBidAmount(raw);
  if (value == null) return 'Enter a valid amount in Ringgit, e.g. 500.';
  if (value < kMinIncrementMyr) {
    return 'The increment has to be at least ${formatPrice(kMinIncrementMyr)}.';
  }
  if (value > kMaxPriceMyr) {
    return 'That increment is too large.';
  }
  return null;
}

String formatCountdown(Duration left) {
  if (left <= Duration.zero) return 'Ended';
  if (left.inDays > 0) {
    final hours = left.inHours % 24;
    return '${left.inDays}d ${hours}h left';
  }
  if (left.inHours > 0) {
    final minutes = left.inMinutes % 60;
    return '${left.inHours}h ${minutes}m left';
  }
  if (left.inMinutes > 0) return '${left.inMinutes}m left';
  return 'Ending now';
}
