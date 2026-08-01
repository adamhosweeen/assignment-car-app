// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the in-progress [ListingDraft] and persists it to Hive after every
/// change, so a crash or force-quit never loses input (V1_SPEC §4.5). The
/// controller is ephemeral; the draft survives in Hive and is reloaded on
/// re-entry.

@ProviderFor(SellController)
final sellControllerProvider = SellControllerProvider._();

/// Owns the in-progress [ListingDraft] and persists it to Hive after every
/// change, so a crash or force-quit never loses input (V1_SPEC §4.5). The
/// controller is ephemeral; the draft survives in Hive and is reloaded on
/// re-entry.
final class SellControllerProvider
    extends $NotifierProvider<SellController, ListingDraft> {
  /// Owns the in-progress [ListingDraft] and persists it to Hive after every
  /// change, so a crash or force-quit never loses input (V1_SPEC §4.5). The
  /// controller is ephemeral; the draft survives in Hive and is reloaded on
  /// re-entry.
  SellControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellControllerHash();

  @$internal
  @override
  SellController create() => SellController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingDraft>(value),
    );
  }
}

String _$sellControllerHash() => r'513f626c660d7ccfb1d8e4f31f0380cae4133a81';

/// Owns the in-progress [ListingDraft] and persists it to Hive after every
/// change, so a crash or force-quit never loses input (V1_SPEC §4.5). The
/// controller is ephemeral; the draft survives in Hive and is reloaded on
/// re-entry.

abstract class _$SellController extends $Notifier<ListingDraft> {
  ListingDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ListingDraft, ListingDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListingDraft, ListingDraft>,
              ListingDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
