/// Bid domain models — **placeholder, nothing defined yet**.
///
/// The Bid tab is a "coming soon" screen in v1 and there is no `bids` table
/// in `0001_init.sql`. When bidding is scoped, define here (as freezed
/// classes, mirroring the schema you add):
///
/// - `Bid` — id, listing_id, bidder_id, amount_myr (integer Ringgit),
///   status (pending / accepted / rejected / withdrawn), created_at
/// - optionally an auction window on the listing (starts_at / ends_at,
///   reserve_price_myr) if bids are time-boxed rather than open offers
///
/// Keep money as integer MYR and timestamps as UTC `DateTime` (CLAUDE.md §6).
library;
