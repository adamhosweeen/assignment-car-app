import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/services/supabase_config.dart';

class SignedUrlCache {
  final _urls = <String, Future<String?>>{};

  Future<String?> resolve(String path) =>
      _urls.putIfAbsent(path, () => _sign(path));

  Future<String?> _sign(String path) async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return await Supabase.instance.client.storage
          .from('listing-media')
          .createSignedUrl(path, 3600);
    } catch (_) {
      _urls.remove(path);
      return null;
    }
  }
}
