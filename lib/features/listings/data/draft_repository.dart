import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../domain/listing_draft.dart';

/// Persists the single in-progress sell draft to Hive as a JSON string, so a
/// crash or force-quit never loses input (V1_SPEC §4.5).
class DraftRepository {
  DraftRepository(this._box);

  final Box<dynamic> _box;
  static const String _key = 'current';

  bool get hasDraft => _box.containsKey(_key);

  ListingDraft? load() {
    final raw = _box.get(_key);
    if (raw is! String) return null;
    try {
      return ListingDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // Corrupt/legacy draft — treat as none.
    }
  }

  Future<void> save(ListingDraft draft) =>
      _box.put(_key, jsonEncode(draft.toJson()));

  Future<void> clear() => _box.delete(_key);
}
