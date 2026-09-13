class BidsSyncStatus {
  const BidsSyncStatus({required this.online, this.lastSyncedAt});

  const BidsSyncStatus.unknown() : online = true, lastSyncedAt = null;

  final bool online;

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
