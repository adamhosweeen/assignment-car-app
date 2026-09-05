import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:assignment/control/notifications/notifications_providers.dart';
import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/control/services/image_utils.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

enum _PhotoAction { camera, gallery, remove }

extension on _PhotoAction {
  String get label => switch (this) {
    _PhotoAction.camera => 'Take photo',
    _PhotoAction.gallery => 'Choose from library',
    _PhotoAction.remove => 'Remove photo',
  };
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _changePhoto(BuildContext context, Profile profile) async {
    final action = await showSelectSheet<_PhotoAction>(
      context: context,
      title: 'Profile photo',
      options: [
        _PhotoAction.camera,
        _PhotoAction.gallery,
        if (profile.avatarUrl != null) _PhotoAction.remove,
      ],
      labelOf: (a) => a.label,
    );
    if (action == null || !context.mounted) return;

    final auth = context.read<AuthRepository>();
    final Future<Result<Profile>> Function() run;
    if (action == _PhotoAction.remove) {
      run = auth.removeAvatar;
    } else {
      final picked = await ImagePicker().pickImage(
        source: action == _PhotoAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
      if (picked == null || !context.mounted) return;
      run = () async {
        final path = await compressImage(
          picked.path,
          maxDimension: avatarMaxDimension,
          quality: avatarQuality,
        );
        return auth.updateAvatar(path);
      };
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final res = await run();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final auth = context.read<AuthRepository>();
    final drafts = context.read<DraftRepository>();
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
    final res = await auth.deleteAccount();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    switch (res) {
      case Ok():
        await drafts.clear();
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmLogOut(BuildContext context) async {
    final auth = context.read<AuthRepository>();
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
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<Profile?>();
    final unread = unreadCountOf(
      context.watch<AsyncSnapshot<List<AppNotification>>>(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _body(context, profile, unread),
    );
  }

  Widget _body(BuildContext context, Profile? profile, int unread) {
    if (profile == null) {
      return const Center(child: Text('You’re signed out.'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Center(
          child: Column(
            children: [
              ProfileAvatar.fromProfile(
                profile,
                onTap: () => _changePhoto(context, profile),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.title1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                profile.email,
                style: Theme.of(
                  context,
                ).textTheme.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space32),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Inbox',
              value: unread == 0 ? null : '$unread new',
              valueColor: AppColors.primary,
              showChevron: true,
              onTap: () => context.push('/profile/inbox'),
            ),
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
              label: 'Purchases',
              showChevron: true,
              onTap: () => context.push('/profile/purchases'),
            ),
            GroupedRow(
              label: 'Market Insights',
              showChevron: true,
              onTap: () => context.push('/profile/insights'),
            ),
            GroupedRow(
              label: 'Find Sellers',
              showChevron: true,
              onTap: () => context.push('/sellers'),
            ),
            if (profile.isAdmin)
              GroupedRow(
                label: 'Admin',
                showChevron: true,
                onTap: () => context.push('/admin'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        GroupedSection(
          children: [
            _CentredActionRow(
              label: 'Log out',
              onTap: () => _confirmLogOut(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        GroupedSection(
          children: [
            _CentredActionRow(
              label: 'Delete account',
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ),
      ],
    );
  }
}

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
