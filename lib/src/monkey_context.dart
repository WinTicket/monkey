import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'element.dart';
import 'random.dart';

abstract class MonkeyContext {
  Size get size;

  Element get rootElement;

  Iterable<Element> get allElements;

  Element? randomElement({bool Function(Element)? test});

  bool hitTestable(Element element, {Alignment alignment});
}

class MonkeyContextImpl extends MonkeyContext {
  MonkeyContextImpl(this._binding);

  final WidgetsBinding _binding;

  @override
  Size get size =>
      _binding.window.physicalSize / _binding.window.devicePixelRatio;

  @override
  Element get rootElement => _binding.renderViewElement!;

  @override
  Iterable<Element> get allElements =>
      CachingIterable(_DepthFirstChildIterator(rootElement));

  @override
  Element? randomElement({bool Function(Element element)? test}) {
    int i = 0;
    Element? target;
    for (final element in allElements) {
      if (test == null || test(element)) {
        i++;
        if (random.nextInt(i) == 0) {
          target = element;
        }
      }
    }
    return target;
  }

  @override
  bool hitTestable(
    Element element, {
    Alignment alignment = Alignment.center,
  }) {
    final box = getElementRenderBox(element);
    if (box == null) return false;
    final absoluteOffset = box.localToGlobal(alignment.alongSize(box.size));
    final hitResult = HitTestResult();
    _binding.hitTest(hitResult, absoluteOffset);
    for (final HitTestEntry entry in hitResult.path) {
      if (entry.target == element.renderObject) {
        return true;
      }
    }
    return false;
  }
}

class _DepthFirstChildIterator implements Iterator<Element> {
  _DepthFirstChildIterator(Element rootElement) {
    _fillChildren(rootElement);
  }

  late Element _current;

  final List<Element> _stack = <Element>[];

  @override
  Element get current => _current;

  @override
  bool moveNext() {
    if (_stack.isEmpty) {
      return false;
    }

    _current = _stack.removeLast();
    _fillChildren(_current);

    return true;
  }

  void _fillChildren(Element element) {
    element.debugVisitOnstageChildren(_stack.add);
  }
}
