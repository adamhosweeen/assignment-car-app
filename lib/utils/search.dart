const int maxSearchQueryLength = 60;

final RegExp _reserved = RegExp(r'[%_,().\\"*]');
final RegExp _whitespace = RegExp(r'\s+');

String sanitizeSearchQuery(String raw) {
  final cleaned = raw
      .replaceAll(_reserved, ' ')
      .replaceAll(_whitespace, ' ')
      .trim();
  return cleaned.length > maxSearchQueryLength
      ? cleaned.substring(0, maxSearchQueryLength).trim()
      : cleaned;
}
