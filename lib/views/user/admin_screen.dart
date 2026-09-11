import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/user_providers.dart';
import 'package:assignment/control/user/admin/admin_repository.dart';
import 'package:assignment/model/user/app_user.dart';
import 'package:assignment/model/user/report.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/user/admin_reports_screen.dart';
import 'package:assignment/views/user/admin_users_screen.dart';
import 'package:assignment/widgets/common/segmented_control.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

  late Future<List<AppUser>> _users;
  late Future<List<Report>> _reports;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final admin = context.read<AdminRepository>();
    _users = fetchAppUsers(admin);
    _reports = fetchReports(admin);
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
                AppUsersTab(users: _users, onChanged: _reload),
                ReportsTab(reports: _reports, onChanged: _reload),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
