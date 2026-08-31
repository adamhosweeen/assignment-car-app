import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

/// One conversation thread, reached from the Chat tab or "Chat with seller"
/// on Listing Detail. Takes only [conversationId] — [seed], the
/// [Conversation] the caller already has in hand (route `extra`), is just a
/// same-session fast path so the first frame doesn't have to wait on a
/// fetch. `extra` doesn't survive Android killing and restoring the app
/// process, so [seed] is never required: when absent (or stale), the
/// [Conversation] is fetched by id instead.
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.conversationId, this.seed});

  final String conversationId;
  final Conversation? seed;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  String? _actingOnMessageId;

  /// Offers the seller has countered with a "New price" — disables that
  /// original offer's Confirm/New price row so it can't also be accepted or
  /// countered again. Session-local only: it resets if the thread is
  /// reopened, which just means the seller can change their mind later and
  /// confirm the original after all.
  final Set<String> _counteredOfferIds = {};

  @override
  void initState() {
    super.initState();
    // Fire and forget — a failure here is cosmetic, the badge just won't clear.
    ref.read(chatRepositoryProvider).markRead(widget.conversationId);
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

  /// Sends whatever's typed as a plain text message, or — when [offerAmountMyr]
  /// is given (the "Negotiate" flow, including a seller's counter-offer) — as
  /// an offer, using the typed text as the offer's note (falling back to a
  /// plain "Offer: RM X" body when the composer was left empty).
  Future<bool> _send({int? offerAmountMyr}) async {
    if (_sending) return false;
    final text = _controller.text.trim();
    if (text.isEmpty && offerAmountMyr == null) return false;
    final body = text.isEmpty ? 'Offer: ${formatPrice(offerAmountMyr!)}' : text;
    setState(() => _sending = true);
    _controller.clear();
    final res = await ref
        .read(chatRepositoryProvider)
        .send(widget.conversationId, body, offerAmountMyr: offerAmountMyr);
    if (!mounted) return false;
    setState(() => _sending = false);
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return false;
    }
    return true;
  }

  Future<void> _makeOffer() async {
    final amount = await _promptForOfferAmount(context);
    if (amount == null) return;
    await _send(offerAmountMyr: amount);
  }

  /// The seller counters a buyer's offer with a new price of their own —
  /// same send flow as the composer's "Negotiate" button, just triggered
  /// from that offer's bubble. Marks the original as countered so its
  /// Confirm/New price row won't stay active once this succeeds.
  Future<void> _counterOffer(Message original) async {
    final amount = await _promptForOfferAmount(context);
    if (amount == null) return;
    final sent = await _send(offerAmountMyr: amount);
    if (!mounted || !sent) return;
    setState(() => _counteredOfferIds.add(original.id));
  }

  /// The recipient of a buyer's offer (the seller) accepts its price.
  Future<void> _confirmOffer(Message offer) async {
    setState(() => _actingOnMessageId = offer.id);
    final res = await ref.read(chatRepositoryProvider).confirmOffer(offer.id);
    if (!mounted) return;
    setState(() => _actingOnMessageId = null);
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// The buyer heads to checkout to complete the sale at an offer's price —
  /// either accepting the seller's offer, or completing their own, already
  /// seller-confirmed, offer. The actual `buy_at_offer` call happens on the
  /// checkout screen's "Confirm purchase" tap, not here — this only opens it.
  void _goToOfferCheckout(Message offer, String listingId) {
    context.push(
      '/listing/$listingId/buy',
      extra: (messageId: offer.id, amountMyr: offer.offerAmountMyr!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seed = widget.seed;
    if (seed != null) return _buildThread(context, seed);

    final conversationAsync = ref.watch(
      conversationByIdProvider(widget.conversationId),
    );
    final conversation = conversationAsync.value;
    if (conversation != null) return _buildThread(context, conversation);

    return Scaffold(
      appBar: AppBar(),
      body: conversationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _CenteredNote(
          text: 'We couldn’t load this conversation. Check your connection.',
        ),
        data: (_) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildThread(BuildContext context, Conversation conversation) {
    final text = Theme.of(context).textTheme;
    final uid = ref.watch(authRepositoryProvider).currentUser?.id;
    final otherId = uid == null
        ? conversation.sellerId
        : conversation.otherParticipantId(uid);
    final profile = ref.watch(publicProfileProvider(otherId)).value;
    final displayName = profile?.name ?? 'Chat';
    final listing = ref
        .watch(listingByIdProvider(conversation.listingId))
        .value;
    final messagesAsync = ref.watch(messagesProvider(conversation.id));
    // listingByIdProvider is a one-shot fetch, not realtime, so a status/price
    // change made by the other participant (e.g. they just completed a
    // purchase via buy_at_offer) never reaches this screen on its own.
    // messages, however, already are realtime — an offer's confirm/buy always
    // touches a message row, so piggyback on that to re-check the listing.
    ref.listen(messagesProvider(conversation.id), (_, _) {
      ref.invalidate(listingByIdProvider(conversation.listingId));
    });

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(
                name: displayName,
                avatarUrl: profile?.avatarUrl,
                size: AppSpacing.avatarSm,
              ),
              const SizedBox(width: AppSpacing.space8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: text.headline,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (listing != null)
                      Text(
                        listing.status == ListingStatus.sold
                            ? '${listing.title} · Sold'
                            : listing.title,
                        style: text.footnote.copyWith(
                          color: AppColors.secondaryLabel,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
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
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    return _MessageBubble(
                      message: m,
                      isMine: uid != null && m.isMine(uid),
                      iAmBuyer: uid != null && uid == conversation.buyerId,
                      listingActive: listing?.status == ListingStatus.active,
                      acting: _actingOnMessageId == m.id,
                      countered: _counteredOfferIds.contains(m.id),
                      onConfirm: () => _confirmOffer(m),
                      onBuy: () =>
                          _goToOfferCheckout(m, conversation.listingId),
                      onCounter: () => _counterOffer(m),
                    );
                  },
                );
              },
            ),
          ),
          _Composer(
            controller: _controller,
            sending: _sending,
            onSend: _send,
            negotiable:
                (listing?.negotiable ?? false) &&
                listing?.status == ListingStatus.active,
            onOffer: _makeOffer,
          ),
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
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.iAmBuyer,
    required this.listingActive,
    required this.acting,
    required this.countered,
    required this.onConfirm,
    required this.onBuy,
    required this.onCounter,
  });

  final Message message;
  final bool isMine;
  final bool iAmBuyer;
  final bool listingActive;
  final bool acting;
  final bool countered;
  final VoidCallback onConfirm;
  final VoidCallback onBuy;
  final VoidCallback onCounter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = isMine ? AppColors.onPrimary : AppColors.label;
    final isOffer =
        message.messageType == MessageType.offer &&
        message.offerAmountMyr != null;
    // Suppress the auto-generated "Offer: RM X" body (composer left empty
    // when the offer was sent) — the header line above already says it.
    final showBody =
        !isOffer ||
        message.body != 'Offer: ${formatPrice(message.offerAmountMyr!)}';
    final confirmed = message.offerConfirmedAt != null;

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
                  if (showBody)
                    Text(message.body, style: text.body.copyWith(color: fg)),
                  if (isOffer && listingActive) ...[
                    const SizedBox(height: AppSpacing.space8),
                    _OfferActionRow(
                      isMine: isMine,
                      iAmBuyer: iAmBuyer,
                      confirmed: confirmed,
                      countered: countered,
                      acting: acting,
                      fg: fg,
                      onConfirm: onConfirm,
                      onBuy: onBuy,
                      onCounter: onCounter,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The action (if any) available on an offer bubble, from the viewer's own
/// side of the conversation:
/// - Someone else's offer, and I'm the buyer (so a seller sent it) → I can
///   confirm and buy in one tap (heads to checkout first).
/// - Someone else's offer, and I'm the seller (so a buyer sent it) → I can
///   confirm it (I can't buy my own listing; the buyer completes the sale
///   once I have), or counter with a new price of my own instead.
/// - My own offer, and I'm the buyer → once the seller has confirmed it, I
///   can complete the purchase (heads to checkout).
/// - My own offer, and I'm the seller → nothing left for me to do.
class _OfferActionRow extends StatelessWidget {
  const _OfferActionRow({
    required this.isMine,
    required this.iAmBuyer,
    required this.confirmed,
    required this.countered,
    required this.acting,
    required this.fg,
    required this.onConfirm,
    required this.onBuy,
    required this.onCounter,
  });

  final bool isMine;
  final bool iAmBuyer;
  final bool confirmed;
  final bool countered;
  final bool acting;
  final Color fg;
  final VoidCallback onConfirm;
  final VoidCallback onBuy;
  final VoidCallback onCounter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (!isMine && iAmBuyer && !confirmed) {
      return _button(text, 'Confirm and buy', onBuy);
    }
    if (!isMine && !iAmBuyer && !confirmed) {
      if (countered) {
        return Text(
          'You proposed a new price',
          style: text.caption.copyWith(color: fg),
        );
      }
      return Row(
        children: [
          Expanded(child: _button(text, 'Confirm', onConfirm)),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.groupedBackground,
                foregroundColor: AppColors.primary,
              ),
              onPressed: acting ? null : onCounter,
              child: Text('New price', style: text.footnote),
            ),
          ),
        ],
      );
    }
    if (isMine && iAmBuyer && confirmed) {
      return _button(text, 'Buy now', onBuy);
    }
    if (confirmed) {
      return Text(
        isMine && !iAmBuyer
            ? 'Confirmed — waiting for buyer to complete purchase'
            : 'Confirmed',
        style: text.caption.copyWith(color: fg),
      );
    }
    if (isMine && iAmBuyer) {
      return Text(
        'Waiting for seller to confirm',
        style: text.caption.copyWith(color: fg),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _button(TextTheme text, String label, VoidCallback onPressed) =>
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: acting ? null : onPressed,
          child: acting
              ? const ButtonSpinner()
              : Text(label, style: text.footnote),
        ),
      );
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.negotiable,
    required this.onOffer,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final bool negotiable;
  final VoidCallback onOffer;

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
              if (negotiable)
                IconButton(
                  onPressed: sending ? null : onOffer,
                  tooltip: 'Negotiate',
                  icon: const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primary,
                  ),
                ),
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

/// Prompts for an integer MYR amount ("Negotiate" / counter with a new
/// price). Returns null if cancelled.
Future<int?> _promptForOfferAmount(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (_) => const _OfferAmountDialog(),
  );
}

class _OfferAmountDialog extends StatefulWidget {
  const _OfferAmountDialog();

  @override
  State<_OfferAmountDialog> createState() => _OfferAmountDialogState();
}

class _OfferAmountDialogState extends State<_OfferAmountDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value == null || value <= 0) {
      setState(() => _errorText = 'Enter a valid amount.');
      return;
    }
    if (value > kMaxPriceMyr) {
      setState(
        () => _errorText =
            'That’s too high. Enter an amount under '
            '${formatPrice(kMaxPriceMyr)}.',
      );
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Negotiate', style: Theme.of(context).textTheme.headline),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          prefixText: 'RM ',
          hintText: 'Amount',
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Send')),
      ],
    );
  }
}
