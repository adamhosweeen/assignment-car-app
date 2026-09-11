import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/services/image_utils.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/user/profile_avatar.dart';

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

  Future<void> _changePhoto(BuildContext context, AppUser profile) async {
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
    final Future<Result<AppUser>> Function() run;
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
    final profile = context.watch<AppUser?>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _body(context, profile),
    );
  }

  Widget _body(BuildContext context, AppUser? profile) {
    if (profile == null) {
      return const Center(child: Text('You’re signed out.'));
    }
    final text = Theme.of(context).textTheme;
    final meta = [
      if (profile.state != null) profile.state!,
      'Member since ${formatMonthYear(profile.createdAt)}',
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Center(
          child: Column(
            children: [
              ProfileAvatar.fromUser(
                profile,
                onTap: () => _changePhoto(context, profile),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                profile.name,
                style: text.title1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                profile.email,
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                meta,
                style: text.footnote.copyWith(color: AppColors.tertiaryLabel),
                textAlign: TextAlign.center,
              ),
              if (profile.isAdmin) ...[
                const SizedBox(height: AppSpacing.space8),
                const _Tag('Admin'),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space32),
        GroupedSection(
          header: 'Account',
          children: [
            GroupedRow(
              leading: Icons.mail_outline,
              label: 'Inbox',
              showChevron: true,
              onTap: () => Navigator.pushNamed(context, '/profile/inbox'),
            ),
            GroupedRow(
              leading: Icons.person_outline,
              label: 'My Info',
              showChevron: true,
              onTap: () => Navigator.pushNamed(context, '/profile/info'),
            ),
            GroupedRow(
              leading: Icons.favorite_outline,
              label: 'Car Interests',
              showChevron: true,
              onTap: () => Navigator.pushNamed(context, '/profile/interests'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        GroupedSection(
          header: 'Marketplace',
          children: [
            GroupedRow(
              leading: Icons.receipt_long_outlined,
              label: 'Purchases',
              showChevron: true,
              onTap: () => Navigator.pushNamed(context, '/profile/purchases'),
            ),
            GroupedRow(
              leading: Icons.search,
              label: 'Find Sellers',
              showChevron: true,
              onTap: () => Navigator.pushNamed(context, '/sellers'),
            ),
            GroupedRow(
              leading: Icons.bar_chart,
              label: 'Market Insights',
              showChevron: true,
              onTap: () => Navigator.pushNamed(context, '/profile/insights'),
            ),
          ],
        ),
        if (profile.isAdmin) ...[
          const SizedBox(height: AppSpacing.space24),
          GroupedSection(
            header: 'Moderation',
            children: [
              GroupedRow(
                leading: Icons.admin_panel_settings_outlined,
                label: 'Admin',
                showChevron: true,
                onTap: () => Navigator.pushNamed(context, '/admin'),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.space24),
        GroupedSection(
          children: [
            _CentredActionRow(
              label: 'Log out',
              onTap: () => _confirmLogOut(context),
            ),
            _CentredActionRow(
              label: 'Delete account',
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space16),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4 / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusBar),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.caption.copyWith(color: AppColors.primary),
      ),
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
