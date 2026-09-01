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

/// The Sell tab: an entry point to create a listing plus the user's own
/// listings, split into Active and Sold (V1_SPEC §4.3, §4.6).
class SellHomeScreen extends StatefulWidget {
  const SellHomeScreen({super.key});

  @override
  State<SellHomeScreen> createState() => _SellHomeScreenState();
}

class _SellHomeScreenState extends State<SellHomeScreen> {
  /// Bottom padding so the last list row can scroll clear of the FAB.
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

  Future<void> _discardDraft() async {
    await context.read<DraftRepository>().clear();
    if (mounted) setState(() {});
  }

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

  Future<void> _edit(Listing l) async {
    await context.read<DraftRepository>().save(draftFromListing(l));
    if (!mounted) return;
    // The sell flow is about to open on this draft, so the app-scoped
    // controller has to pick up what was just written.
    setState(context.read<SellController>().reload);
    _startSelling(editing: true);
  }

  Future<void> _delete(Listing l) async {
    // Read before awaiting the dialog — the context can't be used across it.
    final listings = context.read<ListingsRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete this listing?'),
        content: const Text(
          'This removes it from the Buy feed. You can’t undo this.',
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
    final res = await listings.softDelete(l.id);
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
            // A sold listing is frozen — no re-marking sold, no editing.
            if (l.status == ListingStatus.active) ...[
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
            ],
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
    final hasDraft = context.read<DraftRepository>().hasDraft;

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton(
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
          final active = all
              .where((l) => l.status == ListingStatus.active)
              .toList();
          final sold = all
              .where((l) => l.status == ListingStatus.sold)
              .toList();
          final isEmpty = active.isEmpty && sold.isEmpty;

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
                if (active.isNotEmpty) ...[
                  const SectionHeader('Active'),
                  for (final l in active) _tile(l),
                ],
                if (sold.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space8),
                  const SectionHeader('Sold'),
                  for (final l in sold) _tile(l),
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
