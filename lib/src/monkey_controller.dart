import 'package:flutter_test/flutter_test.dart';

abstract class MonkeyController {
  Future<void> tapAt(Offset location);

  Future<void> longPressAt(Offset location);

  Future<void> dragFrom(Offset startLocation, Offset offset, Duration duration);

  Future<void> flingFrom(Offset startLocation, Offset offset, double speed);
}

class MonkeyControllerImpl extends MonkeyController {
  MonkeyControllerImpl(this._controller);

  final WidgetController _controller;

  @override
  Future<void> tapAt(Offset location) {
    return _controller.tapAt(location);
  }

  @override
  Future<void> longPressAt(Offset location) {
    return _controller.longPressAt(location);
  }

  @override
  Future<void> dragFrom(
      Offset startLocation, Offset offset, Duration duration) {
    return _controller.timedDragFrom(startLocation, offset, duration);
  }

  @override
  Future<void> flingFrom(Offset startLocation, Offset offset, double speed) {
    return _controller.flingFrom(startLocation, offset, speed);
  }
}
