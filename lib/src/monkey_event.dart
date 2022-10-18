import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class MonkeyEventFactory<T extends MonkeyEvent> {
  const MonkeyEventFactory();

  T? create(WidgetsBinding binding);
}

abstract class MonkeyEvent {
  void paintEvent(Canvas canvas);

  Future<void> injectEvent(WidgetController controller);
}
