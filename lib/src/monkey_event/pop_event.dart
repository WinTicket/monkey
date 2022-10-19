import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../element.dart';
import '../monkey_event.dart';

class PopEvent extends MonkeyEvent {
  PopEvent(this.center, this.navigatorState);

  static PopEvent fromBinding(WidgetsBinding binding) {
    final navigatorState = findRootNavigatorState(binding.renderViewElement!);
    final size = binding.window.physicalSize / binding.window.devicePixelRatio;
    return PopEvent(size.center(Offset.zero), navigatorState);
  }

  final Offset center;
  final NavigatorState navigatorState;

  @override
  Future<void> injectEvent(WidgetController controller) async {
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
