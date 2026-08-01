import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';

class Line extends Shape {
  Vec2 p2;

  Line(Vec2 p1, this.p2) : super(p1);

  @pragma('vm:prefer-inline')
  Vec2 get p1 => position;

  double get left => min(p1.x, p2.x);
  double get top => min(p1.y, p2.y);
  double get right => max(p1.x, p2.x);
  double get bottom => max(p1.y, p2.y);

  @override
  Line clone() => Line(position.clone(), p2.clone());

  @override
  AABB get aabb => AABB(Vec2(left, top), width: right - left, height: bottom - top);

  @override
  void draw(Canvas canvas, Color color, [bool drawBoundingBox = false]) {
    Shape.paint.style = PaintingStyle.stroke;
    Shape.paint.color = color;
    canvas.drawLine(p1.offset(), p2.offset(), Shape.paint);
    if (drawBoundingBox) super.draw(canvas, const Color(0xFFFFFFFF));
  }
}
