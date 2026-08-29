/// A minimal result type for fallible operations.
///
/// The data layer returns [Result] instead of throwing, so the UI can handle
/// loading / empty / error explicitly (CLAUDE.md §6). [Err.message] is always a
/// plain-English sentence safe to show the user — never a raw exception.
sealed class Result<T> {
  const Result();

  /// True when this is an [Ok].
  bool get isOk => this is Ok<T>;

  /// The value if [Ok], otherwise null.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message, [this.cause]);

  /// Plain-English, user-facing sentence with a next action where possible.
  final String message;

  /// Optional underlying error, for logging only — never shown to the user.
  final Object? cause;
}
