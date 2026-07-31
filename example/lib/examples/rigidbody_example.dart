import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class RigidBodyExample extends ScreenController {
  final bodies = <RigidBody>[];
  final lines = <Line>[];
  late final FixedUpdate fixedUpdate;

  final mouse = Vec2.zero();

  @override
  void setup(BuildContext context, double width, double height) {
    fixedUpdate = FixedUpdate(60, onUpdate: updateRigidBodies);
    final center = Vec2(width * 0.5, height * 0.5);

    // Set lines
    lines.addAll([
      Line(Vec2(0, center.y), Vec2(center.x, 0)),
      Line(Vec2(center.x, 0), Vec2(width, center.y)),
      Line(Vec2(width, center.y), Vec2(center.x, height)),
      Line(Vec2(center.x, height), Vec2(0, center.y)),
    ]);

    // Spawn rigidbodies
    for (int i = 0; i < 30; i++) {
      final circle = Circle(center.clone(), radius: MathUtils.randDouble(10, 26));
      final velocity = Vec2(MathUtils.randDouble(-1, 1), MathUtils.randDouble(-1, 1));
      velocity.setMag(100);
      bodies.add(RigidBody(shape: circle, velocity: velocity));
    }

    // Movable body
    bodies[0].velocity.scale(0);
    bodies[0].elasticity = 0;
    bodies[0].mass = 5;

    // Static body
    (bodies[1].shape as Circle).radius = 50;
    bodies[1].velocity.scale(0);
    bodies[1].isStatic = true;
  }

  void updateRigidBodies(double fixedDeltaTime) {
    final bodyToMouse = mouse - bodies[0].shape.position;
    bodyToMouse.setMag(80);
    bodies[0].applyImpulse(bodyToMouse);

    for (final b in bodies) {
      b.update(fixedDeltaTime);
    }

    for (final body in bodies) {
      for (final line in lines) {
        CollisionResolver.circleToStaticLine(body, line);
      }
    }

    for (int i = 0; i < bodies.length; i++) {
      for (int j = i + 1; j < bodies.length; j++) {
        final b1 = bodies[i];
        final b2 = bodies[j];
        CollisionResolver.circleToCircle(b1, b2);
      }
    }
  }

  @override
  void update(double deltaTime) => fixedUpdate.update(deltaTime);

  Color getBodyColor(RigidBody body) {
    if (body == bodies[0]) return Colors.blue;
    if (body.isStatic) return Colors.red;
    return Colors.green;
  }

  @override
  void draw(Canvas canvas, Size size) {
    for (final b in bodies) {
      b.shape.draw(canvas, getBodyColor(b));
      b.velocity.draw(
        canvas,
        Colors.white,
        origin: b.shape.position.offset(),
        drawOrigin: true,
        drawArrowHead: true,
        scale: 0.2,
      );
    }

    for (final l in lines) {
      l.draw(canvas, Colors.white);
    }
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) =>
      mouse.set(mouseX, mouseY);

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) => mouse.set(mouseX, mouseY);

  @override
  void dispose() {}
}
