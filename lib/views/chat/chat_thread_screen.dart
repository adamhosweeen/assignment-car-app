import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, required this.conversationId, this.seed});

  final String conversationId;
  final Conversation? seed;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  String? _actingOnMessageId;

  Conversation? _conversation;
  bool _conversationFailed = false;

  late final Stream<List<Message>> _messages;

  Future<Listing>? _listing;
  Future<PublicProfile?>? _otherProfile;

  List<Message>? _seenMessages;

  final Set<String> _counteredOfferIds = {};

  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatRepository>();
    chat.markRead(widget.conversationId);
    _messages = watchMessages(chat, widget.conversationId);

    final seed = widget.seed;
    if (seed != null) {
      _conversation = seed;
      _loadConversationDetails();
      return;
    }
    fetchConversationById(chat, widget.conversationId)
        .then((conversation) {
          if (!mounted) return;
          setState(() {
            _conversation = conversation;
            _loadConversationDetails();
          });
        })
        .catchError((Object _) {
          if (mounted) setState(() => _conversationFailed = true);
        });
  }

  void _loadConversationDetails() {
    final conversation = _conversation;
    if (conversation == null) return;
    _listing = fetchListingById(
      context.read<ListingsRepository>(),
      conversation.listingId,
    );
    final uid = context.read<AuthRepository>().currentUser?.id;
    _otherProfile = fetchPublicProfile(
      context.read<ProfilesRepository>(),
      uid == null
          ? conversation.sellerId
          : conversation.otherParticipantId(uid),
    );
  }

  void _onMessages(List<Message> messages) {
    if (listEquals(_seenMessages, messages)) return;
    _seenMessages = messages;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(_loadConversationDetails);
    });
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

  Future<bool> _send({int? offerAmountMyr}) async {
    if (_sending) return false;
    final text = _controller.text.trim();
    if (text.isEmpty && offerAmountMyr == null) return false;
    final body = text.isEmpty ? 'Offer: ${formatPrice(offerAmountMyr!)}' : text;
    setState(() => _sending = true);
    _controller.clear();
    final res = await context.read<ChatRepository>().send(
      widget.conversationId,
      body,
      offerAmountMyr: offerAmountMyr,
    );
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

  Future<void> _counterOffer(Message original) async {
    final amount = await _promptForOfferAmount(context);
    if (amount == null) return;
    final sent = await _send(offerAmountMyr: amount);
    if (!mounted || !sent) return;
    setState(() => _counteredOfferIds.add(original.id));
  }

  Future<void> _confirmOffer(Message offer) async {
    setState(() => _actingOnMessageId = offer.id);
    final res = await context.read<ChatRepository>().confirmOffer(offer.id);
    if (!mounted) return;
    setState(() => _actingOnMessageId = null);
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _goToOfferCheckout(Message offer, String listingId) {
    Navigator.pushNamed(
      context,
      '/listing/$listingId/buy',
      arguments: (messageId: offer.id, amountMyr: offer.offerAmountMyr!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(),
        body: _conversationFailed
            ? const _CenteredNote(
                text:
                    'We couldn’t load this conversation. Check your '
                    'connection.',
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PublicProfile?>(
      future: _otherProfile,
      builder: (context, profile) => FutureBuilder<Listing>(
        future: _listing,
        builder: (context, listing) =>
            _buildThread(context, conversation, profile.data, listing.data),
      ),
    );
  }

  Widget _buildThread(
    BuildContext context,
    Conversation conversation,
    PublicProfile? profile,
    Listing? listing,
  ) {
    final text = Theme.of(context).textTheme;
    final uid = context.read<AuthRepository>().currentUser?.id;
    final displayName = profile?.name ?? 'Chat';

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pushNamed(
            context,
            '/listing/${conversation.listingId}',
          ),
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
            child: StreamBuilder<List<Message>>(
              stream: _messages,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _CenteredNote(
                    text:
                        'We couldn’t load this conversation. Check your '
                        'connection.',
                  );
                }
                final msgs = snapshot.data;
                if (msgs == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                _onMessages(msgs);
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
                      listingActive: listing?.status == ListingStatus.selling,
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
                listing?.status == ListingStatus.selling,
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
