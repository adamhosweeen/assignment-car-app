import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/insights/insights_providers.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/segmented_control.dart';
import 'package:assignment/widgets/insights/rank_bar_row.dart';

/// How many entries a list shows before "Show all".
const int _previewCount = 5;

enum _Segment { brands, models, nearYou, trends }

extension on _Segment {
  String get label => switch (this) {
    _Segment.brands => 'Brands',
    _Segment.models => 'Models',
    _Segment.nearYou => 'Near you',
    _Segment.trends => 'Trends',
  };
}

/// Profile → Market insights: what Malaysians actually registered over the
/// last 12 months (JPJ data via data.gov.my), from the precomputed
/// `car_popularity` snapshot. Read-only; the app never calls data.gov.my.
///
/// Laid out as a compact summary plus a segmented control so each view fits
/// on one screen: lists show their top 5 with a "Show all" toggle.
class MarketInsightsScreen extends ConsumerStatefulWidget {
  const MarketInsightsScreen({super.key});

  @override
  ConsumerState<MarketInsightsScreen> createState() =>
      _MarketInsightsScreenState();
}

class _MarketInsightsScreenState extends ConsumerState<MarketInsightsScreen> {
  _Segment _segment = _Segment.brands;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(carPopularityProvider);
    final userState = ref.watch(authStateProvider).value?.state;

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Market Insights')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Message(
          text: error is InsightsException
              ? error.message
              : 'Something went wrong. Please try again.',
          onRetry: () => ref.invalidate(carPopularityProvider),
        ),
        data: (snapshot) {
          if (snapshot == null) {
            return const _Message(
              text:
                  'Market insights aren’t published yet. '
                  'Check back after the next data refresh.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(carPopularityProvider);
              await ref.read(carPopularityProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                _SummaryCard(snapshot: snapshot),
                const SizedBox(height: AppSpacing.space16),
                SegmentedControl(
                  labels: [for (final s in _Segment.values) s.label],
                  selected: _segment.index,
                  onChanged: (i) => setState(() {
                    _segment = _Segment.values[i];
                    _showAll = false;
                  }),
                ),
                const SizedBox(height: AppSpacing.space16),
                ..._segmentBody(context, snapshot, userState),
                const SizedBox(height: AppSpacing.space24),
                _Footnote(
                  'Source: JPJ car registrations via data.gov.my (CC BY 4.0). '
                  'Generated ${formatDate(snapshot.generatedAt)}.',
                ),
                const SizedBox(height: AppSpacing.space32),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _segmentBody(
    BuildContext context,
    CarPopularity snapshot,
    String? userState,
  ) {
    switch (_segment) {
      case _Segment.brands:
        return [
          GroupedSection(
            header: _showAll ? 'ALL BRANDS' : 'TOP $_previewCount BRANDS',
            children: _rankedRows(snapshot.topMakers, expandable: true),
          ),
        ];
      case _Segment.models:
        final models = snapshot.topModels;
        final shown = _showAll ? models : models.take(_previewCount).toList();
        return [
          GroupedSection(
            header: _showAll ? 'ALL MODELS' : 'TOP $_previewCount MODELS',
            children: [
              if (models.isEmpty) const _EmptyRow(),
              for (final (i, m) in shown.indexed)
                RankBarRow(
                  rank: i + 1,
                  label: m.name,
                  sublabel: m.maker,
                  count: m.count,
                  fraction: _fraction(m.count, models.first.count),
                ),
              if (models.length > _previewCount) _showAllRow(models.length),
            ],
          ),
        ];
      case _Segment.nearYou:
        if (userState == null) {
          return [
            _Notice(
              text:
                  'Add your location in My Info to see what’s popular in '
                  'your state.',
              actionLabel: 'Open My Info',
              onAction: () => context.push('/profile/info'),
            ),
          ];
        }
        final makers = snapshot.topMakersIn(userState);
        if (makers.isEmpty) {
          return [
            _Notice(
              text:
                  'JPJ has no state-level registrations for $userState in '
                  'this period.',
            ),
          ];
        }
        return [
          GroupedSection(
            header: 'POPULAR IN ${userState.toUpperCase()}',
            children: _rankedRows(makers),
          ),
          const SizedBox(height: AppSpacing.space8),
          const _Footnote(
            'Registrations made through dealer portals carry no state, so '
            'state figures cover a smaller sample.',
          ),
        ];
      case _Segment.trends:
        return [
          GroupedSection(
            header: 'REGISTRATIONS BY MONTH',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: snapshot.monthly.isEmpty
                    ? const _EmptyRow()
                    : MonthlyBars(
                        months: [for (final m in snapshot.monthly) m.month],
                        counts: [for (final m in snapshot.monthly) m.count],
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),
          GroupedSection(
            header: 'FUEL TYPE',
            children: _rankedRows(snapshot.fuelSplit),
          ),
          const SizedBox(height: AppSpacing.space24),
          GroupedSection(
            header: 'VEHICLE TYPE',
            children: _rankedRows(snapshot.typeSplit),
          ),
        ];
    }
  }

  /// Ranked rows scaled to the top entry; when [expandable], only the first
  /// [_previewCount] show until "Show all" is tapped.
  List<Widget> _rankedRows(List<RankedCount> items, {bool expandable = false}) {
    if (items.isEmpty) return const [_EmptyRow()];
    final top = items.first.count;
    final shown = expandable && !_showAll
        ? items.take(_previewCount).toList()
        : items;
    return [
      for (final (i, item) in shown.indexed)
        RankBarRow(
          rank: i + 1,
          label: item.name,
          count: item.count,
          fraction: _fraction(item.count, top),
        ),
      if (expandable && items.length > _previewCount) _showAllRow(items.length),
    ];
  }

  Widget _showAllRow(int total) => GroupedRow(
    label: _showAll ? 'Show top $_previewCount' : 'Show all $total',
    labelColor: AppColors.primary,
    onTap: () => setState(() => _showAll = !_showAll),
  );

  static double _fraction(int count, int top) => top == 0 ? 0 : count / top;
}

/// Compact headline: the 12-month total and the window it covers.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.snapshot});

  final CarPopularity snapshot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: ColoredBox(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New cars registered',
                      style: text.footnote.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      formatCount(snapshot.totalRegistrations),
                      style: text.title1,
                    ),
                  ],
                ),
              ),
              Text(
                snapshot.periodLabel,
                textAlign: TextAlign.right,
                style: text.footnote.copyWith(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.footnote.copyWith(color: AppColors.secondaryLabel),
      ),
    );
  }
}

/// An in-card message for a segment with nothing to rank, optionally with a
/// single link-style action.
class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: ColoredBox(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: theme.body.copyWith(color: AppColors.secondaryLabel),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: AppSpacing.space8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAction,
                  child: Text(
                    actionLabel!,
                    style: theme.body.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Text(
        'No data for this period.',
        style: Theme.of(
          context,
        ).textTheme.subhead.copyWith(color: AppColors.secondaryLabel),
      ),
    );
  }
}

/// Centred message for the empty and error states, with an optional retry.
class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

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
            Icon(
              Icons.bar_chart,
              size: AppSpacing.iconXl,
              color: AppColors.tertiaryLabel,
            ),
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
