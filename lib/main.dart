import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'app/providers.dart';
import 'core/storage/app_storage.dart';
import 'core/supabase/supabase_config.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }
  final storage = await AppStorage.init();
  runApp(
    ProviderScope(
      overrides: [appStorageProvider.overrideWith((ref) => storage)],
      child: const AssignmentApp(),
    ),
  );
}

/// Root of the app. [MaterialApp.router] with Material widgets styled to feel
/// iOS — never [CupertinoApp] (CLAUDE.md §5).
class AssignmentApp extends ConsumerWidget {
  const AssignmentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Assignment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
