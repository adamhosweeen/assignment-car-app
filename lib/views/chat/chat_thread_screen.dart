import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/auth/auth_repository.dart';
import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/services/image_utils.dart';
import 'package:assignment/control/user/user_providers.dart';
import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/model/chat/message.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/listing/media_image.dart';
import 'package:assignment/widgets/user/user_avatar.dart';

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
  Future<AppUser?>? _otherProfile;

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
    _otherProfile = fetchUser(
      context.read<UsersRepository>(),
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

  Future<void> _sendImage() async {
    if (_sending) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => _sending = true);
    final compressed = await compressImage(picked.path);
    if (!mounted) return;
    final res = await context.read<ChatRepository>().sendImage(
      widget.conversationId,
      compressed,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
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

  Future<void> _showMessageActions(Message message) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.undo_outlined,
                color: AppColors.destructive,
              ),
              title: Text(
                'Recall message',
                style: Theme.of(
                  sheetContext,
                ).textTheme.body.copyWith(color: AppColors.destructive),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _recall(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recall(Message target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Recall this message?'),
        content: const Text(
          'The other person will no longer see what you sent. '
          'You can’t undo this.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Recall'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final res = await context.read<ChatRepository>().recallMessage(target.id);
    if (!mounted) return;
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

    return FutureBuilder<AppUser?>(
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
    AppUser? profile,
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
              UserAvatar(
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
                    final isMine = uid != null && m.isMine(uid);
                    return _MessageBubble(
                      message: m,
                      isMine: isMine,
                      iAmBuyer: uid != null && uid == conversation.buyerId,
                      listingActive: listing?.status == ListingStatus.selling,
                      acting: _actingOnMessageId == m.id,
                      countered: _counteredOfferIds.contains(m.id),
                      onConfirm: () => _confirmOffer(m),
                      onBuy: () =>
                          _goToOfferCheckout(m, conversation.listingId),
                      onCounter: () => _counterOffer(m),
                      onLongPress: isMine && !m.isRecalled
                          ? () => _showMessageActions(m)
                          : null,
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
            onImage: _sendImage,
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
    this.onLongPress,
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
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (message.isRecalled) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space12),
        child: Row(
          mainAxisAlignment: isMine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(
              isMine ? 'You recalled a message' : 'Message recalled',
              style: text.footnote.copyWith(
                color: AppColors.tertiaryLabel,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    final isOffer =
        message.messageType == MessageType.offer &&
        message.offerAmountMyr != null;
    final isImage =
        message.messageType == MessageType.image && message.imagePath != null;
    final showBody =
        !isImage &&
        (!isOffer ||
            message.body != 'Offer: ${formatPrice(message.offerAmountMyr!)}');
    final confirmed = message.offerConfirmedAt != null;
    // Once the seller confirms the buyer's own offer, show it like the
    // seller's offer bubble (white block, black "Buy now" button) instead of
    // the usual solid "mine" bubble.
    final isConfirmedBuyNow = isOffer && isMine && iAmBuyer && confirmed;
    final bubbleFilled = isMine && !isConfirmedBuyNow;
    final fg = bubbleFilled ? AppColors.onPrimary : AppColors.label;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                  vertical: AppSpacing.space12,
                ),
                decoration: BoxDecoration(
                  color: bubbleFilled
                      ? AppColors.primary
                      : AppColors.groupedBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isImage)
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            fullscreenDialog: true,
                            builder: (_) =>
                                _FullscreenChatImage(path: message.imagePath!),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInput,
                          ),
                          child: MediaImage(
                            path: message.imagePath,
                            bucket: 'chat-media',
                            width: AppSpacing.chatImageSize,
                            height: AppSpacing.chatImageSize,
                          ),
                        ),
                      ),
                    if (isOffer)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.space4,
                        ),
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
          ),
        ],
      ),
    );
  }
}

// Mirrors listing_detail_screen.dart's _FullscreenGallery, minus paging —
// a chat message carries exactly one photo.
class _FullscreenChatImage extends StatelessWidget {
  const _FullscreenChatImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.label,
      appBar: AppBar(
        backgroundColor: AppColors.label,
        foregroundColor: AppColors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: InteractiveViewer(
        child: Center(
          child: MediaImage(
            path: path,
            bucket: 'chat-media',
            fit: BoxFit.contain,
          ),
        ),
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
              : Text(
                  label,
                  style: text.footnote.copyWith(color: AppColors.onPrimary),
                ),
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
    required this.onImage,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final bool negotiable;
  final VoidCallback onOffer;
  final VoidCallback onImage;

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
              IconButton(
                onPressed: sending ? null : onImage,
                tooltip: 'Send a photo',
                icon: const Icon(
                  Icons.image_outlined,
                  color: AppColors.primary,
                ),
              ),
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
