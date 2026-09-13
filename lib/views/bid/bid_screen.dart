import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_providers.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_auction.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/bid/auction_card.dart';
import 'package:assignment/widgets/bid/bids_offline_banner.dart';
import 'package:assignment/widgets/bid/bid_status_badge.dart';
import 'package:assignment/widgets/common/segmented_control.dart';

class BidScreen extends StatefulWidget {
  const BidScreen({super.key});

  @override
  State<BidScreen> createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  int _segment = 0;

  late Stream<List<AuctionWithListing>> _live;
  late Stream<List<BidWithAuction>> _myBids;
  late Stream<List<AuctionWithListing>> _myAuctions;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    final auth = context.read<AuthRepository>();
    final bids = context.read<BidsRepository>();
    _live = watchLiveAuctions(bids);
    _myBids = watchMyBids(auth, bids);
    _myAuctions = watchMyAuctions(auth, bids);
  }

  void _retry() => setState(_subscribe);

  Future<bool> _deleteAuction(AuctionWithListing entry) async {
    final res = await context.read<BidsRepository>().deleteAuction(
      entry.auction.id,
    );
    if (!mounted) return false;
    switch (res) {
      case Ok():
        return true;
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Bids'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(AppSpacing.searchBarHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              AppSpacing.space12,
            ),
            child: SegmentedControl(
              labels: const ['Live', 'My bids', 'My auctions'],
              selected: _segment,
              onChanged: (i) => setState(() => _segment = i),
            ),
          ),
        ),
      ),
      floatingActionButton: BidsSyncBuilder(
        builder: (context, sync) => FloatingActionButton.extended(
          heroTag: 'bid-start-auction-fab',
          onPressed: sync.online
              ? () => Navigator.pushNamed(context, '/auction/new')
              : null,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          backgroundColor: sync.online
              ? AppColors.primary
              : AppColors.tertiaryLabel,
          foregroundColor: AppColors.onPrimary,
          icon: const Icon(Icons.gavel),
          label: const Text('Start an auction'),
        ),
      ),
      body: IndexedStack(
        index: _segment,
        children: [
          _AuctionList(
            stream: _live,
            onRetry: _retry,
            emptyTitle: 'No live auctions',
            emptyMessage:
                'When someone puts a car up for auction it shows here. '
                'You can start one on a car you are selling.',
          ),
          _MyBidsList(stream: _myBids, onRetry: _retry),
          _AuctionList(
            stream: _myAuctions,
            onRetry: _retry,
            emptyTitle: 'You haven’t run an auction yet',
            emptyMessage:
                'Tap “Start an auction” and pick one of the cars you have '
                'for sale.',
            canDismiss: (e) => e.auction.status != AuctionStatus.running,
            onDismiss: _deleteAuction,
          ),
        ],
      ),
    );
  }
}

class _AuctionList extends StatelessWidget {
  const _AuctionList({
    required this.stream,
    required this.onRetry,
    required this.emptyTitle,
    required this.emptyMessage,
    this.canDismiss,
    this.onDismiss,
  });

  final Stream<List<AuctionWithListing>> stream;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyMessage;
  final bool Function(AuctionWithListing entry)? canDismiss;
  final Future<bool> Function(AuctionWithListing entry)? onDismiss;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<AuctionWithListing>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Couldn’t load auctions',
            message: 'Check your connection and try again.',
            onRetry: onRetry,
          );
        }
        final items = snapshot.data;
        if (items == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (items.isEmpty) {
          return _EmptyState(
            icon: Icons.gavel_outlined,
            title: emptyTitle,
            message: emptyMessage,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.space32 * 2,
          ),
          children: [
            const BidsOfflineBanner(),
            for (final entry in items) ...[
              _tile(context, entry),
              const SizedBox(height: AppSpacing.space12),
            ],
            if (onDismiss != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                child: Text(
                  'Swipe left to delete a finished auction.',
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _tile(BuildContext context, AuctionWithListing entry) {
    final card = AuctionCard(
      entry: entry,
      onTap: () => Navigator.pushNamed(context, '/auction/${entry.auction.id}'),
    );
    final dismiss = onDismiss;
    if (dismiss == null || !(canDismiss?.call(entry) ?? false)) return card;
    return Dismissible(
      key: ValueKey(entry.auction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => dismiss(entry),
      background: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: const ColoredBox(
          color: AppColors.destructive,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: AppSpacing.space16),
              child: Icon(Icons.delete_outline, color: AppColors.onPrimary),
            ),
          ),
        ),
      ),
      child: card,
    );
  }
}

class _MyBidsList extends StatelessWidget {
  const _MyBidsList({required this.stream, required this.onRetry});

  final Stream<List<BidWithAuction>> stream;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<BidWithAuction>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Couldn’t load bids',
            message: 'Check your connection and try again.',
            onRetry: onRetry,
          );
        }
        final all = snapshot.data;
        if (all == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = latestBidPerAuction(all);
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.gavel_outlined,
            title: 'No bids yet',
            message:
                'Open a live auction and place a bid — you’ll be able to '
                'follow it here.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.space32 * 2,
          ),
          children: [
            const BidsOfflineBanner(),
            for (final entry in items) ...[
              _card(context, text, entry),
              const SizedBox(height: AppSpacing.space12),
            ],
          ],
        );
      },
    );
  }

  Widget _card(BuildContext context, TextTheme text, BidWithAuction entry) {
    final leading = entry.isWinning && entry.bid.status.isLive;
    return AuctionCard(
      entry: entry.auction,
      onTap: () =>
          Navigator.pushNamed(context, '/auction/${entry.bid.auctionId}'),
      trailing: entry.hasOutcome
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space8),
              child: BidStatusBadge(status: entry.bid.status),
            )
          : null,
      footer: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.space12),
        child: Text(
          leading
              ? 'Your ${formatPrice(entry.bid.amountMyr)} bid is '
                    'leading.'
              : 'You bid ${formatPrice(entry.bid.amountMyr)}.',
          style: text.footnote.copyWith(
            color: leading ? AppColors.success : AppColors.secondaryLabel,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.iconXl, color: AppColors.tertiaryLabel),
            const SizedBox(height: AppSpacing.space16),
            Text(title, style: text.headline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.subhead.copyWith(color: AppColors.secondaryLabel),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.space16),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
