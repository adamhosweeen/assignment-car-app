import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/control/auth/supabase_auth_repository.dart';

void main() {
  const base = 'https://abc.supabase.co/storage/v1/object/public/avatars/';

  test('avatarObjectPath extracts the object path from a public URL', () {
    expect(avatarObjectPath('${base}user-1/photo-1.jpg'), 'user-1/photo-1.jpg');
  });

  test('avatarObjectPath strips a query string and decodes escapes', () {
    expect(avatarObjectPath('${base}user-1/a%20b.jpg?t=123'), 'user-1/a b.jpg');
  });

  test('avatarObjectPath is null for other URLs or null', () {
    expect(avatarObjectPath(null), isNull);
    expect(avatarObjectPath('https://example.com/x.jpg'), isNull);
    expect(
      avatarObjectPath(
        'https://abc.supabase.co/storage/v1/object/public/listing-media/u/l/x.jpg',
      ),
      isNull,
    );
    expect(avatarObjectPath(base), isNull);
  });
}
