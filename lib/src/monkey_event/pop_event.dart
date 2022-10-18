import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../element.dart';
import '../monkey_event.dart';

class PopEventFactory extends MonkeyEventFactory<PopEvent> {
  const PopEventFactory();

  @override
  PopEvent? create(WidgetsBinding binding) {
    final navigatorState = rootNavigatorState(binding);
    return PopEvent(navigatorState);
  }
}

class PopEvent extends MonkeyEvent {
  PopEvent(this.navigatorState);

  final NavigatorState navigatorState;

  @override
  Future<void> injectEvent(WidgetController controller) async {
    if (navigatorState.canPop()) {
      await navigatorState.maybePop();
    }
  }

  @override
  void paintEvent(Canvas canvas) {}
}
