import 'package:tremble/types.dart';

class ChainState {
  final double time;
  final TimeUpdateCallback? onUpdate;
  final VoidCallback onEnd;

  ChainState({
    required this.time,
    required this.onEnd,
    this.onUpdate,
  });
}

class WaitEvents {
  final _updates = <UpdateSubscriptionCallback>[];

  bool get hasEvent => _updates.isNotEmpty;
  int get length => _updates.length;

  clear() => _updates.clear();

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

  void waitUntil({
    required UpdateSubscriptionCallback onUpdate,
    required VoidCallback onEnd,
  }) {
    tempCallback(double deltaTime) {
      if (onUpdate(deltaTime) != true) {
        onEnd.call();
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
        onEnd?.call();
        return false;
      }
      onUpdate(deltaTime, time);
      return true;
    }

    _updates.add(tempCallback);
  }

  void chain(List<ChainState> states) {
    double time = 0;
    for (int i = 0; i < states.length; i++) {
      final state = states[i];
      time += state.time;
      if (state.onUpdate != null) {
        waitAndDo(time: time, onUpdate: state.onUpdate!, onEnd: state.onEnd);
      } else {
        wait(time: time, onEnd: state.onEnd);
      }
    }
  }

  void update(dt) {
    for (int i = _updates.length - 1; i >= 0; i--) {
      if (_updates[i](dt) != true) _updates.removeAt(i);
    }
  }
}
