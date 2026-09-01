import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/model/bid/bid.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/model/listing/draft_from_listing.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_enums.dart';
import 'package:assignment/model/listing/listing_media.dart';
import 'package:assignment/control/bid/bids_providers.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/media_image.dart';
import 'package:assignment/widgets/listing/status_badge.dart';
import 'package:assignment/widgets/profile/seller_row.dart';

/// Standalone listing detail, reachable from the Buy feed and My Listings
/// (V1_SPEC §4.7). Takes only a listing id.
class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  /// One-shot fetches, held so a rebuild never re-issues them. The screen is
  /// pushed fresh every time, so entering it is already the "refresh".
  late final Future<Listing> _listing;
  late final Future<Bid?> _pendingBid;

  @override
  void initState() {
    super.initState();
    _listing = fetchListingById(
      context.read<ListingsRepository>(),
      widget.id,
    );
    _pendingBid = fetchMyPendingBid(
      context.read<AuthRepository>(),
      context.read<BidsRepository>(),
      widget.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Listing>(
      future: _listing,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Text(
                  'This listing is no longer available.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.body.copyWith(color: AppColors.secondaryLabel),
                ),
              ),
            ),
          );
        }
        final listing = snapshot.data;
        if (listing == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _DetailScaffold(listing: listing, pendingBid: _pendingBid);
      },
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.listing, required this.pendingBid});

  final Listing listing;
  final Future<Bid?> pendingBid;

  Future<void> _edit(BuildContext context) async {
    await context.read<DraftRepository>().save(draftFromListing(listing));
    if (!context.mounted) return;
    // The sell flow is about to open on this draft, so the app-scoped
    // controller has to pick up what was just written.
    context.read<SellController>().reload();
    context.push('/sell/new', extra: true);
  }

  Future<void> _markSold(BuildContext context) async {
    final res = await context.read<ListingsRepository>().markSold(listing.id);
    if (!context.mounted) return;
    if (res case Err(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } else {
      context.pop();
    }
  }

  Future<void> _openChat(BuildContext context) async {
    final res = await context.read<ChatRepository>().openConversation(
      listing.id,
    );
    if (!context.mounted) return;
    switch (res) {
      case Ok(:final value):
        context.push('/chat/${value.id}', extra: value);
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final photos = listing.media
        .where((m) => m.mediaType == MediaType.photo)
        .toList();

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Gallery(photos: photos),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        formatPrice(listing.priceMyr),
                        style: text.largeTitle,
                      ),
                    ),
                    if (listing.negotiable) ...[
                      const SizedBox(width: AppSpacing.space12),
                      const _NegotiableChip(),
                    ],
                    if (listing.status == ListingStatus.sold) ...[
                      const SizedBox(width: AppSpacing.space12),
                      StatusBadge(status: listing.status),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(listing.title, style: text.title3),
                const SizedBox(height: AppSpacing.space20),
                _KeyFacts(listing: listing),
                const SizedBox(height: AppSpacing.space24),
                GroupedSection(
                  header: 'Details',
                  children: [
                    GroupedRow(
                      label: 'Body type',
                      value: listing.bodyType.label,
                    ),
                    GroupedRow(label: 'Colour', value: listing.colour),
                    GroupedRow(
                      label: 'Previous owners',
                      value: listing.ownersCount.toString(),
                    ),
                    GroupedRow(
                      label: 'Accident-free',
                      value: listing.accidentFree ? 'Yes' : 'No',
                    ),
                    GroupedRow(
                      label: 'Road tax expiry',
                      value: listing.roadTaxExpiry != null
                          ? formatDate(listing.roadTaxExpiry!)
                          : '—',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space20),
                GroupedSection(
                  header: 'Location',
                  children: [
                    GroupedRow(
                      label: 'Region',
                      value: listing.registrationRegion.label,
                    ),
                    GroupedRow(label: 'State', value: listing.state),
                    GroupedRow(label: 'City', value: listing.city),
                  ],
                ),
                const SizedBox(height: AppSpacing.space20),
                _SellerSection(sellerId: listing.sellerId),
                if (listing.description != null &&
                    listing.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space24),
                  Text(
                    'Description',
                    style: text.footnote.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(listing.description!, style: text.body),
                ],
                const SizedBox(height: AppSpacing.space24),
                Text(
                  formatPosted(listing.createdAt),
                  style: text.footnote.copyWith(color: AppColors.tertiaryLabel),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: FutureBuilder<Bid?>(
            future: pendingBid,
            builder: (context, bid) => _Actions(
              listing: listing,
              isSeller:
                  context.read<AuthRepository>().currentUser?.id ==
                  listing.sellerId,
              onEdit: () => _edit(context),
              onMarkSold: () => _markSold(context),
              onChat: () => _openChat(context),
              onBuy: () => context.push('/listing/${listing.id}/buy'),
              onBid: () => context.push('/listing/${listing.id}/bid'),
              // Null while it loads, so the button reads "Place a bid" until
              // we know otherwise rather than flickering between the two
              // labels.
              hasPendingBid: bid.data != null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Who is selling: a tappable row to the seller's public page. Hidden when
/// the profile can't be loaded — the listing itself is what matters here.
class _SellerSection extends StatefulWidget {
  const _SellerSection({required this.sellerId});

  final String sellerId;

  @override
  State<_SellerSection> createState() => _SellerSectionState();
}

class _SellerSectionState extends State<_SellerSection> {
  late final Future<PublicProfile?> _profile = fetchPublicProfile(
    context.read<ProfilesRepository>(),
    widget.sellerId,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PublicProfile?>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GroupedSection(
            header: 'Seller',
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.space16),
                child: SizedBox(
                  height: AppSpacing.space12,
                  child: ColoredBox(color: AppColors.fill),
                ),
              ),
            ],
          );
        }
        final profile = snapshot.data;
        if (profile == null) return const SizedBox.shrink();
        return GroupedSection(
          header: 'Seller',
          children: [
            SellerRow(
              profile: profile,
              onTap: () => context.push('/seller/${profile.id}'),
            ),
          ],
        );
      },
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.listing,
    required this.isSeller,
    required this.onEdit,
    required this.onMarkSold,
    required this.onChat,
    required this.onBuy,
    required this.onBid,
    required this.hasPendingBid,
  });

  final Listing listing;
  final bool isSeller;
  final VoidCallback onEdit;
  final VoidCallback onMarkSold;
  final VoidCallback onChat;
  final VoidCallback onBuy;
  final VoidCallback onBid;

  /// Whether the viewer already has a live bid on this car — the bid button
  /// then offers to change it rather than to place a second one.
  final bool hasPendingBid;

  @override
  Widget build(BuildContext context) {
    if (!isSeller) {
      final available = listing.status == ListingStatus.active;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: available ? onBuy : null,
              child: Text(available ? 'Buy this car' : 'Sold'),
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.groupedBackground,
                    foregroundColor: AppColors.primary,
                  ),
                  // Bidding on a sold car is pointless, and the server would
                  // reject it anyway — so the button goes with the price.
                  onPressed: available ? onBid : null,
                  child: Text(hasPendingBid ? 'Change bid' : 'Place a bid'),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.groupedBackground,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: onChat,
                  child: const Text('Chat'),
                ),
              ),
            ],
          ),
        ],
      );
    }
    // A sold (or deleted) listing is frozen — no edit, no re-marking sold.
    if (listing.status != ListingStatus.active) {
      return const SizedBox.shrink();
    }
    final editButton = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.groupedBackground,
        foregroundColor: AppColors.primary,
      ),
      onPressed: onEdit,
      child: const Text('Edit'),
    );
    return Row(
      children: [
        Expanded(child: editButton),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: FilledButton(
            onPressed: onMarkSold,
            child: const Text('Mark as sold'),
          ),
        ),
      ],
    );
  }
}

