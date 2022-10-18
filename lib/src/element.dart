import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'random.dart';

Element? randomElement(
  WidgetsBinding binding, {
  bool Function(Element)? test,
  bool skipOffstage = true,
}) {
  final allElements = collectAllElementsFrom(
    binding.renderViewElement!,
    skipOffstage: skipOffstage,
  );
  int i = 0;
  Element? target;
  for (final element in allElements) {
    if (test?.call(element) == true) {
      if (random.nextInt(i + 1) == 0) {
        target = element;
        i++;
      }
    }
  }
  return target;
}

NavigatorState rootNavigatorState(WidgetsBinding binding) {
  final allElements = collectAllElementsFrom(
    binding.renderViewElement!,
    skipOffstage: false,
  );
  final element = allElements.firstWhere(
    (e) => e is StatefulElement && e.state is NavigatorState,
  );
  return (element as StatefulElement).state as NavigatorState;
}

RenderBox? getRenderBox(Element element) {
  final RenderObject? renderObject = element.renderObject;
  if (renderObject is! RenderBox) {
    return null;
  }
  return element.renderObject! as RenderBox;
}
