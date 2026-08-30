import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/model/profile/car_interests.dart';

part 'registration_data.freezed.dart';

/// Everything the registration flow collects besides the email/password
/// credentials. Passed to [AuthRepository.signUp] in one piece.
@freezed
abstract class RegistrationData with _$RegistrationData {
  const factory RegistrationData({
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String phoneE164,
    required String state,
    required CarInterests interests,
  }) = _RegistrationData;
}
