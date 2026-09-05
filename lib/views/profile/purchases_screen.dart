import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/purchases/purchases_providers.dart';
import 'package:assignment/control/purchases/purchases_repository.dart';
import 'package:assignment/model/purchase/purchase.dart';
import 'package:assignment/model/purchase/purchase_with_listing.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/listing/cover_image.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  late Future<List<PurchaseWithListing>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchMyPurchases(context.read<PurchasesRepository>());
  }

  void _reload() {
    setState(() {
      _future = fetchMyPurchases(context.read<PurchasesRepository>());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Purchases')),
      body: FutureBuilder<List<PurchaseWithListing>>(
        future: _future,
        builder: (context, snapshot) {
          final error = snapshot.error;
          if (error != null) {
            return _Message(
              icon: Icons.error_outline,
              text: '$error',
              onRetry: _reload,
            );
          }
          final items = snapshot.data;
          if (items == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const _Message(
              icon: Icons.receipt_long_outlined,
              text:
                  'Nothing bought yet. Cars you buy will show up here with '
                  'what you paid.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                GroupedSection(
                  children: [
                    for (final item in items)
                      _PurchaseRow(
                        item: item,
                        onTap: item.purchase.listingId == null
                            ? null
                            : () => context.push(
                                '/listing/${item.purchase.listingId}',
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                Center(
                  child: Text(
                    '${items.length} ${items.length == 1 ? 'car' : 'cars'} · '
                    '${formatPrice(totalSpentMyr(items))} total',
                    style: Theme.of(context).textTheme.caption.copyWith(
                      color: AppColors.tertiaryLabel,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.item, this.onTap});

  final PurchaseWithListing item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final purchase = item.purchase;
    final listing = item.listing;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
              child: SizedBox(
                width: AppSpacing.thumbMd,
                height: AppSpacing.thumbMd,
                child: listing == null
                    ? const ColoredBox(
                        color: AppColors.groupedBackground,
                        child: Icon(
                          Icons.directions_car_outlined,
                          color: AppColors.tertiaryLabel,
                        ),
                      )
                    : CoverImage(
                        media: listing.cover,
                        height: AppSpacing.thumbMd,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.headline,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    formatPrice(purchase.priceMyr),
                    style: text.body.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    '${purchase.method.label} · '
                    '${formatDate(purchase.createdAt)}',
                    style: text.footnote.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                  if (listing == null) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'This listing is no longer available.',
                      style: text.caption.copyWith(
                        color: AppColors.tertiaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.space4),
                child: Icon(
                  Icons.chevron_right,
                  size: AppSpacing.iconMd,
                  color: AppColors.tertiaryLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

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
