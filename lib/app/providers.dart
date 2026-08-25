import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../core/storage/app_storage.dart';
import '../core/supabase/supabase_config.dart';
import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/data/supabase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/listings/data/draft_repository.dart';
import '../features/listings/data/fake_listings_repository.dart';
import '../features/listings/data/supabase_listings_repository.dart';
import '../features/listings/domain/listings_repository.dart';
import '../features/profile/domain/profile.dart';

part 'providers.g.dart';

/// Composition root. These providers return domain interfaces, so features
/// depend only on abstractions — swapping the fakes for Supabase later touches
/// this file alone.

/// The open sqflite database plus its initial rows. Overridden in `main()`
/// with the initialised instance.
@Riverpod(keepAlive: true)
AppStorage appStorage(Ref ref) =>
    throw UnimplementedError('appStorageProvider must be overridden in main()');

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  if (SupabaseConfig.isConfigured) {
    return SupabaseAuthRepository(Supabase.instance.client);
  }
  final storage = ref.watch(appStorageProvider);
  return FakeAuthRepository(storage.db, storage.initialSessionRow);
}

@Riverpod(keepAlive: true)
ListingsRepository listingsRepository(Ref ref) => SupabaseConfig.isConfigured
    ? SupabaseListingsRepository(Supabase.instance.client)
    : FakeListingsRepository();

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
