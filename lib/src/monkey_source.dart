import 'package:flutter_test/flutter_test.dart';
import 'package:monkey/src/monkey_context.dart';

import 'monkey_event.dart';
import 'random.dart';

abstract class MonkeySource {
  const MonkeySource();

  MonkeyEvent nextEvent(MonkeyContext context);
}

class MonkeySourceRandom extends MonkeySource {
  const MonkeySourceRandom({
    this.factoryWeights = defaultFactoryWeights,
  });

  static const defaultFactoryWeights = <MonkeyEventFactory, int>{
    TapAtEvent.atRandomElement: 15,
    LongPressAtEvent.atRandomElement: 2,
    DragFromEvent.atRandomElement: 5,
    PopEvent.ofRootNavigator: 1,
  };

  final Map<MonkeyEventFactory, int> factoryWeights;

  @override
  MonkeyEvent nextEvent(MonkeyContext context) {
    MonkeyEvent? event;
    while (event == null) {
      TestAsyncUtils.guardSync();
      event = _randomFactory()(context);
    }
    return event;
  }

  MonkeyEventFactory _randomFactory() {
    final sumOfWeight = factoryWeights.values.fold(0, (prev, e) {
      if (e < 0) throw StateError('Weight cannot less than 0.');
      return prev + e;
    });
    if (sumOfWeight <= 0) {
      throw StateError('Sum of weight must bigger than 0.');
    }
    var rnd = random.nextInt(sumOfWeight);
    MonkeyEventFactory? eventFactory;
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
