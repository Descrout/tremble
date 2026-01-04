import 'package:tremble/utils/types.dart';
import 'package:tremble/wait_chain_builder.dart';

class WaitEvents {
  final _updates = <UpdateSubscriptionCallback>[];

  bool get hasEvent => _updates.isNotEmpty;
  int get length => _updates.length;

  bool _clearRequest = false;
  void clear() {
    _clearRequest = true;
    _updates.clear();
  }

  WaitChainBuilder chain() => WaitChainBuilder(this);

  void wait({
    required double time,
    required VoidCallback onEnd,
  }) {
    tempCallback(double deltaTime) {
      time -= deltaTime;
      if (time < 0) {
        onEnd();
        return false;
      }
      return true;
    }

    _updates.add(tempCallback);
  }

  void periodic({
    required double time,
    required PeriodicCallback onTick,
    VoidCallback? onEnd,
  }) {
    int phase = 0;
    double currentTime = 0;
    tempCallback(double deltaTime) {
      currentTime += deltaTime;
      if (currentTime >= time) {
        final result = onTick(phase);
        if (result) {
          currentTime = 0;
          phase++;
          return true;
        }

        onEnd?.call();
        return false;
      }
      return true;
    }

    _updates.add(tempCallback);
  }

  void waitUntil({
    required UpdateSubscriptionCallback onUpdate,
    VoidCallback? onEnd,
  }) {
    tempCallback(double deltaTime) {
      if (onUpdate(deltaTime) != true) {
        onEnd?.call();
        return false;
      }
      return true;
    }

    _updates.add(tempCallback);
  }

  void waitAndDo({
    required double time,
    required TimeUpdateCallback onUpdate,
    VoidCallback? onEnd,
  }) {
    tempCallback(double deltaTime) {
      time -= deltaTime;
      if (time < 0) {
        onUpdate(deltaTime, 0);
        onEnd?.call();
        return false;
      }
      onUpdate(deltaTime, time);
      return true;
    }

    _updates.add(tempCallback);
  }

  void update(double dt) {
    if (_clearRequest) {
      _clearRequest = false;
    }

    for (int i = _updates.length - 1; i >= 0; i--) {
      final result = _updates[i](dt);
      if (_clearRequest) {
        _clearRequest = false;
        return;
      }
      if (!result) _updates.removeAt(i);
    }
  }
}
