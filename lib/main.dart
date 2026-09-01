import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/providers.dart';
import 'package:assignment/control/services/app_storage.dart';
import 'package:assignment/control/services/supabase_config.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!SupabaseConfig.isConfigured) {
    // The backend is required; fail loudly and legibly rather than crashing.
    runApp(const MissingConfigApp());
    return;
  }
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  final storage = await AppStorage.init();
  runApp(
    MultiProvider(
      providers: appProviders(storage),
      child: const AssignmentApp(),
    ),
  );
}

/// Shown when the app is launched without Supabase credentials. There is no
/// offline backend — the keys are required (README "Getting started").
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Builder(
        builder: (context) {
          final text = Theme.of(context).textTheme;
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: AppSpacing.iconXl,
                      color: AppColors.tertiaryLabel,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    Text(
                      'Supabase keys missing',
                      style: text.headline,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'Run the app with --dart-define-from-file=env.json. '
                      'See the README for setup steps.',
                      style: text.subhead.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Root of the app. [MaterialApp.router] with Material widgets styled to feel
/// iOS — never [CupertinoApp] (CLAUDE.md §5).
class AssignmentApp extends StatelessWidget {
  const AssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Assignment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: context.read<GoRouter>(),
    );
  }
}
