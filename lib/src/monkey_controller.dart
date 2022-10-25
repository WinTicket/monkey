import 'package:flutter/animation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class MonkeyController {
  Future<void> tapAt(Offset location);

  Future<void> longPressAt(Offset location);

  Future<void> dragFrom(Offset startLocation, Offset offset, Duration duration);
}

class MonkeyControllerImpl extends MonkeyController {
  MonkeyControllerImpl(this._controller);

  final WidgetController _controller;

  int _pointer = 1;
  int get _nextPointer {
    final p = _pointer;
    _pointer++;
    return p;
  }

  @override
  Future<void> tapAt(Offset location) {
    return _controller.tapAt(location, pointer: _nextPointer);
  }

  @override
  Future<void> longPressAt(Offset location) {
    return _controller.longPressAt(location, pointer: _nextPointer);
  }

  @override
  Future<void> dragFrom(
      Offset startLocation, Offset offset, Duration duration) {
    final pointer = _nextPointer;
    const curve = Interval(0.0, 0.7, curve: Curves.easeInOut);

    final int intervals = duration.inMicroseconds * 60.0 ~/ 1E6;
    assert(intervals > 1);

    final List<Duration> timeStamps = <Duration>[
      for (int t = 0; t <= intervals; t += 1) duration * t ~/ intervals,
    ];
    final List<Offset> offsets = <Offset>[
      startLocation,
      for (int t = 0; t <= intervals; t += 1)
        startLocation + offset * curve.transform(t / intervals),
    ];
    final List<PointerEventRecord> records = <PointerEventRecord>[
      PointerEventRecord(Duration.zero, <PointerEvent>[
        PointerAddedEvent(
          position: startLocation,
        ),
        PointerDownEvent(
          position: startLocation,
          pointer: pointer,
        ),
      ]),
      ...<PointerEventRecord>[
        for (int t = 0; t <= intervals; t += 1)
          PointerEventRecord(timeStamps[t], <PointerEvent>[
            PointerMoveEvent(
              timeStamp: timeStamps[t],
              position: offsets[t + 1],
              delta: offsets[t + 1] - offsets[t],
              pointer: pointer,
            ),
          ]),
      ],
      PointerEventRecord(duration, <PointerEvent>[
        PointerUpEvent(
          timeStamp: duration,
          position: offsets.last,
          pointer: pointer,
          // The PointerData received from the engine with
          // change = PointerChange.up, which translates to PointerUpEvent,
          // doesn't provide the button field.
          // buttons: buttons,
        ),
      ]),
    ];
    return TestAsyncUtils.guard<void>(() async {
      await _controller.handlePointerEventRecord(records);
    });
  }
}
