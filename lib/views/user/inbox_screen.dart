import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/inbox/inbox_repository.dart';
import 'package:assignment/model/user/inbox_message.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future<List<InboxMessage>> _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final inbox = context.read<InboxRepository>();
    _items = inbox.list().then(
      (res) => switch (res) {
        Ok(:final value) => value,
        Err(:final message) => throw InboxException(message),
      },
    );
  }

  Future<void> _open(InboxMessage message) async {
    if (!message.isRead) {
      await context.read<InboxRepository>().markRead(message.id);
      if (!mounted) return;
      setState(_load);
    }
    final route = message.route;
    if (route != null && mounted) {
      await Navigator.pushNamed(context, route);
    }
  }

  Future<void> _delete(InboxMessage message) async {
    final res = await context.read<InboxRepository>().delete(message.id);
    if (!mounted) return;
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Inbox')),
      body: FutureBuilder<List<InboxMessage>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            return _Message(
              icon: Icons.error_outline,
              text: error is InboxException
                  ? error.message
                  : 'We couldn’t load your inbox. Check your connection.',
              onRetry: () => setState(_load),
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
                  'saved interests.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              GroupedSection(
                children: [
                  for (final message in items)
                    Dismissible(
                      key: ValueKey(message.id),
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
                      onDismissed: (_) => _delete(message),
                      child: _InboxRow(
                        message: message,
                        onTap: () => _open(message),
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

class InboxException implements Exception {
  const InboxException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.message, required this.onTap});

  final InboxMessage message;
  final VoidCallback onTap;

  static IconData iconFor(InboxKind kind) => switch (kind) {
    InboxKind.welcome => Icons.waving_hand_outlined,
    InboxKind.listingMatch => Icons.directions_car_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
                  iconFor(message.kind),
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
                      message.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: message.isRead ? text.body : text.headline,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      message.body,
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
                    formatRelative(message.createdAt),
                    style: text.caption.copyWith(
                      color: AppColors.tertiaryLabel,
                    ),
                  ),
                  if (!message.isRead) ...[
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
