import 'dart:math';

import 'package:tremble/utils/vector2.dart';

class SecondOrderDynamics {
  late final double k1;
  late final double k2;
  late final double k3;

  Vector2 posPrev;
  Vector2 pos;
  Vector2 vel;

  SecondOrderDynamics(
    double f,
    double z,
    double r,
    Vector2 initial,
  )   : posPrev = initial.clone(),
        pos = initial.clone(),
        vel = Vector2.zero() {
    k1 = z / (pi * f);
    final double twopif = 2 * pi * f;
    k2 = 1 / (twopif * twopif);
    k3 = r * z / twopif;
  }

  Vector2 update(double dt, Vector2 to) {
    final Vector2 targetVel = (to - posPrev) / dt;

    posPrev.setFrom(to);

    // stability clamp
    final double k2Stable = max(k2, 1.1 * (dt * dt / 4 + dt * k1 / 2));

    // integrate position
    pos += vel * dt;

    // acceleration
    final Vector2 acc = (to + targetVel * k3 - pos - vel * k1);

    // integrate velocity
    vel += (acc * dt) / k2Stable;

    return pos;
  }

// =========================
// CAMERA PRESETS
// =========================

  factory SecondOrderDynamics.cameraSmooth(Vector2 initial) =>
      SecondOrderDynamics(2.5, 1.0, 1.0, initial);

  factory SecondOrderDynamics.cameraLively(Vector2 initial) =>
      SecondOrderDynamics(3.0, 0.8, 1.0, initial);

  factory SecondOrderDynamics.cameraCinematic(Vector2 initial) =>
      SecondOrderDynamics(1.5, 1.2, 0.8, initial);

// =========================
// CHARACTER / FOLLOW
// =========================

  factory SecondOrderDynamics.followSmooth(Vector2 initial) =>
      SecondOrderDynamics(3.5, 0.9, 1.2, initial);

  factory SecondOrderDynamics.followCartoon(Vector2 initial) =>
      SecondOrderDynamics(4.5, 0.6, 1.0, initial);

// =========================
// UI
// =========================

  factory SecondOrderDynamics.uiButton(Vector2 initial) =>
      SecondOrderDynamics(6.0, 0.7, 0.0, initial);

  factory SecondOrderDynamics.uiMenu(Vector2 initial) =>
      SecondOrderDynamics(4.0, 0.9, 0.0, initial);

  factory SecondOrderDynamics.uiNotification(Vector2 initial) =>
      SecondOrderDynamics(7.0, 0.5, 0.0, initial);

// =========================
// AIM / CROSSHAIR
// =========================

  factory SecondOrderDynamics.aimStable(Vector2 initial) =>
      SecondOrderDynamics(8.0, 1.0, 2.0, initial);

  factory SecondOrderDynamics.aimElastic(Vector2 initial) =>
      SecondOrderDynamics(7.0, 0.7, 1.5, initial);

// =========================
// IMPACT / RECOIL
// =========================

  factory SecondOrderDynamics.recoil(Vector2 initial) =>
      SecondOrderDynamics(10.0, 0.5, 0.0, initial);

  factory SecondOrderDynamics.cameraImpact(Vector2 initial) =>
      SecondOrderDynamics(6.0, 0.6, 0.0, initial);

// =========================
// SPRING / PHYSICS
// =========================

  factory SecondOrderDynamics.springLoose(Vector2 initial) =>
      SecondOrderDynamics(2.0, 0.3, 0.0, initial);

  factory SecondOrderDynamics.springStable(Vector2 initial) =>
      SecondOrderDynamics(3.0, 0.5, 0.0, initial);

// =========================
// UNIVERSAL DEFAULT
// =========================

  factory SecondOrderDynamics.defaultPreset(Vector2 initial) =>
      SecondOrderDynamics(3.5, 0.85, 1.0, initial);
}
