import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/control/auth/location_service.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/auth/registration_data.dart';
import 'package:assignment/utils/formatters.dart';

part 'registration_controller.freezed.dart';

/// Everything the registration flow has collected so far. Ephemeral — unlike
/// the sell draft, a half-finished signup is not persisted across app kills.
@freezed
abstract class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default('') String firstName,
    @Default('') String lastName,
    DateTime? dob,
    @Default('') String phoneInput,
    String? stateName,
    @Default(false) bool detectingLocation,
    @Default(false) bool locationFailed,
    @Default(CarInterests()) CarInterests interests,
  }) = _RegistrationState;
}

/// Owns the in-progress registration form across its steps. Same shape as
/// `SellController`, minus the sqflite persistence — it is scoped to the
/// `/register` route, so leaving the flow throws the half-filled form away.
class RegistrationController extends ChangeNotifier {
  RegistrationState _state = const RegistrationState();

  /// Everything collected so far. Watch this to rebuild a step on every edit.
  RegistrationState get state => _state;

  void _set(RegistrationState next) {
    _state = next;
    notifyListeners();
  }

  void setEmail(String v) => _set(_state.copyWith(email: v));
  void setPassword(String v) => _set(_state.copyWith(password: v));
  void setConfirmPassword(String v) =>
      _set(_state.copyWith(confirmPassword: v));
  void setFirstName(String v) => _set(_state.copyWith(firstName: v));
  void setLastName(String v) => _set(_state.copyWith(lastName: v));
  void setDob(DateTime? v) => _set(_state.copyWith(dob: v));
  void setPhoneInput(String v) => _set(_state.copyWith(phoneInput: v));
  void setStateName(String? v) =>
      _set(_state.copyWith(stateName: v, locationFailed: false));
  void setInterests(CarInterests v) => _set(_state.copyWith(interests: v));

  /// Back to an empty form, after a successful signup.
  void reset() => _set(const RegistrationState());

  /// Try GPS; on success fill in the state, on failure flag it so the step
  /// can point at the manual picker.
  Future<void> detectLocation() async {
    if (_state.detectingLocation) return;
    _set(_state.copyWith(detectingLocation: true, locationFailed: false));
    final detected = await detectStateName();
    _set(
      _state.copyWith(
        detectingLocation: false,
        stateName: detected ?? _state.stateName,
        locationFailed: detected == null,
      ),
    );
  }

  /// The completed payload. Only valid once every step's `_canAdvance` has
  /// passed — the bangs mirror those guarantees.
  RegistrationData buildData() => RegistrationData(
    firstName: state.firstName.trim(),
    lastName: state.lastName.trim(),
    dob: state.dob!,
    phoneE164: nationalToE164(state.phoneInput)!,
    state: state.stateName!,
    interests: state.interests,
  );
}
