import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/model/bid/auction.dart';
import 'package:assignment/model/bid/auction_with_listing.dart';
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

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key, required this.id});

  final String id;

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  late Stream<AuctionWithListing> _auction;
  final _amount = TextEditingController();
  Timer? _tick;

  bool _submitting = false;
  bool _submitted = false;
  String? _amountError;
  String? _serverError;
  int? _prefilledFor;

  @override
  void initState() {
    super.initState();
    _subscribe();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _subscribe() {
    _auction = context.read<BidsRepository>().watchAuction(widget.id);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _amount.dispose();
    super.dispose();
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

    setState(() => _submitting = true);
    final res = await context.read<BidsRepository>().placeBid(
      auction.id,
      parseBidAmount(_amount.text)!,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (res) {
      case Ok():
        _amount.clear();
        setState(() {
          _submitted = false;
          _prefilledFor = null;
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Bid placed.')));
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
        content: const Text(
          'The car goes back on sale at its asking price. You can start '
          'another auction later.',
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
          return _body(context, entry);
        },
      ),
    );
  }

  Widget _body(BuildContext context, AuctionWithListing entry) {
    final text = Theme.of(context).textTheme;
    final auction = entry.auction;
    final uid = context.read<AuthRepository>().currentUser?.id;
    final isSeller = uid != null && auction.isSeller(uid);
    final live = auction.isLive();
    final finalising =
        auction.status == AuctionStatus.running && auction.hasEnded();

    if (live && !isSeller && _prefilledFor != auction.minimumNextBidMyr) {
      _amount.text = '${auction.minimumNextBidMyr}';
      _prefilledFor = auction.minimumNextBidMyr;
    }

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
            GroupedRow(
              label: finalising ? 'Status' : 'Time left',
              value: finalising
                  ? 'Finalising…'
                  : live
                  ? formatCountdown(auction.remaining())
                  : auction.status.label,
              valueColor: live ? AppColors.warning : null,
            ),
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
          InlineNotice(text: _serverError!),
        ],
        const SizedBox(height: AppSpacing.space20),
        if (isSeller)
          _sellerActions(context, auction)
        else if (live)
          _bidForm(context, auction)
        else
          _outcome(context, auction),
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

  Widget _bidForm(BuildContext context, Auction auction) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your bid', style: text.headline),
        const SizedBox(height: AppSpacing.space8),
        TextField(
          key: bidAmountFieldKey,
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixText: 'RM ',
            hintText: '${auction.minimumNextBidMyr}',
            errorText: _submitted ? _amountError : null,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'Bids go up in steps of at least '
          '${formatPrice(auction.minIncrementMyr)}.',
          style: text.footnote.copyWith(color: AppColors.secondaryLabel),
        ),
        const SizedBox(height: AppSpacing.space16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : () => _placeBid(auction),
            child: _submitting
                ? const ButtonSpinner()
                : const Text('Place bid'),
          ),
        ),
      ],
    );
  }

  Widget _sellerActions(BuildContext context, Auction auction) {
    final text = Theme.of(context).textTheme;
    if (!auction.isLive()) {
      return Text(
        auction.status == AuctionStatus.cancelled
            ? 'You cancelled this auction.'
            : auction.highestBidMyr == null
            ? 'Ended with no bids. The car is hidden — put it back on sale '
                  'from My Listings.'
            : 'Sold for ${formatPrice(auction.highestBidMyr!)}.',
        style: text.body.copyWith(color: AppColors.secondaryLabel),
      );
    }
    final uid = context.read<AuthRepository>().currentUser?.id ?? '';
    final canCancel = auction.canCancel(uid);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This is your auction', style: text.headline),
        const SizedBox(height: AppSpacing.space8),
        Text(
          canCancel
              ? 'Nobody has bid yet, so you can still cancel.'
              : 'Someone has already bid, so this has to run its course.',
          style: text.footnote.copyWith(color: AppColors.secondaryLabel),
        ),
        const SizedBox(height: AppSpacing.space16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.groupedBackground,
              foregroundColor: canCancel
                  ? AppColors.destructive
                  : AppColors.tertiaryLabel,
            ),
            onPressed: canCancel ? () => _cancel(auction) : null,
            child: const Text('Cancel auction'),
          ),
        ),
      ],
    );
  }

  Widget _outcome(BuildContext context, Auction auction) {
    final text = Theme.of(context).textTheme;
    final message = switch (auction.status) {
      AuctionStatus.cancelled => 'This auction was cancelled by the seller.',
      _ when auction.highestBidMyr == null =>
        'This auction ended without any bids.',
      _ =>
        'This auction ended at ${formatPrice(auction.highestBidMyr!)}. '
            'Check My bids to see how yours did.',
    };
    return Text(
      message,
      style: text.body.copyWith(color: AppColors.secondaryLabel),
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
