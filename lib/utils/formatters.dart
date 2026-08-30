// Small display formatters (no `intl` dependency).

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _thousands(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}$buf';
}

/// Plain integer with thousands separators → "12,345".
String formatCount(int n) => _thousands(n);

/// Month key "2026-03" → "Mar 2026"; anything unparsable is returned as-is.
String formatMonthKey(String yyyyMm) {
  final parts = yyyyMm.split('-');
  if (parts.length < 2) return yyyyMm;
  final month = int.tryParse(parts[1]);
  if (month == null || month < 1 || month > 12) return yyyyMm;
  return '${_months[month - 1]} ${parts[0]}';
}

/// Month key "2026-03" → "M" (single-letter axis label).
String monthInitial(String yyyyMm) {
  final label = formatMonthKey(yyyyMm);
  return label == yyyyMm ? '' : label[0];
}

/// Integer Ringgit → "RM 48,800".
String formatPrice(int myr) => 'RM ${_thousands(myr)}';

/// Integer kilometres → "38,000 km".
String formatMileage(int km) => '${_thousands(km)} km';

/// Local date → "12 Mar 2026".
String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// Local date → "Mar 2026" (e.g. member since).
String formatMonthYear(DateTime date) {
  final local = date.toLocal();
  return '${_months[local.month - 1]} ${local.year}';
}

/// "Posted 12 Mar 2026".
String formatPosted(DateTime date) => 'Posted ${formatDate(date)}';

/// Convert user input to E.164, or null if it is not a valid Malaysian mobile
/// number. Accepts an optional leading 0; the national part must start with 1
/// and be 9–10 digits.
String? nationalToE164(String input) {
  var d = input.replaceAll(RegExp('[^0-9]'), '');
  if (d.startsWith('0')) d = d.substring(1);
  if (!d.startsWith('1')) return null;
  if (d.length < 9 || d.length > 10) return null;
  return '+60$d';
}
