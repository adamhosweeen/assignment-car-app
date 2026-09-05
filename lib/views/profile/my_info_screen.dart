import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/grouped_section.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<Profile?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Info'),
        actions: [
          if (profile != null)
            TextButton(
              onPressed: () => context.push('/profile/edit'),
              child: const Text('Edit'),
            ),
        ],
      ),
      body: _body(profile),
    );
  }

  Widget _body(Profile? profile) {
    if (profile == null) {
      return const Center(child: Text('You’re signed out.'));
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        GroupedSection(
          header: 'NAME',
          children: [
            GroupedRow(
              label: 'First name',
              value: profile.firstName ?? 'Not set',
            ),
            GroupedRow(
              label: 'Last name',
              value: profile.lastName ?? 'Not set',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        GroupedSection(
          header: 'CONTACT',
          children: [
            GroupedRow(label: 'Email', value: profile.email),
            GroupedRow(label: 'Phone', value: profile.phone ?? 'Not set'),
            GroupedRow(label: 'Location', value: profile.state ?? 'Not set'),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        GroupedSection(
          header: 'ACCOUNT',
          children: [
            GroupedRow(
              label: 'Date of birth',
              value: profile.dob == null ? 'Not set' : formatDate(profile.dob!),
            ),
            GroupedRow(
              label: 'Member since',
              value: formatMonthYear(profile.createdAt),
            ),
          ],
        ),
      ],
    );
  }
}
