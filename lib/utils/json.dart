/// Helpers for the hand-written `fromJson` / `toJson` on the models in
/// `model/`. This is the untyped-JSON boundary CLAUDE.md §6 allows: Supabase
/// rows and sqflite rows arrive as `Map<String, dynamic>`, and they are
/// narrowed to typed fields here and nowhere else.
///
/// Postgres columns are snake_case while Dart fields are camelCase, so each
/// model spells its own key names out.
library;

/// A required `int`. JSON numbers decode as `num`, and Postgres `numeric`
/// can arrive as a double, so narrow rather than cast straight to `int`.
int asInt(Object? raw) => (raw as num).toInt();

/// An optional `int` — null when the column is null or absent.
int? asIntOrNull(Object? raw) => (raw as num?)?.toInt();

/// A required timestamp. `timestamptz` arrives as an ISO-8601 string.
DateTime asDate(Object? raw) => DateTime.parse(raw as String);

/// An optional timestamp — null when the column is null or absent.
DateTime? asDateOrNull(Object? raw) =>
    raw == null ? null : DateTime.parse(raw as String);

/// A list of strings, empty when the key is null or absent.
List<String> asStringList(Object? raw) =>
    (raw as List<dynamic>?)?.map((e) => e as String).toList() ?? <String>[];

/// A list of nested models, empty when the key is null or absent.
List<T> asModelList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) fromJson,
) =>
    (raw as List<dynamic>?)
        ?.map((e) => fromJson(e as Map<String, dynamic>))
        .toList() ??
    <T>[];

/// A list of enums decoded by constant name, empty when null or absent.
List<T> asEnumList<T extends Enum>(List<T> values, Object? raw) =>
    (raw as List<dynamic>?)?.map((e) => asEnum(values, e)).toList() ?? <T>[];

/// Decode an enum by constant name — the convention every listing, bid and
/// chat enum follows (`FuelType.petrol` <-> `'petrol'`). Throws on an
/// unknown value rather than silently picking a default, so a schema drift
/// surfaces instead of corrupting a row.
T asEnum<T extends Enum>(List<T> values, Object? raw) {
  final value = asEnumOrNull(values, raw);
  if (value == null) {
    throw ArgumentError.notNull('raw');
  }
  return value;
}

/// As [asEnum], but null when the column is null or absent.
T? asEnumOrNull<T extends Enum>(List<T> values, Object? raw) {
  if (raw == null) return null;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  throw ArgumentError.value(
    raw,
    'raw',
    'Not one of: ${values.map((v) => v.name).join(', ')}',
  );
}
