import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/views/app_shell.dart';
import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/views/auth/login_screen.dart';
import 'package:assignment/views/auth/register_flow_screen.dart';
import 'package:assignment/views/auth/splash_screen.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/views/auth/welcome_screen.dart';
import 'package:assignment/views/bid/bid_screen.dart';
import 'package:assignment/views/bid/place_bid_screen.dart';
import 'package:assignment/views/chat/chat_screen.dart';
import 'package:assignment/views/chat/chat_thread_screen.dart';
import 'package:assignment/views/buy/buy_feed_screen.dart';
import 'package:assignment/views/buy/car_search_screen.dart';
import 'package:assignment/views/buy/listing_detail_screen.dart';
import 'package:assignment/views/buy/purchase_screen.dart';
import 'package:assignment/views/sell/sell_flow_screen.dart';
import 'package:assignment/views/sell/sell_home_screen.dart';
import 'package:assignment/views/profile/admin_screen.dart';
import 'package:assignment/views/profile/car_interests_screen.dart';
import 'package:assignment/views/profile/edit_profile_screen.dart';
import 'package:assignment/views/profile/inbox_screen.dart';
import 'package:assignment/views/profile/market_insights_screen.dart';
import 'package:assignment/views/profile/my_info_screen.dart';
import 'package:assignment/views/profile/profile_screen.dart';
import 'package:assignment/views/profile/seller_profile_screen.dart';
import 'package:assignment/views/profile/seller_search_screen.dart';

/// Re-runs the redirect guard whenever auth state flips. Lives as long as the
/// router does, which is the life of the app.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(AuthRepository auth) {
    _sub = auth.authState().listen((_) => notifyListeners());
  }

  late final StreamSubscription<Profile?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// The app router. Splash decides the first destination; the redirect guard
/// keeps signed-out users in the login flow and signed-in users out of it.
GoRouter createRouter(AuthRepository auth) {
  final refresh = _AuthRefresh(auth);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = auth.currentUser != null;
      final loc = state.matchedLocation;
      if (loc == '/splash') return null; // splash routes itself
      final inAuthFlow =
          loc.startsWith('/welcome') ||
          loc.startsWith('/login') ||
          loc.startsWith('/register');
      if (!signedIn) return inAuthFlow ? null : '/welcome';
      if (inAuthFlow) return '/home/buy';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      // The half-filled signup form is scoped to this route, so leaving the
      // flow throws it away.
      GoRoute(
        path: '/register',
        builder: (_, _) => ChangeNotifierProvider(
          create: (_) => RegistrationController(),
          child: const RegisterFlowScreen(),
        ),
      ),
      GoRoute(
        path: '/sell/new',
        builder: (_, state) => SellFlowScreen(editing: state.extra == true),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (_, state) =>
            ListingDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/listing/:id/buy',
        builder: (_, state) {
          // Reached from a chat offer's "Confirm and buy" / "Buy now" with
          // the offer to buy at — never trust its type, `extra` doesn't
          // survive Android killing and restoring the app process.
          final extra = state.extra;
          final offer = extra is ({String messageId, int amountMyr})
              ? extra
              : null;
          return PurchaseScreen(
            id: state.pathParameters['id']!,
            offerMessageId: offer?.messageId,
            offerAmountMyr: offer?.amountMyr,
          );
        },
      ),
      GoRoute(
        path: '/listing/:id/bid',
        builder: (_, state) =>
            PlaceBidScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/search', builder: (_, _) => const CarSearchScreen()),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ChatThreadScreen(
          conversationId: state.pathParameters['id']!,
          // `extra` is only a same-session fast path (avoids the initial
          // fetch when we already have it in hand, e.g. tapping a thread
          // row). It doesn't survive Android killing and restoring the app
          // process, so never trust its type — fall back to fetching by id.
          seed: state.extra is Conversation
              ? state.extra as Conversation
              : null,
        ),
      ),
      GoRoute(path: '/sellers', builder: (_, _) => const SellerSearchScreen()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
      GoRoute(
        path: '/seller/:id',
        builder: (_, state) =>
            SellerProfileScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(path: '/profile/info', builder: (_, _) => const MyInfoScreen()),
      GoRoute(path: '/profile/inbox', builder: (_, _) => const InboxScreen()),
      GoRoute(
        path: '/profile/interests',
        builder: (_, _) => const CarInterestsScreen(),
      ),
      GoRoute(
        path: '/profile/insights',
        builder: (_, _) => const MarketInsightsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/buy',
                builder: (_, _) => const BuyFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/sell',
                builder: (_, _) => const SellHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home/bid', builder: (_, _) => const BidScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/chat',
                builder: (_, _) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
