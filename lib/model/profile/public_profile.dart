import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_profile.freezed.dart';
part 'public_profile.g.dart';

/// The part of a user's profile any signed-in user may see — a row of the
/// `public_profiles` view. Deliberately has no email, phone, DOB, or
/// interests; those never leave the owner's own `profiles` row.
@freezed
abstract class PublicProfile with _$PublicProfile {
  const PublicProfile._();

  const factory PublicProfile({
    required String id,
    String? displayName,
    String? avatarUrl,
    String? state,
    required DateTime createdAt,
  }) = _PublicProfile;

  factory PublicProfile.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileFromJson(json);

  /// Display name, or a neutral fallback for accounts without one.
  String get name {
    final n = displayName?.trim() ?? '';
    return n.isEmpty ? 'Seller' : n;
  }
}
