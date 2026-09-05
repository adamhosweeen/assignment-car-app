import 'package:flutter/foundation.dart';

import 'package:assignment/control/auth/location_service.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/auth/registration_data.dart';
import 'package:assignment/utils/formatters.dart';

/// Sentinel for [RegistrationState.copyWith], so an omitted argument is
/// distinguishable from an explicit `null` — clearing the date of birth or
/// the state has to actually clear it.
const Object _unset = Object();

/// Everything the registration flow has collected so far. Ephemeral — unlike
/// the sell draft, a half-finished signup is not persisted across app kills.
class RegistrationState {
  const RegistrationState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.firstName = '',
    this.lastName = '',
    this.dob,
    this.phoneInput = '',
    this.stateName,
    this.detectingLocation = false,
    this.locationFailed = false,
    this.interests = const CarInterests(),
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final DateTime? dob;
  final String phoneInput;
  final String? stateName;
  final bool detectingLocation;
  final bool locationFailed;
  final CarInterests interests;

  RegistrationState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? firstName,
    String? lastName,
    Object? dob = _unset,
    String? phoneInput,
    Object? stateName = _unset,
    bool? detectingLocation,
    bool? locationFailed,
    CarInterests? interests,
  }) => RegistrationState(
    email: email ?? this.email,
    password: password ?? this.password,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    dob: identical(dob, _unset) ? this.dob : dob as DateTime?,
    phoneInput: phoneInput ?? this.phoneInput,
    stateName: identical(stateName, _unset)
        ? this.stateName
        : stateName as String?,
    detectingLocation: detectingLocation ?? this.detectingLocation,
    locationFailed: locationFailed ?? this.locationFailed,
    interests: interests ?? this.interests,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistrationState &&
          email == other.email &&
          password == other.password &&
          confirmPassword == other.confirmPassword &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          dob == other.dob &&
          phoneInput == other.phoneInput &&
          stateName == other.stateName &&
          detectingLocation == other.detectingLocation &&
          locationFailed == other.locationFailed &&
          interests == other.interests;

  @override
  int get hashCode => Object.hash(
    email,
    password,
    confirmPassword,
    firstName,
    lastName,
    dob,
    phoneInput,
    stateName,
    detectingLocation,
    locationFailed,
    interests,
  );

  @override
  String toString() =>
      'RegistrationState(email: $email, firstName: $firstName, '
      'lastName: $lastName, dob: $dob, phoneInput: $phoneInput, '
      'stateName: $stateName, detectingLocation: $detectingLocation, '
      'locationFailed: $locationFailed, interests: $interests)';
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
