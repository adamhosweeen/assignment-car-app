import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/recommendations_provider.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/listing_card.dart';
import 'package:assignment/widgets/listing/listing_card_compact.dart';

/// The Buy feed: newest-first list of every active listing (V1_SPEC §4.4).
/// No search / filters / sort in v1. Reuses the same [ListingCard] as
/// My Listings, without the status badge or row actions.
class BuyFeedScreen extends ConsumerWidget {
  const BuyFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activeListingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Buy')),
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
          final recommended = ref.watch(recommendedListingsProvider);
          final hasRecommended = recommended.isNotEmpty;
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeListingsProvider);
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: listings.length + (hasRecommended ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.space24),
              itemBuilder: (_, i) {
                if (hasRecommended && i == 0) {
                  return _RecommendedRow(listings: recommended);
                }
                final l = listings[hasRecommended ? i - 1 : i];
                return ListingCard(
                  listing: l,
                  cover: CoverImage(media: l.cover),
                  onTap: () => context.push('/listing/${l.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Horizontal strip of interest-matched listings above the newest-first feed.
class _RecommendedRow extends StatelessWidget {
  const _RecommendedRow({required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.space4,
            bottom: AppSpacing.space12,
          ),
          child: Text(
            'RECOMMENDED FOR YOU',
            style: text.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
        ),
        SizedBox(
          height: AppSpacing.recommendRowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: listings.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.space12),
            itemBuilder: (context, i) {
              final l = listings[i];
              return ListingCardCompact(
                listing: l,
                cover: CoverImage(
                  media: l.cover,
                  height: AppSpacing.recommendCoverHeight,
                ),
                onTap: () => context.push('/listing/${l.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
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

/// Skeleton placeholders while the first fetch resolves (§4.4).
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space24),
      itemBuilder: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(height: AppSpacing.coverHeight, radius: AppSpacing.radiusCard),
          const SizedBox(height: AppSpacing.space12),
          _bar(height: AppSpacing.space20, widthFactor: 0.6),
          const SizedBox(height: AppSpacing.space8),
          _bar(height: AppSpacing.space16, widthFactor: 0.3),
        ],
      ),
    );
  }

  Widget _bar({
    required double height,
    double widthFactor = 1,
    double radius = AppSpacing.radiusInput,
  }) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.groupedBackground,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
