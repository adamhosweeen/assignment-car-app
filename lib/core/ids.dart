import 'dart:math';

final Random _rand = Random();

/// A random RFC-4122-style v4 UUID string.
///
/// Not cryptographically strong — good enough for client-side ids in the fake
/// backend. In the Supabase build the server assigns ids via `gen_random_uuid()`.
String newId() {
  final b = List<int>.generate(16, (_) => _rand.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40; // version 4
  b[8] = (b[8] & 0x3f) | 0x80; // variant 10
  String h(int start, int end) => b
      .sublist(start, end)
      .map((x) => x.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${h(0, 4)}-${h(4, 6)}-${h(6, 8)}-${h(8, 10)}-${h(10, 16)}';
}
