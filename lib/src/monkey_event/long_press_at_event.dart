import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../element.dart';
import '../monkey_event.dart';

class LongPressAtEvent extends MonkeyEvent {
  LongPressAtEvent(this.location);

  static LongPressAtEvent? atRandomElement(WidgetsBinding binding) {
    final element = chooseRandomElement(
      binding.renderViewElement!,
      test: (e) =>
          e.widget is GestureDetector &&
          (e.widget as GestureDetector).onLongPress != null &&
          isElementHitTestable(e, binding),
    );
    if (element == null) return null;
    final location =
        getElementPoint(element, (size) => size.center(Offset.zero));
    if (location == null) return null;
    return LongPressAtEvent(location);
  }

  final Offset location;

  @override
  Future<void> injectEvent(WidgetController controller) async {
    await controller.longPressAt(location);
  }

  @override
  void paintEvent(Canvas canvas) {
    final paint = Paint()..color = Colors.brown;
    canvas.drawRect(Rect.fromCircle(center: location, radius: 16), paint);
  }

  @override
  String toString() {
    return 'LongPressAt(location: $location)';
  }
}
