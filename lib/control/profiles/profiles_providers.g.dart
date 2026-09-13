// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profiles_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One user's public profile (seller page, seller row on Listing Detail).
/// Null when the account no longer exists.

@ProviderFor(publicProfile)
final publicProfileProvider = PublicProfileFamily._();

/// One user's public profile (seller page, seller row on Listing Detail).
/// Null when the account no longer exists.

final class PublicProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublicProfile?>,
          PublicProfile?,
          FutureOr<PublicProfile?>
        >
    with $FutureModifier<PublicProfile?>, $FutureProvider<PublicProfile?> {
  /// One user's public profile (seller page, seller row on Listing Detail).
  /// Null when the account no longer exists.
  PublicProfileProvider._({
    required PublicProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicProfileHash();

  @override
  String toString() {
    return r'publicProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PublicProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PublicProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return publicProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicProfileHash() => r'f8751a20e02050020bcf54ea26ea273c630963e0';

/// One user's public profile (seller page, seller row on Listing Detail).
/// Null when the account no longer exists.

final class PublicProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PublicProfile?>, String> {
  PublicProfileFamily._()
    : super(
        retry: null,
        name: r'publicProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One user's public profile (seller page, seller row on Listing Detail).
  /// Null when the account no longer exists.

  PublicProfileProvider call(String id) =>
      PublicProfileProvider._(argument: id, from: this);

  @override
  String toString() => r'publicProfileProvider';
}

/// Seller-name search. Empty query → empty list, no request.

@ProviderFor(sellerSearch)
final sellerSearchProvider = SellerSearchFamily._();

/// Seller-name search. Empty query → empty list, no request.

final class SellerSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PublicProfile>>,
          List<PublicProfile>,
          FutureOr<List<PublicProfile>>
        >
    with
        $FutureModifier<List<PublicProfile>>,
        $FutureProvider<List<PublicProfile>> {
  /// Seller-name search. Empty query → empty list, no request.
  SellerSearchProvider._({
    required SellerSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sellerSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sellerSearchHash();

  @override
  String toString() {
    return r'sellerSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PublicProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PublicProfile>> create(Ref ref) {
    final argument = this.argument as String;
    return sellerSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SellerSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sellerSearchHash() => r'7792d5cc191274dcc407ecc32ba5752dfbd698a9';

/// Seller-name search. Empty query → empty list, no request.

final class SellerSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PublicProfile>>, String> {
  SellerSearchFamily._()
    : super(
        retry: null,
        name: r'sellerSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Seller-name search. Empty query → empty list, no request.

  SellerSearchProvider call(String query) =>
      SellerSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'sellerSearchProvider';
}
