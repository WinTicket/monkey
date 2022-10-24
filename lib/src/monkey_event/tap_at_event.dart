import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../element.dart';
import '../monkey_event.dart';

class TapAtEvent extends MonkeyEvent {
  TapAtEvent(this.location);

  static TapAtEvent? atRandomElement(WidgetsBinding binding) {
    final element = chooseRandomElement(
      binding.renderViewElement!,
      test: (e) =>
          e.widget is GestureDetector &&
          (e.widget as GestureDetector).onTap != null &&
          isElementHitTestable(e, binding),
    );
    if (element == null) return null;
    final location =
        getElementPoint(element, (size) => size.center(Offset.zero));
    if (location == null) return null;
    return TapAtEvent(location);
  }

  final Offset location;

  @override
  Future<void> injectEvent(WidgetController controller) async {
    await controller.tapAt(location);
  }

  @override
  void paintEvent(Canvas canvas) {
    final paint = Paint()..color = Colors.blue;
    canvas.drawCircle(location, 16, paint);
  }

  @override
  String toString() {
    return 'TapAtEvent(location: $location)';
  }
}
