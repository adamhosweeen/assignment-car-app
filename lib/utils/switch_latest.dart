import 'dart:async';

extension SwitchLatest<T> on Stream<T> {
  Stream<S> switchMap<S>(Stream<S> Function(T value) convert) {
    final controller = StreamController<S>();
    StreamSubscription<T>? outer;
    StreamSubscription<S>? inner;
    var outerDone = false;

    void closeIfFinished() {
      if (outerDone && inner == null && !controller.isClosed) {
        controller.close();
      }
    }

    controller
      ..onListen = () {
        outer = listen(
          (value) {
            inner?.cancel();
            inner = null;
            if (controller.isClosed) return;
            inner = convert(value).listen(
              controller.add,
              onError: controller.addError,
              onDone: () {
                inner = null;
                closeIfFinished();
              },
            );
          },
          onError: controller.addError,
          onDone: () {
            outerDone = true;
            closeIfFinished();
          },
        );
      }
      ..onCancel = () async {
        final outerSub = outer;
        final innerSub = inner;
        outer = null;
        inner = null;
        await outerSub?.cancel();
        await innerSub?.cancel();
      };

    return controller.stream;
  }
}
