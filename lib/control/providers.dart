import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/services/app_storage.dart';
import 'package:assignment/control/auth/profile_cache_repository.dart';
import 'package:assignment/control/auth/supabase_auth_repository.dart';
import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/insights/insights_repository.dart';
import 'package:assignment/control/insights/supabase_insights_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/listings_cache_repository.dart';
import 'package:assignment/control/listings/supabase_listings_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/model/profile/profile.dart';

part 'providers.g.dart';

/// Composition root. These providers return domain interfaces, so features
/// depend only on abstractions.
///
/// Supabase credentials are required (`--dart-define-from-file=env.json`);
/// `main()` shows a configuration-error screen and never builds these
/// providers when the keys are missing.

/// The open sqflite database plus its initial rows. Overridden in `main()`
/// with the initialised instance.
@Riverpod(keepAlive: true)
AppStorage appStorage(Ref ref) =>
    throw UnimplementedError('appStorageProvider must be overridden in main()');

@Riverpod(keepAlive: true)
ProfileCacheRepository profileCacheRepository(Ref ref) {
  final storage = ref.watch(appStorageProvider);
  return ProfileCacheRepository(storage.db, storage.initialProfileRow);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => SupabaseAuthRepository(
  Supabase.instance.client,
  ref.watch(profileCacheRepositoryProvider),
);

@Riverpod(keepAlive: true)
ListingsCacheRepository listingsCacheRepository(Ref ref) {
  final storage = ref.watch(appStorageProvider);
  return ListingsCacheRepository(
    storage.db,
    storage.initialListingRows,
    storage.initialListingMediaRows,
  );
}

@Riverpod(keepAlive: true)
ListingsRepository listingsRepository(Ref ref) => SupabaseListingsRepository(
  Supabase.instance.client,
  ref.watch(listingsCacheRepositoryProvider),
);

/// Read-only market snapshot (Profile → Market insights).
@Riverpod(keepAlive: true)
InsightsRepository insightsRepository(Ref ref) =>
    SupabaseInsightsRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
DraftRepository draftRepository(Ref ref) {
  final storage = ref.watch(appStorageProvider);
  return DraftRepository(
    storage.db,
    storage.initialDraftRow,
    storage.initialDraftPhotoPaths,
  );
}

/// The signed-in profile as a stream (null when signed out).
@riverpod
Stream<Profile?> authState(Ref ref) =>
    ref.watch(authRepositoryProvider).authState();
