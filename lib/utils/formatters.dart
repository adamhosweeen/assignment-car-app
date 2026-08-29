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

/// Integer Ringgit → "RM 48,800".
String formatPrice(int myr) => 'RM ${_thousands(myr)}';

/// Integer kilometres → "38,000 km".
String formatMileage(int km) => '${_thousands(km)} km';

/// Local date → "12 Mar 2026".
String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
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
