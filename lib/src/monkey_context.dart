import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'element.dart';
import 'key.dart';
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

class MonkeyContextWrapper extends MonkeyContext {
  MonkeyContextWrapper(this._context);

  final MonkeyContext _context;

  @override
  Size get size => _context.size;

  @override
  Element get rootElement => _context.rootElement;

  @override
  Iterable<Element> get allElements => _context.allElements;

  @override
  bool hitTestable(Element element, {Alignment alignment = Alignment.center}) {
    return _context.hitTestable(element, alignment: alignment);
  }

  @override
  Element? randomElement({bool Function(Element p1)? test}) {
    return _context.randomElement(test: test);
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
    while (_stack.isNotEmpty) {
      final element = _stack.removeLast();
      if (element.widget.key is StopMonkeyKey) {
        continue;
      }

      _current = element;
      _fillChildren(_current);
      return true;
    }

    return false;
  }

  void _fillChildren(Element element) {
    element.debugVisitOnstageChildren(_stack.add);
  }
}
