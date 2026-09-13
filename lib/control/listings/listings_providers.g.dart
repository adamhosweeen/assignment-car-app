// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All active listings, newest first (Buy feed). Backed by the realtime stream.

@ProviderFor(activeListings)
final activeListingsProvider = ActiveListingsProvider._();

/// All active listings, newest first (Buy feed). Backed by the realtime stream.

final class ActiveListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Listing>>,
          List<Listing>,
          Stream<List<Listing>>
        >
    with $FutureModifier<List<Listing>>, $StreamProvider<List<Listing>> {
  /// All active listings, newest first (Buy feed). Backed by the realtime stream.
  ActiveListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeListingsHash();

  @$internal
  @override
  $StreamProviderElement<List<Listing>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Listing>> create(Ref ref) {
    return activeListings(ref);
  }
}

String _$activeListingsHash() => r'8c3e7649e24c64abf0ecaec33b0310ee4df82151';

/// The signed-in user's own listings (My Listings).

@ProviderFor(myListings)
final myListingsProvider = MyListingsProvider._();

/// The signed-in user's own listings (My Listings).

final class MyListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Listing>>,
          List<Listing>,
          Stream<List<Listing>>
        >
    with $FutureModifier<List<Listing>>, $StreamProvider<List<Listing>> {
  /// The signed-in user's own listings (My Listings).
  MyListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myListingsHash();

  @$internal
  @override
  $StreamProviderElement<List<Listing>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Listing>> create(Ref ref) {
    return myListings(ref);
  }
}

String _$myListingsHash() => r'5b2648542e02e0b53d0a1278716f6d76f6e55138';

/// Another seller's active listings (public seller page). Realtime-backed.

@ProviderFor(sellerListings)
final sellerListingsProvider = SellerListingsFamily._();

/// Another seller's active listings (public seller page). Realtime-backed.

final class SellerListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Listing>>,
          List<Listing>,
          Stream<List<Listing>>
        >
    with $FutureModifier<List<Listing>>, $StreamProvider<List<Listing>> {
  /// Another seller's active listings (public seller page). Realtime-backed.
  SellerListingsProvider._({
    required SellerListingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sellerListingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sellerListingsHash();

  @override
  String toString() {
    return r'sellerListingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Listing>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Listing>> create(Ref ref) {
    final argument = this.argument as String;
    return sellerListings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SellerListingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sellerListingsHash() => r'0629bf98952a0da615715921bf47a95700b43152';

/// Another seller's active listings (public seller page). Realtime-backed.

final class SellerListingsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Listing>>, String> {
  SellerListingsFamily._()
    : super(
        retry: null,
        name: r'sellerListingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Another seller's active listings (public seller page). Realtime-backed.

  SellerListingsProvider call(String sellerId) =>
      SellerListingsProvider._(argument: sellerId, from: this);

  @override
  String toString() => r'sellerListingsProvider';
}

/// Car search on the Buy tab. Empty query → empty list, no request.

@ProviderFor(carSearch)
final carSearchProvider = CarSearchFamily._();

/// Car search on the Buy tab. Empty query → empty list, no request.

final class CarSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Listing>>,
          List<Listing>,
          FutureOr<List<Listing>>
        >
    with $FutureModifier<List<Listing>>, $FutureProvider<List<Listing>> {
  /// Car search on the Buy tab. Empty query → empty list, no request.
  CarSearchProvider._({
    required CarSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'carSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$carSearchHash();

  @override
  String toString() {
    return r'carSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Listing>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Listing>> create(Ref ref) {
    final argument = this.argument as String;
    return carSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CarSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$carSearchHash() => r'ad5f4c17ac5ef823efe90e76e9e17271d8b2f15b';

/// Car search on the Buy tab. Empty query → empty list, no request.

final class CarSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Listing>>, String> {
  CarSearchFamily._()
    : super(
        retry: null,
        name: r'carSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Car search on the Buy tab. Empty query → empty list, no request.

  CarSearchProvider call(String query) =>
      CarSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'carSearchProvider';
}

/// A single listing by id (Listing detail).

@ProviderFor(listingById)
final listingByIdProvider = ListingByIdFamily._();

/// A single listing by id (Listing detail).

final class ListingByIdProvider
    extends $FunctionalProvider<AsyncValue<Listing>, Listing, FutureOr<Listing>>
    with $FutureModifier<Listing>, $FutureProvider<Listing> {
  /// A single listing by id (Listing detail).
  ListingByIdProvider._({
    required ListingByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingByIdHash();

  @override
  String toString() {
    return r'listingByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Listing> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Listing> create(Ref ref) {
    final argument = this.argument as String;
    return listingById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingByIdHash() => r'b5351a27a012c6967f8f64f8bf0271e958c3aa2a';

/// A single listing by id (Listing detail).

final class ListingByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Listing>, String> {
  ListingByIdFamily._()
    : super(
        retry: null,
        name: r'listingByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single listing by id (Listing detail).

  ListingByIdProvider call(String id) =>
      ListingByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'listingByIdProvider';
}

/// Resolve a Supabase storage bucket path to a temporary signed URL (1 hour).
/// Returns null when Supabase isn't configured (fake backend uses local files).

@ProviderFor(signedImageUrl)
final signedImageUrlProvider = SignedImageUrlFamily._();

/// Resolve a Supabase storage bucket path to a temporary signed URL (1 hour).
/// Returns null when Supabase isn't configured (fake backend uses local files).

final class SignedImageUrlProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Resolve a Supabase storage bucket path to a temporary signed URL (1 hour).
  /// Returns null when Supabase isn't configured (fake backend uses local files).
  SignedImageUrlProvider._({
    required SignedImageUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'signedImageUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$signedImageUrlHash();

  @override
  String toString() {
    return r'signedImageUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return signedImageUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SignedImageUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$signedImageUrlHash() => r'791d87f4d48489e761ba0c6d36eefb63cb66570f';

/// Resolve a Supabase storage bucket path to a temporary signed URL (1 hour).
/// Returns null when Supabase isn't configured (fake backend uses local files).

final class SignedImageUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  SignedImageUrlFamily._()
    : super(
        retry: null,
        name: r'signedImageUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolve a Supabase storage bucket path to a temporary signed URL (1 hour).
  /// Returns null when Supabase isn't configured (fake backend uses local files).

  SignedImageUrlProvider call(String path) =>
      SignedImageUrlProvider._(argument: path, from: this);

  @override
  String toString() => r'signedImageUrlProvider';
}
