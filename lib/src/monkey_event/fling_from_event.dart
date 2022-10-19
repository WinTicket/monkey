import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monkey/src/random.dart';

import '../element.dart';
import '../monkey_event.dart';

class FlingFromEvent extends MonkeyEvent {
  FlingFromEvent(
    this.startLocation,
    this.offset,
    this.speed,
  );

  static FlingFromEvent? randomFromBinding(WidgetsBinding binding) {
    final element = randomElement(
      binding.renderViewElement!,
      test: (e) => e.widget is Scrollable && isElementHitTestable(e, binding),
    );
    if (element == null) return null;
    final scrollable = element.widget as Scrollable;
    final box = getElementRenderBox(element);
    if (box == null) return null;
    final location =
        getElementPoint(element, (size) => size.center(Offset.zero));
    if (location == null) return null;

    Offset halfOffset;
    switch (scrollable.axis) {
      case Axis.horizontal:
        halfOffset = Offset(box.size.width * 0.3, 0);
        break;
      case Axis.vertical:
        halfOffset = Offset(0, box.size.height * 0.3);
        break;
    }
    halfOffset = halfOffset * (random.nextBool() ? -1 : 1);

    return FlingFromEvent(
      location - halfOffset,
      location + halfOffset,
      halfOffset.direction * (random.nextInt(10) + 1),
    );
  }

  final Offset startLocation;
  final Offset offset;
  final double speed;

  @override
  Future<void> injectEvent(WidgetController controller) async {
    await controller.flingFrom(
      startLocation,
      offset,
      speed,
    );
  }

  @override
  void paintEvent(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.pink
      ..strokeWidth = 4;

    final p1 = startLocation;
    final p2 = startLocation + offset;
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
    return 'FlingFromEvent(startLocation: $startLocation, offset: $offset, speed: $speed)';
  }
}
