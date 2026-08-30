import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/search_scaffold.dart';
import 'package:assignment/widgets/common/section_header.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/listing_card.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

/// Another user's public page: photo, name, state, member since, and the
/// cars they currently have for sale. Never shows contact details
/// (V1_SPEC §4.10). Reached from seller search and from Listing Detail.
class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicProfileProvider(id));
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Seller')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SearchMessage(
          icon: Icons.error_outline,
          text: error is ProfilesException
              ? error.message
              : 'We couldn’t load this seller. Please try again.',
          onRetry: () => ref.invalidate(publicProfileProvider(id)),
        ),
        data: (profile) {
          if (profile == null) {
            return const SearchMessage(
              icon: Icons.person_off_outlined,
              text: 'This account no longer exists.',
            );
          }
          return _Body(profile: profile);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final listings = ref.watch(sellerListingsProvider(profile.id));
    final meta = [
      if (profile.state != null) profile.state!,
      'Member since ${formatMonthYear(profile.createdAt)}',
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Center(
          child: Column(
            children: [
              ProfileAvatar(name: profile.name, avatarUrl: profile.avatarUrl),
              const SizedBox(height: AppSpacing.space16),
              Text(
                profile.name,
                style: text.title1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                meta,
                textAlign: TextAlign.center,
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space32),
        const SectionHeader('For sale'),
        listings.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: AppSpacing.space24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const _Note(
            'We couldn’t load this seller’s cars. Pull down to try again.',
          ),
          data: (items) {
            if (items.isEmpty) {
              return const _Note('No cars for sale right now.');
            }
            return Column(
              children: [
                for (final (i, l) in items.indexed)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == items.length - 1 ? 0 : AppSpacing.space16,
                    ),
                    child: ListingCard(
                      listing: l,
                      cover: CoverImage(media: l.cover),
                      onTap: () => context.push('/listing/${l.id}'),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: ColoredBox(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.body.copyWith(color: AppColors.secondaryLabel),
          ),
        ),
      ),
    );
  }
}
