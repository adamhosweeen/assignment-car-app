import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../core/result.dart';
import '../../profile/domain/profile.dart';
import '../domain/auth_repository.dart';

/// Dev-bypass auth for the fake backend: any valid Malaysian number plus any
/// 6-digit code signs you in. The profile is persisted to sqflite's
/// `cached_session` table so a returning user is not asked to log in again
/// (V1_SPEC §5.2).
///
/// Swapped for a real Supabase phone-OTP implementation later — same interface.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._db, Map<String, Object?>? initialSessionRow)
    : _current = initialSessionRow == null ? null : _fromRow(initialSessionRow);

  /// Stable id so a signed-in user always owns the same listings within a run.
  static const String localUserId = 'local-user';

  final Database _db;
  final StreamController<Profile?> _controller =
      StreamController<Profile?>.broadcast();
  Profile? _current;

  @override
  Profile? get currentUser => _current;

  @override
  Stream<Profile?> authState() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> sendOtp(String phoneE164) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const Ok(null);
  }

  @override
  Future<Result<Profile>> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (code.length != 6 || int.tryParse(code) == null) {
      return const Err(
        "That code isn't right. Enter the 6-digit code from your SMS.",
      );
    }
    final profile = Profile(
      id: localUserId,
      phone: phoneE164,
      displayName: _maskedName(phoneE164),
      createdAt: DateTime.now().toUtc(),
    );
    await _persist(profile);
    return Ok(profile);
  }

  @override
  Future<Result<Profile>> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final current = _current;
    if (current == null) {
      return const Err('You need to be signed in to update your profile.');
    }
    final updated = current.copyWith(
      displayName: displayName ?? current.displayName,
      avatarUrl: avatarUrl ?? current.avatarUrl,
    );
    await _persist(updated);
    return Ok(updated);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    await _db.delete('cached_session');
    _controller.add(null);
  }

  Future<void> _persist(Profile profile) async {
    _current = profile;
    await _db.insert(
      'cached_session',
      _toRow(profile),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _controller.add(profile);
  }

  String _maskedName(String phone) {
    if (phone.length <= 4) return phone;
    return 'User ••${phone.substring(phone.length - 4)}';
  }

  static Map<String, Object?> _toRow(Profile profile) => {
    'id': profile.id,
    'phone': profile.phone,
    'display_name': profile.displayName,
    'avatar_url': profile.avatarUrl,
    'created_at': profile.createdAt.toIso8601String(),
  };

  static Profile _fromRow(Map<String, Object?> row) => Profile(
    id: row['id']! as String,
    phone: row['phone']! as String,
    displayName: row['display_name'] as String?,
    avatarUrl: row['avatar_url'] as String?,
    createdAt: DateTime.parse(row['created_at']! as String),
  );
}
