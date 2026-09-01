/// Input rules for the place-a-bid form, as pure functions so they can be
/// unit-tested without a widget tree and reused by the repository as a last
/// line of defence before a write.
///
/// Every function returns `null` when the input is acceptable, or a
/// plain-English sentence with a next action — the same contract as
/// [Err.message] (CLAUDE.md §6), so a caller can surface it directly.
library;

import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/utils/formatters.dart';

/// A bid this far below the asking price is almost always a typo (a digit
/// dropped), not a real offer. 10% of asking.
const double kMinBidFractionOfAsking = 0.10;

/// A bid this far above the asking price is likewise a typo (a digit added).
/// 3× asking — generous enough for a genuine bidding war on a rare car.
const double kMaxBidMultipleOfAsking = 3;

/// Lowest bid the form will accept outright, regardless of asking price, so a
/// cheap listing doesn't allow a RM 1 bid.
const int kMinBidMyr = 100;

/// Parse what the user typed into whole Ringgit. Tolerates the separators and
/// prefix people paste in ("RM 45,000", "45 000"); returns null if what's left
/// isn't a positive whole number.
int? parseBidAmount(String raw) {
  final digits = raw.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return null;
  final value = int.tryParse(digits);
  if (value == null || value <= 0) return null;
  return value;
}

/// Validate a bid amount against the car's asking price.
///
/// [askingPriceMyr] is the listing's own `price_myr`. Bidding above asking is
/// allowed (that's what a bidding war is) — only an implausible multiple is
/// rejected.
String? validateBidAmount(String raw, {required int askingPriceMyr}) {
  if (raw.trim().isEmpty) return 'Enter how much you want to bid.';

  final value = parseBidAmount(raw);
  if (value == null) return 'Enter a valid amount in Ringgit, e.g. 45000.';

  if (value > kMaxPriceMyr) {
    return 'That’s too high. Enter an amount under ${formatPrice(kMaxPriceMyr)}.';
  }
  if (value < kMinBidMyr) {
    return 'Bids start at ${formatPrice(kMinBidMyr)}.';
  }

  // Guard rails relative to the asking price catch a mistyped digit, which is
  // the realistic error here — not a deliberate lowball.
  final floor = (askingPriceMyr * kMinBidFractionOfAsking).round();
  if (value < floor) {
    return 'That’s far below the ${formatPrice(askingPriceMyr)} asking price. '
        'Bid at least ${formatPrice(floor)}.';
  }
  final ceiling = (askingPriceMyr * kMaxBidMultipleOfAsking).round();
  if (value > ceiling) {
    return 'That’s far above the ${formatPrice(askingPriceMyr)} asking price. '
        'Check the amount before bidding.';
  }
  return null;
}

/// Validate the contact number on the bid form. Required — the whole point of
/// the field is that an accepted bid gives the seller somebody to call.
/// Accepts the same shapes as [nationalToE164] (Malaysian mobile, optional
/// leading zero).
String? validateBidPhone(String raw) {
  if (raw.trim().isEmpty) return 'Enter a mobile number the seller can reach.';
  if (nationalToE164(raw) == null) {
    return 'That doesn’t look like a Malaysian mobile number, e.g. 0111234567.';
  }
  return null;
}

/// A non-blocking heads-up shown under a valid amount, or null when there is
/// nothing worth saying. Distinct from [validateBidAmount]: this never stops
/// the bid, it just tells the bidder how their number reads against asking.
String? bidAmountHint(int amountMyr, {required int askingPriceMyr}) {
  if (amountMyr == askingPriceMyr) return 'Same as the asking price.';
  if (amountMyr > askingPriceMyr) {
    return '${formatPrice(amountMyr - askingPriceMyr)} above the asking price.';
  }
  return '${formatPrice(askingPriceMyr - amountMyr)} below the asking price.';
}
