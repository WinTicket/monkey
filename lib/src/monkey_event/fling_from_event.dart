import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monkey/src/random.dart';

import '../element.dart';
import '../monkey_event.dart';

class FlingFromEventFactory extends MonkeyEventFactory<FlingFromEvent> {
  const FlingFromEventFactory();

  @override
  FlingFromEvent? create(WidgetsBinding binding) {
    final element = randomElement(
      binding,
      test: (e) => e.widget is Scrollable,
    );
    if (element == null) return null;
    final scrollable = element.widget as Scrollable;
    final box = getRenderBox(element);
    if (box == null) return null;
    return FlingFromEvent(scrollable, box);
  }
}

class FlingFromEvent extends MonkeyEvent {
  FlingFromEvent(this.scrollable, this.box);

  final Scrollable scrollable;
  final RenderBox box;

  late final Offset location = box.size.center(Offset.zero);
  late final Offset offset = () {
    Offset offset;
    switch (scrollable.axis) {
      case Axis.horizontal:
        offset = Offset(box.size.width * 0.4, 0);
        break;
      case Axis.vertical:
        offset = Offset(0, box.size.height * 0.4);
        break;
    }
    offset = offset * (random.nextBool() ? -1 : 1);
    return offset;
  }();

  @override
  Future<void> injectEvent(WidgetController controller) async {
    await controller.flingFrom(location, offset, offset.distance * 10);
  }

  @override
  void paintEvent(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.pink
      ..strokeWidth = 4;
    canvas.drawCircle(location, 8, paint);
    canvas.drawLine(location, location + offset, paint);
  }
}
