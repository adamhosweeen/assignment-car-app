import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/recommendations_provider.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/widgets/common/search_field.dart';
import 'package:assignment/widgets/common/segmented_control.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/listing_card.dart';

/// The Buy feed. Two tabs at the top of the screen toggle between the
/// interest-matched **Recommended for you** list and the newest-first
/// **Newest listings** feed (V1_SPEC §4.4). Reuses the same [ListingCard] as
/// My Listings, without the status badge or row actions.
///
/// Grouped layout: grey background, white cards. The outer list pads
/// vertically only — each row insets itself.
class BuyFeedScreen extends ConsumerStatefulWidget {
  const BuyFeedScreen({super.key});

  @override
  ConsumerState<BuyFeedScreen> createState() => _BuyFeedScreenState();
}

class _BuyFeedScreenState extends ConsumerState<BuyFeedScreen> {
  /// 0 = Recommended for you, 1 = Newest listings.
  int _tab = 0;

  Future<void> _refresh() async {
    ref.invalidate(activeListingsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(activeListingsProvider);
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Buy'),
        // The tab switch sits above a fixed search bar; tapping the bar opens
        // the search screen (the bar itself never takes input).
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            AppSpacing.segmentHeight +
                AppSpacing.space12 +
                AppSpacing.searchBarHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              AppSpacing.space12,
            ),
            child: Column(
              children: [
                SegmentedControl(
                  labels: const ['Recommended for you', 'Newest listings'],
                  selected: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: AppSpacing.space12),
                SearchField(
                  hint: 'Search cars',
                  onTap: () => context.push('/search'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: async.when(
        loading: () => const _FeedSkeleton(),
        error: (_, _) => const _FeedMessage(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          message: 'We couldn’t load listings. Pull down to try again.',
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return _EmptyFeed(onSell: () => context.go('/home/sell'));
          }
          if (_tab == 0) {
            final recommended = ref.watch(recommendedListingsProvider);
            if (recommended.isEmpty) {
              return const _FeedMessage(
                icon: Icons.recommend_outlined,
                title: 'No recommendations yet',
                message:
                    'Set your car interests in your profile to see cars '
                    'picked for you.',
              );
            }
            return _RefreshableFeed(
              listings: recommended,
              onRefresh: _refresh,
              onTap: (id) => context.push('/listing/$id'),
            );
          }
          return _RefreshableFeed(
            listings: listings,
            onRefresh: _refresh,
            onTap: (id) => context.push('/listing/$id'),
          );
        },
      ),
    );
  }
}

/// A newest-first vertical feed of [ListingCard]s with pull-to-refresh.
class _RefreshableFeed extends StatelessWidget {
  const _RefreshableFeed({
    required this.listings,
    required this.onRefresh,
    required this.onTap,
  });

  final List<Listing> listings;
  final Future<void> Function() onRefresh;
  final void Function(String id) onTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.screenPadding,
        ),
        itemCount: listings.length,
        itemBuilder: (_, i) {
          final l = listings[i];
          return _Inset(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: i == listings.length - 1 ? 0 : AppSpacing.space16,
              ),
              child: ListingCard(
                listing: l,
                cover: CoverImage(media: l.cover),
                onTap: () => onTap(l.id),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Standard horizontal screen inset for a vertical feed row.
class _Inset extends StatelessWidget {
  const _Inset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
    child: child,
  );
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.onSell});

  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: AppSpacing.iconXl,
              color: AppColors.tertiaryLabel,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'No cars listed yet',
              style: text.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Be the first — sell your car.',
              style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space24),
            FilledButton(onPressed: onSell, child: const Text('Sell your car')),
          ],
        ),
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

/// Skeleton placeholders while the first fetch resolves (§4.4): the same
/// white card shape as [ListingCard] with tinted blocks where content goes.
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space16),
      itemBuilder: (_, _) => ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: ColoredBox(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ColoredBox(
                color: AppColors.fill,
                child: SizedBox(
                  width: double.infinity,
                  height: AppSpacing.coverHeight,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(height: AppSpacing.space20, widthFactor: 0.35),
                    const SizedBox(height: AppSpacing.space8),
                    _bar(height: AppSpacing.space16, widthFactor: 0.7),
                    const SizedBox(height: AppSpacing.space8),
                    _bar(height: AppSpacing.space12, widthFactor: 0.45),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar({required double height, double widthFactor = 1}) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: BorderRadius.circular(AppSpacing.radiusBar),
        ),
      ),
    );
  }
}
