import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class MonkeyEvent {
  void paintEvent(Canvas canvas);

  Future<void> injectEvent(WidgetController controller);
}
