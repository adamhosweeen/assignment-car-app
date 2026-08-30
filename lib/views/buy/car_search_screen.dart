import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/widgets/common/search_scaffold.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/listing_card.dart';

/// Buy → search: active listings whose make, model, or variant contains the
/// typed text (server-side, debounced). No filters or sort (V1_SPEC §4.10).
class CarSearchScreen extends StatelessWidget {
  const CarSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
      hint: 'Search cars',
      idleText: 'Search by make, model or variant — e.g. “Myvi” or “Civic”.',
      resultsBuilder: (context, query) => _Results(query: query),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(carSearchProvider(query));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => SearchMessage(
        icon: Icons.error_outline,
        text: 'We couldn’t search right now. Check your connection.',
        onRetry: () => ref.invalidate(carSearchProvider(query)),
      ),
      data: (listings) {
        if (listings.isEmpty) {
          return SearchMessage(text: 'No cars match “$query”.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: listings.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSpacing.space16),
          itemBuilder: (_, i) {
            final l = listings[i];
            return ListingCard(
              listing: l,
              cover: CoverImage(media: l.cover),
              onTap: () => context.push('/listing/${l.id}'),
            );
          },
        );
      },
    );
  }
}
