import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/insights/insights_providers.dart';
import 'package:assignment/control/insights/insights_repository.dart';
import 'package:assignment/model/insights/car_popularity.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/insights/rank_bar_row.dart';

const int _listLength = 10;

class MarketInsightsScreen extends StatefulWidget {
  const MarketInsightsScreen({super.key});

  @override
  State<MarketInsightsScreen> createState() => _MarketInsightsScreenState();
}

class _MarketInsightsScreenState extends State<MarketInsightsScreen> {
  late Future<CarPopularity?> _popularity;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    _popularity = fetchCarPopularity(context.read<InsightsRepository>());
  }

  Future<void> _refresh() async {
    setState(_fetch);
    await _popularity.catchError((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUser?>()?.state;

    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Market Insights')),
      body: FutureBuilder<CarPopularity?>(
        future: _popularity,
        builder: (context, result) {
          final error = result.error;
          if (error != null) {
            return _Message(
              text: error is InsightsException
                  ? error.message
                  : 'Something went wrong. Please try again.',
              onRetry: () => setState(_fetch),
            );
          }
          if (result.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final snapshot = result.data;
          if (snapshot == null) {
            return const _Message(
              text:
                  'Market insights aren’t published yet. '
                  'Check back after the next data refresh.',
            );
          }

          // Show the user's own state when we have figures for it; otherwise
          // the national picture, and say which it is.
          final scoped = snapshot.hasDataFor(userState);
          final scopeLabel = scoped ? userState! : 'Malaysia';
          final models = scoped
              ? snapshot.topModelsIn(userState!)
              : snapshot.topModels;
          final makers = scoped
              ? snapshot.topMakersIn(userState!)
              : snapshot.topMakers;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                _SummaryCard(snapshot: snapshot),
                const SizedBox(height: AppSpacing.space16),
                _ModelList(
                  title: 'Hottest cars in $scopeLabel',
                  models: models,
                ),
                const SizedBox(height: AppSpacing.space16),
                _MakerList(title: 'Top brands in $scopeLabel', makers: makers),
                if (!scoped && userState != null) ...[
                  const SizedBox(height: AppSpacing.space12),
                  _Footnote(
                    'JPJ has no state-level registrations for $userState in '
                    'this period, so these are national figures.',
                  ),
                ],
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
}

class _ModelList extends StatelessWidget {
  const _ModelList({required this.title, required this.models});

  final String title;
  final List<RankedModel> models;

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return GroupedSection(header: title, children: const [_EmptyRow()]);
    }
    final top = models.take(_listLength).toList();
    return GroupedSection(
      header: title,
      children: [
        for (var i = 0; i < top.length; i++)
          RankBarRow(
            rank: i + 1,
            label: top[i].name,
            sublabel: top[i].maker,
            count: top[i].count,
            fraction: _fraction(top[i].count, top.first.count),
          ),
      ],
    );
  }
}

class _MakerList extends StatelessWidget {
  const _MakerList({required this.title, required this.makers});

  final String title;
  final List<RankedCount> makers;

  @override
  Widget build(BuildContext context) {
    if (makers.isEmpty) {
      return GroupedSection(header: title, children: const [_EmptyRow()]);
    }
    final top = makers.take(_listLength).toList();
    return GroupedSection(
      header: title,
      children: [
        for (var i = 0; i < top.length; i++)
          RankBarRow(
            rank: i + 1,
            label: top[i].name,
            count: top[i].count,
            fraction: _fraction(top[i].count, top.first.count),
          ),
      ],
    );
  }
}

double _fraction(int count, int top) =>
    top <= 0 ? 0 : (count / top).clamp(0.0, 1.0);

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

class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space16,
      ),
      child: Text(
        'No data for this period.',
        style: Theme.of(
          context,
        ).textTheme.subhead.copyWith(color: AppColors.secondaryLabel),
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
        ).textTheme.footnote.copyWith(color: AppColors.tertiaryLabel),
      ),
    );
  }
}

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
