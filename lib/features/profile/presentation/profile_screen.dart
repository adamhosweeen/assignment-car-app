import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_theme.dart';
import '../../../shared/widgets/grouped_section.dart';
import '../domain/profile.dart';

/// The Profile tab: view identity and log out (§4.8). Editing the display
/// name is a standalone pushed route ([EditProfileScreen]) reached via the
/// "Edit" app bar action.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Log out?'),
        content: const Text('You’ll need to verify your phone number again.'),
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
                      profile.displayName?.trim().isNotEmpty == true
                          ? profile.displayName!.trim()
                          : 'Add a display name',
                      style: Theme.of(context).textTheme.title1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      profile.phone,
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
                    label: 'Member since',
                    value: _formatDate(profile.createdAt),
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
            ],
          );
        },
      ),
    );
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
    final source = profile.displayName?.trim().isNotEmpty == true
        ? profile.displayName!.trim()
        : profile.phone;
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
