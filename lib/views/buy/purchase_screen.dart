import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/listing/cover_image.dart';

/// A dummy checkout for a car. Shows a fake order summary; confirming flips the
/// listing to `sold` via [ListingsRepository.markSold] so it leaves the Buy
/// feed. No payment and no real fulfilment — enough to demo the buy path.
class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  bool _submitting = false;

  /// Set once the sale goes through; the success screen reads the car from
  /// here so it no longer depends on re-fetching the (now sold) listing.
  Listing? _purchased;

  Future<void> _confirm(Listing listing) async {
    setState(() => _submitting = true);
    final res = await ref.read(listingsRepositoryProvider).buy(listing.id);
    if (!mounted) return;
    if (res case Err(:final message)) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ref.invalidate(activeListingsProvider);
    setState(() {
      _submitting = false;
      _purchased = listing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final purchased = _purchased;
    if (purchased != null) {
      return Scaffold(
        backgroundColor: AppColors.groupedBackground,
        appBar: AppBar(
          title: const Text('Purchase confirmed'),
          automaticallyImplyLeading: false,
        ),
        body: _PurchaseSuccess(
          listing: purchased,
          onDone: () => context.go('/home/buy'),
        ),
      );
    }

    final async = ref.watch(listingByIdProvider(widget.id));
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Checkout')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const _Message('This listing is no longer available.'),
        data: (listing) => _Checkout(
          listing: listing,
          buyer: ref.read(authRepositoryProvider).currentUser,
          submitting: _submitting,
          onConfirm: () => _confirm(listing),
        ),
      ),
    );
  }
}

class _Checkout extends StatelessWidget {
  const _Checkout({
    required this.listing,
    required this.buyer,
    required this.submitting,
    required this.onConfirm,
  });

  final Listing listing;
  final Profile? buyer;
  final bool submitting;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _CarHeader(listing: listing),
              const SizedBox(height: AppSpacing.space24),
              GroupedSection(
                header: 'Order summary',
                children: [
                  GroupedRow(label: 'Car', value: listing.title),
                  GroupedRow(
                    label: 'Price',
                    value: formatPrice(listing.priceMyr),
                  ),
                  GroupedRow(
                    label: 'Collection',
                    value: 'From seller in ${listing.city}',
                  ),
                  const GroupedRow(
                    label: 'Payment',
                    value: 'Cash on collection',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space20),
              GroupedSection(
                header: 'Buyer',
                children: [
                  GroupedRow(label: 'Name', value: buyer?.displayName ?? '—'),
                  GroupedRow(label: 'Phone', value: buyer?.phone ?? '—'),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'This is a demo checkout. Confirming marks the car as sold and '
                'removes it from the Buy feed — no payment is taken.',
                style: text.footnote.copyWith(color: AppColors.tertiaryLabel),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: FilledButton(
              onPressed: submitting ? null : onConfirm,
              child: submitting
                  ? const ButtonSpinner()
                  : Text(
                      'Confirm purchase · ${formatPrice(listing.priceMyr)}',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarHeader extends StatelessWidget {
  const _CarHeader({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: SizedBox(
            width: AppSpacing.thumbMd,
            height: AppSpacing.thumbMd,
            child: CoverImage(
              media: listing.cover,
              height: AppSpacing.thumbMd,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(listing.title, style: text.headline),
              const SizedBox(height: AppSpacing.space4),
              Text(
                formatPrice(listing.priceMyr),
                style: text.body.copyWith(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PurchaseSuccess extends StatelessWidget {
  const _PurchaseSuccess({required this.listing, required this.onDone});

  final Listing listing;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: AppSpacing.iconXl,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Purchase confirmed',
                    style: text.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'You’ve reserved the ${listing.title}. The seller will be '
                    'in touch to arrange collection and payment.',
                    style: text.subhead.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: FilledButton(
              onPressed: onDone,
              child: const Text('Done'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.body.copyWith(color: AppColors.secondaryLabel),
        ),
      ),
    );
  }
}
