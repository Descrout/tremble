import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class Bouncer {
  final Color color;
  final Shape shape;
  final Vec2 velocity;

  Bouncer({
    required this.color,
    required this.shape,
    required this.velocity,
  });

  void update(double deltaTime, double width, double height) {
    shape.position.x += velocity.x * deltaTime;
    shape.position.y += velocity.y * deltaTime;

    if (shape is Circle) {
      final c = shape as Circle;
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
    } else if (shape is AABB) {
      final box = shape as AABB;
      if (box.position.x < 0) {
        box.position.x = 0;
        velocity.x = -velocity.x;
      } else if (box.position.x + box.width > width) {
        box.position.x = width - box.width;
        velocity.x = -velocity.x;
      }
      if (box.position.y < 0) {
        box.position.y = 0;
        velocity.y = -velocity.y;
      } else if (box.position.y + box.height > height) {
        box.position.y = height - box.height;
        velocity.y = -velocity.y;
      }
    }
  }

  void draw(Canvas canvas) {
    double ox = 0;
    double oy = 0;
    if (shape is AABB) {
      ox = (shape as AABB).width * 0.5;
      oy = (shape as AABB).height * 0.5;
    }
    shape.draw(canvas, color);
    velocity.draw(
      canvas,
      Colors.white,
      origin: shape.position.offset(dx: ox, dy: oy),
      drawOrigin: true,
      drawArrowHead: true,
      scale: 0.2,
    );
  }
}

class BouncingShapesExample extends ScreenController {
  final bouncers = <Bouncer>[];
  late double _width;
  late double _height;

  @override
  void setup(BuildContext context, double width, double height) {
    _width = width;
    _height = height;
    final center = Vec2(width * 0.5, height * 0.5);

    for (int i = 0; i < 20; i++) {
      final circle = Circle(center.clone(), radius: MathUtils.randDouble(16, 32));

      bouncers.add(Bouncer(
        color: ColorUtils.randomColor(ColorMood.pastel),
        shape: MathUtils.flipCoin() ? circle : circle.aabb,
        velocity: Vec2(MathUtils.randDouble(-1, 1), MathUtils.randDouble(-1, 1))..setMag(200),
      ));
    }
  }

  @override
  void resize(double width, double height) {
    _width = width;
    _height = height;
  }

  @override
  void update(double deltaTime) {
    for (final b in bouncers) {
      b.update(deltaTime, _width, _height);
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
