import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/model/profile/public_profile.dart';

void main() {
  test('round-trips through snake_case JSON', () {
    final p = PublicProfile(
      id: 'u1',
      displayName: 'Aisyah Rahman',
      avatarUrl: 'https://x/avatars/u1/a.jpg',
      state: 'Selangor',
      createdAt: DateTime.utc(2026, 3, 1),
    );
    final json = p.toJson();
    expect(json['display_name'], 'Aisyah Rahman');
    expect(json['avatar_url'], isNotNull);
    expect(PublicProfile.fromJson(json), p);
  });

  test('name falls back when display_name is missing or blank', () {
    final base = {'id': 'u1', 'created_at': '2026-03-01T00:00:00.000Z'};
    expect(PublicProfile.fromJson(base).name, 'Seller');
    expect(
      PublicProfile.fromJson({...base, 'display_name': '   '}).name,
      'Seller',
    );
    expect(
      PublicProfile.fromJson({...base, 'display_name': 'Ken'}).name,
      'Ken',
    );
  });
}
