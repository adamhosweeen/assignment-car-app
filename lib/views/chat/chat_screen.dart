import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/user/user_providers.dart';
import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/user/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Threads hidden locally while waiting for the server to confirm it.
  final Set<String> _pendingHiddenIds = {};

  Future<void> _refresh(BuildContext context) async {
    context.read<ConversationsFeed>().restart();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void _prunePendingHidden(List<ConversationThread> threads) {
    if (_pendingHiddenIds.isEmpty) return;
    final ids = threads.map((t) => t.conversation.id).toSet();
    final stale = _pendingHiddenIds.difference(ids);
    if (stale.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _pendingHiddenIds.removeAll(stale));
    });
  }

  // Hides a conversation on the server before removing its row.
  Future<bool> _confirmHide(ConversationThread thread) async {
    final res = await context.read<ChatRepository>().hideConversation(
      thread.conversation.id,
    );
    if (!mounted) return false;
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return false;
    }
    return true;
  }

  void _forgetHidden(ConversationThread thread) {
    setState(() => _pendingHiddenIds.add(thread.conversation.id));
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
    final allThreads = snapshot.data;
    if (allThreads == null) {
      return const Center(child: CircularProgressIndicator());
    }
    _prunePendingHidden(allThreads);
    final threads = [
      for (final t in allThreads)
        if (!_pendingHiddenIds.contains(t.conversation.id)) t,
    ];
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
                Dismissible(
                  key: ValueKey(thread.conversation.id),
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
                  confirmDismiss: (_) => _confirmHide(thread),
                  onDismissed: (_) => _forgetHidden(thread),
                  child: _ConversationRow(
                    thread: thread,
                    currentUserId: uid,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chat/${thread.conversation.id}',
                      arguments: thread.conversation,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Text(
              'Swipe left to hide a chat.',
              style: Theme.of(
                context,
              ).textTheme.footnote.copyWith(color: AppColors.secondaryLabel),
            ),
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
  late Future<AppUser?> _profile;
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
    _profile = fetchUser(context.read<UsersRepository>(), otherId);
    _listing = fetchListingById(
      context.read<ListingsRepository>(),
      widget.thread.conversation.listingId,
    );
  }

  String get _preview {
    final last = widget.thread.lastMessage;
    if (last == null) return 'No messages yet';
    if (last.isRecalled) return 'Message recalled';
    if (last.messageType == MessageType.offer && last.offerAmountMyr != null) {
      return 'Offer: ${formatPrice(last.offerAmountMyr!)}';
    }
    if (last.messageType == MessageType.image) return '📷 Photo';
    return last.body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _profile,
      builder: (context, profile) => FutureBuilder<Listing>(
        future: _listing,
        builder: (context, listing) =>
            _row(context, profile.data, listing.data),
      ),
    );
  }

  Widget _row(BuildContext context, AppUser? profile, Listing? listing) {
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
            UserAvatar(
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
