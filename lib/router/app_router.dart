import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app/app_shell.dart';
import '../app/providers.dart';
import '../features/auth/presentation/login_otp_screen.dart';
import '../features/auth/presentation/login_phone_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/listings/presentation/buy_feed_screen.dart';
import '../features/listings/presentation/listing_detail_screen.dart';
import '../features/listings/presentation/sell/sell_flow_screen.dart';
import '../features/listings/presentation/sell_home_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

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
      final loggingIn = loc.startsWith('/login');
      if (!signedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/home/buy';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPhoneScreen()),
      GoRoute(
        path: '/login/otp',
        builder: (_, state) =>
            LoginOtpScreen(phoneE164: state.extra! as String),
      ),
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
