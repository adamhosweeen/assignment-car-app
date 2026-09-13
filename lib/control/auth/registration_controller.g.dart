// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the in-progress registration form across its steps. Same shape as
/// [SellController], minus the sqflite persistence.

@ProviderFor(RegistrationController)
final registrationControllerProvider = RegistrationControllerProvider._();

/// Owns the in-progress registration form across its steps. Same shape as
/// [SellController], minus the sqflite persistence.
final class RegistrationControllerProvider
    extends $NotifierProvider<RegistrationController, RegistrationState> {
  /// Owns the in-progress registration form across its steps. Same shape as
  /// [SellController], minus the sqflite persistence.
  RegistrationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registrationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registrationControllerHash();

  @$internal
  @override
  RegistrationController create() => RegistrationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegistrationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegistrationState>(value),
    );
  }
}

String _$registrationControllerHash() =>
    r'20af21d43cbf8db193900513da243c9b80a60d31';

/// Owns the in-progress registration form across its steps. Same shape as
/// [SellController], minus the sqflite persistence.

abstract class _$RegistrationController extends $Notifier<RegistrationState> {
  RegistrationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RegistrationState, RegistrationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegistrationState, RegistrationState>,
              RegistrationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
