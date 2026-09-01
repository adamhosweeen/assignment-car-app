import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/admin/admin_repository.dart';
import 'package:assignment/control/admin/supabase_admin_repository.dart';
import 'package:assignment/control/services/app_storage.dart';
import 'package:assignment/control/auth/profile_cache_repository.dart';
import 'package:assignment/control/auth/supabase_auth_repository.dart';
import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_cache_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/bid/supabase_bids_repository.dart';
import 'package:assignment/control/chat/chat_cache_repository.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/chat/supabase_chat_repository.dart';
import 'package:assignment/control/insights/insights_repository.dart';
import 'package:assignment/control/insights/supabase_insights_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/listings_cache_repository.dart';
import 'package:assignment/control/listings/supabase_listings_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/control/notifications/supabase_notifications_repository.dart';
import 'package:assignment/control/profiles/profiles_cache_repository.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/control/profiles/supabase_profiles_repository.dart';
import 'package:assignment/control/reports/reports_repository.dart';
import 'package:assignment/control/reports/supabase_reports_repository.dart';
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
ChatCacheRepository chatCacheRepository(Ref ref) {
  final storage = ref.watch(appStorageProvider);
  return ChatCacheRepository(storage.db, storage.initialConversationRows);
}

@Riverpod(keepAlive: true)
BidsCacheRepository bidsCacheRepository(Ref ref) {
  final storage = ref.watch(appStorageProvider);
  return BidsCacheRepository(
    storage.db,
    storage.initialBidRows,
    storage.initialBidListingRows,
    storage.initialBidListingMediaRows,
  );
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => SupabaseAuthRepository(
  Supabase.instance.client,
  ref.watch(profileCacheRepositoryProvider),
  ref.watch(chatCacheRepositoryProvider),
  ref.watch(bidsCacheRepositoryProvider),
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

/// The signed-in user's in-app inbox (Profile → Inbox).
@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) =>
    SupabaseNotificationsRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
ProfilesCacheRepository profilesCacheRepository(Ref ref) =>
    ProfilesCacheRepository(ref.watch(appStorageProvider).db);

/// Other users' public profiles (seller search, seller pages, the other
/// participant in a chat thread).
@Riverpod(keepAlive: true)
ProfilesRepository profilesRepository(Ref ref) => SupabaseProfilesRepository(
  Supabase.instance.client,
  ref.watch(profilesCacheRepositoryProvider),
);

/// Read-only market snapshot (Profile → Market insights).
@Riverpod(keepAlive: true)
InsightsRepository insightsRepository(Ref ref) =>
    SupabaseInsightsRepository(Supabase.instance.client);

/// Buyer ↔ seller chat threads (Chat tab, Listing Detail's "Chat with seller").
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) => SupabaseChatRepository(
  Supabase.instance.client,
  ref.watch(chatCacheRepositoryProvider),
);

/// Bids on listings (Bid tab, Listing Detail's "Place a bid").
@Riverpod(keepAlive: true)
BidsRepository bidsRepository(Ref ref) => SupabaseBidsRepository(
  Supabase.instance.client,
  ref.watch(bidsCacheRepositoryProvider),
);

/// Admin-only reads (Profile → Admin); the server rejects non-admin callers.
@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) =>
    SupabaseAdminRepository(Supabase.instance.client);

/// Filing a report against another user (seller page).
@Riverpod(keepAlive: true)
ReportsRepository reportsRepository(Ref ref) =>
    SupabaseReportsRepository(Supabase.instance.client);

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
