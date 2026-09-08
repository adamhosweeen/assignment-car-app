import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/notifications/notifications_providers.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/notifications/notification_avatar.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  Future<void> _open(BuildContext context, AppNotification n) async {
    if (!n.isRead) {
      context.read<NotificationsRepository>().markRead(n.id);
    }
    final route = n.route;
    if (route != null && context.mounted) Navigator.pushNamed(context, route);
  }

  Future<void> _delete(BuildContext context, AppNotification n) async {
    final res = await context.read<NotificationsRepository>().delete(n.id);
    if (!context.mounted) return;
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _markAllRead(BuildContext context) async {
    final res = await context.read<NotificationsRepository>().markAllRead();
    if (!context.mounted) return;
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AsyncSnapshot<List<AppNotification>>>();
    final unread = unreadCountOf(snapshot);

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => _markAllRead(context),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _body(context, snapshot),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncSnapshot<List<AppNotification>> snapshot,
  ) {
    if (snapshot.hasError) {
      return _Message(
        icon: Icons.error_outline,
        text: 'We couldn’t load your inbox. Check your connection.',
        onRetry: () => context.read<InboxFeed>().restart(),
      );
    }
    final items = snapshot.data;
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return const _Message(
        icon: Icons.inbox_outlined,
        text:
            'Nothing here yet. You’ll hear about cars that match your '
            'interests and new market data.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        GroupedSection(
          children: [
            for (final n in items)
              Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: const ColoredBox(
                  color: AppColors.destructive,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: AppSpacing.space16),
                      child: Icon(
                        Icons.delete_outline,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
                onDismissed: (_) => _delete(context, n),
                child: _InboxRow(
                  notification: n,
                  onTap: () => _open(context, n),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          child: Text(
            'Swipe left to delete.',
            style: Theme.of(
              context,
            ).textTheme.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
        ),
      ],
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final n = notification;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ColoredBox(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationAvatar(kind: n.kind),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: n.isRead ? text.body : text.headline,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      n.body,
                      maxLines: 2,
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
                    formatRelative(n.createdAt),
                    style: text.caption.copyWith(
                      color: AppColors.tertiaryLabel,
                    ),
                  ),
                  if (!n.isRead) ...[
                    const SizedBox(height: AppSpacing.space8),
                    Container(
                      width: AppSpacing.badgeDot,
                      height: AppSpacing.badgeDot,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.iconXl, color: AppColors.tertiaryLabel),
            const SizedBox(height: AppSpacing.space16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.body.copyWith(color: AppColors.secondaryLabel),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.space16),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
