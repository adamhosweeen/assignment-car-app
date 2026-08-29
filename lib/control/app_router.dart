import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:assignment/views/app_shell.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/views/auth/forgot_password_screen.dart';
import 'package:assignment/views/auth/login_screen.dart';
import 'package:assignment/views/auth/register_flow_screen.dart';
import 'package:assignment/views/auth/splash_screen.dart';
import 'package:assignment/views/chat/chat_screen.dart';
import 'package:assignment/views/buy/buy_feed_screen.dart';
import 'package:assignment/views/buy/listing_detail_screen.dart';
import 'package:assignment/views/sell/sell_flow_screen.dart';
import 'package:assignment/views/sell/sell_home_screen.dart';
import 'package:assignment/views/profile/edit_profile_screen.dart';
import 'package:assignment/views/profile/profile_screen.dart';

part 'app_router.g.dart';

/// The app router. Splash decides the first destination; the redirect guard
/// keeps signed-out users in the login flow and signed-in users out of it.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);

  // Re-run redirects whenever auth state flips.
  final refresh = ValueNotifier<int>(0);
  final sub = auth.authState().listen((_) => refresh.value++);
  ref.onDispose(() {
    sub.cancel();
    refresh.dispose();
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = auth.currentUser != null;
      final loc = state.matchedLocation;
      if (loc == '/splash') return null; // splash routes itself
      final inAuthFlow =
          loc.startsWith('/login') || loc.startsWith('/register');
      if (!signedIn) return inAuthFlow ? null : '/login';
      if (inAuthFlow) return '/home/buy';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/login/forgot',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/register', builder: (_, _) => const RegisterFlowScreen()),
      GoRoute(path: '/sell/new', builder: (_, _) => const SellFlowScreen()),
      GoRoute(
        path: '/listing/:id',
        builder: (_, state) =>
            ListingDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const EditProfileScreen(),
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
