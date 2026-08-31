import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/admin/admin_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/admin/admin_user_stats.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/search_field.dart';
import 'package:assignment/widgets/common/segmented_control.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

/// The Users tab of the Admin screen: every user with how many cars they have
/// listed and sold, searchable and sortable, with ban/unban in the detail
/// sheet. Reads the guarded `admin_user_stats()` RPC — a non-admin reaching
/// this just sees the error state.
class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({super.key});

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab> {
  AdminSort _sort = AdminSort.newest;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmSetBanned(AdminUserStats user, bool ban) async {
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
    final res = await ref.read(adminRepositoryProvider).setBanned(user.id, ban);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    switch (res) {
      case Ok():
        ref.invalidate(adminUsersProvider);
        ref.invalidate(adminReportsProvider);
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showDetails(AdminUserStats user) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.groupedBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(
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
                  GroupedRow(label: 'Role', value: user.role),
                  GroupedRow(
                    label: 'Banned',
                    value: user.banned ? 'Yes' : 'No',
                    valueColor: user.banned ? AppColors.destructive : null,
                  ),
                  GroupedRow(label: 'Email', value: user.email ?? '—'),
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
                  GroupedRow(label: 'Listed', value: '${user.activeCount}'),
                  GroupedRow(label: 'Sold', value: '${user.soldCount}'),
                ],
              ),
              if (user.id !=
                  ref.read(authRepositoryProvider).currentUser?.id) ...[
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
    final async = ref.watch(adminUsersProvider);
    final text = Theme.of(context).textTheme;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$e',
                textAlign: TextAlign.center,
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space16),
              TextButton(
                onPressed: () => ref.invalidate(adminUsersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users yet.',
              style: text.subhead.copyWith(color: AppColors.secondaryLabel),
            ),
          );
        }
        final visible = sortAdminUsers(filterAdminUsers(users, _query), _sort);
        final totalActive = users.fold(0, (n, u) => n + u.activeCount);
        final totalSold = users.fold(0, (n, u) => n + u.soldCount);

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminUsersProvider),
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

/// One user: avatar, name (+ Admin tag), state · joined, counts on the right.
class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onTap});

  final AdminUserStats user;
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
            ProfileAvatar(
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
                  '${user.activeCount} listed',
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
                Text(
                  '${user.soldCount} sold',
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
