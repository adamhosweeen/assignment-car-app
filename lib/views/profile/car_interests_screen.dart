import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';

/// Profile → Car Interests: the saved questionnaire answers that drive the
/// "Recommended for you" row. Read-only here; edited on Edit Profile.
class CarInterestsScreen extends ConsumerWidget {
  const CarInterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(authStateProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Interests'),
        actions: [
          if (async.value != null)
            TextButton(
              onPressed: () => context.push('/profile/edit'),
              child: const Text('Edit'),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Something went wrong. Go back and try again.'),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('You’re signed out.'));
          }
          final interests = profile.interests;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              GroupedSection(
                header: 'PREFERENCES',
                children: [
                  GroupedRow(
                    label: 'Brands',
                    value: interests.makes.isEmpty
                        ? 'Any'
                        : interests.makes.join(', '),
                  ),
                  GroupedRow(
                    label: 'Body types',
                    value: interests.bodyTypes.isEmpty
                        ? 'Any'
                        : interests.bodyTypes.map((b) => b.label).join(', '),
                  ),
                  GroupedRow(
                    label: 'Transmission',
                    value: interests.transmission?.label ?? 'Any',
                  ),
                  GroupedRow(
                    label: 'Fuel type',
                    value: interests.fuelType?.label ?? 'Any',
                  ),
                  GroupedRow(label: 'Budget', value: _formatBudget(interests)),
                ],
              ),
              const SizedBox(height: AppSpacing.space12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                child: Text(
                  interests.isEmpty
                      ? 'Set some preferences to get a “Recommended for you” '
                            'row on the Buy tab.'
                      : 'These shape the “Recommended for you” row on the '
                            'Buy tab.',
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatBudget(CarInterests interests) {
    final min = interests.budgetMinMyr;
    final max = interests.budgetMaxMyr;
    if (min != null && max != null) {
      return '${formatPrice(min)} – ${formatPrice(max)}';
    }
    if (min != null) return 'From ${formatPrice(min)}';
    if (max != null) return 'Up to ${formatPrice(max)}';
    return 'Any';
  }
}
