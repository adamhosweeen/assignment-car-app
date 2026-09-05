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
import 'package:assignment/control/purchases/purchases_repository.dart';
import 'package:assignment/control/purchases/supabase_purchases_repository.dart';
import 'package:assignment/control/profiles/supabase_profiles_repository.dart';
import 'package:assignment/control/reports/reports_repository.dart';
import 'package:assignment/control/reports/supabase_reports_repository.dart';
import 'package:assignment/model/profile/profile.dart';

List<SingleChildWidget> appProviders(AppStorage storage) {
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
  final purchases = SupabasePurchasesRepository(client);
  final admin = SupabaseAdminRepository(client);
  final reports = SupabaseReportsRepository(client);

  return [
    Provider<AppStorage>.value(value: storage),
    Provider<ProfileCacheRepository>.value(value: profileCache),
    Provider<ChatCacheRepository>.value(value: chatCache),
    Provider<BidsCacheRepository>.value(value: bidsCache),
    Provider<ListingsCacheRepository>.value(value: listingsCache),
    Provider<ProfilesCacheRepository>.value(value: profilesCache),

    Provider<DraftRepository>.value(value: draftRepository),

    Provider<AuthRepository>.value(value: auth),
    Provider<ListingsRepository>.value(value: listings),

    Provider<ChatRepository>.value(value: chat),

    Provider<BidsRepository>.value(value: bids),

    Provider<NotificationsRepository>.value(value: notifications),

    Provider<ProfilesRepository>.value(value: profiles),

    Provider<InsightsRepository>.value(value: insights),

    Provider<PurchasesRepository>.value(value: purchases),

    Provider<AdminRepository>.value(value: admin),

    Provider<ReportsRepository>.value(value: reports),

    Provider<SignedUrlCache>(create: (_) => SignedUrlCache()),

    StreamProvider<Profile?>.value(
      value: auth.authState(),
      initialData: auth.currentUser,
    ),

    ...notificationsProviders,
    ...chatProviders,

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
