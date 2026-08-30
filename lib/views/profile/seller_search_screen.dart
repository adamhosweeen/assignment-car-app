import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/search_scaffold.dart';
import 'package:assignment/widgets/profile/seller_row.dart';

/// Profile → Find Sellers: look up other users by name and open their public
/// seller page (V1_SPEC §4.10).
class SellerSearchScreen extends StatelessWidget {
  const SellerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
      hint: 'Search sellers',
      idleText: 'Search sellers by name to see the cars they’re selling.',
      resultsBuilder: (context, query) => _Results(query: query),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sellerSearchProvider(query));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => SearchMessage(
        icon: Icons.error_outline,
        text: error is ProfilesException
            ? error.message
            : 'We couldn’t search right now. Check your connection.',
        onRetry: () => ref.invalidate(sellerSearchProvider(query)),
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return SearchMessage(
            icon: Icons.person_search_outlined,
            text: 'No sellers match “$query”.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            GroupedSection(
              children: [
                for (final p in profiles)
                  SellerRow(
                    profile: p,
                    onTap: () => context.push('/seller/${p.id}'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
