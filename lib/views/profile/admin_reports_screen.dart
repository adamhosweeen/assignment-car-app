import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/admin/admin_repository.dart';
import 'package:assignment/model/report/admin_report.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/segmented_control.dart';

/// The Reports tab of the Admin screen: user-filed reports, split Open /
/// Resolved. From a report the admin can ban (or unban) the reported user
/// and mark the report resolved.
class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({
    super.key,
    required this.reports,
    required this.onChanged,
  });

  final Future<List<AdminReport>> reports;

  /// Re-runs both admin fetches — banning a user changes the Users tab too.
  final VoidCallback onChanged;

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  bool _showOpen = true;

  void _refresh() => widget.onChanged();

  Future<void> _runAction(Future<Result<void>> Function() action) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final res = await action();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    switch (res) {
      case Ok():
        _refresh();
      case Err(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmSetBanned(AdminReport report, bool ban) async {
    // Read before awaiting the dialog — the context can't be used across it.
    final admin = context.read<AdminRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          ban ? 'Ban ${report.reported}?' : 'Unban ${report.reported}?',
        ),
        content: Text(
          ban
              ? 'They won’t be able to log in again and their cars disappear '
                    'from buyers until they are unbanned.'
              : 'They will be able to log in again and their cars become '
                    'visible to buyers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ban
                ? TextButton.styleFrom(foregroundColor: AppColors.destructive)
                : null,
            child: Text(ban ? 'Ban' : 'Unban'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runAction(() => admin.setBanned(report.reportedId, ban));
  }

  void _showDetails(AdminReport report) {
    final text = Theme.of(context).textTheme;
    final admin = context.read<AdminRepository>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.groupedBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(report.title, style: text.title3),
              const SizedBox(height: AppSpacing.space8),
              Text(
                '${report.reporter} reported ${report.reported} · '
                '${formatDate(report.createdAt)}',
                style: text.footnote.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space16),
              GroupedSection(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Text(report.description, style: text.body),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              FilledButton(
                style: report.reportedBanned
                    ? null
                    : FilledButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                      ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _confirmSetBanned(report, !report.reportedBanned);
                },
                child: Text(
                  report.reportedBanned
                      ? 'Unban ${report.reported}'
                      : 'Ban ${report.reported}',
                ),
              ),
              if (report.isOpen) ...[
                const SizedBox(height: AppSpacing.space12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.groupedBackground,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _runAction(() => admin.resolveReport(report.id));
                  },
                  child: const Text('Mark resolved'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return FutureBuilder<List<AdminReport>>(
      future: widget.reports,
      builder: (context, snapshot) {
        final error = snapshot.error;
        if (error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: text.subhead.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final reports = snapshot.data;
        if (reports == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final visible = [
          for (final r in reports)
            if (r.isOpen == _showOpen) r,
        ];
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              SegmentedControl(
                labels: const ['Open', 'Resolved'],
                selected: _showOpen ? 0 : 1,
                onChanged: (i) => setState(() => _showOpen = i == 0),
              ),
              const SizedBox(height: AppSpacing.space16),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space32,
                  ),
                  child: Center(
                    child: Text(
                      _showOpen ? 'No open reports.' : 'No resolved reports.',
                      style: text.subhead.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ),
                )
              else
                for (final (i, report) in visible.indexed)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == visible.length - 1 ? 0 : AppSpacing.space12,
                    ),
                    child: _ReportCard(
                      report: report,
                      onTap: () => _showDetails(report),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// One report: title, a preview of the description, who reported whom.
class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});

  final AdminReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: ColoredBox(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.headline,
                      ),
                    ),
                    if (report.reportedBanned) ...[
                      const SizedBox(width: AppSpacing.space8),
                      const _Tag(
                        label: 'Banned',
                        color: AppColors.destructive,
                        background: AppColors.destructiveMuted,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.subhead.copyWith(color: AppColors.secondaryLabel),
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  '${report.reporter} reported ${report.reported} · '
                  '${formatDate(report.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.footnote.copyWith(color: AppColors.tertiaryLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small tinted status tag (also used for "Banned" on the users screen).
class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4 / 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusBar),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.caption.copyWith(color: color),
      ),
    );
  }
}
