// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bids_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bids the signed-in user has placed, newest first, live over realtime.
/// Empty stream when signed out; re-created when the user changes.

@ProviderFor(myBids)
final myBidsProvider = MyBidsProvider._();

/// Bids the signed-in user has placed, newest first, live over realtime.
/// Empty stream when signed out; re-created when the user changes.

final class MyBidsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BidWithListing>>,
          List<BidWithListing>,
          Stream<List<BidWithListing>>
        >
    with
        $FutureModifier<List<BidWithListing>>,
        $StreamProvider<List<BidWithListing>> {
  /// Bids the signed-in user has placed, newest first, live over realtime.
  /// Empty stream when signed out; re-created when the user changes.
  MyBidsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBidsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBidsHash();

  @$internal
  @override
  $StreamProviderElement<List<BidWithListing>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BidWithListing>> create(Ref ref) {
    return myBids(ref);
  }
}

String _$myBidsHash() => r'4abea0f8ee99051cc47c3cbf3efbabba6f754440';

/// Bids other people have placed on the signed-in user's cars, newest first.

@ProviderFor(bidsReceived)
final bidsReceivedProvider = BidsReceivedProvider._();

/// Bids other people have placed on the signed-in user's cars, newest first.

final class BidsReceivedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BidWithListing>>,
          List<BidWithListing>,
          Stream<List<BidWithListing>>
        >
    with
        $FutureModifier<List<BidWithListing>>,
        $StreamProvider<List<BidWithListing>> {
  /// Bids other people have placed on the signed-in user's cars, newest first.
  BidsReceivedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bidsReceivedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bidsReceivedHash();

  @$internal
  @override
  $StreamProviderElement<List<BidWithListing>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BidWithListing>> create(Ref ref) {
    return bidsReceived(ref);
  }
}

String _$bidsReceivedHash() => r'cf6ab380f8c94db90db4ca04975cfd21fe9ed183';

/// Every bid on one listing (seller's per-car view on Listing Detail).

@ProviderFor(bidsForListing)
final bidsForListingProvider = BidsForListingFamily._();

/// Every bid on one listing (seller's per-car view on Listing Detail).

final class BidsForListingProvider
    extends
        $FunctionalProvider<AsyncValue<List<Bid>>, List<Bid>, Stream<List<Bid>>>
    with $FutureModifier<List<Bid>>, $StreamProvider<List<Bid>> {
  /// Every bid on one listing (seller's per-car view on Listing Detail).
  BidsForListingProvider._({
    required BidsForListingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bidsForListingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bidsForListingHash();

  @override
  String toString() {
    return r'bidsForListingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Bid>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Bid>> create(Ref ref) {
    final argument = this.argument as String;
    return bidsForListing(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BidsForListingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bidsForListingHash() => r'51fd60c6ff3785f9c079ef774d3224092115c0f7';

/// Every bid on one listing (seller's per-car view on Listing Detail).

final class BidsForListingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Bid>>, String> {
  BidsForListingFamily._()
    : super(
        retry: null,
        name: r'bidsForListingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every bid on one listing (seller's per-car view on Listing Detail).

  BidsForListingProvider call(String listingId) =>
      BidsForListingProvider._(argument: listingId, from: this);

  @override
  String toString() => r'bidsForListingProvider';
}

/// The signed-in user's live bid on [listingId], or null when they have none.
/// The bid form reads this to switch between "Place your bid" and "Update
/// your bid", and Listing Detail to label its button.

@ProviderFor(myPendingBid)
final myPendingBidProvider = MyPendingBidFamily._();

/// The signed-in user's live bid on [listingId], or null when they have none.
/// The bid form reads this to switch between "Place your bid" and "Update
/// your bid", and Listing Detail to label its button.

final class MyPendingBidProvider
    extends $FunctionalProvider<AsyncValue<Bid?>, Bid?, FutureOr<Bid?>>
    with $FutureModifier<Bid?>, $FutureProvider<Bid?> {
  /// The signed-in user's live bid on [listingId], or null when they have none.
  /// The bid form reads this to switch between "Place your bid" and "Update
  /// your bid", and Listing Detail to label its button.
  MyPendingBidProvider._({
    required MyPendingBidFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myPendingBidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myPendingBidHash();

  @override
  String toString() {
    return r'myPendingBidProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Bid?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Bid?> create(Ref ref) {
    final argument = this.argument as String;
    return myPendingBid(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyPendingBidProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myPendingBidHash() => r'c4dc4234ff25f37a0e57c7c0b9dd87fbc380fe7a';

/// The signed-in user's live bid on [listingId], or null when they have none.
/// The bid form reads this to switch between "Place your bid" and "Update
/// your bid", and Listing Detail to label its button.

final class MyPendingBidFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Bid?>, String> {
  MyPendingBidFamily._()
    : super(
        retry: null,
        name: r'myPendingBidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The signed-in user's live bid on [listingId], or null when they have none.
  /// The bid form reads this to switch between "Place your bid" and "Update
  /// your bid", and Listing Detail to label its button.

  MyPendingBidProvider call(String listingId) =>
      MyPendingBidProvider._(argument: listingId, from: this);

  @override
  String toString() => r'myPendingBidProvider';
}

/// How many bids on the signed-in user's cars are still waiting on them —
/// drives the count on the Bid tab's "On my cars" segment.

@ProviderFor(pendingBidsReceivedCount)
final pendingBidsReceivedCountProvider = PendingBidsReceivedCountProvider._();

/// How many bids on the signed-in user's cars are still waiting on them —
/// drives the count on the Bid tab's "On my cars" segment.

final class PendingBidsReceivedCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many bids on the signed-in user's cars are still waiting on them —
  /// drives the count on the Bid tab's "On my cars" segment.
  PendingBidsReceivedCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingBidsReceivedCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingBidsReceivedCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return pendingBidsReceivedCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pendingBidsReceivedCountHash() =>
    r'1149acaf94aeefc640057336177860b4ca7bd323';
