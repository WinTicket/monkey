import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monkey/src/element.dart';
import 'package:monkey/src/monkey_event.dart';
import 'package:monkey/src/monkey_source.dart';
import 'package:monkey/src/monkey_source/monkey_source_random.dart';

class Monkey {
  Monkey._(WidgetsBinding binding)
      : _controller = LiveWidgetController(binding);

  static Monkey? _instance;
  static Monkey get instance => _instance ??= Monkey._(WidgetsBinding.instance);

  final LiveWidgetController _controller;
  final ValueNotifier<CustomPainter?> _painter = ValueNotifier(null);

  OverlayEntry? _overlayEntry;
  Timer? _timer;
  bool _running = false;

  void start({
    MonkeySource source = const MonkeySourceRandom(),
    Duration duration = const Duration(minutes: 1),
    Duration throttle = const Duration(milliseconds: 400),
  }) {
    if (_running) return;
    assert(duration > Duration.zero);
    assert(throttle > Duration.zero);
    _running = true;

    final navigator = rootNavigatorState(_controller.binding);
    final overlay = navigator.overlay!;
    final overlayEntry = _createOverlayEntry();
    _overlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    _timer = Timer(duration, stop);
    _run(source: source, throttle: throttle);
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _run({
    required MonkeySource source,
    required Duration throttle,
  }) async {
    while (_running) {
      await TestAsyncUtils.guard(() => Future<void>.delayed(throttle));
      final event = source.nextEvent(_controller.binding);
      _painter.value = _MonkeyEventPainter(event);
      await TestAsyncUtils.guard(() => event.injectEvent(_controller));
      _painter.value = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: _painter,
        builder: (context, painter, _) => CustomPaint(
          painter: painter,
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
          ),
        ),
      ),
    );
  }
}

class _MonkeyEventPainter extends CustomPainter {
  _MonkeyEventPainter(this.event);

  final MonkeyEvent event;

  @override
  void paint(Canvas canvas, Size size) {
    event.paintEvent(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
