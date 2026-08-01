import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/circle.dart';
import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';

abstract final class Sweep {
  static Shape expand(Shape moving, Shape target) {
    return switch ((moving, target)) {
      (AABB movingAABB, AABB targetAABB) => expandAABB(movingAABB, targetAABB),
      (Circle movingCircle, Circle targetCircle) => expandCircle(movingCircle, targetCircle),
      (AABB movingAABB, Circle targetCircle) => expandAABBAndCircle(movingAABB, targetCircle),
      (Circle movingCircle, AABB targetAABB) => expandCircleAndAABB(movingCircle, targetAABB),
      _ => throw UnimplementedError(
          '${moving.runtimeType} and ${target.runtimeType} is not defined for Sweep.',
        ),
    };
  }

  static AABB expandAABB(AABB moving, AABB target) {
    return AABB(
      Vec2(target.position.x - moving.width * 0.5, target.position.y - moving.height * 0.5),
      width: target.width + moving.width,
      height: target.height + moving.height,
    );
  }

  static Circle expandCircle(Circle moving, Circle target) {
    return Circle(
      Vec2(target.position.x, target.position.y),
      radius: moving.radius + target.radius,
    );
  }

  static AABB expandAABBAndCircle(AABB moving, Circle target) {
    return AABB(
      Vec2(
        target.position.x - target.radius - moving.width / 2,
        target.position.y - target.radius - moving.height / 2,
      ),
      width: (target.radius * 2) + moving.width,
      height: (target.radius * 2) + moving.height,
    );
  }

  static AABB expandCircleAndAABB(Circle moving, AABB target) {
    return AABB(
      Vec2(target.position.x - moving.radius, target.position.y - moving.radius),
      width: target.width + (moving.radius * 2),
      height: target.height + (moving.radius * 2),
    );
  }
}
