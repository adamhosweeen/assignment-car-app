/// Bid data contract — **placeholder, not implemented in v1**.
///
/// The Bid tab shows a "coming soon" screen. Nothing here is wired into
/// `providers.dart`. When bidding is scoped:
///
/// 1. Add the `bids` table (+ RLS: a bidder reads/writes their own bids, a
///    seller reads bids on their listings) to `0001_init.sql`.
/// 2. Define the freezed models in `model/bid/bid.dart`.
/// 3. Fill in this interface — expected surface, to be confirmed:
///    - `Stream<List<Bid>> watchBidsForListing(String listingId)` (seller view)
///    - `Stream<List<Bid>> watchMyBids()` (bidder view)
///    - `Future<Result<Bid>> placeBid(String listingId, int amountMyr)`
///    - `Future<Result<void>> withdrawBid(String bidId)`
///    - `Future<Result<void>> respondToBid(String bidId, {required bool accept})`
/// 4. Add `SupabaseBidsRepository` next to this file and a provider in
///    `providers.dart`; replace `BidScreen`'s placeholder.
library;

/// Intentionally empty until the feature is scoped (see the library doc).
abstract interface class BidsRepository {}
