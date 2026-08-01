/// Supabase connection values, injected at build time via
/// `--dart-define` / `--dart-define-from-file=env.json` (never committed —
/// CLAUDE.md §6).
///
/// When these are empty the app falls back to the in-memory fake backend, so it
/// still runs without credentials.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
