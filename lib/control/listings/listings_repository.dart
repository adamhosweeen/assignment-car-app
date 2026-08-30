import 'package:assignment/utils/result.dart';
import 'package:assignment/model/listing/listing.dart';
import 'package:assignment/model/listing/listing_draft.dart';

/// The listings data contract. The UI depends only on this; the fake in-memory
/// implementation and (later) the Supabase implementation are interchangeable.
abstract interface class ListingsRepository {
  /// All `active` listings, newest first. Re-emits on any change (realtime).
  Stream<List<Listing>> watchActive();

  /// A seller's own listings (any status except deleted), newest first.
  Stream<List<Listing>> watchBySeller(String sellerId);

  /// Another seller's `active` listings, newest first (public seller page).
  /// Re-emits on any change (realtime).
  Stream<List<Listing>> watchActiveBySeller(String sellerId);

  /// `active` listings whose make, model, or variant contains [query]
  /// (case-insensitive), newest first, capped at 50. Empty query → empty.
  Future<Result<List<Listing>>> searchActive(String query);

  /// A single listing by id, or an [Err] if it is gone.
  Future<Result<Listing>> getById(String id);

  /// Publish a completed draft as an `active` listing owned by [sellerId].
  Future<Result<Listing>> publish(ListingDraft draft, String sellerId);

  /// Mark a listing `sold`.
  Future<Result<void>> markSold(String id);

  /// Soft-delete a listing (`status = deleted`); never hard-delete.
  Future<Result<void>> softDelete(String id);
}
