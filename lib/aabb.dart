import 'dart:ui';

import 'package:tremble/vec2.dart';

class AABB {
  Vec2 position;
  double width;
  double height;

  AABB({
    required this.position,
    required this.width,
    required this.height,
  });

  double get x => position.x;
  double get y => position.y;

  double get left => position.x;
  double get top => position.y;
  double get right => position.x + width;
  double get bottom => position.y + height;
  Rect get rect => Rect.fromLTWH(position.x, position.y, width, height);

  AABB copyWith({
    Vec2? position,
    double? width,
    double? height,
  }) {
    return AABB(
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  AABB inflated(double amount) {
    return AABB(
      position: Vec2(position.x - amount, position.y - amount),
      width: width + amount * 2,
      height: height + amount * 2,
    );
  }

  AABB deflated(double amount) {
    return AABB(
      position: Vec2(position.x + amount, position.y + amount),
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
}
