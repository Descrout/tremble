import 'package:flutter/material.dart';
import 'package:tremble/vec2.dart';

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
}
