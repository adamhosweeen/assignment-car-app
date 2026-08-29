import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:assignment/model/profile/car_interests.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// A user profile. Mirrors the `profiles` table.
@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? phone,
    String? state,
    @Default(CarInterests()) CarInterests interests,
    String? avatarUrl,
    required DateTime createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  /// Full name, falling back to the email prefix so there is always something
  /// to show.
  String get displayName {
    final name = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (name.isNotEmpty) return name;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }
}
