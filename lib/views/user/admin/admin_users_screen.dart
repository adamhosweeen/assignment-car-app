import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/admin/admin_providers.dart';
import 'package:assignment/control/user/admin/admin_repository.dart';
import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/search_field.dart';
import 'package:assignment/widgets/common/segmented_control.dart';
import 'package:assignment/widgets/user/user_avatar.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({
    super.key,
    required this.users,
    required this.onChanged,
  });

  final Future<List<AppUser>> users;

  final VoidCallback onChanged;

  @override
  State<AdminUsersTab> createState() => _AppUsersTabState();
}

class _AppUsersTabState extends State<AdminUsersTab> {
  AdminSort _sort = AdminSort.newest;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmSetBanned(AppUser user, bool ban) async {
    final admin = context.read<AdminRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(ban ? 'Ban ${user.name}?' : 'Unban ${user.name}?'),
        content: Text(
          ban
              ? 'They won’t be able to log in again and their cars disappear '
                    'from buyers until they are unbanned.'
              : 'They will be able to log in again and their cars become '
                    'visible to buyers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ban
                ? TextButton.styleFrom(foregroundColor: AppColors.destructive)
                : null,
            child: Text(ban ? 'Ban' : 'Unban'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final res = await admin.setBanned(user.id, ban);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    switch (res) {
      case Ok():
        widget.onChanged();
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDelete(AppUser user) async {
    final admin = context.read<AdminRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(user: user),
    );
    if (confirmed != true || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final res = await admin.deleteUser(user.id, avatarUrl: user.avatarUrl);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    switch (res) {
      case Ok():
        widget.onChanged();
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showDetails(AppUser user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.groupedBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    name: user.name,
                    avatarUrl: user.avatarUrl,
                    size: AppSpacing.avatarSm,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Text(
                      user.name,
                      style: Theme.of(context).textTheme.title3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              GroupedSection(
                children: [
                  GroupedRow(label: 'Role', value: user.role.name),
                  GroupedRow(
                    label: 'Banned',
                    value: user.banned ? 'Yes' : 'No',
                    valueColor: user.banned ? AppColors.destructive : null,
                  ),
                  GroupedRow(
                    label: 'Email',
                    value: user.email.isEmpty ? '—' : user.email,
                  ),
                  GroupedRow(label: 'Phone', value: user.phone ?? '—'),
                  GroupedRow(
                    label: 'Date of birth',
                    value: user.dob == null ? '—' : formatDate(user.dob!),
                  ),
                  GroupedRow(label: 'State', value: user.state ?? '—'),
                  GroupedRow(
                    label: 'Joined',
                    value: formatDate(user.createdAt),
                  ),
                  GroupedRow(
                    label: 'Listed',
                    value: '${user.activeCount ?? 0}',
                  ),
                  GroupedRow(label: 'Sold', value: '${user.soldCount ?? 0}'),
                ],
              ),
              if (user.id !=
                  context.read<AuthRepository>().currentUser?.id) ...[
                const SizedBox(height: AppSpacing.space16),
                FilledButton(
                  style: user.banned
                      ? null
                      : FilledButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                        ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _confirmSetBanned(user, !user.banned);
                  },
                  child: Text(user.banned ? 'Unban user' : 'Ban user'),
                ),
                if (!user.isAdmin) ...[
                  const SizedBox(height: AppSpacing.space8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmDelete(user);
                    },
                    child: Center(child: const Text('Delete user')),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.space8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return FutureBuilder<List<AppUser>>(
      future: widget.users,
      builder: (context, snapshot) {
        final error = snapshot.error;
        if (error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: text.subhead.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  TextButton(
                    onPressed: widget.onChanged,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final users = snapshot.data;
        if (users == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users yet.',
              style: text.subhead.copyWith(color: AppColors.secondaryLabel),
            ),
          );
        }
        final visible = sortUsers(filterUsers(users, _query), _sort);
        final totalActive = users.fold(0, (n, u) => n + (u.activeCount ?? 0));
        final totalSold = users.fold(0, (n, u) => n + (u.soldCount ?? 0));

        return RefreshIndicator(
          onRefresh: () async => widget.onChanged(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              SearchField(
                hint: 'Search name, email, phone or state',
                controller: _search,
                onChanged: (q) => setState(() => _query = q),
              ),
              const SizedBox(height: AppSpacing.space12),
              SegmentedControl(
                labels: const ['Newest', 'Listed', 'Sold'],
                selected: _sort.index,
                onChanged: (i) => setState(() => _sort = AdminSort.values[i]),
              ),
              const SizedBox(height: AppSpacing.space16),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space32,
                  ),
                  child: Center(
                    child: Text(
                      'No users match “${_query.trim()}”.',
                      style: text.subhead.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ),
                )
              else
                GroupedSection(
                  children: [
                    for (final user in visible)
                      _UserRow(user: user, onTap: () => _showDetails(user)),
                  ],
                ),
              const SizedBox(height: AppSpacing.space16),
              Center(
                child: Text(
                  '${users.length} users · $totalActive listed · '
                  '$totalSold sold',
                  style: text.caption.copyWith(color: AppColors.tertiaryLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onTap});

  final AppUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final subtitle = [
      if (user.state != null) user.state!,
      'joined ${formatMonthYear(user.createdAt)}',
    ].join(' · ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Row(
          children: [
            UserAvatar(
              name: user.name,
              avatarUrl: user.avatarUrl,
              size: AppSpacing.avatarSm,
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.body,
                        ),
                      ),
                      if (user.isAdmin) ...[
                        const SizedBox(width: AppSpacing.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space8,
                            vertical: AppSpacing.space4 / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusBar,
                            ),
                          ),
                          child: Text(
                            'Admin',
                            style: text.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                      if (user.banned) ...[
                        const SizedBox(width: AppSpacing.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space8,
                            vertical: AppSpacing.space4 / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.destructiveMuted,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusBar,
                            ),
                          ),
                          child: Text(
                            'Banned',
                            style: text.caption.copyWith(
                              color: AppColors.destructive,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.footnote.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.activeCount ?? 0} listed',
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
                Text(
                  '${user.soldCount ?? 0} sold',
                  style: text.footnote.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDeleteDialog extends StatefulWidget {
  const _ConfirmDeleteDialog({required this.user});

  final AppUser user;

  @override
  State<_ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<_ConfirmDeleteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = widget.user;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Delete ${user.name}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This cannot be undone. Their listings, chats, bids and purchase '
            'history are removed, along with any reports about them. Buyers '
            'keep the receipts for cars this user sold.',
            style: text.subhead.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            'Type ${user.name} to confirm.',
            style: text.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.space8),
          TextField(controller: _controller, autofocus: true),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, _) => TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            onPressed: value.text.trim() == user.name
                ? () => Navigator.pop(context, true)
                : null,
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}
