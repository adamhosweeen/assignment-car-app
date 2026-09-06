import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/draft_from_listing.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/widgets/common/section_header.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/listing_card.dart';
import 'package:assignment/widgets/listing/status_badge.dart';

class SellHomeScreen extends StatefulWidget {
  const SellHomeScreen({super.key});

  @override
  State<SellHomeScreen> createState() => _SellHomeScreenState();
}

class _SellHomeScreenState extends State<SellHomeScreen> {
  static const double _fabClearance = 88;

  late Stream<List<Listing>> _myListings;

  @override
  void initState() {
    super.initState();
    _myListings = watchMyListings(
      context.read<AuthRepository>(),
      context.read<ListingsRepository>(),
    );
  }

  void _startSelling({bool editing = false}) =>
      context.push('/sell/new', extra: editing);

  Future<void> _discardDraft() =>
      // Goes through the controller so the in-memory draft is reset too (not
      // just the sqflite row) and listeners are notified.
      context.read<SellController>().discard();

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markSold(Listing l) async {
    final res = await context.read<ListingsRepository>().markSold(l.id);
    if (!mounted) return;
    if (res case Err(:final message)) _showError(message);
  }

  Future<void> _setHidden(Listing l, bool hidden) async {
    final listings = context.read<ListingsRepository>();
    final res = hidden
        ? await listings.hide(l.id)
        : await listings.unhide(l.id);
    if (!mounted) return;
    if (res case Err(:final message)) _showError(message);
  }

  Future<void> _edit(Listing l) async {
    await context.read<DraftRepository>().save(draftFromListing(l));
    if (!mounted) return;
    setState(context.read<SellController>().reload);
    _startSelling(editing: true);
  }

  Future<void> _delete(Listing l) async {
    final listings = context.read<ListingsRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete this listing?'),
        content: const Text(
          'This removes the car and its photos for good. You can’t undo this. '
          'To take it off the Buy feed but keep it, hide it instead.',
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
    if (confirmed != true) return;
    final res = await listings.deleteListing(l.id);
    if (!mounted) return;
    if (res case Err(:final message)) _showError(message);
  }

  Future<void> _showActions(Listing l) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (l.status == ListingStatus.selling) ...[
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Mark as sold'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _markSold(l);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _edit(l);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: const Text('Hide from buyers'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _setHidden(l, true);
                },
              ),
            ],
            if (l.status == ListingStatus.hidden) ...[
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Put back on sale'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _setHidden(l, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _edit(l);
                },
              ),
            ],
            if (l.status == ListingStatus.bidding)
              const ListTile(
                leading: Icon(Icons.gavel_outlined),
                title: Text('Auction running'),
                subtitle: Text(
                  'Manage it from the Bid tab. It can’t be edited or sold '
                  'while bidding is open.',
                ),
              ),
            if (l.status != ListingStatus.sold &&
                l.status != ListingStatus.bidding)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.destructive,
                ),
                title: Text(
                  'Delete',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.body.copyWith(color: AppColors.destructive),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _delete(l);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller so the resume banner disappears the moment the draft
    // is discarded — including by publishing from inside the wizard.
    final hasDraft = context.watch<SellController>().hasDraft;

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sell-new-listing-fab',
        onPressed: _startSelling,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        tooltip: 'Sell your car',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Listing>>(
        stream: _myListings,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MessageState(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              message:
                  'We couldn’t load your listings. Pull down to try again.',
            );
          }
          final all = snapshot.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Listing> withStatus(ListingStatus status) =>
              all.where((l) => l.status == status).toList();
          final selling = withStatus(ListingStatus.selling);
          final bidding = withStatus(ListingStatus.bidding);
          final hidden = withStatus(ListingStatus.hidden);
          final sold = withStatus(ListingStatus.sold);
          final isEmpty = all.isEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              _fabClearance,
            ),
            children: [
              if (hasDraft) ...[
                _ResumeBanner(
                  onContinue: _startSelling,
                  onDiscard: _discardDraft,
                ),
                const SizedBox(height: AppSpacing.space24),
              ],
              if (isEmpty)
                const _MessageState(
                  icon: Icons.directions_car_outlined,
                  title: "You haven't listed a car yet",
                  message: 'Tap + to create your first listing.',
                )
              else ...[
                for (final (header, group) in [
                  ('Selling', selling),
                  ('Bidding', bidding),
                  ('Hidden', hidden),
                  ('Sold', sold),
                ])
                  if (group.isNotEmpty) ...[
                    SectionHeader(header),
                    for (final l in group) _tile(l),
                    const SizedBox(height: AppSpacing.space8),
                  ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _tile(Listing l) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space16),
      child: ListingCard(
        listing: l,
        cover: CoverImage(media: l.cover),
        statusBadge: StatusBadge(status: l.status),
        onTap: () => context.push('/listing/${l.id}'),
        onLongPress: () => _showActions(l),
        trailing: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showActions(l),
          child: const Padding(
            padding: EdgeInsets.only(left: AppSpacing.space8),
            child: Icon(Icons.more_horiz, color: AppColors.secondaryLabel),
          ),
        ),
      ),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.onContinue, required this.onDiscard});

  final VoidCallback onContinue;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unfinished listing', style: text.headline),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'You have a draft in progress. Continue where you left off?',
            style: text.subhead.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.space12),
          Row(
            children: [
              TextButton(onPressed: onContinue, child: const Text('Continue')),
              const SizedBox(width: AppSpacing.space8),
              TextButton(
                onPressed: onDiscard,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryLabel,
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space32),
      child: Column(
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
        ],
      ),
    );
  }
}
