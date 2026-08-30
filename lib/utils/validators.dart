/// Input validation rules shared by login, registration, and profile editing.
library;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String input) => _emailPattern.hasMatch(input.trim());

/// At least 8 characters with at least one letter and one digit.
bool isValidPassword(String input) =>
    input.length >= 8 &&
    input.contains(RegExp('[A-Za-z]')) &&
    input.contains(RegExp('[0-9]'));

/// Whether someone born on [dob] is 18 or older. [now] is injectable for
/// tests; someone turns 18 on their 18th birthday, not the day after.
bool isAtLeast18(DateTime dob, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final threshold = DateTime(today.year - 18, today.month, today.day);
  return !dob.isAfter(threshold);
}
