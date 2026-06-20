import 'package:flutter/material.dart';
import 'package:tremble/utils/math_utils.dart';
import 'package:tremble/vec2.dart';
import 'package:tremble/wait_events.dart';

class Camera {
  static int _idCounter = 0;
  final int id;

  static int? _lastCameraStarted;

  Vec2 position;
  double zoom;

  Camera({
    this.zoom = 1,
    double x = 0,
    double y = 0,
  })  : position = Vec2(x, y),
        id = _idCounter++;

  void reset() {
    position.set(0, 0);
    zoom = 1;
  }

  void start(Canvas canvas) {
    if (_lastCameraStarted != null) {
      throw "Another camera already started, please stop that camera before starting this one";
    }
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.scale(zoom);
    _lastCameraStarted = id;
  }

  void stop(Canvas canvas) {
    if (_lastCameraStarted == null) return;
    canvas.restore();
    _lastCameraStarted = null;
  }

  void shake(
      {required WaitEvents wait, double time = 0.1, double amount = 8, bool slowlyHalt = false}) {
    wait.waitAndDo(
      time: time,
      onUpdate: (deltaTime, remaining) {
        final ratio = slowlyHalt ? (remaining / time) : 1;
        final amt = amount * ratio;
        final dx = MathUtils.randDouble(-amt, amt);
        final dy = MathUtils.randDouble(-amt, amt);
        position.set(dx, dy);
      },
      onEnd: () => reset(),
    );
  }
}
