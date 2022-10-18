import 'package:flutter/material.dart';

import 'monkey_event.dart';

abstract class MonkeySource {
  const MonkeySource();

  MonkeyEvent nextEvent(WidgetsBinding binding);
}
