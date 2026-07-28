import 'dart:math' as math;

import 'package:tremble/physics/vec2.dart';

class Spring1D {
  double value;
  double velocity;

  /// Larger = reaches target faster.
  final double stiffness;

  /// Larger = less oscillation.
  final double damping;

  Spring1D({
    required double initialValue,
    this.stiffness = 180.0,
    this.damping = 12.0,
  })  : value = initialValue,
        velocity = 0.0;

  Spring1D.critical({
    required double initialValue,
    this.stiffness = 180.0,
  })  : damping = 2 * math.sqrt(stiffness),
        value = initialValue,
        velocity = 0.0;

  double update(double dt, double target) {
    final double force = (target - value) * stiffness - velocity * damping;
    velocity += force * dt;
    value += velocity * dt;
    return value;
  }

  void snap(double newValue) {
    value = newValue;
    velocity = 0.0;
  }

  bool isSettled(double target, [double threshold = 0.001]) {
    return (value - target).abs() < threshold && velocity.abs() < threshold;
  }
}

class Spring2D {
  Vec2 pos;
  Vec2 velocity;

  /// Larger = reaches target faster.
  final double stiffness;

  /// Larger = less oscillation.
  final double damping;

  final Vec2 _force = Vec2.zero();

  Spring2D({
    required Vec2 initialPos,
    this.stiffness = 180.0,
    this.damping = 12.0,
  })  : pos = initialPos.clone(),
        velocity = Vec2.zero();

  Spring2D.critical({
    required Vec2 initialPos,
    this.stiffness = 180.0,
  })  : damping = 2 * math.sqrt(stiffness),
        pos = initialPos.clone(),
        velocity = Vec2.zero();

  Vec2 update(double dt, Vec2 target) {
    _force
      ..setFrom(target)
      ..sub(pos)
      ..scale(stiffness);

    _force.x -= velocity.x * damping;
    _force.y -= velocity.y * damping;

    velocity.x += _force.x * dt;
    velocity.y += _force.y * dt;

    pos.x += velocity.x * dt;
    pos.y += velocity.y * dt;

    return pos;
  }

  void snap(Vec2 newPos) {
    pos.setFrom(newPos);
    velocity.set(0, 0);
  }

  bool isSettled(Vec2 target, [double threshold = 0.001]) {
    return pos.distanceTo(target) < threshold && velocity.magnitude < threshold;
  }
}
