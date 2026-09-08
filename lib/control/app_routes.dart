import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/model/chat/conversation.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/auth/login_screen.dart';
import 'package:assignment/views/auth/register_flow_screen.dart';
import 'package:assignment/views/auth/welcome_screen.dart';
import 'package:assignment/views/bid/auction_screen.dart';
import 'package:assignment/views/bid/start_auction_screen.dart';
import 'package:assignment/views/buy/car_search_screen.dart';
import 'package:assignment/views/buy/listing_detail_screen.dart';
import 'package:assignment/views/buy/purchase_screen.dart';
import 'package:assignment/views/chat/chat_thread_screen.dart';
import 'package:assignment/views/profile/admin_screen.dart';
import 'package:assignment/views/profile/car_interests_screen.dart';
import 'package:assignment/views/profile/edit_profile_screen.dart';
import 'package:assignment/views/profile/inbox_screen.dart';
import 'package:assignment/views/profile/market_insights_screen.dart';
import 'package:assignment/views/profile/my_info_screen.dart';
import 'package:assignment/views/profile/purchases_screen.dart';
import 'package:assignment/views/profile/seller_profile_screen.dart';
import 'package:assignment/views/profile/seller_search_screen.dart';
import 'package:assignment/views/sell/sell_flow_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) => MaterialPageRoute<void>(
  settings: settings,
  builder: (_) => _pageFor(settings) ?? const _UnknownScreen(),
);

Widget? _pageFor(RouteSettings settings) {
  final segments = Uri.parse(settings.name ?? '').pathSegments;
  final args = settings.arguments;

  return switch (segments) {
    ['welcome'] => const WelcomeScreen(),
    ['login'] => const LoginScreen(),
    ['register'] => ChangeNotifierProvider(
      create: (_) => RegistrationController(),
      child: const RegisterFlowScreen(),
    ),
    ['search'] => const CarSearchScreen(),
    ['sellers'] => const SellerSearchScreen(),
    ['admin'] => const AdminScreen(),
    ['sell', 'new'] => SellFlowScreen(editing: args == true),
    ['auction', 'new'] => const StartAuctionScreen(),
    ['auction', final id] => AuctionScreen(id: id),
    ['listing', final id] => ListingDetailScreen(id: id),
    ['listing', final id, 'buy'] => _purchaseScreen(id, args),
    ['chat', final id] => ChatThreadScreen(
      conversationId: id,
      seed: args is Conversation ? args : null,
    ),
    ['seller', final id] => SellerProfileScreen(id: id),
    ['profile', 'edit'] => const EditProfileScreen(),
    ['profile', 'info'] => const MyInfoScreen(),
    ['profile', 'inbox'] => const InboxScreen(),
    ['profile', 'purchases'] => const PurchasesScreen(),
    ['profile', 'interests'] => const CarInterestsScreen(),
    ['profile', 'insights'] => const MarketInsightsScreen(),
    _ => null,
  };
}

Widget _purchaseScreen(String id, Object? args) {
  final offer = args is ({String messageId, int amountMyr}) ? args : null;
  return PurchaseScreen(
    id: id,
    offerMessageId: offer?.messageId,
    offerAmountMyr: offer?.amountMyr,
  );
}

class _UnknownScreen extends StatelessWidget {
  const _UnknownScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Text(
            'This page is no longer available.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.subhead.copyWith(color: AppColors.secondaryLabel),
          ),
        ),
      ),
    );
  }
}
