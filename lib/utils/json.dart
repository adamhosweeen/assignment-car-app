library;

int asInt(Object? raw) => (raw as num).toInt();

int? asIntOrNull(Object? raw) => (raw as num?)?.toInt();

DateTime asDate(Object? raw) => DateTime.parse(raw as String);

DateTime? asDateOrNull(Object? raw) =>
    raw == null ? null : DateTime.parse(raw as String);

List<String> asStringList(Object? raw) =>
    (raw as List<dynamic>?)?.map((e) => e as String).toList() ?? <String>[];

List<T> asModelList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) fromJson,
) =>
    (raw as List<dynamic>?)
        ?.map((e) => fromJson(e as Map<String, dynamic>))
        .toList() ??
    <T>[];

List<T> asEnumList<T extends Enum>(List<T> values, Object? raw) =>
    (raw as List<dynamic>?)?.map((e) => asEnum(values, e)).toList() ?? <T>[];

T asEnum<T extends Enum>(List<T> values, Object? raw) {
  final value = asEnumOrNull(values, raw);
  if (value == null) {
    throw ArgumentError.notNull('raw');
  }
  return value;
}

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
