import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_validation.dart';
import 'package:assignment/model/bid/bids_sync_status.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/section_header.dart';
import 'package:assignment/widgets/bid/bids_offline_banner.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/listing/cover_image.dart';

const Key bidAmountFieldKey = Key('auction-bid-amount');
const Key placeBidButtonKey = Key('auction-place-bid');
const Key raiseBidButtonKey = Key('auction-raise-bid');
const Key extendAuctionButtonKey = Key('auction-extend');
const Key deleteAuctionButtonKey = Key('auction-delete');

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key, required this.id});

  final String id;

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  late Stream<AuctionWithListing> _auction;
  late Stream<List<Bid>> _bids;
  final _amount = TextEditingController();

  bool _touched = false;
  bool _raising = false;
  bool _submitting = false;
  bool _extending = false;
  bool _submitted = false;
  String? _amountError;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    final bids = context.read<BidsRepository>();
    _auction = bids.watchAuction(widget.id);
    _bids = bids.watchBidsForAuction(widget.id);
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _setAmount(int value) {
    _amount.text = '$value';
    _amount.selection = TextSelection.collapsed(offset: _amount.text.length);
    setState(() {
      _touched = true;
      _amountError = null;
    });
  }

  Future<void> _placeBid(Auction auction) async {
    setState(() {
      _submitted = true;
      _serverError = null;
    });
    final error = validateBidAmount(
      _amount.text,
      minimumMyr: auction.minimumNextBidMyr,
    );
    setState(() => _amountError = error);
    if (error != null) return;

    final amount = parseBidAmount(_amount.text)!;
    setState(() => _submitting = true);
    final res = await context.read<BidsRepository>().placeBid(
      auction.id,
      amount,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (res) {
      case Ok():
        _amount.clear();
        setState(() {
          _touched = false;
          _raising = false;
          _submitted = false;
        });
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Bid placed — you’re the highest bidder at '
                '${formatPrice(amount)}.',
              ),
            ),
          );
      case Err(:final message):
        setState(() => _serverError = message);
    }
  }

  // A rule refusal from extend_auction reaches us verbatim (the repository's
  // _passThrough list); every mapError fallback instead ends in "try again",
  // and stacking one of those on our own sentence would apologise twice.
  static String _extendFailure(String message) => message.contains('try again')
      ? 'Failed to extend or update the time duration for this bidding.'
      : 'Failed to extend or update the time duration for this bidding. '
            '$message';

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _extend(Auction auction) async {
    final options = extensionOptions(auction);
    if (options.isEmpty) return;

    // Cleared before the sheet opens, not after a pick: a leftover cancel or
    // delete error would otherwise sit behind the sheet looking like a
    // complaint about this extend.
    setState(() => _serverError = null);

    // The sheet spells out the resulting deadline for every choice, so it is
    // the confirmation step — no second dialog on top of it.
    final picked = await showSelectSheet<Duration>(
      context: context,
      title: 'Add how much time?',
      options: options,
      labelOf: (d) =>
          '${auctionExtensionLabel(d)} · ends '
          '${formatDateTime(auction.endsAt.add(d))}',
    );
    if (picked == null || !mounted) return;

    final endsAt = auction.endsAt.add(picked);
    setState(() => _extending = true);
    final res = await context.read<BidsRepository>().extendAuction(
      auction.id,
      endsAt,
    );
    if (!mounted) return;
    setState(() => _extending = false);
    // Both outcomes are snackbars: an extend that failed says so and gets out
    // of the way, rather than leaving a notice pinned to the page.
    switch (res) {
      case Ok():
        _snack('Time updated to ${formatDateTime(endsAt)} successfully.');
      case Err(:final message):
        _snack(_extendFailure(message));
    }
  }

  Future<void> _cancel(Auction auction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel this auction?'),
        content: Text(
          auction.bidCount == 0
              ? 'The car goes back on sale at its asking price. You can '
                    'start another auction later.'
              : 'The auction ends with no winner and every bid is '
                    'released — nobody is outbid. The car goes back on sale '
                    'at its asking price.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Cancel auction'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final res = await context.read<BidsRepository>().cancelAuction(auction.id);
    if (!mounted) return;
    if (res case Err(:final message)) {
      setState(() => _serverError = message);
    }
  }

  Future<void> _delete(Auction auction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete this auction?'),
        content: const Text(
          'This removes it from your auctions list. A purchase it produced '
          'stays in the buyer’s history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final res = await context.read<BidsRepository>().deleteAuction(auction.id);
    if (!mounted) return;
    switch (res) {
      case Ok():
        Navigator.of(context).maybePop();
      case Err(:final message):
        setState(() => _serverError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Auction')),
      body: StreamBuilder<AuctionWithListing>(
        stream: _auction,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Message(
              icon: Icons.cloud_off_outlined,
              text: 'We couldn’t load this auction. Check your connection.',
              action: TextButton(
                onPressed: () => setState(_subscribe),
                child: const Text('Retry'),
              ),
            );
          }
          final entry = snapshot.data;
          if (entry == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<Bid>>(
            stream: _bids,
            builder: (context, bids) =>
                _body(context, entry, bids.data ?? const []),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, AuctionWithListing entry, List<Bid> bids) {
    final text = Theme.of(context).textTheme;
    final auction = entry.auction;
    final uid = context.read<AuthRepository>().currentUser?.id;
    final isSeller = uid != null && auction.isSeller(uid);
    final live = auction.isLive();
    final finalising =
        auction.status == AuctionStatus.running && auction.hasEnded();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const BidsOfflineBanner(),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: CoverImage(media: entry.listing.cover),
        ),
        const SizedBox(height: AppSpacing.space12),
        Text(entry.title, style: text.title3),
        const SizedBox(height: AppSpacing.space16),
        GroupedSection(
          children: [
            GroupedRow(
              label: auction.highestBidMyr == null
                  ? 'Starting price'
                  : 'Current highest',
              value: formatPrice(
                auction.highestBidMyr ?? auction.startingPriceMyr,
              ),
              valueColor: AppColors.primary,
            ),
            GroupedRow(label: 'Bids', value: '${auction.bidCount}'),
            GroupedRow(
              label: 'Minimum next bid',
              value: formatPrice(auction.minimumNextBidMyr),
            ),
            GroupedRow(
              label: 'Started',
              value: formatDateTime(auction.createdAt),
            ),
            if (finalising)
              const GroupedRow(
                label: 'Status',
                value: 'Finalising…',
                valueColor: AppColors.warning,
              )
            else if (live)
              _Countdown(auction: auction)
            // A cancelled auction stopped when the seller pulled it, so its
            // ends_at never arrived; settled_at is the real stop time.
            else if (auction.status == AuctionStatus.cancelled)
              GroupedRow(
                label: 'Cancelled',
                value: formatDateTime(auction.settledAt ?? auction.endsAt),
              )
            // ends_at, not settled_at: settlement is opportunistic and can run
            // well after bidding actually closed.
            else
              GroupedRow(label: 'Ended', value: formatDateTime(auction.endsAt)),
          ],
        ),
        if (finalising) ...[
          const SizedBox(height: AppSpacing.space16),
          const InlineNotice(
            text:
                'The clock has run out. Settling the result now — pull down '
                'or reopen in a moment to see who won.',
          ),
        ],
        if (_serverError != null) ...[
          const SizedBox(height: AppSpacing.space16),
          InlineNotice(text: _serverError!, kind: NoticeKind.error),
        ],
        const SizedBox(height: AppSpacing.space20),
        // Everything below can start a write, so it is rebuilt with the sync
        // state rather than reading it once.
        BidsSyncBuilder(
          builder: (context, sync) {
            if (isSeller) return _sellerSection(context, auction, bids, sync);
            if (live) return _buyerSection(context, auction, bids, sync);
            return _outcome(context, auction, bids);
          },
        ),
        const SizedBox(height: AppSpacing.space24),
        const SectionHeader('Car'),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Asking price',
              value: formatPrice(entry.listing.priceMyr),
            ),
            GroupedRow(label: 'Year', value: '${entry.listing.year}'),
            GroupedRow(
              label: 'Mileage',
              value: formatMileage(entry.listing.mileageKm),
            ),
            GroupedRow(label: 'State', value: entry.listing.state),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/listing/${entry.listing.id}'),
          child: const Text('See the full listing'),
        ),
      ],
    );
  }

  Widget _buyerSection(
    BuildContext context,
    Auction auction,
    List<Bid> bids,
    BidsSyncStatus sync,
  ) {
    final text = Theme.of(context).textTheme;
    final mine = bids.isEmpty ? null : bids.first;
    // The auction row and the bid rows arrive on separate streams, so a bid of
    // mine can be on screen a round trip before the highest bid it set. Being
    // outbid is its own claim, not merely "not leading": place_bid only accepts
    // a bid that beats the current highest, so a bid with nothing higher yet
    // reported is winning. Reading that gap as an outbid used to render the
    // amount that is still null, which threw during build.
    final highest = auction.highestBidMyr;
    final leading =
        mine != null && (highest == null || mine.amountMyr >= highest);
    final outbid = mine != null && highest != null && mine.amountMyr < highest;

    if (leading && !_raising) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InlineNotice(
            kind: NoticeKind.success,
            text:
                'You’re the highest bidder at ${formatPrice(mine.amountMyr)}.',
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            // No promise of a notification: nothing writes a bid message to
            // the inbox (only `welcome` and `listing_match` triggers exist),
            // so telling a bidder they will hear about it would send them away
            // to wait for something that never arrives.
            'Someone can still outbid you before it ends — check back, or '
            'raise your bid now to stay ahead.',
            style: text.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.space12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: raiseBidButtonKey,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groupedBackground,
                foregroundColor: AppColors.primary,
              ),
              onPressed: () => setState(() => _raising = true),
              child: const Text('Raise my bid'),
            ),
          ),
        ],
      );
    }

    final minimum = auction.minimumNextBidMyr;
    if (!_touched && _amount.text != '$minimum') {
      _amount.text = '$minimum';
    }
    final typed = parseBidAmount(_amount.text);
    final belowMinimum = typed != null && typed < minimum;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (outbid) ...[
          InlineNotice(
            kind: NoticeKind.error,
            text:
                'You’ve been outbid. Your ${formatPrice(mine.amountMyr)} is '
                'below the current ${formatPrice(highest)}.',
          ),
          const SizedBox(height: AppSpacing.space12),
        ],
        Text(
          mine == null ? 'Place your bid' : 'Raise your bid',
          style: text.headline,
        ),
        const SizedBox(height: AppSpacing.space8),
        TextField(
          key: bidAmountFieldKey,
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {
            _touched = true;
            _amountError = null;
          }),
          decoration: InputDecoration(
            prefixText: 'RM ',
            hintText: '$minimum',
            errorText: _submitted ? _amountError : null,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Wrap(
          spacing: AppSpacing.space8,
          runSpacing: AppSpacing.space8,
          children: [
            _AmountChip(
              label: 'Minimum ${formatPrice(minimum)}',
              onTap: () => _setAmount(minimum),
            ),
            for (final steps in const [1, 2, 5])
              _AmountChip(
                label: '+${formatPrice(auction.minIncrementMyr * steps)}',
                onTap: () =>
                    _setAmount(minimum + auction.minIncrementMyr * steps),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          belowMinimum
              ? 'That’s below the minimum of ${formatPrice(minimum)}.'
              : 'Bids go up in steps of at least '
                    '${formatPrice(auction.minIncrementMyr)}.',
          style: text.footnote.copyWith(
            color: belowMinimum
                ? AppColors.destructive
                : AppColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: placeBidButtonKey,
            // Offline, the minimum on screen may already be out of date, so
            // the bid is refused here rather than by the server.
            onPressed: _submitting || belowMinimum || !sync.online
                ? null
                : () => _placeBid(auction),
            child: _submitting
                ? const ButtonSpinner()
                : Text(
                    typed == null ? 'Place bid' : 'Bid ${formatPrice(typed)}',
                  ),
          ),
        ),
        if (_raising) ...[
          const SizedBox(height: AppSpacing.space8),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _raising = false;
                _touched = false;
                _amount.clear();
              }),
              child: const Text('Keep my current bid'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sellerSection(
    BuildContext context,
    Auction auction,
    List<Bid> bids,
    BidsSyncStatus sync,
  ) {
    final text = Theme.of(context).textTheme;
    final uid = context.read<AuthRepository>().currentUser?.id ?? '';
    final canExtend = canExtendAuction(auction, uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!auction.isLive()) ...[
          Text(
            auction.status == AuctionStatus.cancelled
                ? 'You cancelled this auction.'
                : auction.highestBidMyr == null
                ? 'Ended with no bids. The car is hidden — put it back on '
                      'sale from My Listings.'
                : 'Sold for ${formatPrice(auction.highestBidMyr!)}.',
            style: text.body.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.space12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: deleteAuctionButtonKey,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groupedBackground,
                foregroundColor: AppColors.destructive,
              ),
              onPressed: sync.online ? () => _delete(auction) : null,
              child: const Text('Delete auction'),
            ),
          ),
        ] else ...[
          Text('This is your auction', style: text.headline),
          // Each action sits directly under the line that explains it.
          const SizedBox(height: AppSpacing.space8),
          Text(
            canExtend
                ? 'Ends ${formatDateTime(auction.endsAt)}. You can give '
                      'bidders more time, but you can’t cut it short.'
                : 'Ends ${formatDateTime(auction.endsAt)}. It is already '
                      'running the full 7 days, so the deadline can’t move.',
            style: text.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.space12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: extendAuctionButtonKey,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groupedBackground,
                foregroundColor: canExtend
                    ? AppColors.primary
                    : AppColors.tertiaryLabel,
              ),
              onPressed: canExtend && !_extending && sync.online
                  ? () => _extend(auction)
                  : null,
              child: _extending
                  ? const ButtonSpinner()
                  : const Text('Extend auction'),
            ),
          ),
          const SizedBox(height: AppSpacing.space20),
          Text(
            auction.bidCount == 0
                ? 'Nobody has bid yet. You can cancel at any time.'
                : 'Cancelling ends the auction with no winner and releases '
                      'every bid. The car goes back on sale.',
            style: text.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.space12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groupedBackground,
                foregroundColor: auction.canCancel(uid)
                    ? AppColors.destructive
                    : AppColors.tertiaryLabel,
              ),
              onPressed: auction.canCancel(uid) && sync.online
                  ? () => _cancel(auction)
                  : null,
              child: const Text('Cancel auction'),
            ),
          ),
        ],
        if (bids.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space24),
          const SectionHeader('Bids so far'),
          GroupedSection(
            children: [
              for (final b in bids)
                GroupedRow(
                  label: formatPrice(b.amountMyr),
                  labelColor: b.status == BidStatus.won
                      ? AppColors.success
                      : null,
                  value: formatRelative(b.createdAt),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _outcome(BuildContext context, Auction auction, List<Bid> bids) {
    final won = bids.any((b) => b.status == BidStatus.won);
    final message = switch (auction.status) {
      AuctionStatus.cancelled => 'This auction was cancelled by the seller.',
      _ when auction.highestBidMyr == null =>
        'This auction ended without any bids.',
      _ when won =>
        'You won this auction at ${formatPrice(auction.highestBidMyr!)}. '
            'It’s in your Purchases.',
      _ when bids.isNotEmpty =>
        'This auction ended at ${formatPrice(auction.highestBidMyr!)} — '
            'a higher bid than yours.',
      _ => 'This auction ended at ${formatPrice(auction.highestBidMyr!)}.',
    };
    return InlineNotice(
      kind: won ? NoticeKind.success : NoticeKind.info,
      text: message,
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({required this.auction});

  final Auction auction;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GroupedRow(
      label: 'Time left',
      value: formatCountdown(widget.auction.remaining()),
      valueColor: AppColors.warning,
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          border: Border.all(
            color: AppColors.separator,
            width: AppSpacing.hairline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space12,
            vertical: AppSpacing.space8,
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.footnote.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.iconXl, color: AppColors.tertiaryLabel),
            const SizedBox(height: AppSpacing.space16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.body.copyWith(color: AppColors.secondaryLabel),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.space16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
