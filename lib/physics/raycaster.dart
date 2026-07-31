import 'dart:math' as math;

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/circle.dart';
import 'package:tremble/physics/line.dart';
import 'package:tremble/physics/ray.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/spatial_hash.dart';
import 'package:tremble/physics/vec2.dart';

class RaycastHit<T> {
  T object;
  Vec2 point;
  Vec2 normal;
  double distance;

  RaycastHit({
    required this.object,
    required this.point,
    required this.normal,
    required this.distance,
  });
}

class RaycastGridHit {
  final int tx;
  final int ty;
  final double distance;
  final Vec2 point;
  final int normalX;
  final int normalY;

  RaycastGridHit({
    required this.tx,
    required this.ty,
    required this.distance,
    required this.point,
    required this.normalX,
    required this.normalY,
  });
}

abstract final class Raycaster {
  static RaycastHit<Circle>? raycastCircle(Ray ray, Circle circle) {
    final ocX = ray.origin.x - circle.position.x;
    final ocY = ray.origin.y - circle.position.y;

    final b = 2 * (ocX * ray.direction.x + ocY * ray.direction.y);
    final c = ocX * ocX + ocY * ocY - circle.radius * circle.radius;
    final disc = b * b - 4 * c;

    if (disc < 0) return null;

    final sqrtDisc = math.sqrt(disc);
    final t1 = (-b - sqrtDisc) / 2;
    final t2 = (-b + sqrtDisc) / 2;

    final t = t1 >= 0 ? t1 : (t2 >= 0 ? t2 : null);
    if (t == null) return null;

    return RaycastHit<Circle>(
      object: circle,
      point: Vec2(
        ray.origin.x + ray.direction.x * t,
        ray.origin.y + ray.direction.y * t,
      ),
      normal: Vec2(
        (ray.origin.x + ray.direction.x * t - circle.position.x) / circle.radius,
        (ray.origin.y + ray.direction.y * t - circle.position.y) / circle.radius,
      ),
      distance: t,
    );
  }

  static RaycastHit<AABB>? raycastAABB(Ray ray, AABB aabb) {
    final invDirX = 1 / ray.direction.x;
    final invDirY = 1 / ray.direction.y;

    final t1 =
        invDirX >= 0 ? (aabb.left - ray.origin.x) * invDirX : (aabb.right - ray.origin.x) * invDirX;
    final t2 =
        invDirX >= 0 ? (aabb.right - ray.origin.x) * invDirX : (aabb.left - ray.origin.x) * invDirX;

    final ty1 =
        invDirY >= 0 ? (aabb.top - ray.origin.y) * invDirY : (aabb.bottom - ray.origin.y) * invDirY;
    final ty2 =
        invDirY >= 0 ? (aabb.bottom - ray.origin.y) * invDirY : (aabb.top - ray.origin.y) * invDirY;

    if (t1 > ty2 || ty1 > t2) return null;

    final tMin = math.max(t1, ty1);
    final tMax = math.min(t2, ty2);

    final t = tMin >= 0 ? tMin : (tMax >= 0 ? tMax : null);
    if (t == null) return null;

    double nx, ny;
    if (t == t1) {
      nx = invDirX >= 0 ? -1 : 1;
      ny = 0;
    } else if (t == ty1) {
      nx = 0;
      ny = invDirY >= 0 ? -1 : 1;
    } else if (t == t2) {
      nx = invDirX >= 0 ? 1 : -1;
      ny = 0;
    } else {
      nx = 0;
      ny = invDirY >= 0 ? 1 : -1;
    }

    return RaycastHit<AABB>(
      object: aabb,
      point: Vec2(
        ray.origin.x + ray.direction.x * t,
        ray.origin.y + ray.direction.y * t,
      ),
      normal: Vec2(nx, ny),
      distance: t,
    );
  }

