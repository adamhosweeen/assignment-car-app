import 'dart:async';

/// A stream that can be torn down and re-subscribed on demand.
///
/// App-scoped `StreamProvider`s subscribe once and have no way to re-run a
/// failed load — but the screens reading them have an explicit error state
/// with a "Retry". This sits between the two: the provider listens to
/// [stream], and the screen calls [restart] to re-subscribe to a fresh source.
///
/// Have the source emit `AsyncSnapshot.waiting()` as its first value so a
/// restart puts the screen back into its loading state.
class RestartableStream<T> {
  RestartableStream(this._source);

  final Stream<T> Function() _source;

  StreamSubscription<T>? _sub;

  /// Bumped on every (re)subscribe, so a cancelled source that is still
  /// draining a queued event can't push it into [stream] after the restart.
  int _generation = 0;

  late final StreamController<T> _out = StreamController<T>(
    onListen: _subscribe,
    onCancel: _unsubscribe,
  );

  /// The stable outward-facing stream. Survives a [restart].
  Stream<T> get stream => _out.stream;

  void _subscribe() {
    final generation = ++_generation;
    _sub = _source().listen(
      (value) {
        if (generation == _generation) _out.add(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (generation == _generation) _out.addError(error, stackTrace);
      },
    );
  }

  Future<void> _unsubscribe() async {
    final sub = _sub;
    _sub = null;
    _generation++;
    await sub?.cancel();
  }

  /// Drop the current subscription and start the source again. A no-op until
  /// something is listening — there is nothing to restart yet.
  void restart() {
    if (_sub == null) return;
    _unsubscribe();
    _subscribe();
  }

  Future<void> dispose() async {
    await _unsubscribe();
    await _out.close();
  }
}
