import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/services/supabase_config.dart';

/// Resolves Supabase storage bucket paths to temporary signed URLs, and
/// remembers the in-flight/resolved future per path.
///
/// Listing photos are rendered inside scrolling lists, where a tile is rebuilt
/// (and its [State] recreated) every time it leaves and re-enters the viewport.
/// Without the memo every scroll would re-sign the same path. The URLs are
/// valid for an hour, which comfortably outlives one visit to a screen.
class SignedUrlCache {
  final _urls = <String, Future<String?>>{};

  /// The signed URL for [path], or null when Supabase isn't configured or the
  /// object can't be signed. Never throws — a missing photo falls back to the
  /// placeholder rather than breaking the row it sits in.
  Future<String?> resolve(String path) =>
      _urls.putIfAbsent(path, () => _sign(path));

  Future<String?> _sign(String path) async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return await Supabase.instance.client.storage
          .from('listing-media')
          .createSignedUrl(path, 3600);
    } catch (_) {
      // Drop the failure so a later rebuild can try again.
      _urls.remove(path);
      return null;
    }
  }
}
