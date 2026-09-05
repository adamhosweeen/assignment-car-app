import 'dart:async';

class RestartableStream<T> {
  RestartableStream(this._source);

  final Stream<T> Function() _source;

  StreamSubscription<T>? _sub;

  int _generation = 0;

  late final StreamController<T> _out = StreamController<T>(
    onListen: _subscribe,
    onCancel: _unsubscribe,
  );

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