class _NegotiableChip extends StatelessWidget {
  const _NegotiableChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.groupedBackground,
        borderRadius: BorderRadius.circular(AppSpacing.space8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space4,
        ),
        child: Text(
          'Negotiable',
          style: Theme.of(
            context,
          ).textTheme.footnote.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _KeyFacts extends StatelessWidget {
  const _KeyFacts({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Fact(
              label: 'Mileage',
              value: formatMileage(listing.mileageKm),
            ),
          ),
          const _VDivider(),
          Expanded(
            child: _Fact(
              label: 'Transmission',
              value: listing.transmission.label,
            ),
          ),
          const _VDivider(),
          Expanded(
            child: _Fact(label: 'Fuel', value: listing.fuelType.label),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: text.headline, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.space4),
        Text(
          label,
          style: text.caption.copyWith(color: AppColors.secondaryLabel),
        ),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppSpacing.hairline,
      child: ColoredBox(color: AppColors.separator),
    );
  }
}

/// Swipeable photo gallery with page dots; tap opens the fullscreen viewer.
class _Gallery extends StatefulWidget {
  const _Gallery({required this.photos});

  final List<ListingMedia> photos;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen(int initial) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) =>
            _FullscreenGallery(photos: widget.photos, initial: initial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const CoverImage(media: null, height: AppSpacing.galleryHeight);
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: AppSpacing.galleryHeight,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.photos.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _openFullscreen(i),
              child: CoverImage(
                media: widget.photos[i],
                height: AppSpacing.galleryHeight,
              ),
            ),
          ),
        ),
        if (widget.photos.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.photos.length; i++)
                  Container(
                    width: AppSpacing.space8,
                    height: AppSpacing.space8,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4 / 2,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? AppColors.primary
                          : AppColors.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({required this.photos, required this.initial});

  final List<ListingMedia> photos;
  final int initial;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller = PageController(
    initialPage: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: MediaImage(
              path: widget.photos[i].storagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
