import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/bid/bid_screen.dart';
import 'package:assignment/views/buy/buy_feed_screen.dart';
import 'package:assignment/views/chat/chat_screen.dart';
import 'package:assignment/views/user/profile_screen.dart';
import 'package:assignment/views/sell/sell_home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final AppNavigator _navigator;
  late int _index;
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    _navigator = context.read<AppNavigator>();
    _index = _navigator.tab.value;
    _visited.add(_index);
    _navigator.tab.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _navigator.tab.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {
      _index = _navigator.tab.value;
      _visited.add(_index);
    });
  }

  void _select(int index) => _navigator.tab.value = index;

  @override
  Widget build(BuildContext context) {
    final chatUnread = unreadChatCountOf(
      context.watch<AsyncSnapshot<List<ConversationThread>>>(),
    );
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            _visited.contains(i) ? _screenAt(i) : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onSelect: _select,
        chatBadge: chatUnread > 0,
      ),
    );
  }
}

Widget _screenAt(int index) => switch (index) {
  homeTabBuy => const BuyFeedScreen(),
  homeTabSell => const SellHomeScreen(),
  homeTabBid => const BidScreen(),
  homeTabChat => const ChatScreen(),
  _ => const ProfileScreen(),
};

class _NavDef {
  const _NavDef(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const List<_NavDef> _tabs = [
  _NavDef(Icons.storefront_outlined, Icons.storefront, 'Buy'),
  _NavDef(Icons.sell_outlined, Icons.sell, 'Sell'),
  _NavDef(Icons.gavel_outlined, Icons.gavel, 'Bid'),
  _NavDef(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat'),
  _NavDef(Icons.person_outline, Icons.person, 'Profile'),
];

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.index,
    required this.onSelect,
    required this.chatBadge,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final bool chatBadge;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.separator,
            width: AppSpacing.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.navBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    def: _tabs[i],
                    selected: i == index,
                    badge: chatBadge && i == homeTabChat,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.def,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final _NavDef def;
  final bool selected;
  final bool badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.secondaryLabel;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                selected ? def.activeIcon : def.icon,
                size: AppSpacing.iconNav,
                color: color,
              ),
              if (badge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: AppSpacing.badgeDot,
                    height: AppSpacing.badgeDot,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.destructive,
                      border: Border.all(
                        color: AppColors.surface,
                        width: AppSpacing.hairline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            def.label,
            style: Theme.of(context).textTheme.navLabel.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
