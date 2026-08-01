import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Opened Hive boxes for the app. Initialised once in `main()` before `runApp`.
///
/// Hive is a cache/draft store only — never the source of truth (CLAUDE.md §3).
/// - [draftBox]   — the current in-progress sell form (JSON string).
/// - [sessionBox] — the signed-in profile, so a returning user skips login.
class AppStorage {
  const AppStorage._(this.draftBox, this.sessionBox);

  final Box<dynamic> draftBox;
  final Box<dynamic> sessionBox;

  static Future<AppStorage> init() async {
    await Hive.initFlutter();
    final draftBox = await Hive.openBox<dynamic>('draft');
    final sessionBox = await Hive.openBox<dynamic>('session');
    return AppStorage._(draftBox, sessionBox);
  }
}
