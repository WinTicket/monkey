import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../element.dart';
import '../monkey_event.dart';

class PopEvent extends MonkeyEvent {
  PopEvent(this.navigatorState);

  static PopEvent fromBinding(WidgetsBinding binding) {
    final navigatorState = rootNavigatorState(binding.renderViewElement!);
    return PopEvent(navigatorState);
  }

  final NavigatorState navigatorState;

  @override
  Future<void> injectEvent(WidgetController controller) async {
    if (navigatorState.canPop()) {
      await navigatorState.maybePop();
    }
  }

  @override
  void paintEvent(Canvas canvas) {}

  @override
  String toString() {
    return 'PopEvent()';
  }
}
