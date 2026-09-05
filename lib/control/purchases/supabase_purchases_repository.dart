import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:assignment/control/purchases/purchases_repository.dart';
import 'package:assignment/control/services/error_mapper.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/purchase/purchase.dart';
import 'package:assignment/model/purchase/purchase_with_listing.dart';
import 'package:assignment/utils/result.dart';

class SupabasePurchasesRepository implements PurchasesRepository {
  SupabasePurchasesRepository(this._client);

  final SupabaseClient _client;
  static const String _table = 'purchases';
  static const String _select = '*, listings(*, listing_media(*))';
  static const Duration _fetchTimeout = Duration(seconds: 8);

  @override
  Future<Result<List<PurchaseWithListing>>> listMine() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Err('You need to be signed in.');
    try {
      final rows = await _client
          .from(_table)
          .select(_select)
          .eq('buyer_id', userId)
          .order('created_at', ascending: false)
          .timeout(_fetchTimeout);
      return Ok(rows.map(_fromRow).toList());
    } catch (e) {
      return Err(mapError(e));
    }
  }

  PurchaseWithListing _fromRow(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    final listingRow = map.remove('listings');
    return PurchaseWithListing(
      purchase: Purchase.fromJson(map),
      listing: listingRow == null
          ? null
          : _listingFrom(listingRow as Map<String, dynamic>),
    );
  }

  Listing _listingFrom(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['media'] = (map.remove('listing_media') as List?) ?? const [];
    return Listing.fromJson(map);
  }
}
