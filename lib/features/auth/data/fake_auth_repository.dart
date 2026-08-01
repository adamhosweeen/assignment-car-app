import 'dart:async';
import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../../../core/result.dart';
import '../../profile/domain/profile.dart';
import '../domain/auth_repository.dart';

/// Dev-bypass auth for the fake backend: any valid Malaysian number plus any
/// 6-digit code signs you in. The profile is persisted to Hive so a returning
/// user is not asked to log in again (V1_SPEC §5.2).
///
/// Swapped for a real Supabase phone-OTP implementation later — same interface.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._sessionBox) {
    _current = _restore();
  }

  /// Stable id so a signed-in user always owns the same listings within a run.
  static const String localUserId = 'local-user';
  static const String _key = 'profile';

  final Box<dynamic> _sessionBox;
  final StreamController<Profile?> _controller =
      StreamController<Profile?>.broadcast();
  Profile? _current;

  Profile? _restore() {
    final raw = _sessionBox.get(_key);
    if (raw is! String) return null;
    try {
      return Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

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
    _current = profile;
    await _sessionBox.put(_key, jsonEncode(profile.toJson()));
    _controller.add(profile);
    return Ok(profile);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    await _sessionBox.delete(_key);
    _controller.add(null);
  }

  String _maskedName(String phone) {
    if (phone.length <= 4) return phone;
    return 'User ••${phone.substring(phone.length - 4)}';
  }
}
