import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class BouncingBallsExample extends ScreenController {
  final bouncers = <Bouncer>[];

  @override
  void setup(BuildContext context, double width, double height) {
    final center = Vec2(width * 0.5, height * 0.5);

    for (int i = 0; i < 30; i++) {
      final circle = Circle(center.clone(), radius: MathUtils.randDouble(16, 32));
      final velocity = Vec2(MathUtils.randDouble(-1, 1), MathUtils.randDouble(-1, 1))..setMag(200);

      bouncers.add(Bouncer(
        color: ColorUtils.randomColor(ColorMood.pastel),
        circle: circle,
        velocity: velocity,
      ));
    }
  }

  @override
  void update(double deltaTime) {
    for (final b in bouncers) {
      b.update(deltaTime);
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    for (final b in bouncers) {
      b.draw(canvas);
    }
  }

  @override
  void dispose() {}
}

///// Bouncer Class
class Bouncer {
  final Color color;
  final Circle circle;
  final Vec2 velocity;

  Bouncer({
    required this.color,
    required this.circle,
    required this.velocity,
  });

  void update(double deltaTime) {
    circle.position.x += velocity.x * deltaTime;
    circle.position.y += velocity.y * deltaTime;

    constraints(800, 600);
  }

  void draw(Canvas canvas) {
    circle.draw(canvas, color);

    velocity.draw(
      canvas,
      Colors.white,
      origin: circle.position.offset(),
      drawOrigin: true,
      drawArrowHead: true,
      scale: 0.2,
    );
  }

  void constraints(double width, double height) {
    final c = circle;

    if (c.position.x - c.radius < 0) {
      c.position.x = c.radius;
      velocity.x = -velocity.x;
    } else if (c.position.x + c.radius > width) {
      c.position.x = width - c.radius;
      velocity.x = -velocity.x;
    }
    if (c.position.y - c.radius < 0) {
      c.position.y = c.radius;
      velocity.y = -velocity.y;
    } else if (c.position.y + c.radius > height) {
      c.position.y = height - c.radius;
      velocity.y = -velocity.y;
    }
  }
}
