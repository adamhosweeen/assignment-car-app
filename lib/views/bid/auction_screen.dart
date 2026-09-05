import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_validation.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/section_header.dart';
import 'package:assignment/widgets/listing/cover_image.dart';

const Key bidAmountFieldKey = Key('auction-bid-amount');
const Key placeBidButtonKey = Key('auction-place-bid');
const Key raiseBidButtonKey = Key('auction-raise-bid');
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
              : 'Every bid on it will be marked as lost and the bidders '
                    'will be told. The car goes back on sale at its asking '
                    'price.',
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
            if (finalising)
              const GroupedRow(
                label: 'Status',
                value: 'Finalising…',
                valueColor: AppColors.warning,
              )
            else if (live)
              _Countdown(auction: auction)
            else
              GroupedRow(label: 'Status', value: auction.status.label),
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
        if (isSeller)
          _sellerSection(context, auction, bids)
        else if (live)
          _buyerSection(context, auction, bids)
        else
          _outcome(context, auction, bids),
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
          onPressed: () => context.push('/listing/${entry.listing.id}'),
          child: const Text('See the full listing'),
        ),
      ],
    );
  }

  Widget _buyerSection(BuildContext context, Auction auction, List<Bid> bids) {
    final text = Theme.of(context).textTheme;
    final mine = bids.isEmpty ? null : bids.first;
    final leading =
        mine != null &&
        auction.highestBidMyr != null &&
        mine.amountMyr >= auction.highestBidMyr!;
    final outbid = mine != null && !leading;

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
            'If someone outbids you we’ll let you know. You can also raise '
            'your bid now to stay ahead.',
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
                'below the current ${formatPrice(auction.highestBidMyr!)}.',
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
            onPressed: _submitting || belowMinimum
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

  Widget _sellerSection(BuildContext context, Auction auction, List<Bid> bids) {
    final text = Theme.of(context).textTheme;
    final uid = context.read<AuthRepository>().currentUser?.id ?? '';

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
              onPressed: () => _delete(auction),
              child: const Text('Delete auction'),
            ),
          ),
        ] else ...[
          Text('This is your auction', style: text.headline),
          const SizedBox(height: AppSpacing.space8),
          Text(
            auction.bidCount == 0
                ? 'Nobody has bid yet. You can cancel at any time.'
                : 'Cancelling now marks every bid as lost and tells the '
                      'bidders. The car goes back on sale.',
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
              onPressed: auction.canCancel(uid) ? () => _cancel(auction) : null,
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
