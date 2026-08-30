import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

/// Chat tab: every thread the signed-in user is part of, most recent
/// activity first, live over realtime.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(conversationsProvider);
    final uid = ref.watch(authRepositoryProvider).currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Chat')),
      body: uid == null
          ? const _StateMessage(
              icon: Icons.chat_bubble_outline,
              text: 'Sign in to message sellers and buyers.',
            )
          : async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _StateMessage(
                icon: Icons.error_outline,
                text: 'We couldn’t load your chats. Check your connection.',
                onRetry: () => ref.invalidate(conversationsProvider),
              ),
              data: (threads) {
                if (threads.isEmpty) {
                  return const _StateMessage(
                    icon: Icons.chat_bubble_outline,
                    text:
                        'No conversations yet. Message a seller from a '
                        'listing to start one.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: [
                    GroupedSection(
                      children: [
                        for (final thread in threads)
                          _ConversationRow(
                            thread: thread,
                            currentUserId: uid,
                            onTap: () => context.push(
                              '/chat/${thread.conversation.id}',
                              extra: thread.conversation,
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
}

class _ConversationRow extends ConsumerWidget {
  const _ConversationRow({
    required this.thread,
    required this.currentUserId,
    required this.onTap,
  });

  final ConversationThread thread;
  final String currentUserId;
  final VoidCallback onTap;

  String _preview(BuildContext context) {
    final last = thread.lastMessage;
    if (last == null) return 'No messages yet';
    if (last.messageType == MessageType.offer && last.offerAmountMyr != null) {
      return 'Offer: ${formatPrice(last.offerAmountMyr!)}';
    }
    return last.body;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final unread = thread.unreadCount > 0;
    final otherId = thread.conversation.otherParticipantId(currentUserId);
    final profileAsync = ref.watch(publicProfileProvider(otherId));
    final listingAsync = ref.watch(
      listingByIdProvider(thread.conversation.listingId),
    );
    final name = profileAsync.value?.name ?? 'Seller';
    final avatarUrl = profileAsync.value?.avatarUrl;
    final listingTitle = listingAsync.value?.title;
    final when =
        thread.conversation.lastMessageAt ?? thread.conversation.createdAt;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(
              name: name,
              avatarUrl: avatarUrl,
              size: AppSpacing.avatarSm,
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: unread ? text.headline : text.body,
                  ),
                  if (listingTitle != null)
                    Text(
                      listingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.footnote.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    _preview(context),
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
                  formatRelative(when),
                  style: text.caption.copyWith(color: AppColors.tertiaryLabel),
                ),
                if (unread) ...[
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
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.text, this.onRetry});

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
