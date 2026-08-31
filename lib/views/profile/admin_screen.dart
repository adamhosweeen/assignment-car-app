import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/profile/admin_reports_screen.dart';
import 'package:assignment/views/profile/admin_users_screen.dart';
import 'package:assignment/widgets/common/segmented_control.dart';

/// The admin area (Profile → Admin): one screen with a Users | Reports
/// switch. Both tabs read admin-guarded RPCs, so a non-admin who reaches
/// this route only ever sees error states.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

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
            // IndexedStack keeps both tabs alive, so search text, sort, and
            // the Open/Resolved toggle survive switching back and forth.
            child: IndexedStack(
              index: _tab,
              children: const [AdminUsersTab(), AdminReportsTab()],
            ),
          ),
        ],
      ),
    );
  }
}
