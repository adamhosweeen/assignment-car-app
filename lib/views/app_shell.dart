import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/chat/chat_providers.dart';
import 'package:assignment/control/notifications/notifications_providers.dart';
import 'package:assignment/model/chat/conversation_thread.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

/// The signed-in shell: five tabs (Buy / Sell / Bid / Chat / Profile) over a
/// flat, iOS-style bottom bar. Each tab keeps its own navigation stack via
/// [StatefulNavigationShell]. The Chat tab shows a dot while any thread has
/// unread messages; the Profile tab shows one while the inbox does.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final unread = unreadCountOf(
      context.watch<AsyncSnapshot<List<AppNotification>>>(),
    );
    final chatUnread = unreadChatCountOf(
      context.watch<AsyncSnapshot<List<ConversationThread>>>(),
    );
    return Scaffold(
      body: shell,
      bottomNavigationBar: _BottomNav(
        shell: shell,
        profileBadge: unread > 0,
        chatBadge: chatUnread > 0,
      ),
    );
  }
}

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

/// Index of the Chat tab (unread-messages badge).
const int _chatIndex = 3;

/// Index of the Profile tab (the one that carries the inbox badge).
const int _profileIndex = 4;

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.shell,
    required this.profileBadge,
    required this.chatBadge,
  });

  final StatefulNavigationShell shell;
  final bool profileBadge;
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
                    selected: i == shell.currentIndex,
                    badge:
                        (profileBadge && i == _profileIndex) ||
                        (chatBadge && i == _chatIndex),
                    onTap: () => shell.goBranch(
                      i,
                      initialLocation: i == shell.currentIndex,
                    ),
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
