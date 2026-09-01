import 'dart:async';

import 'package:flutter/widgets.dart';

/// Folds a data stream's errors into values, so a `StreamProvider` can carry
/// loading / error / data the same way a [StreamBuilder] does.
///
/// `StreamProvider` has no error channel of its own — an error on the source
/// stream would otherwise be reported to [FlutterError] and the screen would
/// sit on its last value forever. The repository streams do emit errors (a
/// failed first load with nothing cached to show), and those screens have an
/// explicit error state with a retry, so the error has to reach the widget.
///
/// Pair it with `initialData: const AsyncSnapshot.waiting()`.
Stream<AsyncSnapshot<T>> snapshots<T>(Stream<T> source) => source.transform(
  StreamTransformer<T, AsyncSnapshot<T>>.fromHandlers(
    handleData: (value, sink) =>
        sink.add(AsyncSnapshot.withData(ConnectionState.active, value)),
    handleError: (error, stackTrace, sink) => sink.add(
      AsyncSnapshot.withError(ConnectionState.active, error, stackTrace),
    ),
  ),
);
