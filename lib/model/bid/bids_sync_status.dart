/// Whether the bidding module is currently reading live data, and when it last
/// managed to.
///
/// There is no connectivity plugin behind this: [online] is inferred from
/// whether the most recent fetch succeeded, which is the condition that
/// actually matters. A reachable network with an unreachable Supabase is just
/// as offline from the user's point of view.
class BidsSyncStatus {
  const BidsSyncStatus({required this.online, this.lastSyncedAt});

  /// Before the first fetch resolves, assume we are online: showing an offline
  /// banner during the opening round trip would be wrong far more often than
  /// it was right.
  const BidsSyncStatus.unknown() : online = true, lastSyncedAt = null;

  final bool online;

  /// When live data last arrived. Null means never — this session is running
  /// entirely on whatever SQLite had.
  final DateTime? lastSyncedAt;

  /// Cached rows are worth labelling only once we know they are not live.
  bool get isStale => !online;

  BidsSyncStatus copyWith({bool? online, DateTime? lastSyncedAt}) =>
      BidsSyncStatus(
        online: online ?? this.online,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidsSyncStatus &&
          online == other.online &&
          lastSyncedAt == other.lastSyncedAt;

  @override
  int get hashCode => Object.hash(online, lastSyncedAt);

  @override
  String toString() =>
      'BidsSyncStatus(online: $online, lastSyncedAt: $lastSyncedAt)';
}
