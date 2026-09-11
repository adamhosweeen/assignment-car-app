import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/user/user_providers.dart';
import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/ids.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/user/seller_row.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({
    super.key,
    required this.id,
    this.offerMessageId,
    this.offerAmountMyr,
  });

  final String id;

  final String? offerMessageId;
  final int? offerAmountMyr;

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _submitting = false;

  late final Future<Listing> _listing = fetchListingById(
    context.read<ListingsRepository>(),
    widget.id,
  );

  Listing? _purchased;

  late final String _orderRef = _newOrderRef();
  late final DateTime _placedAt = DateTime.now();

  static String _newOrderRef() {
    final raw = newId().replaceAll('-', '').toUpperCase();
    return 'GRJ-${raw.substring(0, 4)}-${raw.substring(4, 8)}';
  }

  Future<void> _confirm(Listing listing) async {
    setState(() => _submitting = true);
    final offerMessageId = widget.offerMessageId;
    final res = offerMessageId == null
        ? await context.read<ListingsRepository>().buy(listing.id)
        : await context.read<ChatRepository>().buyAtOffer(offerMessageId);
    if (!mounted) return;
    if (res case Err(:final message)) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    setState(() {
      _submitting = false;
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

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Checkout')),
      body: FutureBuilder<Listing>(
        future: _listing,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _Message('This listing is no longer available.');
          }
          final listing = snapshot.data;
          if (listing == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (listing.status != ListingStatus.selling) {
            return _successScaffold(listing);
          }
          return _Checkout(
            listing: listing,
            priceMyr: widget.offerAmountMyr ?? listing.priceMyr,
            negotiated: widget.offerAmountMyr != null,
            buyer: context.read<AuthRepository>().currentUser,
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
      onDone: () => context.read<AppNavigator>().goHome(homeTabBuy),
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

  final int priceMyr;
  final bool negotiated;
  final AppUser? buyer;
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
                  GroupedRow(label: 'Name', value: buyer?.name ?? '—'),
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

class _SellerCard extends StatefulWidget {
  const _SellerCard({required this.sellerId});

  final String sellerId;

  @override
  State<_SellerCard> createState() => _SellerCardState();
}

class _SellerCardState extends State<_SellerCard> {
  late final Future<AppUser?> _profile = fetchAppUser(
    context.read<UsersRepository>(),
    widget.sellerId,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GroupedSection(
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
          );
        }
        final profile = snapshot.data;
        if (profile == null) return const SizedBox.shrink();
        return GroupedSection(
          header: 'Seller',
          children: [
            SellerRow(
              user: profile,
              onTap: () =>
                  Navigator.pushNamed(context, '/seller/${profile.id}'),
            ),
          ],
        );
      },
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
