import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monkey/src/monkey_context.dart';
import 'package:monkey/src/random.dart';

import 'element.dart';
import 'monkey_controller.dart';

typedef MonkeyEventFactory = MonkeyEvent? Function(MonkeyContext context);

abstract class MonkeyEvent {
  void paintEvent(Canvas canvas);

  Future<void> injectEvent(MonkeyController controller);
}

class TapAtEvent extends MonkeyEvent {
  TapAtEvent(this.location);

  static TapAtEvent? atRandomElement(MonkeyContext context) {
    final element = context.randomElement(
      test: (e) =>
          e.widget is GestureDetector &&
          (e.widget as GestureDetector).onTap != null &&
          context.hitTestable(e),
    );
    if (element == null) return null;
    final location =
        getElementPoint(element, (size) => size.center(Offset.zero));
    if (location == null) return null;
    return TapAtEvent(location);
  }

  final Offset location;

  @override
  Future<void> injectEvent(MonkeyController controller) async {
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

class LongPressAtEvent extends MonkeyEvent {
  LongPressAtEvent(this.location);

  static LongPressAtEvent? atRandomElement(MonkeyContext context) {
    final element = context.randomElement(
      test: (e) =>
          e.widget is GestureDetector &&
          (e.widget as GestureDetector).onLongPress != null &&
          context.hitTestable(e),
    );
    if (element == null) return null;
    final location =
        getElementPoint(element, (size) => size.center(Offset.zero));
    if (location == null) return null;
    return LongPressAtEvent(location);
  }

  final Offset location;

  @override
  Future<void> injectEvent(MonkeyController controller) async {
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

class DragFromEvent extends MonkeyEvent {
  DragFromEvent(
    this.startLocation,
    this.offset,
    this.scrollable,
  );

  static DragFromEvent? atRandomElement(MonkeyContext context) {
    final element = context.randomElement(
      test: (e) {
        if (e.widget is! Scrollable) return false;
        final position =
            ((e as StatefulElement).state as ScrollableState).position;
        if (!position.hasContentDimensions ||
            (position.minScrollExtent == 0.0 &&
                position.maxScrollExtent == 0.0)) {
          return false;
        }
        return context.hitTestable(e);
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

    return DragFromEvent(
      location - halfOffset,
      halfOffset * 2,
      (element as StatefulElement).state as ScrollableState,
    );
  }

  final Offset startLocation;
  final Offset offset;
  final ScrollableState scrollable;

  @override
  Future<void> injectEvent(MonkeyController controller) async {
    await controller.dragFrom(
      startLocation,
      offset,
      const Duration(milliseconds: 100),
    );
    while (scrollable.position.isScrollingNotifier.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void paintEvent(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.purple
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
    return 'DragFromEvent(startLocation: $startLocation, offset: $offset)';
  }
}

class FlingFromEvent extends MonkeyEvent {
  FlingFromEvent(
    this.startLocation,
    this.offset,
  );

  static FlingFromEvent? atRandomElement(MonkeyContext context) {
    final element = context.randomElement(
      test: (e) {
        if (e.widget is! Scrollable) return false;
        final position =
            ((e as StatefulElement).state as ScrollableState).position;
        if (!position.hasContentDimensions ||
            (position.minScrollExtent == 0.0 &&
                position.maxScrollExtent == 0.0)) {
          return false;
        }
        return context.hitTestable(e);
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
  Future<void> injectEvent(MonkeyController controller) async {
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

class PopEvent extends MonkeyEvent {
  PopEvent(this.center, this.navigatorState);

  static PopEvent ofRootNavigator(MonkeyContext context) {
    final navigatorState = findRootNavigatorState(context.rootElement);
    return PopEvent(context.size.center(Offset.zero), navigatorState);
  }

  final Offset center;
  final NavigatorState navigatorState;

  @override
  Future<void> injectEvent(MonkeyController controller) async {
    if (navigatorState.canPop()) {
      await navigatorState.maybePop();
    }
  }

  @override
  void paintEvent(Canvas canvas) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Pop',
        style: TextStyle(
          fontSize: 32,
          color: Colors.white,
          backgroundColor: Colors.grey,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center.translate(
        -textPainter.width / 2,
        -textPainter.height / 2,
      ),
    );
  }

  @override
  String toString() {
    return 'PopEvent()';
  }
}
