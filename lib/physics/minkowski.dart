import 'dart:math' as math;

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/circle.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';

abstract final class Minkowski {
  static Shape difference(Shape a, Shape b) {
    return switch ((a, b)) {
      (AABB aabbA, AABB aabbB) => differenceAABB(aabbA, aabbB),
      (Circle circleA, Circle circleB) => differenceCircle(circleA, circleB),
      (AABB aabb, Circle circle) => differenceAABBAndCircle(aabb, circle),
      (Circle circle, AABB aabb) => differenceCircleAndAABB(circle, aabb),
      _ => throw UnimplementedError(
          '${a.runtimeType} and ${b.runtimeType} is not defined for Minkowski.',
        ),
    };
  }

  static AABB differenceAABB(AABB a, AABB b) {
    return AABB(
      Vec2(a.position.x - b.right, a.position.y - b.bottom),
      width: a.width + b.width,
      height: a.height + b.height,
    );
  }

  static Circle differenceCircle(Circle a, Circle b) {
    return Circle(
      Vec2(a.position.x - b.position.x, a.position.y - b.position.y),
      radius: a.radius + b.radius,
    );
  }

  static AABB differenceAABBAndCircle(AABB a, Circle b) {
    final circleRight = b.position.x + b.radius;
    final circleBottom = b.position.y + b.radius;

    return AABB(
      Vec2(a.position.x - circleRight, a.position.y - circleBottom),
      width: a.width + (b.radius * 2),
      height: a.height + (b.radius * 2),
    );
  }

  static AABB differenceCircleAndAABB(Circle a, AABB b) {
    final circleLeft = a.position.x - a.radius;
    final circleTop = a.position.y - a.radius;

    return AABB(
      Vec2(circleLeft - b.right, circleTop - b.bottom),
      width: (a.radius * 2) + b.width,
      height: (a.radius * 2) + b.height,
    );
  }

  static bool containsOriginAABB(AABB aabb) =>
      aabb.left <= 0 && aabb.right >= 0 && aabb.top <= 0 && aabb.bottom >= 0;

  static bool containsOriginCircle(Circle circle) =>
      (circle.position.x * circle.position.x + circle.position.y * circle.position.y) <=
      (circle.radius * circle.radius);

  static bool containsOrigin(Shape shape) {
    return switch (shape) {
      AABB aabb => containsOriginAABB(aabb),
      Circle circle => containsOriginCircle(circle),
      _ => throw UnimplementedError('Unsupported shape type'),
    };
  }

  static Vec2? getPenetration(Shape shape) {
    return switch (shape) {
      AABB aabb => getPenetrationAABB(aabb),
      Circle circle => getPenetrationCircle(circle),
      _ => throw UnimplementedError('Unsupported shape type'),
    };
  }

  static Vec2? getPenetrationAABB(AABB aabb) {
    if (!containsOriginAABB(aabb)) {
      return null;
    }

    final overlapLeft = -aabb.left;
    final overlapRight = aabb.right;
    final overlapTop = -aabb.top;
    final overlapBottom = aabb.bottom;

    double minOverlap = overlapLeft;
    Vec2 penetration = Vec2(overlapLeft, 0);

    if (overlapRight < minOverlap) {
      minOverlap = overlapRight;
      penetration = Vec2(-overlapRight, 0);
    }

    if (overlapTop < minOverlap) {
      minOverlap = overlapTop;
      penetration = Vec2(0, overlapTop);
    }

    if (overlapBottom < minOverlap) {
      minOverlap = overlapBottom;
      penetration = Vec2(0, -overlapBottom);
    }

    return penetration;
  }

  static Vec2? getPenetrationCircle(Circle circle) {
    if (!containsOriginCircle(circle)) {
      return null;
    }

    final distSq = circle.position.x * circle.position.x + circle.position.y * circle.position.y;
    final distance = math.sqrt(distSq);

    if (distance == 0) {
      return Vec2(0, -circle.radius);
    }

    final overlap = circle.radius - distance;

    final normalX = circle.position.x / distance;
    final normalY = circle.position.y / distance;

    return Vec2(normalX * overlap, normalY * overlap);
  }
}
