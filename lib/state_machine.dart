import 'package:tremble/utils/types.dart';

class StateMachine<T> {
  final enter = <T, VoidCallback>{};
  final exit = <T, VoidCallback>{};
  final updates = <T, UpdateCallback>{};

  T? _state;
  T? previousState;

  T? get state => _state;

  set state(T? name) {
    if (name == _state) return;
    previousState = _state;
    exit[_state]?.call();
    _state = name;
    enter[_state]?.call();
  }

  void resetState() {
    exit[_state]?.call();
    enter[_state]?.call();
  }

  void add(
    T name, {
    VoidCallback? onEnter,
    UpdateCallback? onUpdate,
    VoidCallback? onExit,
  }) {
    if (onEnter != null) enter[name] = onEnter;
    if (onUpdate != null) updates[name] = onUpdate;
    if (onExit != null) exit[name] = onExit;
  }

  void update(double dt) => updates[_state]?.call(dt);
}
