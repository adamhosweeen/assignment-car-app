import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';

/// One conversation thread, reached from the Chat tab or "Chat with seller"
/// on Listing Detail. Takes the full [Conversation] via route `extra` — both
/// entry points already have one in hand, so there's no separate
/// "get conversation by id" fetch.
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Fire and forget — a failure here is cosmetic, the badge just won't clear.
    ref.read(chatRepositoryProvider).markRead(widget.conversation.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    final res = await ref
        .read(chatRepositoryProvider)
        .send(widget.conversation.id, text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final conversation = widget.conversation;
    final uid = ref.watch(authRepositoryProvider).currentUser?.id;
    final otherId = uid == null
        ? conversation.sellerId
        : conversation.otherParticipantId(uid);
    final profile = ref.watch(publicProfileProvider(otherId)).value;
    final listing = ref
        .watch(listingByIdProvider(conversation.listingId))
        .value;
    final messagesAsync = ref.watch(messagesProvider(conversation.id));

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // listingByIdProvider is a one-shot fetch, not realtime — this
            // screen keeps watching it underneath the pushed route, so
            // without invalidating first the detail screen would just reuse
            // whatever was cached from before the listing was marked sold.
            ref.invalidate(listingByIdProvider(conversation.listingId));
            context.push('/listing/${conversation.listingId}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(profile?.name ?? 'Chat', style: text.headline),
              if (listing != null)
                Text(
                  listing.status == ListingStatus.sold
                      ? '${listing.title} · Sold'
                      : listing.title,
                  style: text.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _CenteredNote(
                text:
                    'We couldn’t load this conversation. Check your '
                    'connection.',
              ),
              data: (msgs) {
                if (msgs.isEmpty) {
                  return const _CenteredNote(
                    text: 'No messages yet. Say hello.',
                  );
                }
                _scrollToBottom();
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) => _MessageBubble(
                    message: msgs[i],
                    isMine: uid != null && msgs[i].isMine(uid),
                  ),
                );
              },
            ),
          ),
          _Composer(controller: _controller, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

class _CenteredNote extends StatelessWidget {
  const _CenteredNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.body.copyWith(color: AppColors.secondaryLabel),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = isMine ? AppColors.onPrimary : AppColors.label;
    final isOffer =
        message.messageType == MessageType.offer &&
        message.offerAmountMyr != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space12,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : AppColors.groupedBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOffer)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                      child: Text(
                        'Offer: ${formatPrice(message.offerAmountMyr!)}',
                        style: text.headline.copyWith(color: fg),
                      ),
                    ),
                  Text(message.body, style: text.body.copyWith(color: fg)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.separator,
            width: AppSpacing.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !sending,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Message'),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final enabled = !sending && value.text.trim().isNotEmpty;
                  return IconButton(
                    onPressed: enabled ? onSend : null,
                    icon: Icon(
                      Icons.arrow_upward,
                      color: enabled
                          ? AppColors.onPrimary
                          : AppColors.tertiaryLabel,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: enabled
                          ? AppColors.primary
                          : AppColors.fill,
                      shape: const CircleBorder(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
