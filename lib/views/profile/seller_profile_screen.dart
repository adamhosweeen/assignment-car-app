import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/listings/listings_providers.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/profiles/profiles_providers.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/control/reports/reports_repository.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/profile/public_profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/search_scaffold.dart';
import 'package:assignment/widgets/common/section_header.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';
import 'package:assignment/widgets/listing/cover_image.dart';
import 'package:assignment/widgets/listing/listing_card.dart';
import 'package:assignment/widgets/profile/profile_avatar.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key, required this.id});

  final String id;

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  late Future<PublicProfile?> _profile;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() => _profile = fetchPublicProfile(
    context.read<ProfilesRepository>(),
    widget.id,
  );

  void _openReportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      builder: (_) => _ReportSheet(reportedId: widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelf = context.read<AuthRepository>().currentUser?.id == widget.id;
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Seller'),
        actions: [
          if (!isSelf)
            IconButton(
              tooltip: 'Report this user',
              onPressed: () => _openReportSheet(context),
              icon: const Icon(
                Icons.flag_outlined,
                size: AppSpacing.iconMd,
                color: AppColors.secondaryLabel,
              ),
            ),
        ],
      ),
      body: FutureBuilder<PublicProfile?>(
        future: _profile,
        builder: (context, snapshot) {
          final error = snapshot.error;
          if (error != null) {
            return SearchMessage(
              icon: Icons.error_outline,
              text: error is ProfilesException
                  ? error.message
                  : 'We couldn’t load this seller. Please try again.',
              onRetry: () => setState(_fetch),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
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

class _Body extends StatefulWidget {
  const _Body({required this.profile});

  final PublicProfile profile;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final Stream<List<Listing>> _listings = watchSellerListings(
    context.read<ListingsRepository>(),
    widget.profile.id,
  );

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final text = Theme.of(context).textTheme;
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
        StreamBuilder<List<Listing>>(
          stream: _listings,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _Note(
                'We couldn’t load this seller’s cars. Pull down to try again.',
              );
            }
            final items = snapshot.data;
            if (items == null) {
              return const Padding(
                padding: EdgeInsets.only(top: AppSpacing.space24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
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
                      onTap: () =>
                          Navigator.pushNamed(context, '/listing/${l.id}'),
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

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.reportedId});

  final String reportedId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  bool _submitting = false;
  String? _error;

  static const int _titleMax = 80;
  static const int _descriptionMax = 500;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _title.text.trim().isNotEmpty && _description.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });
    final res = await context.read<ReportsRepository>().submit(
      reportedId: widget.reportedId,
      title: _title.text,
      description: _description.text,
    );
    if (!mounted) return;
    switch (res) {
      case Ok():
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Thanks — an admin will review this report.'),
            ),
          );
      case Err(:final message):
        setState(() {
          _submitting = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Report this user', style: text.title3),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Tell us what happened. Reports are only visible to admins.',
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space20),
              const FieldLabel('Title'),
              TextField(
                controller: _title,
                autofocus: true,
                maxLength: _titleMax,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Misleading listing',
                  counterText: '',
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: AppSpacing.space16),
              const FieldLabel('Description'),
              TextField(
                controller: _description,
                maxLength: _descriptionMax,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Describe what this user did.',
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.space12),
                InlineNotice(text: _error!, kind: NoticeKind.error),
              ],
              const SizedBox(height: AppSpacing.space16),
              FilledButton(
                onPressed: (_canSubmit && !_submitting) ? _submit : null,
                child: _submitting
                    ? const ButtonSpinner()
                    : const Text('Submit report'),
              ),
            ],
          ),
        ),
      ),
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
