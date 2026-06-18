import 'dart:math';

import 'package:tremble/aabb.dart';
import 'package:tremble/vec2.dart';

class Line {
  Vec2 p1;
  Vec2 p2;

  Line({
    required this.p1,
    required this.p2,
  });

  double get left => min(p1.x, p2.x);
  double get top => min(p1.y, p2.y);
  double get right => max(p1.x, p2.x);
  double get bottom => max(p1.y, p2.y);

  AABB get aabb => AABB(position: Vec2(left, top), width: right - left, height: bottom - top);
}
