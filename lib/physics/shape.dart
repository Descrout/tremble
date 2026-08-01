import 'dart:ui';

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/vec2.dart';

abstract class Shape {
  static final Paint paint = Paint();

  Vec2 position;
  Shape(this.position);

  Shape clone();

  double get x => position.x;
  double get y => position.y;

  AABB get aabb;

  void draw(Canvas canvas, Color color, [bool drawBoundingBox = true]) {
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(aabb.rect, paint);
  }
}
