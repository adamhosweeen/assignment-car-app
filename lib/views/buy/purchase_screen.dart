import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/profile/seller_row.dart';

/// A dummy checkout for a car. Shows a fake order summary; confirming flips the
/// listing to `sold` via [ListingsRepository.buy] (list price) or, when
/// reached from a chat offer's "Confirm and buy" / "Buy now" ([offerMessageId]
/// set), [ChatRepository.buyAtOffer] (the negotiated price) — so it leaves the
/// Buy feed, then shows a receipt with an order reference. No payment and no
/// real fulfilment — enough to demo the buy path.
class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({
    super.key,
    required this.id,
    this.offerMessageId,
    this.offerAmountMyr,
  });

  final String id;

  /// Set together: the chat offer message to buy at, and its amount — the
  /// checkout shows and confirms at this price instead of the listing's own.
  final String? offerMessageId;
  final int? offerAmountMyr;

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  bool _submitting = false;

  /// Set once the sale goes through; the success screen reads the car from
  /// here so it no longer depends on re-fetching the (now sold) listing.
  Listing? _purchased;

  /// Generated once per screen visit — used whether the sale completes here
  /// (a fresh "Confirm purchase" tap) or the listing was already sold on
  /// arrival (e.g. a chat offer just bought via `buy_at_offer`).
  late final String _orderRef = _newOrderRef();
  late final DateTime _placedAt = DateTime.now();

  /// A short, human-quotable reference, e.g. "GRJ-A1B2-C3D4".
  static String _newOrderRef() {
    final raw = newId().replaceAll('-', '').toUpperCase();
    return 'GRJ-${raw.substring(0, 4)}-${raw.substring(4, 8)}';
  }

  Future<void> _confirm(Listing listing) async {
    setState(() => _submitting = true);
    final offerMessageId = widget.offerMessageId;
    final res = offerMessageId == null
        ? await ref.read(listingsRepositoryProvider).buy(listing.id)
        : await ref.read(chatRepositoryProvider).buyAtOffer(offerMessageId);
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
      // buy_at_offer records the offer's amount as the listing's final
      // price server-side; reflect that on the receipt without waiting on a
      // re-fetch.
      _purchased = widget.offerAmountMyr == null
          ? listing
          : listing.copyWith(
              status: ListingStatus.sold,
              priceMyr: widget.offerAmountMyr!,
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    final purchased = _purchased;
    if (purchased != null) {
      return _successScaffold(purchased);
    }

    final async = ref.watch(listingByIdProvider(widget.id));
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Checkout')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Message('This listing is no longer available.'),
        data: (listing) {
          // Already sold on arrival — e.g. a chat offer just completed the
          // purchase via `buy_at_offer` before this screen was even reached.
          // Show the same receipt instead of a stale "confirm purchase" form
          // that would only fail if tapped.
          if (listing.status != ListingStatus.active) {
            return _successScaffold(listing);
          }
          return _Checkout(
            listing: listing,
            priceMyr: widget.offerAmountMyr ?? listing.priceMyr,
            negotiated: widget.offerAmountMyr != null,
            buyer: ref.read(authRepositoryProvider).currentUser,
            submitting: _submitting,
            onConfirm: () => _confirm(listing),
          );
        },
      ),
    );
  }

  Widget _successScaffold(Listing listing) => Scaffold(
    backgroundColor: AppColors.groupedBackground,
    appBar: AppBar(
      title: const Text('Purchase confirmed'),
      automaticallyImplyLeading: false,
    ),
    body: _PurchaseSuccess(
      listing: listing,
      orderRef: _orderRef,
      placedAt: _placedAt,
      onDone: () => context.go('/home/buy'),
    ),
  );
}

class _Checkout extends StatelessWidget {
  const _Checkout({
    required this.listing,
    required this.priceMyr,
    required this.negotiated,
    required this.buyer,
    required this.submitting,
    required this.onConfirm,
  });

  final Listing listing;

  /// What this checkout actually charges — the listing's own price, unless
  /// [negotiated] (reached from a confirmed chat offer), in which case it's
  /// that offer's amount instead.
  final int priceMyr;
  final bool negotiated;
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
              _CarHeader(listing: listing, priceMyr: priceMyr),
              const SizedBox(height: AppSpacing.space24),
              GroupedSection(
                header: 'Car details',
                children: [
                  GroupedRow(label: 'Year', value: listing.year.toString()),
                  GroupedRow(
                    label: 'Mileage',
                    value: formatMileage(listing.mileageKm),
                  ),
                  GroupedRow(
                    label: 'Transmission',
                    value: listing.transmission.label,
                  ),
                  GroupedRow(label: 'Fuel', value: listing.fuelType.label),
                ],
              ),
              const SizedBox(height: AppSpacing.space20),
              GroupedSection(
                header: 'Order summary',
                children: [
                  GroupedRow(label: 'Car', value: listing.title),
                  GroupedRow(
                    label: negotiated ? 'Agreed price' : 'Price',
                    value: formatPrice(priceMyr),
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
              _SellerCard(sellerId: listing.sellerId),
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
                  : Text('Confirm purchase · ${formatPrice(priceMyr)}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Who you're buying from. Mirrors the seller row on the listing detail
/// screen; tapping opens the seller's public page. Hidden if the profile
/// can't be loaded — the checkout still works without it.
class _SellerCard extends ConsumerWidget {
  const _SellerCard({required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicProfileProvider(sellerId));
    return async.when(
      loading: () => const GroupedSection(
        header: 'Seller',
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.space16),
            child: SizedBox(
              height: AppSpacing.space12,
              child: ColoredBox(color: AppColors.fill),
            ),
          ),
        ],
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (profile) => profile == null
          ? const SizedBox.shrink()
          : GroupedSection(
              header: 'Seller',
              children: [
                SellerRow(
                  profile: profile,
                  onTap: () => context.push('/seller/${profile.id}'),
                ),
              ],
            ),
    );
  }
}

class _CarHeader extends StatelessWidget {
  const _CarHeader({required this.listing, required this.priceMyr});

  final Listing listing;
  final int priceMyr;

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
            child: CoverImage(media: listing.cover, height: AppSpacing.thumbMd),
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
                formatPrice(priceMyr),
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
  const _PurchaseSuccess({
    required this.listing,
    required this.orderRef,
    required this.placedAt,
    required this.onDone,
  });

  final Listing listing;
  final String orderRef;
  final DateTime placedAt;
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
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Sold for ${formatPrice(listing.priceMyr)}',
                    style: text.title3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  Text(
                    'Order reference',
                    style: text.footnote.copyWith(
                      color: AppColors.tertiaryLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(orderRef, style: text.headline),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    formatDate(placedAt),
                    style: text.footnote.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: FilledButton(onPressed: onDone, child: const Text('Done')),
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
