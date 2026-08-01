import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/storage/app_storage.dart';
import '../features/auth/data/fake_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/listings/data/draft_repository.dart';
import '../features/listings/data/fake_listings_repository.dart';
import '../features/listings/domain/listings_repository.dart';
import '../features/profile/domain/profile.dart';

part 'providers.g.dart';

/// Composition root. These providers return domain interfaces, so features
/// depend only on abstractions — swapping the fakes for Supabase later touches
/// this file alone.

/// Opened Hive boxes. Overridden in `main()` with the initialised instance.
@Riverpod(keepAlive: true)
AppStorage appStorage(Ref ref) =>
    throw UnimplementedError('appStorageProvider must be overridden in main()');

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    FakeAuthRepository(ref.watch(appStorageProvider).sessionBox);

@Riverpod(keepAlive: true)
ListingsRepository listingsRepository(Ref ref) => FakeListingsRepository();

@Riverpod(keepAlive: true)
DraftRepository draftRepository(Ref ref) =>
    DraftRepository(ref.watch(appStorageProvider).draftBox);

/// The signed-in profile as a stream (null when signed out).
@riverpod
Stream<Profile?> authState(Ref ref) =>
    ref.watch(authRepositoryProvider).authState();
