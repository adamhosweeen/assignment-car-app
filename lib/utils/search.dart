/// Longest search string sent to the backend.
const int maxSearchQueryLength = 60;

/// Characters with meaning inside a PostgREST filter expression
/// (`or=(make.ilike.%q%,...)`) or a LIKE pattern. Stripping them keeps a
/// user's typing from breaking the filter or matching every row.
final RegExp _reserved = RegExp(r'[%_,().\\"*]');
final RegExp _whitespace = RegExp(r'\s+');

/// Normalise free-text search input: trim, collapse internal whitespace,
/// drop filter-reserved characters, cap the length. Returns '' when nothing
/// searchable is left, which callers treat as "no query".
String sanitizeSearchQuery(String raw) {
  final cleaned = raw
      .replaceAll(_reserved, ' ')
      .replaceAll(_whitespace, ' ')
      .trim();
  return cleaned.length > maxSearchQueryLength
      ? cleaned.substring(0, maxSearchQueryLength).trim()
      : cleaned;
}
