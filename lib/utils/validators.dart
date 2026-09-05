library;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String input) => _emailPattern.hasMatch(input.trim());

bool isValidPassword(String input) =>
    input.length >= 8 &&
    input.contains(RegExp('[A-Za-z]')) &&
    input.contains(RegExp('[0-9]'));

bool hasMinLength(String p) => p.length >= 8;
bool hasLetter(String p) => p.contains(RegExp('[A-Za-z]'));
bool hasDigit(String p) => p.contains(RegExp('[0-9]'));

int passwordStrength(String p) {
  if (p.isEmpty) return 0;
  if (!isValidPassword(p)) return 1;
  final extra =
      p.length >= 12 &&
      (p.contains(RegExp('[^A-Za-z0-9]')) ||
          (p.contains(RegExp('[a-z]')) && p.contains(RegExp('[A-Z]'))));
  return extra ? 3 : 2;
}

bool isAtLeast18(DateTime dob, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final threshold = DateTime(today.year - 18, today.month, today.day);
  return !dob.isAfter(threshold);
}
