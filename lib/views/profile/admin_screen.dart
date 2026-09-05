import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/admin/admin_providers.dart';
import 'package:assignment/control/admin/admin_repository.dart';
import 'package:assignment/model/admin/admin_user_stats.dart';
import 'package:assignment/model/report/admin_report.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/profile/admin_reports_screen.dart';
import 'package:assignment/views/profile/admin_users_screen.dart';
import 'package:assignment/widgets/common/segmented_control.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

  late Future<List<AdminUserStats>> _users;
  late Future<List<AdminReport>> _reports;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final admin = context.read<AdminRepository>();
    _users = fetchAdminUsers(admin);
    _reports = fetchAdminReports(admin);
  }

  void _reload() => setState(_load);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupedBackground,
      appBar: AppBar(title: const Text('Admin')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.space12,
              AppSpacing.screenPadding,
              0,
            ),
            child: SegmentedControl(
              labels: const ['Users', 'Reports'],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                AdminUsersTab(users: _users, onChanged: _reload),
                AdminReportsTab(reports: _reports, onChanged: _reload),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
