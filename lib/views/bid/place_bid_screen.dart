import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_providers.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/bid/bid_validation.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/bid/bid_spec_field.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart'
    show FieldLabel;
import 'package:assignment/widgets/listing/cover_image.dart';

const Key bidAmountFieldKey = Key('bid-amount-field');
const Key bidPhoneFieldKey = Key('bid-phone-field');

class PlaceBidScreen extends StatefulWidget {
  const PlaceBidScreen({super.key, required this.listingId});

  final String listingId;

  @override
  State<PlaceBidScreen> createState() => _PlaceBidScreenState();
}

class _PlaceBidScreenState extends State<PlaceBidScreen> {
  final _amount = TextEditingController();
  final _phone = TextEditingController();

  late Future<Listing> _listing;
  late Future<Bid?> _existingBid;

  bool _notifyWhatsapp = false;
  bool _submitting = false;

  bool _submitted = false;

  String? _amountError;
  String? _phoneError;

  Bid? _existing;

  Bid? _placed;

  @override
  void initState() {
    super.initState();
    _phone.text = context.read<AuthRepository>().currentUser?.phone ?? '';
    _listing = fetchListingById(
      context.read<ListingsRepository>(),
      widget.listingId,
    );
    _existingBid = fetchMyPendingBid(
      context.read<AuthRepository>(),
      context.read<BidsRepository>(),
      widget.listingId,
    );
    _prefillFromExistingBid();
  }

  @override
  void dispose() {
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _prefillFromExistingBid() {
    _existingBid
        .then((existing) {
          if (!mounted || existing == null) return;
          setState(() {
            _existing = existing;
            _amount.text = existing.amountMyr.toString();
            final phone = existing.contactPhone;
            if (phone != null && phone.isNotEmpty) _phone.text = phone;
            _notifyWhatsapp = existing.notifyWhatsapp;
          });
        })
        .catchError((Object _) {});
  }

  bool _validate(Listing listing) {
    final amountError = validateBidAmount(
      _amount.text,
      askingPriceMyr: listing.priceMyr,
    );
    final phoneError = validateBidPhone(_phone.text);
    setState(() {
      _amountError = amountError;
      _phoneError = phoneError;
    });
    return amountError == null && phoneError == null;
  }

  Future<void> _submit(Listing listing) async {
    setState(() => _submitted = true);
    if (!_validate(listing)) return;

    final amount = parseBidAmount(_amount.text);
    if (amount == null) return;

    setState(() => _submitting = true);
    final res = await context.read<BidsRepository>().placeBid(
      listing.id,
      amount,
      contactPhone: _phone.text.trim(),
      notifyWhatsapp: _notifyWhatsapp,
    );
    if (!mounted) return;

    switch (res) {
      case Ok(:final value):
        setState(() {
          _submitting = false;
          _existing = value;
          _placed = value;
        });
      case Err(:final message):
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _reloadListing() => setState(() {
    _listing = fetchListingById(
      context.read<ListingsRepository>(),
      widget.listingId,
    );
  });

  @override
  Widget build(BuildContext context) {
    final placed = _placed;

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        title: Text(placed == null ? 'Place your bid' : 'Bid placed'),
        automaticallyImplyLeading: placed == null,
      ),
      body: FutureBuilder<Listing>(
        future: _listing,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _CentredMessage(
              text: 'This listing is no longer available.',
              onRetry: _reloadListing,
            );
          }
          final listing = snapshot.data;
          if (listing == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (placed != null) {
            return _BidPlaced(
              bid: placed,
              listing: listing,
              onDone: () => context.go('/home/bid'),
            );
          }
          return _guard(listing) ?? _form(listing);
        },
      ),
    );
  }

  Widget? _guard(Listing listing) {
    final me = context.read<AuthRepository>().currentUser;
    if (me != null && listing.sellerId == me.id) {
      return const _CentredMessage(
        text:
            "This is your own car. You can't bid on it — open it from the "
            'Bid tab to see the bids you have received.',
      );
    }
    if (listing.status != ListingStatus.active) {
      return const _CentredMessage(
        text: 'This car is no longer available to bid on.',
      );
    }
    return null;
  }

