import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/model/bid/bid_validation.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/section_header.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/listing/cover_image.dart';

const Key startingPriceFieldKey = Key('auction-starting-price');
const Key incrementFieldKey = Key('auction-increment');

class StartAuctionScreen extends StatefulWidget {
  const StartAuctionScreen({super.key});

  @override
  State<StartAuctionScreen> createState() => _StartAuctionScreenState();
}

class _StartAuctionScreenState extends State<StartAuctionScreen> {
  late Stream<List<Listing>> _cars;
  final _price = TextEditingController();
  final _increment = TextEditingController(text: '500');

  Listing? _car;
  Duration _duration = kAuctionDurations[3];
  bool _submitting = false;
  bool _submitted = false;
  String? _priceError;
  String? _incrementError;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthRepository>();
    final listings = context.read<ListingsRepository>();
    final uid = auth.currentUser?.id;
    _cars = uid == null
        ? Stream.value(const [])
        : watchSellerListings(listings, uid);
  }

  @override
  void dispose() {
    _price.dispose();
    _increment.dispose();
    super.dispose();
  }

  void _pickCar(List<Listing> cars) async {
    final picked = await showSelectSheet<Listing>(
      context: context,
      title: 'Which car?',
      options: cars,
      labelOf: (l) => '${l.title} · ${formatPrice(l.priceMyr)}',
      selected: _car,
    );
    if (picked == null) return;
    setState(() {
      _car = picked;
      if (_price.text.trim().isEmpty) {
        _price.text = '${picked.priceMyr}';
      }
    });
  }

  void _pickDuration() async {
    final picked = await showSelectSheet<Duration>(
      context: context,
      title: 'How long should it run?',
      options: kAuctionDurations,
      labelOf: auctionDurationLabel,
      selected: _duration,
    );
    if (picked != null) setState(() => _duration = picked);
  }

  bool _validate() {
    final priceError = validateStartingPrice(_price.text);
    final incrementError = validateIncrement(_increment.text);
    setState(() {
      _priceError = priceError;
      _incrementError = incrementError;
    });
    return _car != null && priceError == null && incrementError == null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _serverError = null;
    });
    if (!_validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Start this auction?'),
        content: Text(
          'The highest bid wins automatically when the time is up, even if '
          'it is only the ${formatPrice(parseBidAmount(_price.text)!)} '
          'starting price. Once someone bids you can’t cancel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final res = await context.read<BidsRepository>().startAuction(
      listingId: _car!.id,
      startingPriceMyr: parseBidAmount(_price.text)!,
      minIncrementMyr: parseBidAmount(_increment.text)!,
      endsAt: DateTime.now().toUtc().add(_duration),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (res) {
      case Ok(:final value):
        context.pushReplacement('/auction/$value');
      case Err(:final message):
        setState(() => _serverError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Start an auction')),
      body: StreamBuilder<List<Listing>>(
        stream: _cars,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _Message(
              icon: Icons.cloud_off_outlined,
              text: 'We couldn’t load your cars. Check your connection.',
            );
          }
          final cars = snapshot.data;
          if (cars == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cars.isEmpty) {
            return _Message(
              icon: Icons.directions_car_outlined,
              text:
                  'You need a car that is for sale before you can auction it.',
              action: TextButton(
                onPressed: () => context.go('/home/sell'),
                child: const Text('Go to My Listings'),
              ),
            );
          }
          return _form(context, cars);
        },
      ),
    );
  }

  Widget _form(BuildContext context, List<Listing> cars) {
    final text = Theme.of(context).textTheme;
    final endsAt = DateTime.now().add(_duration);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const SectionHeader('Car'),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Car',
              value: _car?.title ?? 'Select',
              showChevron: true,
              onTap: () => _pickCar(cars),
            ),
          ],
        ),
        if (_car != null) ...[
          const SizedBox(height: AppSpacing.space12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: CoverImage(
              media: _car!.cover,
              height: AppSpacing.coverHeight,
            ),
          ),
        ],
        if (_submitted && _car == null) ...[
          const SizedBox(height: AppSpacing.space12),
          const InlineNotice(text: 'Pick the car you want to auction.'),
        ],
        const SizedBox(height: AppSpacing.space20),
        const SectionHeader('Terms'),
        _MoneyField(
          fieldKey: startingPriceFieldKey,
          label: 'Starting price',
          hint: 'The first bid has to reach this',
          controller: _price,
          error: _submitted ? _priceError : null,
        ),
        const SizedBox(height: AppSpacing.space16),
        _MoneyField(
          fieldKey: incrementFieldKey,
          label: 'Minimum increment',
          hint: 'How much each bid must beat the last one by',
          controller: _increment,
          error: _submitted ? _incrementError : null,
        ),
        const SizedBox(height: AppSpacing.space16),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Runs for',
              value: auctionDurationLabel(_duration),
              showChevron: true,
              onTap: _pickDuration,
            ),
            GroupedRow(
              label: 'Ends around',
              value: '${formatDate(endsAt)}, ${_time(endsAt)}',
            ),
          ],
        ),
        if (_serverError != null) ...[
          const SizedBox(height: AppSpacing.space16),
          InlineNotice(text: _serverError!),
        ],
        const SizedBox(height: AppSpacing.space24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const ButtonSpinner()
                : const Text('Start auction'),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Text(
          'The highest bid wins automatically at the deadline. You can only '
          'cancel before the first bid arrives.',
          style: text.footnote.copyWith(color: AppColors.secondaryLabel),
        ),
      ],
    );
  }

  String _time(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.controller,
    this.error,
  });

  final Key fieldKey;
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.subhead),
        const SizedBox(height: AppSpacing.space8),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixText: 'RM ',
            hintText: hint,
            errorText: error,
          ),
        ),
      ],
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
