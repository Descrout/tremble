import 'package:flutter/material.dart';
import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/vec2.dart';
import 'package:tremble/utils/math_utils.dart';
import 'package:tremble/utils/wait_events.dart';

class Camera {
  static int _idCounter = 0;
  final int id;

  static int? _lastCameraStarted;

  final _position = Vec2.zero();
  double _viewportWidth;
  double _viewportHeight;
  double _zoom;

  Camera({
    double zoom = 1,
    required double viewportWidth,
    required double viewportHeight,
  })  : assert(zoom != 0, "zoom cannot be 0"),
        assert(viewportWidth > 0, "viewportWidth cannot be 0 or lower"),
        assert(viewportHeight > 0, "viewportHeight cannot be 0 or lower"),
        _zoom = zoom,
        _viewportWidth = viewportWidth,
        _viewportHeight = viewportHeight,
        id = _idCounter++;

  AABB get aabb => AABB(_position, width: _viewportWidth / _zoom, height: _viewportHeight / _zoom);

  double get zoom => _zoom;
  set zoom(double value) {
    assert(value != 0, "zoom cannot be 0");
    final cx = centerX, cy = centerY;
    _zoom = value;
    centerX = cx;
    centerY = cy;
  }

  void setViewport(double viewportWidth, double viewportHeight) {
    assert(viewportWidth > 0, "viewportWidth cannot be 0 or lower");
    assert(viewportHeight > 0, "viewportHeight cannot be 0 or lower");
    final cx = centerX, cy = centerY;
    _viewportWidth = viewportWidth;
    _viewportHeight = viewportHeight;
    centerX = cx;
    centerY = cy;
  }

  double get x => _position.x;
  double get y => _position.y;
  set x(double value) => _position.x = value;
  set y(double value) => _position.y = value;

  double get centerX => _position.x + _viewportWidth / _zoom * 0.5;
  double get centerY => _position.y + _viewportHeight / _zoom * 0.5;
  set centerX(double value) => _position.x = value - _viewportWidth / _zoom * 0.5;
  set centerY(double value) => _position.y = value - _viewportHeight / _zoom * 0.5;

  void reset() {
    _zoom = 1;
    _position.set(0, 0);
  }

  void start(Canvas canvas) {
    if (_lastCameraStarted != null) {
      throw "Another camera already started, please stop that camera before starting this one";
    }
    canvas.save();
    canvas.scale(_zoom);
    canvas.translate(-_position.x, -_position.y);
    _lastCameraStarted = id;
  }

  void stop(Canvas canvas) {
    if (_lastCameraStarted != id) return;
    canvas.restore();
    _lastCameraStarted = null;
  }

  bool _shaking = false;
  void shake(
      {required WaitEvents wait, double time = 0.1, double amount = 2, bool slowlyHalt = false}) {
    if (_shaking) return;
    _shaking = true;
    final beforePos = _position.clone();
    wait.waitAndDo(
      time: time,
      onUpdate: (deltaTime, remaining) {
        final ratio = slowlyHalt ? (remaining / time) : 1;
        final amt = amount * ratio / _zoom;
        _position.x = beforePos.x + MathUtils.randDouble(-amt, amt);
        _position.y = beforePos.y + MathUtils.randDouble(-amt, amt);
      },
      onEnd: () {
        _position.setFrom(beforePos);
        _shaking = false;
      },
    );
  }
}
