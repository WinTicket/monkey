import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../monkey_event.dart';
import '../monkey_event/fling_from_event.dart';
import '../monkey_event/pop_event.dart';
import '../monkey_event/tap_at_event.dart';
import '../monkey_source.dart';
import '../random.dart';

class MonkeySourceRandom extends MonkeySource {
  const MonkeySourceRandom({
    this.factorieWeights = defaultFactoryWeights,
  });

  static const defaultFactoryWeights = <MonkeyEventFactory, int>{
    TapAtEventFactory(): 15,
    FlingFromEventFactory(): 5,
    PopEventFactory(): 2,
  };

  final Map<MonkeyEventFactory, int> factorieWeights;

  @override
  MonkeyEvent nextEvent(WidgetsBinding binding) {
    MonkeyEvent? event;
    while (event == null) {
      TestAsyncUtils.guardSync();
      event = _randomFactory().create(binding);
    }
    return event;
  }

  MonkeyEventFactory _randomFactory() {
    final sumOfWeight = factorieWeights.values.fold(0, (prev, e) => prev + e);
    var rnd = random.nextInt(sumOfWeight);
    MonkeyEventFactory? eventFactory;
    for (final entry in factorieWeights.entries) {
      if (rnd < entry.value) {
        eventFactory = entry.key;
        break;
      }
      rnd -= entry.value;
    }
    return eventFactory!;
  }
}
