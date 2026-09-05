import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/notifications/notification_alerts.dart';
import 'package:assignment/control/notifications/notifications_repository.dart';
import 'package:assignment/model/notifications/app_notification.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/widgets/notifications/notification_avatar.dart';

const Duration _slideDuration = Duration(milliseconds: 240);

const Duration _visibleDuration = Duration(seconds: 4);

const String _inboxRoute = '/profile/inbox';

class NotificationBannerHost extends StatefulWidget {
  const NotificationBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationBannerHost> createState() => _NotificationBannerHostState();
}

class _NotificationBannerHostState extends State<NotificationBannerHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final CurvedAnimation _curve;

  final List<AppNotification> _queue = [];
  final Set<String> _seen = {};
  String? _userId;
  bool _seeded = false;
  bool _scheduled = false;
  AppNotification? _current;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: _slideDuration);
    _curve = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _sync(String? userId, List<AppNotification>? items) {
    if (userId != _userId) {
      _userId = userId;
      _seen.clear();
      _queue.clear();
      _seeded = false;
      if (_current != null) _scheduleFrame(_dismiss);
    }
    if (items == null) return;
    if (!_seeded) {
      _seen.addAll(items.map((n) => n.id));
      _seeded = true;
      return;
    }
    final fresh = newArrivals(items, _seen);
    _seen.addAll(items.map((n) => n.id));
    if (fresh.isEmpty) return;
    _queue.addAll(fresh);
    if (_current == null) _scheduleFrame(_showNext);
  }

  void _scheduleFrame(VoidCallback action) {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) action();
    });
  }

  bool get _onInbox {
    final matches = context
        .read<GoRouter>()
        .routerDelegate
        .currentConfiguration
        .matches;
    return matches.isNotEmpty && matches.last.matchedLocation == _inboxRoute;
  }

  void _showNext() {
    if (_queue.isEmpty || _current != null) return;
    if (_onInbox) {
      _queue.clear();
      return;
    }
    setState(() => _current = _queue.removeAt(0));
    _anim.forward(from: 0);
    _timer?.cancel();
    _timer = Timer(_visibleDuration, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (_current == null) return;
    await _anim.reverse();
    if (!mounted) return;
    setState(() => _current = null);
    if (_queue.isNotEmpty) _showNext();
  }

  void _clearAfterSwipe() {
    _timer?.cancel();
    setState(() => _current = null);
    _anim.value = 0;
    if (_queue.isNotEmpty) _scheduleFrame(_showNext);
  }

  void _open(AppNotification n) {
    _timer?.cancel();
    final router = context.read<GoRouter>();
    final notifications = context.read<NotificationsRepository>();
    if (!n.isRead) notifications.markRead(n.id);
    final route = n.route;
    if (route != null) router.push(route);
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AsyncSnapshot<List<AppNotification>>>();
    final userId = context.watch<Profile?>()?.id;
    _sync(userId, snapshot.data);

    final current = _current;
    return Stack(
      children: [
        widget.child,
        if (current != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Material(
              type: MaterialType.transparency,
              child: _Banner(
                notification: current,
                animation: _curve,
                onTap: () => _open(current),
                onSwipedAway: _clearAfterSwipe,
              ),
            ),
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.notification,
    required this.animation,
    required this.onTap,
    required this.onSwipedAway,
  });

  final AppNotification notification;
  final Animation<double> animation;
  final VoidCallback onTap;
  final VoidCallback onSwipedAway;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final n = notification;
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Dismissible(
              key: ValueKey(n.id),
              direction: DismissDirection.up,
              onDismissed: (_) => onSwipedAway(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSheet),
                    border: Border.all(
                      color: AppColors.separator,
                      width: AppSpacing.hairline,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NotificationAvatar(kind: n.kind),
                        const SizedBox(width: AppSpacing.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.headline,
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              Text(
                                n.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text.footnote.copyWith(
                                  color: AppColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
