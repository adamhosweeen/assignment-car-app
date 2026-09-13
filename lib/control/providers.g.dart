// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root. These providers return domain interfaces, so features
/// depend only on abstractions.
///
/// Supabase credentials are required (`--dart-define-from-file=env.json`);
/// `main()` shows a configuration-error screen and never builds these
/// providers when the keys are missing.
/// The open sqflite database plus its initial rows. Overridden in `main()`
/// with the initialised instance.

@ProviderFor(appStorage)
final appStorageProvider = AppStorageProvider._();

/// Composition root. These providers return domain interfaces, so features
/// depend only on abstractions.
///
/// Supabase credentials are required (`--dart-define-from-file=env.json`);
/// `main()` shows a configuration-error screen and never builds these
/// providers when the keys are missing.
/// The open sqflite database plus its initial rows. Overridden in `main()`
/// with the initialised instance.

final class AppStorageProvider
    extends $FunctionalProvider<AppStorage, AppStorage, AppStorage>
    with $Provider<AppStorage> {
  /// Composition root. These providers return domain interfaces, so features
  /// depend only on abstractions.
  ///
  /// Supabase credentials are required (`--dart-define-from-file=env.json`);
  /// `main()` shows a configuration-error screen and never builds these
  /// providers when the keys are missing.
  /// The open sqflite database plus its initial rows. Overridden in `main()`
  /// with the initialised instance.
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

@ProviderFor(profileCacheRepository)
final profileCacheRepositoryProvider = ProfileCacheRepositoryProvider._();

final class ProfileCacheRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileCacheRepository,
          ProfileCacheRepository,
          ProfileCacheRepository
        >
    with $Provider<ProfileCacheRepository> {
  ProfileCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileCacheRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileCacheRepository create(Ref ref) {
    return profileCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileCacheRepository>(value),
    );
  }
}

String _$profileCacheRepositoryHash() =>
    r'faa5ae7f2fafa342eea843df893c0a738e5a0022';

@ProviderFor(chatCacheRepository)
final chatCacheRepositoryProvider = ChatCacheRepositoryProvider._();

final class ChatCacheRepositoryProvider
    extends
        $FunctionalProvider<
          ChatCacheRepository,
          ChatCacheRepository,
          ChatCacheRepository
        >
    with $Provider<ChatCacheRepository> {
  ChatCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatCacheRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChatCacheRepository create(Ref ref) {
    return chatCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatCacheRepository>(value),
    );
  }
}

String _$chatCacheRepositoryHash() =>
    r'1fb71a50d059b7341d8e3d024bf9de8c9c03e0e3';

@ProviderFor(bidsCacheRepository)
final bidsCacheRepositoryProvider = BidsCacheRepositoryProvider._();

final class BidsCacheRepositoryProvider
    extends
        $FunctionalProvider<
          BidsCacheRepository,
          BidsCacheRepository,
          BidsCacheRepository
        >
    with $Provider<BidsCacheRepository> {
  BidsCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bidsCacheRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bidsCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<BidsCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BidsCacheRepository create(Ref ref) {
    return bidsCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BidsCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BidsCacheRepository>(value),
    );
  }
}

String _$bidsCacheRepositoryHash() =>
    r'ab77acf186895accbfeef951e23b9f139ff717f1';

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

String _$authRepositoryHash() => r'248efd640eaf794943ef780a42d141d200c58a2a';

@ProviderFor(listingsCacheRepository)
final listingsCacheRepositoryProvider = ListingsCacheRepositoryProvider._();

final class ListingsCacheRepositoryProvider
    extends
        $FunctionalProvider<
          ListingsCacheRepository,
          ListingsCacheRepository,
          ListingsCacheRepository
        >
    with $Provider<ListingsCacheRepository> {
  ListingsCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingsCacheRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingsCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListingsCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListingsCacheRepository create(Ref ref) {
    return listingsCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingsCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingsCacheRepository>(value),
    );
  }
}

String _$listingsCacheRepositoryHash() =>
    r'61f1d43e51498836f2a608c0216168fe4117f3d0';

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
    r'69770db952f7727069ee508cace69a6d44781415';

/// The signed-in user's in-app inbox (Profile → Inbox).

@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider = NotificationsRepositoryProvider._();

/// The signed-in user's in-app inbox (Profile → Inbox).

final class NotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationsRepository,
          NotificationsRepository,
          NotificationsRepository
        >
    with $Provider<NotificationsRepository> {
  /// The signed-in user's in-app inbox (Profile → Inbox).
  NotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsRepository create(Ref ref) {
    return notificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsRepository>(value),
    );
  }
}

