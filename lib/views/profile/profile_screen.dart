import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';

/// The Profile tab (§4.8): identity header, then a hub of three rows that each
/// push their own screen — My Info, Car Interests, Market Insights — followed
/// by the destructive Log out / Delete account rows.
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
      appBar: AppBar(title: const Text('Profile')),
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
                children: [
                  GroupedRow(
                    label: 'My Info',
                    showChevron: true,
                    onTap: () => context.push('/profile/info'),
                  ),
                  GroupedRow(
                    label: 'Car Interests',
                    showChevron: true,
                    onTap: () => context.push('/profile/interests'),
                  ),
                  GroupedRow(
                    label: 'Market Insights',
                    showChevron: true,
                    onTap: () => context.push('/profile/insights'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              GroupedSection(
                children: [
                  _CentredActionRow(
                    label: 'Log out',
                    onTap: () => _confirmLogOut(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              GroupedSection(
                children: [
                  _CentredActionRow(
                    label: 'Delete account',
                    onTap: () => _confirmDeleteAccount(context, ref),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A full-width, centred destructive action inside a grouped card.
class _CentredActionRow extends StatelessWidget {
  const _CentredActionRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
        child: Center(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.headline.copyWith(color: AppColors.destructive),
          ),
        ),
      ),
    );
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
