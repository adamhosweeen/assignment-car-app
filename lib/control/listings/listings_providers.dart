import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/providers.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/control/services/supabase_config.dart';
import 'package:assignment/model/listing/listing.dart';

part 'listings_providers.g.dart';

/// All active listings, newest first (Buy feed). Backed by the realtime stream.
@riverpod
Stream<List<Listing>> activeListings(Ref ref) =>
    ref.watch(listingsRepositoryProvider).watchActive();

/// The signed-in user's own listings (My Listings).
@riverpod
Stream<List<Listing>> myListings(Ref ref) {
  ref.watch(authStateProvider); // rebuild when the signed-in user changes
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(const <Listing>[]);
  return ref.watch(listingsRepositoryProvider).watchBySeller(user.id);
}

/// A single listing by id (Listing detail).
@riverpod
Future<Listing> listingById(Ref ref, String id) async {
  final res = await ref.watch(listingsRepositoryProvider).getById(id);
  return switch (res) {
    Ok(:final value) => value,
    Err(:final message) => throw Exception(message),
  };
}

/// Resolve a Supabase storage bucket path to a temporary signed URL (1 hour).
/// Returns null when Supabase isn't configured (fake backend uses local files).
@riverpod
Future<String?> signedImageUrl(Ref ref, String path) async {
  if (!SupabaseConfig.isConfigured) return null;
  try {
    return await Supabase.instance.client.storage
        .from('listing-media')
        .createSignedUrl(path, 3600);
  } catch (_) {
    return null;
  }
}
