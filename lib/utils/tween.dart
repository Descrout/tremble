import 'package:tremble/utils/parametrics.dart';

enum TweenState { forwarding, backwarding, halt }

class Tween {
  final double from;
  final double to;

  double t;
  double get value => from + (to - from) * parametric(t);
  bool get isTweening => _state != TweenState.halt;

  ParametricFunc parametric;
  double _speed;
  TweenState _state = TweenState.halt;

  Tween(this.from, this.to,
      {double time = 1, double startFrom = 0, ParametricFunc curve = Parametrics.linear})
      : t = startFrom,
        parametric = curve,
        _speed = 1 / time;

  TweenState? get lastDirection {
    if (_state != TweenState.halt) return null;
    if (t > 0.5) return TweenState.forwarding;
    return TweenState.backwarding;
  }

  void changeTime(double time) => _speed = 1 / time;

  void forward({double startFrom = 0}) {
    t = startFrom;
    _state = TweenState.forwarding;
  }

  void backward({double startFrom = 1}) {
    t = startFrom;
    _state = TweenState.backwarding;
  }

  void stop({double? stopAt}) {
    if (_state == TweenState.halt) return;
    _state = TweenState.halt;
    if (stopAt != null) {
      t = stopAt;
    } else if (_state == TweenState.forwarding) {
      t = 1;
    } else if (_state == TweenState.backwarding) {
      t = 0;
    }
  }

  void update(double deltaTime) {
    switch (_state) {
      case TweenState.forwarding:
        t += deltaTime * _speed;
        if (t > 1) stop();
        break;
      case TweenState.backwarding:
        t -= deltaTime * _speed;
        if (t < 0) stop();
        break;
      default:
    }
  }
}
