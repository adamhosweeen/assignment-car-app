import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/app_routes.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/control/services/app_storage.dart';
import 'package:assignment/control/services/supabase_config.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/auth/auth_gate.dart';
import 'package:assignment/widgets/notifications/notification_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!SupabaseConfig.isConfigured) {
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

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarSell',
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

class AssignmentApp extends StatelessWidget {
  const AssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator = context.read<AppNavigator>();
    return MaterialApp(
      title: 'CarSell',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: navigator.key,
      navigatorObservers: [navigator.tracker],
      onGenerateRoute: generateRoute,
      home: const AuthGate(),
      builder: (context, child) =>
          NotificationBannerHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
