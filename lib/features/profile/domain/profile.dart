import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// A user profile. Mirrors the `profiles` table.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String phone,
    String? displayName,
    String? avatarUrl,
    required DateTime createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
