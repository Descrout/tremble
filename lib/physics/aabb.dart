import 'dart:math';
import 'dart:ui';

import 'package:tremble/tremble.dart';

class AABB extends Shape {
  double width;
  double height;

  AABB(
    super.position, {
    required this.width,
    required this.height,
  });

  double get left => position.x;
  double get top => position.y;
  double get right => position.x + width;
  double get bottom => position.y + height;

  Rect get rect => Rect.fromLTWH(position.x, position.y, width, height);

  @override
  AABB clone() => AABB(position.clone(), width: width, height: height);

  AABB inflated(double amount) {
    return AABB(
      Vec2(position.x - amount, position.y - amount),
      width: width + amount * 2,
      height: height + amount * 2,
    );
  }

  AABB deflated(double amount) {
    return AABB(
      Vec2(position.x + amount, position.y + amount),
      width: width - amount * 2,
      height: height - amount * 2,
    );
  }

  void inflate(double amount) {
    position.x -= amount;
    position.y -= amount;
    width += amount * 2;
    height += amount * 2;
  }

  void deflate(double amount) {
    position.x += amount;
    position.y += amount;
    width -= amount * 2;
    height -= amount * 2;
  }

  Circle get circle =>
      Circle(Vec2(x + width * 0.5, y + height * 0.5), radius: min(width, height) * 0.5);

  @override
  AABB get aabb => this;

  @override
  void draw(Canvas canvas, Color color, [bool drawBoundingBox = false]) {
    Shape.paint.style = PaintingStyle.fill;
    Shape.paint.color = color;
    canvas.drawRect(rect, Shape.paint);
    if (drawBoundingBox) super.draw(canvas, const Color(0xFFFFFFFF));
  }
}
