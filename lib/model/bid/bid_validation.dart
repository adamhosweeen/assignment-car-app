library;

import 'package:assignment/model/listing/listing_draft.dart' show kMaxPriceMyr;
import 'package:assignment/utils/formatters.dart';

const double kMinBidFractionOfAsking = 0.10;

const double kMaxBidMultipleOfAsking = 3;

const int kMinBidMyr = 100;

int? parseBidAmount(String raw) {
  final digits = raw.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return null;
  final value = int.tryParse(digits);
  if (value == null || value <= 0) return null;
  return value;
}

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

String? validateBidPhone(String raw) {
  if (raw.trim().isEmpty) return 'Enter a mobile number the seller can reach.';
  if (nationalToE164(raw) == null) {
    return 'That doesn’t look like a Malaysian mobile number, e.g. 0111234567.';
  }
  return null;
}

String? bidAmountHint(int amountMyr, {required int askingPriceMyr}) {
  if (amountMyr == askingPriceMyr) return 'Same as the asking price.';
  if (amountMyr > askingPriceMyr) {
    return '${formatPrice(amountMyr - askingPriceMyr)} above the asking price.';
  }
  return '${formatPrice(askingPriceMyr - amountMyr)} below the asking price.';
}
