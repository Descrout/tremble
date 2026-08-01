import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';

class Ray {
  Vec2 origin;
  Vec2 direction;

  Ray({
    required this.origin,
    required Vec2 direction,
  }) : direction = direction.normalized();

  Vec2 pointAt(double distance) {
    return Vec2(
      origin.x + direction.x * distance,
      origin.y + direction.y * distance,
    );
  }

  void draw(Canvas canvas, Color color, double length, {bool drawArrowHead = true}) {
    Shape.paint.color = color;

    final o = origin.offset();
    final tip = pointAt(length);
    final t = tip.offset();

    Shape.paint.style = PaintingStyle.fill;
    canvas.drawCircle(o, 4, Shape.paint);

    Shape.paint.style = PaintingStyle.stroke;
    canvas.drawLine(o, t, Shape.paint);

    if (drawArrowHead) {
      const arrowLen = 12.0;
      const arrowAngle = 0.45;
      final dx = -direction.x * arrowLen;
      final dy = -direction.y * arrowLen;
      final ca = cos(arrowAngle);
      final sa = sin(arrowAngle);

      canvas.drawLine(t, Offset(tip.x + dx * ca - dy * sa, tip.y + dy * ca + dx * sa), Shape.paint);
      canvas.drawLine(t, Offset(tip.x + dx * ca + dy * sa, tip.y + dy * ca - dx * sa), Shape.paint);
    }
  }
}
