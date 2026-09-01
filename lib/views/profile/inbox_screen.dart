import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/notifications/notifications_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';

/// Profile → Inbox: server-generated notifications (welcome, listings that
/// match your interests, market-insights refreshes). Live over realtime;
/// tap opens the linked screen and marks the row read; swipe left deletes.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    if (!n.isRead) {
      // Fire and forget — realtime refreshes the list; an error here is
      // cosmetic and shouldn't block navigation.
      ref.read(notificationsRepositoryProvider).markRead(n.id);
    }
    final route = n.route;
    if (route != null && context.mounted) context.push(route);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    final res = await ref.read(notificationsRepositoryProvider).delete(n.id);
    if (!context.mounted) return;
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    final res = await ref.read(notificationsRepositoryProvider).markAllRead();
    if (!context.mounted) return;
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inboxProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => _markAllRead(context, ref),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Message(
          icon: Icons.error_outline,
          text: 'We couldn’t load your inbox. Check your connection.',
          onRetry: () => ref.invalidate(inboxProvider),
        ),
        data: (items) {
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
                      onDismissed: (_) => _delete(context, ref, n),
                      child: _InboxRow(
                        notification: n,
                        onTap: () => _open(context, ref, n),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                child: Text(
                  'Swipe left to delete.',
                  style: Theme.of(context).textTheme.footnote.copyWith(
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
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon => switch (notification.kind) {
    NotificationKind.welcome => Icons.waving_hand_outlined,
    NotificationKind.listingMatch => Icons.directions_car_outlined,
    NotificationKind.insightsUpdated => Icons.bar_chart,
    NotificationKind.bidPlaced => Icons.gavel_outlined,
    NotificationKind.bidAccepted => Icons.check_circle_outline,
    NotificationKind.bidRejected => Icons.cancel_outlined,
  };

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
              Container(
                width: AppSpacing.avatarSm,
                height: AppSpacing.avatarSm,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryMuted,
                ),
                child: Icon(
                  _icon,
                  size: AppSpacing.iconMd,
                  color: AppColors.primary,
                ),
              ),
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
