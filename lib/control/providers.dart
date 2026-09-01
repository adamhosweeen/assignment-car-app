import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/admin/admin_repository.dart';
import 'package:assignment/control/admin/supabase_admin_repository.dart';
import 'package:assignment/control/app_router.dart';
import 'package:assignment/control/services/app_storage.dart';
import 'package:assignment/control/services/signed_url_cache.dart';
import 'package:assignment/control/auth/profile_cache_repository.dart';
import 'package:assignment/control/auth/supabase_auth_repository.dart';
import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/bid/bids_cache_repository.dart';
import 'package:assignment/control/bid/bids_repository.dart';
import 'package:assignment/control/bid/supabase_bids_repository.dart';
import 'package:assignment/control/chat/chat_cache_repository.dart';
import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/chat/chat_repository.dart';
import 'package:assignment/control/chat/supabase_chat_repository.dart';
import 'package:assignment/control/insights/insights_repository.dart';
import 'package:assignment/control/insights/supabase_insights_repository.dart';
import 'package:assignment/control/listings/draft_repository.dart';
import 'package:assignment/control/listings/listings_cache_repository.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/control/listings/supabase_listings_repository.dart';
import 'package:assignment/control/listings/listings_repository.dart';
import 'package:assignment/control/notifications/notifications_providers.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/control/notifications/supabase_notifications_repository.dart';
import 'package:assignment/control/profiles/profiles_cache_repository.dart';
import 'package:assignment/control/profiles/profiles_repository.dart';
import 'package:assignment/control/profiles/supabase_profiles_repository.dart';
import 'package:assignment/control/reports/reports_repository.dart';
import 'package:assignment/control/reports/supabase_reports_repository.dart';
import 'package:assignment/model/profile/profile.dart';

/// Composition root. These providers expose domain interfaces, so features
/// depend only on abstractions.
///
/// Supabase credentials are required (`--dart-define-from-file=env.json`);
/// `main()` shows a configuration-error screen and never calls this when the
/// keys are missing.
///
/// The graph is wired up here rather than through nested `create` callbacks
/// because two things need a repository *before* the widget tree exists: the
/// router's redirect guard needs [AuthRepository], and the auth stream needs
/// `currentUser` as its initial value. Every constructor below is a field
/// assignment or a decode of rows [AppStorage] has already read, so building
/// them up front costs nothing.
List<SingleChildWidget> appProviders(AppStorage storage) {
  // ── Local caches over the open sqflite database ─────────────────────────
  final profileCache = ProfileCacheRepository(
    storage.db,
    storage.initialProfileRow,
  );
  final chatCache = ChatCacheRepository(
    storage.db,
    storage.initialConversationRows,
  );
  final bidsCache = BidsCacheRepository(
    storage.db,
    storage.initialBidRows,
    storage.initialBidListingRows,
    storage.initialBidListingMediaRows,
  );
  final listingsCache = ListingsCacheRepository(
    storage.db,
    storage.initialListingRows,
    storage.initialListingMediaRows,
  );
  final profilesCache = ProfilesCacheRepository(storage.db);
  final draftRepository = DraftRepository(
    storage.db,
    storage.initialDraftRow,
    storage.initialDraftPhotoPaths,
  );

  // ── Backend repositories ────────────────────────────────────────────────
  final client = Supabase.instance.client;
  final auth = SupabaseAuthRepository(
    client,
    profileCache,
    chatCache,
    bidsCache,
  );
  final listings = SupabaseListingsRepository(client, listingsCache);
  final chat = SupabaseChatRepository(client, chatCache);
  final bids = SupabaseBidsRepository(client, bidsCache);
  final notifications = SupabaseNotificationsRepository(client);
  final profiles = SupabaseProfilesRepository(client, profilesCache);
  final insights = SupabaseInsightsRepository(client);
  final admin = SupabaseAdminRepository(client);
  final reports = SupabaseReportsRepository(client);

  return [
    Provider<AppStorage>.value(value: storage),
    Provider<ProfileCacheRepository>.value(value: profileCache),
    Provider<ChatCacheRepository>.value(value: chatCache),
    Provider<BidsCacheRepository>.value(value: bidsCache),
    Provider<ListingsCacheRepository>.value(value: listingsCache),
    Provider<ProfilesCacheRepository>.value(value: profilesCache),

    /// The in-progress listing draft, persisted to sqflite.
    Provider<DraftRepository>.value(value: draftRepository),

    Provider<AuthRepository>.value(value: auth),
    Provider<ListingsRepository>.value(value: listings),

    /// Buyer ↔ seller chat threads (Chat tab, Listing Detail's "Chat with
    /// seller").
    Provider<ChatRepository>.value(value: chat),

    /// Bids on listings (Bid tab, Listing Detail's "Place a bid").
    Provider<BidsRepository>.value(value: bids),

    /// The signed-in user's in-app inbox (Profile → Inbox).
    Provider<NotificationsRepository>.value(value: notifications),

    /// Other users' public profiles (seller search, seller pages, the other
    /// participant in a chat thread).
    Provider<ProfilesRepository>.value(value: profiles),

    /// Read-only market snapshot (Profile → Market insights).
    Provider<InsightsRepository>.value(value: insights),

    /// Admin-only reads (Profile → Admin); the server rejects non-admin
    /// callers.
    Provider<AdminRepository>.value(value: admin),

    /// Filing a report against another user (seller page).
    Provider<ReportsRepository>.value(value: reports),

    Provider<SignedUrlCache>(create: (_) => SignedUrlCache()),

    // ── App-wide state ────────────────────────────────────────────────────
    /// The signed-in profile, null when signed out. `currentUser` is available
    /// synchronously from the cached session, so this stream has no loading
    /// state to speak of — the initial value is already the right answer.
    StreamProvider<Profile?>.value(
      value: auth.authState(),
      initialData: auth.currentUser,
    ),

    /// Both of these feed a tab badge in the shell *and* a screen, so they
    /// have to be one shared subscription — the repository streams are
    /// single-subscription and open a realtime channel per listen.
    ...notificationsProviders,
    ...chatProviders,

    /// The in-progress sell draft. App-scoped rather than scoped to the sell
    /// route because publishing a listing resets it from outside that flow.
    ChangeNotifierProvider<SellController>(
      create: (_) => SellController(draftRepository),
    ),

    Provider<GoRouter>(
      lazy: false,
      create: (_) => createRouter(auth),
      dispose: (_, router) => router.dispose(),
    ),
  ];
}
