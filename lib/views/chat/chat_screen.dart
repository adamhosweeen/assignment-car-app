import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    context.read<ConversationsFeed>().restart();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AsyncSnapshot<List<ConversationThread>>>();
    final uid = context.read<AuthRepository>().currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Chat')),
      body: uid == null
          ? const _StateMessage(
              icon: Icons.chat_bubble_outline,
              text: 'Sign in to message sellers and buyers.',
            )
          : _body(context, snapshot, uid),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncSnapshot<List<ConversationThread>> snapshot,
    String uid,
  ) {
    if (snapshot.hasError) {
      return _StateMessage(
        icon: Icons.error_outline,
        text: 'We couldn’t load your chats. Check your connection.',
        onRetry: () => context.read<ConversationsFeed>().restart(),
      );
    }
    final threads = snapshot.data;
    if (threads == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (threads.isEmpty) {
      return const _StateMessage(
        icon: Icons.chat_bubble_outline,
        text:
            'No conversations yet. Message a seller from a '
            'listing to start one.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          GroupedSection(
            children: [
              for (final thread in threads)
                _ConversationRow(
                  thread: thread,
                  currentUserId: uid,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/chat/${thread.conversation.id}',
                    arguments: thread.conversation,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends StatefulWidget {
  const _ConversationRow({
    required this.thread,
    required this.currentUserId,
    required this.onTap,
  });

  final ConversationThread thread;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  State<_ConversationRow> createState() => _ConversationRowState();
}

class _ConversationRowState extends State<_ConversationRow> {
  late Future<PublicProfile?> _profile;
  late Future<Listing> _listing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_ConversationRow old) {
    super.didUpdateWidget(old);
    final conversation = widget.thread.conversation;
    if (conversation.id != old.thread.conversation.id ||
        widget.currentUserId != old.currentUserId) {
      _load();
    }
  }

  void _load() {
    final otherId = widget.thread.conversation.otherParticipantId(
      widget.currentUserId,
    );
    _profile = fetchPublicProfile(context.read<ProfilesRepository>(), otherId);
    _listing = fetchListingById(
      context.read<ListingsRepository>(),
      widget.thread.conversation.listingId,
    );
  }

  String get _preview {
    final last = widget.thread.lastMessage;
    if (last == null) return 'No messages yet';
    if (last.messageType == MessageType.offer && last.offerAmountMyr != null) {
      return 'Offer: ${formatPrice(last.offerAmountMyr!)}';
    }
    return last.body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PublicProfile?>(
      future: _profile,
      builder: (context, profile) => FutureBuilder<Listing>(
        future: _listing,
        builder: (context, listing) =>
            _row(context, profile.data, listing.data),
      ),
    );
  }

  Widget _row(BuildContext context, PublicProfile? profile, Listing? listing) {
    final thread = widget.thread;
    final onTap = widget.onTap;
    final text = Theme.of(context).textTheme;
    final unread = thread.unreadCount > 0;
    final name = profile?.name ?? 'Seller';
    final avatarUrl = profile?.avatarUrl;
    final listingTitle = listing?.title;
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
                    _preview,
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
