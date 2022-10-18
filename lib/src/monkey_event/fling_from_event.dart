import 'dart:math' as math;

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
      binding.renderViewElement!,
      test: (e) => e.widget is Scrollable,
    );
    if (element == null) return null;
    final scrollable = element.widget as Scrollable;
    final box = getElementRenderBox(element);
    if (box == null) return null;
    final location =
        getElementPoint(element, (size) => size.center(Offset.zero));
    if (location == null) return null;
    return FlingFromEvent(scrollable, location, box);
  }
}

class FlingFromEvent extends MonkeyEvent {
  FlingFromEvent(this.scrollable, this.location, this.box);

  final Scrollable scrollable;
  final Offset location;
  final RenderBox box;

  late final Offset offset = () {
    Offset offset;
    switch (scrollable.axis) {
      case Axis.horizontal:
        offset = Offset(box.size.width * 0.3, 0);
        break;
      case Axis.vertical:
        offset = Offset(0, box.size.height * 0.3);
        break;
    }
    offset = offset * (random.nextBool() ? -1 : 1);
    return offset;
  }();

  @override
  Future<void> injectEvent(WidgetController controller) async {
    await controller.flingFrom(
        location - offset, offset * 2, offset.distance * 10);
  }

  @override
  void paintEvent(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.pink
      ..strokeWidth = 4;

    final p1 = location + offset;
    final p2 = location - offset;
    final dX = p2.dx - p1.dx;
    final dY = p2.dy - p1.dy;

    const arrowSize = 30;
    const arrowAngle = 25 * math.pi / 180;

    final angle = math.atan2(dY, dX);
    canvas.drawLine(
      p1,
      Offset(
        p2.dx - arrowSize * math.cos(angle) * 0.5,
        p2.dy - arrowSize * math.sin(angle) * 0.5,
      ),
      paint,
    );

    final path = Path()
      ..moveTo(
        p2.dx - arrowSize * math.cos(angle - arrowAngle),
        p2.dy - arrowSize * math.sin(angle - arrowAngle),
      )
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(
        p2.dx - arrowSize * math.cos(angle + arrowAngle),
        p2.dy - arrowSize * math.sin(angle + arrowAngle),
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  String toString() {
    return 'FlingFromEvent(startLocation: $location, offset: $offset)';
  }
}