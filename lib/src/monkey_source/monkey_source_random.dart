import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monkey/src/monkey_event/drag_from_event.dart';
import 'package:monkey/src/monkey_event/long_press_at_event.dart';

import '../monkey_event.dart';
import '../monkey_event/fling_from_event.dart';
import '../monkey_event/pop_event.dart';
import '../monkey_event/tap_at_event.dart';
import '../monkey_source.dart';
import '../random.dart';

typedef RandomMonkeyEventFactory = MonkeyEvent? Function(
  WidgetsBinding binding,
);

class MonkeySourceRandom extends MonkeySource {
  const MonkeySourceRandom({
    this.factoryWeights = defaultFactoryWeights,
  });

  static const defaultFactoryWeights = <RandomMonkeyEventFactory, int>{
    TapAtEvent.atRandomElement: 15,
    LongPressAtEvent.atRandomElement: 2,
    DragFromEvent.atRandomElement: 5,
    FlingFromEvent.atRandomElement: 2,
    PopEvent.ofRootNavigator: 1,
  };

  final Map<RandomMonkeyEventFactory, int> factoryWeights;

  @override
  MonkeyEvent nextEvent(WidgetsBinding binding) {
    MonkeyEvent? event;
    while (event == null) {
      TestAsyncUtils.guardSync();
      event = _randomFactory()(binding);
    }
    return event;
  }

  RandomMonkeyEventFactory _randomFactory() {
    final sumOfWeight = factoryWeights.values.fold(0, (prev, e) {
      if (e < 0) throw StateError('Weight cannot less than 0.');
      return prev + e;
    });
    if (sumOfWeight <= 0) {
      throw StateError('Sum of weight must bigger than 0.');
    }
    var rnd = random.nextInt(sumOfWeight);
    RandomMonkeyEventFactory? eventFactory;
    for (final entry in factoryWeights.entries) {
      if (rnd < entry.value) {
        eventFactory = entry.key;
        break;
      }
      rnd -= entry.value;
    }
    return eventFactory!;
  }
}
