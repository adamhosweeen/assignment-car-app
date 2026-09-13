// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Listings recommended for the signed-in user, matched client-side against
/// their saved car interests and location — no extra backend query; it reuses
/// the already-streamed active listings.

@ProviderFor(recommendedListings)
final recommendedListingsProvider = RecommendedListingsProvider._();

/// Listings recommended for the signed-in user, matched client-side against
/// their saved car interests and location — no extra backend query; it reuses
/// the already-streamed active listings.

final class RecommendedListingsProvider
    extends $FunctionalProvider<List<Listing>, List<Listing>, List<Listing>>
    with $Provider<List<Listing>> {
  /// Listings recommended for the signed-in user, matched client-side against
  /// their saved car interests and location — no extra backend query; it reuses
  /// the already-streamed active listings.
  RecommendedListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendedListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendedListingsHash();

  @$internal
  @override
  $ProviderElement<List<Listing>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Listing> create(Ref ref) {
    return recommendedListings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Listing> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Listing>>(value),
    );
  }
}

String _$recommendedListingsHash() =>
    r'a3cbce099ea5542aaf8a71df0afc3f946b47d0c1';
