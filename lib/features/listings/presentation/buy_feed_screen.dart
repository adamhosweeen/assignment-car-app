import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_spacing.dart';
import '../../../theme/app_theme.dart';
import 'listings_providers.dart';
import 'widgets/cover_image.dart';
import 'widgets/listing_card.dart';

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
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeListingsProvider);
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: listings.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.space24),
              itemBuilder: (_, i) {
                final l = listings[i];
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
