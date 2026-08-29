import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/profile/profile.dart';

/// The Profile tab: view identity and log out (§4.8). Editing the display
/// name is a standalone pushed route ([EditProfileScreen]) reached via the
/// "Edit" app bar action.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently deletes your profile, your listings, their '
          'photos, and your login. This cannot be undone.',
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
    if (confirmed != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final res = await ref.read(authRepositoryProvider).deleteAccount();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    switch (res) {
      case Ok():
        // Also discard any local sell draft; the router redirect handles
        // navigation back to the login screen.
        await ref.read(draftRepositoryProvider).clear();
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmLogOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Log out?'),
        content: const Text('You’ll need to sign in with your email again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          async.maybeWhen(
            data: (profile) => profile == null
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => context.push('/profile/edit'),
                    child: const Text('Edit'),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Something went wrong. Pull down to try again.'),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('You’re signed out.'));
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Center(
                child: Column(
                  children: [
                    _Avatar(profile: profile),
                    const SizedBox(height: AppSpacing.space16),
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.title1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space32),
              GroupedSection(
                header: 'DETAILS',
                children: [
                  GroupedRow(label: 'Phone', value: profile.phone ?? 'Not set'),
                  GroupedRow(
                    label: 'Location',
                    value: profile.state ?? 'Not set',
                  ),
                  GroupedRow(
                    label: 'Date of birth',
                    value: profile.dob == null
                        ? 'Not set'
                        : formatDate(profile.dob!),
                  ),
                  GroupedRow(
                    label: 'Member since',
                    value: _formatDate(profile.createdAt),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              GroupedSection(
                header: 'CAR INTERESTS',
                children: [
                  GroupedRow(
                    label: 'Brands',
                    value: profile.interests.makes.isEmpty
                        ? 'Any'
                        : profile.interests.makes.join(', '),
                  ),
                  GroupedRow(
                    label: 'Body types',
                    value: profile.interests.bodyTypes.isEmpty
                        ? 'Any'
                        : profile.interests.bodyTypes
                              .map((b) => b.label)
                              .join(', '),
                  ),
                  GroupedRow(
                    label: 'Transmission',
                    value: profile.interests.transmission?.label ?? 'Any',
                  ),
                  GroupedRow(
                    label: 'Fuel type',
                    value: profile.interests.fuelType?.label ?? 'Any',
                  ),
                  GroupedRow(
                    label: 'Budget',
                    value: _formatBudget(profile.interests),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              GroupedSection(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _confirmLogOut(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space12,
                      ),
                      child: Center(
                        child: Text(
                          'Log out',
                          style: Theme.of(context).textTheme.headline.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              GroupedSection(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _confirmDeleteAccount(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space12,
                      ),
                      child: Center(
                        child: Text(
                          'Delete account',
                          style: Theme.of(context).textTheme.headline.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[local.month - 1]} ${local.year}';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final source = profile.displayName;
    final initial = source.isNotEmpty ? source[0].toUpperCase() : '?';

    return Container(
      width: AppSpacing.avatarLg,
      height: AppSpacing.avatarLg,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryMuted,
        border: Border.all(
          color: AppColors.primary,
          width: AppSpacing.avatarRingWidth,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(
          context,
        ).textTheme.largeTitle.copyWith(color: AppColors.primary),
      ),
    );
  }
}
