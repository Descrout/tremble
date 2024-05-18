import 'package:tremble/utils/types.dart';

class StateMachine {
  final enter = <String, VoidCallback>{};
  final exit = <String, VoidCallback>{};
  final updates = <String, UpdateCallback>{};

  String _state = "";
  String previousState = "";

  String get state => _state;
  set state(String name) {
    previousState = _state;
    exit[_state]?.call();
    _state = name;
    enter[_state]?.call();
  }

  void add(
    String name, {
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