  static RaycastHit<Line>? raycastLine(Ray ray, Line line) {
    final lx = line.p2.x - line.p1.x;
    final ly = line.p2.y - line.p1.y;
    final dx = line.p1.x - ray.origin.x;
    final dy = line.p1.y - ray.origin.y;

    final denom = ray.direction.x * ly - ray.direction.y * lx;
    if (denom.abs() < 1e-10) return null;

    final t = (dx * ly - dy * lx) / denom;
    final s = (dx * ray.direction.y - dy * ray.direction.x) / denom;

    if (t < 0 || s < 0 || s > 1) return null;

    final lineLen = math.sqrt(lx * lx + ly * ly);
    double nx = -ly / lineLen;
    double ny = lx / lineLen;

    // flip normal to face the ray origin
    final toOriginX = ray.origin.x - (ray.origin.x + ray.direction.x * t);
    final toOriginY = ray.origin.y - (ray.origin.y + ray.direction.y * t);
    if (nx * toOriginX + ny * toOriginY < 0) {
      nx = -nx;
      ny = -ny;
    }

    return RaycastHit<Line>(
      object: line,
      point: Vec2(
        ray.origin.x + ray.direction.x * t,
        ray.origin.y + ray.direction.y * t,
      ),
      normal: Vec2(nx, ny),
      distance: t,
    );
  }

  static RaycastHit<Shape>? raycastShape(Ray ray, Shape shape) {
    if (shape is Circle) return raycastCircle(ray, shape);
    if (shape is AABB) return raycastAABB(ray, shape);
    if (shape is Line) return raycastLine(ray, shape);
    return null;
  }

  static RaycastHit<T>? raycastSpatial<T>(
    Ray ray,
    SpatialHash<T> world,
    Shape Function(T) shape,
  ) {
    const maxDist = 1e6;
    final farX = ray.origin.x + ray.direction.x * maxDist;
    final farY = ray.origin.y + ray.direction.y * maxDist;
    final minX = math.min(ray.origin.x, farX);
    final maxX = math.max(ray.origin.x, farX);
    final minY = math.min(ray.origin.y, farY);
    final maxY = math.max(ray.origin.y, farY);

    final candidates = world.query(
      AABB(Vec2(minX, minY), width: maxX - minX, height: maxY - minY),
    );

    RaycastHit<T>? closest;
    for (final obj in candidates) {
      final hit = raycastShape(ray, shape(obj));
      if (hit == null) continue;
      if (closest == null || hit.distance < closest.distance) {
        closest = RaycastHit<T>(
          object: obj,
          point: hit.point,
          normal: hit.normal,
          distance: hit.distance,
        );
      }
    }

    return closest;
  }

  static RaycastGridHit? raycastGrid(
    Ray ray, {
    required int cellSize,
    required double maxDistance,
    required bool Function(int tx, int ty) isSolid,
  }) {
    final dirX = ray.direction.x;
    final dirY = ray.direction.y;

    final startX = ray.origin.x / cellSize;
    final startY = ray.origin.y / cellSize;

    final stepSizeX = dirX.abs() < 1e-10 ? double.infinity : 1 / dirX.abs();
    final stepSizeY = dirY.abs() < 1e-10 ? double.infinity : 1 / dirY.abs();

    int mapX = startX.floor();
    int mapY = startY.floor();

    double rayLenX, rayLenY;
    int stepX, stepY;

    if (dirX < 0) {
      stepX = -1;
      rayLenX = (startX - mapX) * stepSizeX;
    } else {
      stepX = 1;
      rayLenX = ((mapX + 1) - startX) * stepSizeX;
    }

    if (dirY < 0) {
      stepY = -1;
      rayLenY = (startY - mapY) * stepSizeY;
    } else {
      stepY = 1;
      rayLenY = ((mapY + 1) - startY) * stepSizeY;
    }

    double distance = 0;
    var hitVertical = false;

    while (distance < maxDistance) {
      if (rayLenX < rayLenY) {
        mapX += stepX;
        distance = rayLenX;
        rayLenX += stepSizeX;
        hitVertical = true;
      } else {
        mapY += stepY;
        distance = rayLenY;
        rayLenY += stepSizeY;
        hitVertical = false;
      }

      if (distance >= maxDistance) break;

      if (isSolid(mapX, mapY)) {
        return RaycastGridHit(
          tx: mapX,
          ty: mapY,
          distance: distance * cellSize,
          point: Vec2(
            ray.origin.x + dirX * distance * cellSize,
            ray.origin.y + dirY * distance * cellSize,
          ),
          normalX: hitVertical ? -stepX : 0,
          normalY: hitVertical ? 0 : -stepY,
        );
      }
    }

    return null;
  }
}
