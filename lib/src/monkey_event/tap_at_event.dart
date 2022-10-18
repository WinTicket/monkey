import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../element.dart';
import '../monkey_event.dart';

class TapAtEventFactory extends MonkeyEventFactory<TapAtEvent> {
  const TapAtEventFactory();

  @override
  TapAtEvent? create(WidgetsBinding binding) {
    final element = randomElement(
      binding,
      test: (e) =>
          e.widget is GestureDetector &&
          (e.widget as GestureDetector).onTap != null,
    );
    if (element == null) return null;
    final renderBox = getRenderBox(element);
    if (renderBox == null) return null;
    final location = renderBox.size.center(Offset.zero);
    return TapAtEvent(location);
  }
}

class TapAtEvent extends MonkeyEvent {
  TapAtEvent(this.location);

  final Offset location;

  @override
  Future<void> injectEvent(WidgetController controller) async {
    await controller.tapAt(location);
  }

  @override
  void paintEvent(Canvas canvas) {
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(location, 8, paint);
  }
}
