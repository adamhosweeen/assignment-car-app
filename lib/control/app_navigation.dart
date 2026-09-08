import 'package:flutter/widgets.dart';

const List<String> homeTabRoutes = [
  '/home/buy',
  '/home/sell',
  '/home/bid',
  '/home/chat',
  '/home/profile',
];

const int homeTabBuy = 0;
const int homeTabSell = 1;
const int homeTabBid = 2;
const int homeTabChat = 3;
const int homeTabProfile = 4;

int? homeTabFor(String route) {
  final index = homeTabRoutes.indexOf(route);
  return index == -1 ? null : index;
}

class RouteTracker extends NavigatorObserver {
  String? _current;

  String? get current => _current;

  void _track(Route<dynamic>? route) => _current = route?.settings.name;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _track(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _track(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _track(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _track(newRoute);
}

class AppNavigator {
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  final ValueNotifier<int> tab = ValueNotifier<int>(homeTabBuy);
  final RouteTracker tracker = RouteTracker();

  NavigatorState? get _navigator => key.currentState;

  String? get currentRoute => tracker.current;

  Future<void> open(String route) async {
    final tabIndex = homeTabFor(route);
    if (tabIndex != null) {
      goHome(tabIndex);
      return;
    }
    await _navigator?.pushNamed(route);
  }

  void goHome(int index) {
    popToRoot();
    tab.value = index;
  }

  void popToRoot() => _navigator?.popUntil((route) => route.isFirst);

  void dispose() => tab.dispose();
}
