import 'package:assignment/model/notifications/app_notification.dart';

const int kMaxBannerBurst = 3;

List<AppNotification> newArrivals(
  List<AppNotification> current,
  Set<String> seen, {
  int max = kMaxBannerBurst,
}) {
  final fresh = [
    for (final n in current)
      if (!n.isRead && !seen.contains(n.id)) n,
  ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return fresh.length > max ? fresh.sublist(fresh.length - max) : fresh;
}
