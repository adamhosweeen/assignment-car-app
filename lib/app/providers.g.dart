// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root. These providers return domain interfaces, so features
/// depend only on abstractions — swapping the fakes for Supabase later touches
/// this file alone.
/// Opened Hive boxes. Overridden in `main()` with the initialised instance.

@ProviderFor(appStorage)
final appStorageProvider = AppStorageProvider._();

/// Composition root. These providers return domain interfaces, so features
/// depend only on abstractions — swapping the fakes for Supabase later touches
/// this file alone.
/// Opened Hive boxes. Overridden in `main()` with the initialised instance.

final class AppStorageProvider
    extends $FunctionalProvider<AppStorage, AppStorage, AppStorage>
    with $Provider<AppStorage> {
  /// Composition root. These providers return domain interfaces, so features
  /// depend only on abstractions — swapping the fakes for Supabase later touches
  /// this file alone.
  /// Opened Hive boxes. Overridden in `main()` with the initialised instance.
  AppStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStorageHash();

  @$internal
  @override
  $ProviderElement<AppStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppStorage create(Ref ref) {
    return appStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppStorage>(value),
    );
  }
}

String _$appStorageHash() => r'07a72bbadaa89fe6644373908b164b8f86beee19';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'f4b6bfc578831e1ccc03834ec4327799f55ac3b3';

@ProviderFor(listingsRepository)
final listingsRepositoryProvider = ListingsRepositoryProvider._();

final class ListingsRepositoryProvider
    extends
        $FunctionalProvider<
          ListingsRepository,
          ListingsRepository,
          ListingsRepository
        >
    with $Provider<ListingsRepository> {
  ListingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListingsRepository create(Ref ref) {
    return listingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingsRepository>(value),
    );
  }
}

String _$listingsRepositoryHash() =>
    r'aa6017da0bb396d8c349be28b83f0bd7fcfa10e1';

@ProviderFor(draftRepository)
final draftRepositoryProvider = DraftRepositoryProvider._();

final class DraftRepositoryProvider
    extends
        $FunctionalProvider<DraftRepository, DraftRepository, DraftRepository>
    with $Provider<DraftRepository> {
  DraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftRepositoryHash();

  @$internal
  @override
  $ProviderElement<DraftRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DraftRepository create(Ref ref) {
    return draftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftRepository>(value),
    );
  }
}

String _$draftRepositoryHash() => r'97073f19670553269e9d5110e87bf9c32aa99c04';

/// The signed-in profile as a stream (null when signed out).

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// The signed-in profile as a stream (null when signed out).

final class AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, Stream<Profile?>>
    with $FutureModifier<Profile?>, $StreamProvider<Profile?> {
  /// The signed-in profile as a stream (null when signed out).
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Profile?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'ac555be9b1f40c73ca7fa0c9169195f9bed49580';
