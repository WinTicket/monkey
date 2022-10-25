import 'package:flutter/widgets.dart';
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
    this.skipTest,
  });

  static const defaultFactoryWeights = <MonkeyEventFactory, int>{
    TapAtEvent.atRandomElement: 15,
    LongPressAtEvent.atRandomElement: 2,
    DragFromEvent.atRandomElement: 5,
    PopEvent.ofRootNavigator: 1,
    IdleEvent.create: 3,
  };

  final Map<MonkeyEventFactory, int> factoryWeights;
  final bool Function(Element element)? skipTest;

  @override
  MonkeyEvent nextEvent(MonkeyContext context) {
    MonkeyEvent? event;
    final contextWrapper = _MonkeySourceRandomContext(context, skipTest);
    while (event == null) {
      TestAsyncUtils.guardSync();
      event = _randomFactory()(contextWrapper);
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

class _MonkeySourceRandomContext extends MonkeyContextWrapper {
  _MonkeySourceRandomContext(super.context, this._skipTest);

  final bool Function(Element element)? _skipTest;

  @override
  Element? randomElement({bool Function(Element)? test}) {
    bool mergedTest(Element element) {
      return [test, _skipTest].every((t) => t == null || t(element));
    }
    return super.randomElement(test: mergedTest);
  }
}
