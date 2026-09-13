import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/services/supabase_config.dart';

class SignedUrlCache {
  final _urls = <String, Future<String?>>{};

  Future<String?> resolve(String bucket, String path) =>
      _urls.putIfAbsent('$bucket/$path', () => _sign(bucket, path));

  Future<String?> _sign(String bucket, String path) async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return await Supabase.instance.client.storage
          .from(bucket)
          .createSignedUrl(path, 3600);
    } catch (_) {
      _urls.remove('$bucket/$path');
      return null;
    }
  }
}
