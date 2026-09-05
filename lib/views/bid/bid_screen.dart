import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_providers.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_with_listing.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/bid/bid_card.dart';
import 'package:assignment/widgets/common/segmented_control.dart';

class BidScreen extends StatefulWidget {
  const BidScreen({super.key});

  @override
  State<BidScreen> createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  int _segment = 0;

  late Stream<List<BidWithListing>> _myBids;
  late Stream<List<BidWithListing>> _received;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    final auth = context.read<AuthRepository>();
    final bids = context.read<BidsRepository>();
    _myBids = watchMyBids(auth, bids);
    _received = watchBidsReceived(auth, bids);
  }

  void _retry() => setState(_subscribe);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BidWithListing>>(
      stream: _received,
      builder: (context, received) {
        final pending = pendingBidsReceivedCount(received.data);
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
                  labels: [
                    'My bids',
                    pending > 0 ? 'On my cars ($pending)' : 'On my cars',
                  ],
                  selected: _segment,
                  onChanged: (i) => setState(() => _segment = i),
                ),
              ),
            ),
          ),
          body: _segment == 0
              ? _MyBidsList(stream: _myBids, onRetry: _retry)
              : _ReceivedList(snapshot: received, onRetry: _retry),
        );
      },
    );
  }
}

class _MyBidsList extends StatelessWidget {
  const _MyBidsList({required this.stream, required this.onRetry});

  final Stream<List<BidWithListing>> stream;
  final VoidCallback onRetry;

  Future<void> _withdraw(BuildContext context, BidWithListing entry) async {
    final confirmed = await _confirm(
      context,
      title: 'Withdraw bid?',
      message:
          'Your ${formatPrice(entry.bid.amountMyr)} bid on the '
          '${entry.listing.title} will be withdrawn. You can bid again later '
          'while the car is still for sale.',
      confirmLabel: 'Withdraw',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final res = await context.read<BidsRepository>().withdrawBid(entry.bid.id);
    if (!context.mounted) return;
    if (res case Err(:final message)) {
      _toast(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BidList(
      stream: stream,
      emptyTitle: 'No bids yet',
      emptyMessage:
          'Find a car in the Buy tab and place a bid — the seller can accept, '
          'reject, or let you know they want more.',
      onRetry: onRetry,
      cardBuilder: (entry) => BidCard(
        entry: entry,
        subtitle: 'Placed ${formatRelative(entry.bid.createdAt)}',
        onOpenListing: () => context.push('/listing/${entry.listing.id}'),
        actions: [
          if (entry.bid.status.isLive)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groupedBackground,
                foregroundColor: AppColors.destructive,
              ),
              onPressed: () => _withdraw(context, entry),
              child: const Text('Withdraw'),
            ),
        ],
      ),
    );
  }
}

class _ReceivedList extends StatelessWidget {
  const _ReceivedList({required this.snapshot, required this.onRetry});

  final AsyncSnapshot<List<BidWithListing>> snapshot;
  final VoidCallback onRetry;

  Future<void> _respond(
    BuildContext context,
    BidWithListing entry, {
    required bool accept,
  }) async {
    final amount = formatPrice(entry.bid.amountMyr);
    final confirmed = await _confirm(
      context,
      title: accept ? 'Accept this bid?' : 'Reject this bid?',
      message: accept
          ? 'Your ${entry.listing.title} will be marked sold at $amount, and '
                'every other bid on it will be rejected. This cannot be undone.'
          : 'The bidder will be told their $amount bid was not accepted.',
      confirmLabel: accept ? 'Accept' : 'Reject',
      destructive: !accept,
    );
    if (!confirmed || !context.mounted) return;

    final res = await context.read<BidsRepository>().respondToBid(
      entry.bid.id,
      accept: accept,
    );
    if (!context.mounted) return;
    if (res case Err(:final message)) {
      _toast(context, message);
    } else {
      _toast(
        context,
        accept ? 'Bid accepted — the car is marked sold.' : 'Bid rejected.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BidList(
      snapshot: snapshot,
      emptyTitle: 'No bids on your cars',
      emptyMessage:
          'When someone bids on a car you have listed, it shows up here for '
          'you to accept or reject.',
      onRetry: onRetry,
      cardBuilder: (entry) => BidCard(
        entry: entry,
        subtitle: _receivedSubtitle(entry.bid),
        onOpenListing: () => context.push('/listing/${entry.listing.id}'),
        actions: [
          if (entry.bid.status.isLive) ...[
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groupedBackground,
                foregroundColor: AppColors.destructive,
              ),
              onPressed: () => _respond(context, entry, accept: false),
              child: const Text('Reject'),
            ),
            FilledButton(
              onPressed: () => _respond(context, entry, accept: true),
              child: const Text('Accept'),
            ),
          ],
        ],
      ),
    );
  }

  String _receivedSubtitle(Bid bid) {
    if (bid.status == BidStatus.accepted && bid.contactPhone != null) {
      return 'Contact the bidder on ${bid.contactPhone}';
    }
    return 'Received ${formatRelative(bid.createdAt)}';
  }
}

class _BidList extends StatelessWidget {
  const _BidList({
    this.stream,
    this.snapshot,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRetry,
    required this.cardBuilder,
  }) : assert(
         (stream == null) != (snapshot == null),
         'pass exactly one of stream / snapshot',
       );

  final Stream<List<BidWithListing>>? stream;
  final AsyncSnapshot<List<BidWithListing>>? snapshot;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget Function(BidWithListing) cardBuilder;

  @override
  Widget build(BuildContext context) {
    final snapshot = this.snapshot;
    if (snapshot != null) return _body(snapshot);
    return StreamBuilder<List<BidWithListing>>(
      stream: stream,
      builder: (_, snapshot) => _body(snapshot),
    );
  }

  Widget _body(AsyncSnapshot<List<BidWithListing>> snapshot) {
    if (snapshot.hasError) {
      return _EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Couldn’t load bids',
        message: 'Check your connection and try again.',
        onRetry: onRetry,
      );
    }
    final bids = snapshot.data;
    if (bids == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (bids.isEmpty) {
      return _EmptyState(
        icon: Icons.gavel_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: bids.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, i) => cardBuilder(bids[i]),
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
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.iconXl, color: AppColors.tertiaryLabel),
            const SizedBox(height: AppSpacing.space16),
            Text(title, style: text.headline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.space8),
            Text(
              message,
              style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.space16),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: Theme.of(dialogContext).textTheme.headline),
      content: Text(message, style: Theme.of(dialogContext).textTheme.subhead),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: destructive
              ? TextButton.styleFrom(foregroundColor: AppColors.destructive)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
