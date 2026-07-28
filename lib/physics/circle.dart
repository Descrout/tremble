import 'dart:ui';

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';
import 'package:tremble/utils/extensions.dart';

class Circle extends Shape {
  double radius;

  Circle(
    super.position, {
    required this.radius,
  });

  double get radSq => radius * radius;

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
  void draw(Canvas canvas, Color color, [bool drawBoundingBox = true]) {
    Shape.paint.style = PaintingStyle.fill;
    Shape.paint.color = color;
    canvas.drawCircle(Offset(position.x, position.y), radius, Shape.paint);
    if (drawBoundingBox) super.draw(canvas, color.inverted);
  }

  Circle copyWith({
    Vec2? position,
    double? radius,
  }) {
    return Circle(
      position ?? this.position,
      radius: radius ?? this.radius,
    );
  }
}
