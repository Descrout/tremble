import 'dart:math';

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/circle.dart';
import 'package:tremble/physics/line.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';

abstract final class CollisionDetector {
  static bool shapeToShape(Shape a, Shape b) {
    return switch ((a, b)) {
      (AABB aabbA, AABB aabbB) => rectToRect(aabbA, aabbB),
      (Circle circleA, Circle circleB) => circleToCircle(circleA, circleB),
      (AABB aabb, Circle circle) => circleToRect(circle, aabb),
      (Circle circle, AABB aabb) => circleToRect(circle, aabb),
      (Line lineA, Line lineB) => lineToLine(lineA, lineB),
      (Line line, AABB rect) => lineToRect(line, rect),
      (Line line, Circle circle) => lineToCircle(line, circle),
      (AABB rect, Line line) => lineToRect(line, rect),
      (Circle circle, Line line) => lineToCircle(line, circle),
      _ => throw UnimplementedError(
          '${a.runtimeType} and ${b.runtimeType} is not defined for CollisionDetector.',
        ),
    };
  }

  static bool circleToCircle(Circle a, Circle b) {
    final dist = a.position - b.position;
    final sumRadius = a.radius + b.radius;
    return sumRadius * sumRadius >= dist.magnitudeSquared;
  }

  static bool rectToRect(AABB a, AABB b) =>
      a.right >= b.left && a.left <= b.right && a.bottom >= b.top && a.top <= b.bottom;

  static bool pointToCircle(Vec2 p, Circle b) {
    final dist = p - b.position;
    return b.radSq >= dist.magnitudeSquared;
  }

  static bool circleToRect(Circle circle, AABB rect, {Vec2? out}) {
    final closest = Vec2(
      circle.x.clamp(rect.left, rect.right),
      circle.y.clamp(rect.top, rect.bottom),
    );

    final dx = circle.x - closest.x;
    final dy = circle.y - closest.y;
    final magSq = dx * dx + dy * dy;

    double diff = circle.radSq - magSq;
    if (diff <= 0) return false;

    if (out != null) {
      final mag = sqrt(magSq);
      if (mag == 0) return true;
      diff = circle.radius - mag;
      out.x = (dx / mag) * diff;
      out.y = (dy / mag) * diff;
    }

    return true;
  }

  static bool pointToRect(Vec2 p, AABB rect) =>
      p.x >= rect.left && p.x <= rect.right && p.y >= rect.top && p.y <= rect.bottom;

  static bool pointToLine(Vec2 p, Line line, [double tolerance = 0.1]) {
    if (p.x < line.left - tolerance ||
        p.x > line.right + tolerance ||
        p.y < line.top - tolerance ||
        p.y > line.bottom + tolerance) {
      return false;
    }

    final d1 = p.distanceTo(line.p1);
    final d2 = p.distanceTo(line.p2);
    final lineLen = line.p1.distanceTo(line.p2);

    return (d1 + d2 - lineLen).abs() <= tolerance;
  }

  static bool lineToLine(Line a, Line b) {
    final d1 = a.p2 - a.p1;
    final d2 = b.p2 - b.p1;

    final denom = d1.cross(d2);

    if (denom == 0) {
      return pointToLine(b.p1, a) || pointToLine(b.p2, a);
    }

    final diff = b.p1 - a.p1;
    final t = diff.cross(d2) / denom;
    final u = diff.cross(d1) / denom;

    return t >= 0 && t <= 1 && u >= 0 && u <= 1;
  }

  static bool lineToRect(Line line, AABB rect) {
    if (pointToRect(line.p1, rect) || pointToRect(line.p2, rect)) return true;

    final top = Line(Vec2(rect.left, rect.top), Vec2(rect.right, rect.top));
    final bottom = Line(Vec2(rect.left, rect.bottom), Vec2(rect.right, rect.bottom));
    final left = Line(Vec2(rect.left, rect.top), Vec2(rect.left, rect.bottom));
    final right = Line(Vec2(rect.right, rect.top), Vec2(rect.right, rect.bottom));

    return lineToLine(line, top) ||
        lineToLine(line, bottom) ||
        lineToLine(line, left) ||
        lineToLine(line, right);
  }

  static bool lineToCircle(Line line, Circle circle) {
    //if (pointToCircle(line.p1, circle) || pointToCircle(line.p2, circle)) return true;

    final lineVec = line.p2 - line.p1;
    final toCircle = circle.position - line.p1;

    final t = (toCircle.dot(lineVec) / lineVec.magnitudeSquared).clamp(0.0, 1.0);

    final closest = line.p1 + lineVec * t;
    return pointToCircle(closest, circle);
  }
}
