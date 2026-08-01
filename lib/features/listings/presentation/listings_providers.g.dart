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

String _$myListingsHash() => r'4b584b4644a295e5b5bdd14ddfce6fee989f24e3';

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
