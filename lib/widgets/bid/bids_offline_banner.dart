import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/bids_sync_status.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/inline_notice.dart';

/// Says the auction data on screen came from SQLite rather than the server.
///
/// Worth its own line because an auction is the one thing in this app where
/// age changes meaning: a price from ten minutes ago may already have been
/// beaten, and the countdown beside it is still ticking down convincingly.
/// Nothing here is an error — the data is real, just not current — so it reads
/// as information, and the write buttons are what actually get withheld.
class BidsOfflineBanner extends StatelessWidget {
  const BidsOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BidsSyncBuilder(
      builder: (context, status) {
        if (status.online) return const SizedBox.shrink();
        final since = status.lastSyncedAt;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space16),
          child: InlineNotice(
            // formatRelative yields "Just now" / "5m" / "12 Sep 2026", so it
            // is placed after "Last updated" rather than glued to an "ago".
            text: since == null
                ? 'You’re offline. Showing saved auctions — prices and '
                      'countdowns may have moved on.'
                : 'You’re offline. Last updated ${formatRelative(since)}. '
                      'Prices and countdowns may have moved on.',
          ),
        );
      },
    );
  }
}

/// Rebuilds on every change to the bidding module's sync state.
///
/// Screens use it for the other half of being offline: a write composed
/// against stale data is a write the server would reject anyway, so the
/// buttons that start one are disabled rather than left to fail.
class BidsSyncBuilder extends StatelessWidget {
  const BidsSyncBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, BidsSyncStatus status) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BidsSyncStatus>(
      valueListenable: context.read<BidsRepository>().syncStatus,
      builder: (context, status, _) => builder(context, status),
    );
  }
}
