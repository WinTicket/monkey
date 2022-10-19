import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'random.dart';

Element? randomElement(
  Element rootElement, {
  bool Function(Element)? test,
  bool skipOffstage = true,
}) {
  final allElements = collectAllElementsFrom(
    rootElement,
    skipOffstage: skipOffstage,
  );
  int i = 0;
  Element? target;
  for (final element in allElements) {
    if (test?.call(element) == true) {
      i++;
      if (random.nextInt(i) == 0) {
        target = element;
      }
    }
  }
  return target;
}

NavigatorState rootNavigatorState(Element rootElement) {
  final allElements = collectAllElementsFrom(
    rootElement,
    skipOffstage: true,
  );
  final element = allElements.firstWhere(
    (e) => e is StatefulElement && e.state is NavigatorState,
  );
  return (element as StatefulElement).state as NavigatorState;
}

Offset? getElementPoint(Element element, Offset Function(Size) sizeToPoint) {
  final renderBox = getElementRenderBox(element);
  if (renderBox == null) return null;
  return renderBox.localToGlobal(sizeToPoint(renderBox.size));
}

RenderBox? getElementRenderBox(Element element) {
  final RenderObject? renderObject = element.renderObject;
  if (renderObject is! RenderBox) {
    return null;
  }
  return element.renderObject! as RenderBox;
}

bool isElementHitTestable(
  Element element,
  WidgetsBinding binding, {
  Alignment alignment = Alignment.center,
}) {
  final box = getElementRenderBox(element);
  if (box == null) return false;
  final absoluteOffset = box.localToGlobal(alignment.alongSize(box.size));
  final hitResult = HitTestResult();
  binding.hitTest(hitResult, absoluteOffset);
  for (final HitTestEntry entry in hitResult.path) {
    if (entry.target == element.renderObject) {
      return true;
    }
  }
  return false;
}
