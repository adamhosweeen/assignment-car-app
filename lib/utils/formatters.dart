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

String formatCount(int n) => _thousands(n);

String formatMonthKey(String yyyyMm) {
  final parts = yyyyMm.split('-');
  if (parts.length < 2) return yyyyMm;
  final month = int.tryParse(parts[1]);
  if (month == null || month < 1 || month > 12) return yyyyMm;
  return '${_months[month - 1]} ${parts[0]}';
}

String monthInitial(String yyyyMm) {
  final label = formatMonthKey(yyyyMm);
  return label == yyyyMm ? '' : label[0];
}

String formatPrice(int myr) => 'RM ${_thousands(myr)}';

String formatMileage(int km) => '${_thousands(km)} km';

String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

String formatMonthYear(DateTime date) {
  final local = date.toLocal();
  return '${_months[local.month - 1]} ${local.year}';
}

String formatRelative(DateTime date, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).toUtc().difference(date.toUtc());
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return formatDate(date);
}

String formatPosted(DateTime date) => 'Posted ${formatDate(date)}';

String? nationalToE164(String input) {
  var d = input.replaceAll(RegExp('[^0-9]'), '');
  if (d.startsWith('0')) d = d.substring(1);
  if (!d.startsWith('1')) return null;
  if (d.length < 9 || d.length > 10) return null;
  return '+60$d';
}
