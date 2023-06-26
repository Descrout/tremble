import 'package:tremble/utils/types.dart';

class StateMachine {
  final enter = <String, VoidCallback>{};
  final exit = <String, VoidCallback>{};
  final updates = <String, UpdateCallback>{};

  String _state = "";
  String get state => _state;
  set state(String name) {
    exit[_state]?.call();
    _state = name;
    enter[_state]?.call();
  }

  void add({
    required String name,
    required VoidCallback onEnter,
    required UpdateCallback onUpdate,
    required VoidCallback onExit,
  }) {
    enter[name] = onEnter;
    updates[name] = onUpdate;
    exit[name] = onExit;
  }

  void update(dt) => updates[_state]?.call(dt);
}
