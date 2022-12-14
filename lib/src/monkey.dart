import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'element.dart';
import 'monkey_controller.dart';
import 'monkey_event.dart';
import 'monkey_source.dart';
import 'monkey_context.dart';

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
  bool get running => _running;

  static const paintThrottle = Duration(milliseconds: 200);

  Future<void> start({
    MonkeySource source = const MonkeySourceRandom(),
    Duration duration = const Duration(minutes: 1),
    Duration throttle = const Duration(milliseconds: 200),
    bool verbose = false,
  }) async {
    if (_running) return;
    if (duration <= Duration.zero) {
      throw StateError('Duration must be bigger than ${Duration.zero}.');
    }
    if (throttle <= Duration.zero) {
      throw StateError('Throttle must be bigger than ${Duration.zero}.');
    }

    _running = true;

    final navigator =
        findRootNavigatorState(_controller.binding.renderViewElement!);
    final overlay = navigator.overlay!;
    final overlayEntry = _createOverlayEntry();
    _overlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    _timer = Timer(duration, stop);

    final monkeyContext = MonkeyContextImpl(_controller.binding);
    final monkeyController = MonkeyControllerImpl(_controller);

    while (_running) {
      try {
        final event = source.nextEvent(monkeyContext);
        if (verbose) {
          debugPrint(event.toString());
        }
        _painter.value = _MonkeyEventPainter(event);
        await Future.microtask(() => event.injectEvent(monkeyController));
        await _controller.pump(throttle);
        _painter.value = null;
        await _controller.pump(paintThrottle);
      } catch (_) {
        stop();
        rethrow;
      }
    }
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: _painter,
        builder: (context, CustomPainter? painter, _) => CustomPaint(
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
