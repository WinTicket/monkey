import 'package:flutter/foundation.dart';

class StopMonkeyKey extends LocalKey {
  const StopMonkeyKey([this.key]);

  final Key? key;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is StopMonkeyKey && other.key == key;
  }

  @override
  int get hashCode => Object.hash(runtimeType, key);

  @override
  String toString() => 'StopMonkeyKey(key: $key)';
}
