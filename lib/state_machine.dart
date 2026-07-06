import 'dart:ui';

import 'package:tremble/utils/types.dart';

class StateMachine<T> {
  final _enters = <T, VoidCallback>{};
  final _exits = <T, VoidCallback>{};
  final _updates = <T, UpdateCallback>{};
  final _draws = <T, Function(Canvas canvas, Size size)>{};

  StateChangeCallback<T>? onBeforeStateChange;
  StateChangeCallback<T>? onAfterStateChange;

  T? _state;
  T? previousState;

  StateMachine([T? initial]) : _state = initial;

  T? get value => _state;
  set value(T? name) {
    if (name == _state) return;
    previousState = _state;
    _state = name;
    onBeforeStateChange?.call(previousState, _state);
    _exits[previousState]?.call();
    _enters[_state]?.call();
    onAfterStateChange?.call(previousState, _state);
  }

  void restart({bool triggerStateChange = false}) {
    if (triggerStateChange) onBeforeStateChange?.call(_state, _state);
    _exits[_state]?.call();
    _enters[_state]?.call();
    if (triggerStateChange) onAfterStateChange?.call(_state, _state);
  }

  void reset([T? state]) {
    _state = state;
    previousState = null;
  }

  void clear([T? state]) {
    reset(state);
    _enters.clear();
    _exits.clear();
    _updates.clear();
    _draws.clear();
  }

  void register(
    T name, {
    VoidCallback? onEnter,
    UpdateCallback? onUpdate,
    Function(Canvas canvas, Size size)? onDraw,
    VoidCallback? onExit,
  }) {
    if (onEnter != null) _enters[name] = onEnter;
    if (onUpdate != null) _updates[name] = onUpdate;
    if (onDraw != null) _draws[name] = onDraw;
    if (onExit != null) _exits[name] = onExit;
  }

  void update(double deltaTime) => _updates[_state]?.call(deltaTime);
  void draw(Canvas canvas, Size size) => _draws[_state]?.call(canvas, size);
}
