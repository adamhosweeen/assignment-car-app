// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The published car-popularity snapshot, or null when none exists yet.
/// Fetch failures surface as the provider's error state (plain-English
/// message from the repository) so the screen can offer a retry.

@ProviderFor(carPopularity)
final carPopularityProvider = CarPopularityProvider._();

/// The published car-popularity snapshot, or null when none exists yet.
/// Fetch failures surface as the provider's error state (plain-English
/// message from the repository) so the screen can offer a retry.

final class CarPopularityProvider
    extends
        $FunctionalProvider<
          AsyncValue<CarPopularity?>,
          CarPopularity?,
          FutureOr<CarPopularity?>
        >
    with $FutureModifier<CarPopularity?>, $FutureProvider<CarPopularity?> {
  /// The published car-popularity snapshot, or null when none exists yet.
  /// Fetch failures surface as the provider's error state (plain-English
  /// message from the repository) so the screen can offer a retry.
  CarPopularityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carPopularityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carPopularityHash();

  @$internal
  @override
  $FutureProviderElement<CarPopularity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CarPopularity?> create(Ref ref) {
    return carPopularity(ref);
  }
}

String _$carPopularityHash() => r'0229d34bafb27ef3f1d1ebfac72566f0bc783970';