  Widget _form(Listing listing) {
    final existing = _existing;

    final text = Theme.of(context).textTheme;
    final amount = parseBidAmount(_amount.text);
    final hint = amount == null || _amountError != null
        ? null
        : bidAmountHint(amount, askingPriceMyr: listing.priceMyr);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _CarHeader(listing: listing),
              const SizedBox(height: AppSpacing.space20),

              if (existing != null) ...[
                InlineNotice(
                  text:
                      'You already have a ${formatPrice(existing.amountMyr)} '
                      'bid on this car. Placing a new one replaces it.',
                ),
                const SizedBox(height: AppSpacing.space20),
              ],

              Text('Car details', style: text.title3),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Taken from the listing — you are bidding on exactly this car.',
                style: text.footnote.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space16),
              BidSpecGrid(
                children: [
                  BidSpecField(label: 'Car Brand', value: listing.make),
                  BidSpecField(label: 'Car Model', value: listing.model),
                  BidSpecField(
                    label: 'Car Year',
                    value: listing.year.toString(),
                  ),
                  BidSpecField(
                    label: 'Car Variant',
                    value: listing.variant,
                    hint: 'Not specified',
                  ),
                  BidSpecField(label: 'Engine', value: listing.fuelType.label),
                  BidSpecField(
                    label: 'Transmission',
                    value: listing.transmission.label,
                  ),
                  BidSpecField(
                    label: 'Mileage',
                    value: formatMileage(listing.mileageKm),
                  ),
                  BidSpecField(
                    label: 'Car Region',
                    value: listing.registrationRegion.label,
                    info:
                        'Where the car is registered. West Malaysia is the '
                        'peninsula; East Malaysia is Sabah and Sarawak.',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.space24),
              Text('Your bid', style: text.title3),
              const SizedBox(height: AppSpacing.space16),

              const FieldLabel('Your Bid (RM)'),
              TextField(
                key: bidAmountFieldKey,
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_submitting,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.space12,
                      right: AppSpacing.space8,
                    ),
                    child: Text('RM', style: text.body),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  hintText: listing.priceMyr.toString(),
                  errorText: _amountError,
                ),
                onChanged: (_) {
                  if (_submitted) _validate(listing);
                  setState(() {});
                },
              ),
              if (_amountError == null && hint != null) ...[
                const SizedBox(height: AppSpacing.space8),
                Text(
                  hint,
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.space20),
              const FieldLabel('Mobile No.'),
              TextField(
                key: bidPhoneFieldKey,
                controller: _phone,
                keyboardType: TextInputType.phone,
                enabled: !_submitting,
                decoration: InputDecoration(
                  hintText: '0111234567',
                  errorText: _phoneError,
                ),
                onChanged: (_) {
                  if (_submitted) _validate(listing);
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Shared with the seller only if they accept your bid.',
                style: text.footnote.copyWith(color: AppColors.tertiaryLabel),
              ),

              const SizedBox(height: AppSpacing.space16),
              _WhatsappConsent(
                value: _notifyWhatsapp,
                onChanged: _submitting
                    ? null
                    : (v) => setState(() => _notifyWhatsapp = v),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: FilledButton(
              onPressed: _submitting ? null : () => _submit(listing),
              child: _submitting
                  ? const ButtonSpinner()
                  : Text(
                      existing == null ? 'Place Your Bid' : 'Update Your Bid',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WhatsappConsent extends StatelessWidget {
  const _WhatsappConsent({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: value,
            activeColor: AppColors.primary,
            onChanged: enabled ? (v) => onChanged!(v ?? false) : null,
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              'Allow notifications from Garaj on WhatsApp',
              style: Theme.of(context).textTheme.subhead.copyWith(
                color: enabled ? AppColors.label : AppColors.tertiaryLabel,
              ),
            ),
          ),
        ],
      ),
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
                '${formatPrice(listing.priceMyr)} asking',
                style: text.body.copyWith(color: AppColors.secondaryLabel),
              ),
              if (listing.negotiable) ...[
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Seller marked this negotiable',
                  style: text.footnote.copyWith(color: AppColors.primary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BidPlaced extends StatelessWidget {
  const _BidPlaced({
    required this.bid,
    required this.listing,
    required this.onDone,
  });

  final Bid bid;
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
                    Icons.gavel,
                    size: AppSpacing.iconXl,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Bid placed',
                    style: text.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Your ${formatPrice(bid.amountMyr)} bid on the '
                    '${listing.title} is with the seller. You’ll be notified '
                    'when they respond.',
                    style: text.subhead.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  Text(
                    'You can withdraw it from the Bid tab any time before the '
                    'seller responds.',
                    style: text.footnote.copyWith(
                      color: AppColors.tertiaryLabel,
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
              child: const Text('View my bids'),
            ),
          ),
        ),
      ],
    );
  }
}

class _CentredMessage extends StatelessWidget {
  const _CentredMessage({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.body.copyWith(color: AppColors.secondaryLabel),
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
