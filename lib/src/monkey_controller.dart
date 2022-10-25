import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'element.dart';

abstract class MonkeyController {
  Future<void> tapAt(Offset location);

  Future<void> longPressAt(Offset location);

  Future<void> dragFrom(Offset startLocation, Offset offset, Duration duration);

  Future<void> flingFrom(Offset startLocation, Offset offset, double speed);

  Future<void> popBack();
}

class MonkeyControllerImpl extends MonkeyController {
  MonkeyControllerImpl(this._controller, this._rootElement);

  final WidgetController _controller;
  final Element _rootElement;

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

  @override
  Future<void> popBack() {
    final navigator = findRootNavigatorState(_rootElement);
    return navigator.maybePop();
  }
}
