import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'package:assignment/control/user/admin/admin_repository.dart';
import 'package:assignment/control/user/admin/supabase_admin_repository.dart';
import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/services/app_storage.dart';
import 'package:assignment/control/user/inbox/inbox_repository.dart';
import 'package:assignment/control/user/inbox/inbox_cache_repository.dart';
import 'package:assignment/control/user/inbox/supabase_inbox_repository.dart';
import 'package:assignment/control/services/signed_url_cache.dart';
import 'package:assignment/control/user/auth/user_cache_repository.dart';
import 'package:assignment/control/user/auth/supabase_auth_repository.dart';
import 'package:assignment/control/user/auth/auth_repository.dart';
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
import 'package:assignment/control/user/other_users_cache_repository.dart';
import 'package:assignment/control/user/users_repository.dart';
import 'package:assignment/control/purchases/purchases_repository.dart';
import 'package:assignment/control/purchases/supabase_purchases_repository.dart';
import 'package:assignment/control/user/supabase_users_repository.dart';
import 'package:assignment/control/user/report/report_repository.dart';
import 'package:assignment/control/user/report/supabase_report_repository.dart';
import 'package:assignment/model/user/app_user.dart';

List<SingleChildWidget> appProviders(AppStorage storage) {
  final profileCache = UserCacheRepository(
    storage.db,
    storage.initialProfileRow,
  );
  final chatCache = ChatCacheRepository(
    storage.db,
    storage.initialConversationRows,
  );
  final listingsCache = ListingsCacheRepository(
    storage.db,
    storage.initialListingRows,
    storage.initialListingMediaRows,
  );
  final profilesCache = OtherUsersCacheRepository(storage.db);
  final inboxCache = InboxCacheRepository(storage.db);
  final bidsCache = BidsCacheRepository(storage.db);
  final draftRepository = DraftRepository(
    storage.db,
    storage.initialDraftRow,
    storage.initialDraftPhotoPaths,
  );

  final client = Supabase.instance.client;
  final auth = SupabaseAuthRepository(
    client,
    profileCache,
    profilesCache,
    inboxCache,
    chatCache,
    bidsCache,
    draftRepository,
  );
  final listings = SupabaseListingsRepository(client, listingsCache);
  final chat = SupabaseChatRepository(client, chatCache);
  final bids = SupabaseBidsRepository(client, bidsCache);
  final profiles = SupabaseUsersRepository(client, profilesCache);
  final insights = SupabaseInsightsRepository(client);
  final purchases = SupabasePurchasesRepository(client);
  final admin = SupabaseAdminRepository(client);
  final reports = SupabaseReportRepository(client);
  final inbox = SupabaseInboxRepository(client, inboxCache);

  return [
    Provider<AppStorage>.value(value: storage),
    Provider<UserCacheRepository>.value(value: profileCache),
    Provider<ChatCacheRepository>.value(value: chatCache),
    Provider<ListingsCacheRepository>.value(value: listingsCache),
    Provider<OtherUsersCacheRepository>.value(value: profilesCache),

    Provider<DraftRepository>.value(value: draftRepository),

    Provider<AuthRepository>.value(value: auth),
    Provider<ListingsRepository>.value(value: listings),

    Provider<ChatRepository>.value(value: chat),

    Provider<BidsRepository>.value(value: bids),

    Provider<UsersRepository>.value(value: profiles),

    Provider<InsightsRepository>.value(value: insights),

    Provider<PurchasesRepository>.value(value: purchases),

    Provider<AdminRepository>.value(value: admin),

    Provider<ReportRepository>.value(value: reports),

    Provider<InboxRepository>.value(value: inbox),

    Provider<SignedUrlCache>(create: (_) => SignedUrlCache()),

    StreamProvider<AppUser?>.value(
      value: auth.authState(),
      initialData: auth.currentUser,
    ),

    ...chatProviders,

    ChangeNotifierProvider<SellController>(
      create: (_) =>
          SellController(draftRepository, authChanges: auth.authState()),
    ),

    Provider<AppNavigator>(
      lazy: false,
      create: (_) => AppNavigator(),
      dispose: (_, navigator) => navigator.dispose(),
    ),
  ];
}
