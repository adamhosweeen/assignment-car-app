/// Input validation rules shared by login, registration, and profile editing.
library;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String input) => _emailPattern.hasMatch(input.trim());

/// At least 8 characters with at least one letter and one digit.
bool isValidPassword(String input) =>
    input.length >= 8 &&
    input.contains(RegExp('[A-Za-z]')) &&
    input.contains(RegExp('[0-9]'));

/// The three password rules shown as a checklist during registration.
bool hasMinLength(String p) => p.length >= 8;
bool hasLetter(String p) => p.contains(RegExp('[A-Za-z]'));
bool hasDigit(String p) => p.contains(RegExp('[0-9]'));

/// 0 = empty, 1 = weak (some rules), 2 = okay (all rules), 3 = strong
/// (all rules + 12 chars + a symbol or mixed case). Drives the strength meter.
int passwordStrength(String p) {
  if (p.isEmpty) return 0;
  if (!isValidPassword(p)) return 1;
  final extra =
      p.length >= 12 &&
      (p.contains(RegExp('[^A-Za-z0-9]')) ||
          (p.contains(RegExp('[a-z]')) && p.contains(RegExp('[A-Z]'))));
  return extra ? 3 : 2;
}

/// Whether someone born on [dob] is 18 or older. [now] is injectable for
/// tests; someone turns 18 on their 18th birthday, not the day after.
bool isAtLeast18(DateTime dob, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final threshold = DateTime(today.year - 18, today.month, today.day);
  return !dob.isAfter(threshold);
}
