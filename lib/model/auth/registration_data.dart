import 'package:assignment/model/profile/car_interests.dart';

class RegistrationData {
  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.phoneE164,
    required this.state,
    required this.interests,
  });

  final String firstName;
  final String lastName;
  final DateTime dob;
  final String phoneE164;
  final String state;
  final CarInterests interests;

  RegistrationData copyWith({
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? phoneE164,
    String? state,
    CarInterests? interests,
  }) => RegistrationData(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    dob: dob ?? this.dob,
    phoneE164: phoneE164 ?? this.phoneE164,
    state: state ?? this.state,
    interests: interests ?? this.interests,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistrationData &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          dob == other.dob &&
          phoneE164 == other.phoneE164 &&
          state == other.state &&
          interests == other.interests;

  @override
  int get hashCode =>
      Object.hash(firstName, lastName, dob, phoneE164, state, interests);

  @override
  String toString() =>
      'RegistrationData(firstName: $firstName, lastName: $lastName, '
      'dob: $dob, phoneE164: $phoneE164, state: $state, '
      'interests: $interests)';
}
