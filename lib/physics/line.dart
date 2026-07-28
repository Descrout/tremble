import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';
import 'package:tremble/utils/extensions.dart';

class Line extends Shape {
  Vec2 p2;

  Line(super.position, this.p2);

  @pragma('vm:prefer-inline')
  Vec2 get p1 => position;

  double get left => min(p1.x, p2.x);
  double get top => min(p1.y, p2.y);
  double get right => max(p1.x, p2.x);
  double get bottom => max(p1.y, p2.y);

  @override
  AABB get aabb => AABB(Vec2(left, top), width: right - left, height: bottom - top);

  @override
  void draw(Canvas canvas, Color color) {
    Shape.paint.style = PaintingStyle.stroke;
    Shape.paint.color = color;
    canvas.drawLine(p1.offset(), p2.offset(), Shape.paint);
    super.draw(canvas, color.inverted);
  }
}
