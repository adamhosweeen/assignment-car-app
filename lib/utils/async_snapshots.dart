import 'dart:async';

import 'package:flutter/widgets.dart';

Stream<AsyncSnapshot<T>> snapshots<T>(Stream<T> source) => source.transform(
  StreamTransformer<T, AsyncSnapshot<T>>.fromHandlers(
    handleData: (value, sink) =>
        sink.add(AsyncSnapshot.withData(ConnectionState.active, value)),
    handleError: (error, stackTrace, sink) => sink.add(
      AsyncSnapshot.withError(ConnectionState.active, error, stackTrace),
    ),
  ),
);