String _$notificationsRepositoryHash() =>
    r'd1d43df1a31b9b3380558a07556db28d780d6a0c';

@ProviderFor(profilesCacheRepository)
final profilesCacheRepositoryProvider = ProfilesCacheRepositoryProvider._();

final class ProfilesCacheRepositoryProvider
    extends
        $FunctionalProvider<
          ProfilesCacheRepository,
          ProfilesCacheRepository,
          ProfilesCacheRepository
        >
    with $Provider<ProfilesCacheRepository> {
  ProfilesCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesCacheRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfilesCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfilesCacheRepository create(Ref ref) {
    return profilesCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfilesCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfilesCacheRepository>(value),
    );
  }
}

String _$profilesCacheRepositoryHash() =>
    r'9792bd277f24949aff0a68575caa2edc5d5cd4eb';

/// Other users' public profiles (seller search, seller pages, the other
/// participant in a chat thread).

@ProviderFor(profilesRepository)
final profilesRepositoryProvider = ProfilesRepositoryProvider._();

/// Other users' public profiles (seller search, seller pages, the other
/// participant in a chat thread).

final class ProfilesRepositoryProvider
    extends
        $FunctionalProvider<
          ProfilesRepository,
          ProfilesRepository,
          ProfilesRepository
        >
    with $Provider<ProfilesRepository> {
  /// Other users' public profiles (seller search, seller pages, the other
  /// participant in a chat thread).
  ProfilesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfilesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfilesRepository create(Ref ref) {
    return profilesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfilesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfilesRepository>(value),
    );
  }
}

String _$profilesRepositoryHash() =>
    r'20bd7e854dae25d8947466208a26374242180119';

/// Read-only market snapshot (Profile → Market insights).

@ProviderFor(insightsRepository)
final insightsRepositoryProvider = InsightsRepositoryProvider._();

/// Read-only market snapshot (Profile → Market insights).

final class InsightsRepositoryProvider
    extends
        $FunctionalProvider<
          InsightsRepository,
          InsightsRepository,
          InsightsRepository
        >
    with $Provider<InsightsRepository> {
  /// Read-only market snapshot (Profile → Market insights).
  InsightsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsRepositoryHash();

  @$internal
  @override
  $ProviderElement<InsightsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InsightsRepository create(Ref ref) {
    return insightsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InsightsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InsightsRepository>(value),
    );
  }
}

String _$insightsRepositoryHash() =>
    r'17f81f4c9fec3a44e6284ea1bcb8797ba4f2f824';

/// Buyer ↔ seller chat threads (Chat tab, Listing Detail's "Chat with seller").

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

/// Buyer ↔ seller chat threads (Chat tab, Listing Detail's "Chat with seller").

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  /// Buyer ↔ seller chat threads (Chat tab, Listing Detail's "Chat with seller").
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'961428a6fe2453ae9d22ee2b32fb1d83e21a89d0';

/// Bids on listings (Bid tab, Listing Detail's "Place a bid").

@ProviderFor(bidsRepository)
final bidsRepositoryProvider = BidsRepositoryProvider._();

/// Bids on listings (Bid tab, Listing Detail's "Place a bid").

final class BidsRepositoryProvider
    extends $FunctionalProvider<BidsRepository, BidsRepository, BidsRepository>
    with $Provider<BidsRepository> {
  /// Bids on listings (Bid tab, Listing Detail's "Place a bid").
  BidsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bidsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bidsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BidsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BidsRepository create(Ref ref) {
    return bidsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BidsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BidsRepository>(value),
    );
  }
}

String _$bidsRepositoryHash() => r'b6920a3df39da92d0238f87832ff13a1d69d7869';

/// Admin-only reads (Profile → Admin); the server rejects non-admin callers.

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

/// Admin-only reads (Profile → Admin); the server rejects non-admin callers.

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
  /// Admin-only reads (Profile → Admin); the server rejects non-admin callers.
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'288c9fec40e8b153784bef333a243ff033b1cad5';

/// Filing a report against another user (seller page).

@ProviderFor(reportsRepository)
final reportsRepositoryProvider = ReportsRepositoryProvider._();

/// Filing a report against another user (seller page).

final class ReportsRepositoryProvider
    extends
        $FunctionalProvider<
          ReportsRepository,
          ReportsRepository,
          ReportsRepository
        >
    with $Provider<ReportsRepository> {
  /// Filing a report against another user (seller page).
  ReportsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReportsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReportsRepository create(Ref ref) {
    return reportsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsRepository>(value),
    );
  }
}

String _$reportsRepositoryHash() => r'0e8c9b175f5fe9eeb951557ee2e05e3eccbe0c68';

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

String _$draftRepositoryHash() => r'11661fe81a09670bd2ca35b61ce45c0f9c8981b5';

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
