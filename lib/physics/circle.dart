import 'dart:ui';

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';

class Circle extends Shape {
  double radius;

  Circle(
    super.position, {
    required this.radius,
  });

  double get radSq => radius * radius;

  @override
  Circle clone() => Circle(position.clone(), radius: radius);

  @override
  AABB get aabb => AABB(
        Vec2(
          position.x - radius,
          position.y - radius,
        ),
        width: radius * 2,
        height: radius * 2,
      );

  @override
  void draw(Canvas canvas, Color color, [bool drawBoundingBox = false]) {
    Shape.paint.style = PaintingStyle.fill;
    Shape.paint.color = color;
    canvas.drawCircle(Offset(position.x, position.y), radius, Shape.paint);
    if (drawBoundingBox) super.draw(canvas, const Color(0xFFFFFFFF));
  }
}
