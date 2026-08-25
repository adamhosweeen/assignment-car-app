import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// The signed-in shell: the four tabs (Buy / Sell / Chat / Profile) over a
/// flat, iOS-style bottom bar. Each tab keeps its own navigation stack via
/// [StatefulNavigationShell].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: _BottomNav(shell: shell),
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
  _NavDef(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat'),
  _NavDef(Icons.person_outline, Icons.person, 'Profile'),
];

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.shell});

  final StatefulNavigationShell shell;

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
    required this.onTap,
  });

  final _NavDef def;
  final bool selected;
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
          Icon(
            selected ? def.activeIcon : def.icon,
            size: AppSpacing.iconNav,
            color: color,
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
