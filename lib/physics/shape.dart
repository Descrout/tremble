import 'dart:ui';

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/vec2.dart';

abstract class Shape {
  static final Paint paint = Paint();

  Vec2 position;
  Shape(this.position);

  double get x => position.x;
  double get y => position.y;

  AABB get aabb;

  void draw(Canvas canvas, Color color) {
    paint.style = PaintingStyle.stroke;
    paint.color = color;
    canvas.drawCircle(Offset(position.x, position.y), 8, paint);
    canvas.drawRect(aabb.rect, paint);
  }
}
