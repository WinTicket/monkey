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
  );

  static FlingFromEvent? atRandomElement(WidgetsBinding binding) {
    final element = chooseRandomElement(
      binding.renderViewElement!,
      test: (e) {
        if (e.widget is! Scrollable) return false;
        final position =
            ((e as StatefulElement).state as ScrollableState).position;
        if (!position.hasContentDimensions ||
            (position.minScrollExtent == 0.0 &&
                position.maxScrollExtent == 0.0)) {
          return false;
        }
        return isElementHitTestable(e, binding);
      },
    );
    if (element == null) return null;
    final scrollable = element.widget as Scrollable;
    final box = getElementRenderBox(element);
    if (box == null) return null;
    final location =
        getElementPoint(element, (size) => size.center(Offset.zero));
    if (location == null) return null;

    Offset halfOffset;
    final offsetFactor = random.nextDouble() * 0.2;
    switch (scrollable.axis) {
      case Axis.horizontal:
        halfOffset = Offset(box.size.width * offsetFactor, 0);
        break;
      case Axis.vertical:
        halfOffset = Offset(0, box.size.height * offsetFactor);
        break;
    }
    halfOffset = halfOffset * (random.nextBool() ? -1 : 1);

    return FlingFromEvent(
      location - halfOffset,
      halfOffset * 2,
    );
  }

  final Offset startLocation;
  final Offset offset;

  @override
  Future<void> injectEvent(WidgetController controller) async {
    await controller.flingFrom(
      startLocation,
      offset,
      offset.distance * 5,
    );
    await Future.delayed(const Duration(milliseconds: 200));
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
    return 'FlingFromEvent(startLocation: $startLocation, offset: $offset)';
  }
}
