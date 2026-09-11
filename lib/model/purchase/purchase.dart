import 'package:assignment/utils/json.dart';

const Object _unset = Object();

enum PurchaseMethod { buyNow, chatOffer, bid }

const Map<PurchaseMethod, String> purchaseMethodValues = {
  PurchaseMethod.buyNow: 'buy_now',
  PurchaseMethod.chatOffer: 'chat_offer',
  PurchaseMethod.bid: 'bid',
};

extension PurchaseMethodValue on PurchaseMethod {
  String get value => purchaseMethodValues[this]!;

  String get label => switch (this) {
    PurchaseMethod.buyNow => 'Bought now',
    PurchaseMethod.chatOffer => 'Agreed in chat',
    PurchaseMethod.bid => 'Winning bid',
  };
}

PurchaseMethod purchaseMethodFromValue(Object? raw) {
  for (final entry in purchaseMethodValues.entries) {
    if (entry.value == raw) return entry.key;
  }
  throw ArgumentError.value(raw, 'method', 'Unknown purchase method');
}

class Purchase {
  const Purchase({
    required this.id,
    required this.buyerId,
    this.sellerId,
    this.listingId,
    required this.priceMyr,
    required this.method,
    required this.make,
    required this.model,
    required this.year,
    required this.createdAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
    id: json['id'] as String,
    buyerId: json['buyer_id'] as String,
    sellerId: json['seller_id'] as String?,
    listingId: json['listing_id'] as String?,
    priceMyr: asInt(json['price_myr']),
    method: purchaseMethodFromValue(json['method']),
    make: json['make'] as String,
    model: json['model'] as String,
    year: asInt(json['year']),
    createdAt: asDate(json['created_at']),
  );

  final String id;
  final String buyerId;
  final String? sellerId;
  final String? listingId;
  final int priceMyr;
  final PurchaseMethod method;
  final String make;
  final String model;
  final int year;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'buyer_id': buyerId,
    'seller_id': sellerId,
    'listing_id': listingId,
    'price_myr': priceMyr,
    'method': method.value,
    'make': make,
    'model': model,
    'year': year,
    'created_at': createdAt.toIso8601String(),
  };

  String get title => '$year $make $model';

  Purchase copyWith({
    String? id,
    String? buyerId,
    Object? sellerId = _unset,
    Object? listingId = _unset,
    int? priceMyr,
    PurchaseMethod? method,
    String? make,
    String? model,
    int? year,
    DateTime? createdAt,
  }) => Purchase(
    id: id ?? this.id,
    buyerId: buyerId ?? this.buyerId,
    sellerId: identical(sellerId, _unset) ? this.sellerId : sellerId as String?,
    listingId: identical(listingId, _unset)
        ? this.listingId
        : listingId as String?,
    priceMyr: priceMyr ?? this.priceMyr,
    method: method ?? this.method,
    make: make ?? this.make,
    model: model ?? this.model,
    year: year ?? this.year,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Purchase &&
          id == other.id &&
          buyerId == other.buyerId &&
          sellerId == other.sellerId &&
          listingId == other.listingId &&
          priceMyr == other.priceMyr &&
          method == other.method &&
          make == other.make &&
          model == other.model &&
          year == other.year &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    buyerId,
    sellerId,
    listingId,
    priceMyr,
    method,
    make,
    model,
    year,
    createdAt,
  );

  @override
  String toString() =>
      'Purchase(id: $id, title: $title, priceMyr: $priceMyr, '
      'method: $method, createdAt: $createdAt)';
}
