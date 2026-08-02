import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class SweptCollisionExample extends ScreenController {
  final player = AABB(Vec2(100, 100), width: 32, height: 64);
  final playerNew = AABB(Vec2(100, 100), width: 32, height: 64);
  final mouseAABB = AABB(Vec2.zero(), width: 32, height: 64);

  final colliders = <AABB>[];

  @override
  void setup(BuildContext context, double width, double height) {
    colliders.add(AABB(Vec2(width * 0.5 - 50, height * 0.5 - 50), width: 100, height: 100));
    Shape.paint.strokeWidth = 1;
  }

  @override
  void update(double deltaTime) {
    final checkShape = Sweep.expand(player, colliders[0]);

    final diff = mouseAABB.position - player.position;
    final ray = Ray(origin: player.position + Vec2(16, 32), direction: diff);
    final hit = Raycaster.raycastShape(ray, checkShape);
    if (hit == null || hit.distance > diff.magnitude) {
      playerNew.position.setFrom(mouseAABB.position);
    } else {
      playerNew.position.setFrom(hit.point - Vec2(16, 32));
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    for (final collider in colliders) {
      collider.draw(canvas, const Color(0xAAFF8A65));
    }

    player.draw(canvas, const Color(0xFF4FC3F7));
    playerNew.draw(canvas, Colors.red);
    mouseAABB.draw(canvas, Colors.transparent, true);

    final lineColor = Colors.white.withAlpha(90);
    Line(
      Vec2(player.left, player.top),
      Vec2(mouseAABB.left, mouseAABB.top),
    ).draw(canvas, lineColor);

    Line(
      Vec2(player.left, player.bottom),
      Vec2(mouseAABB.left, mouseAABB.bottom),
    ).draw(canvas, lineColor);

    Line(
      Vec2(player.right, player.top),
      Vec2(mouseAABB.right, mouseAABB.top),
    ).draw(canvas, lineColor);

    Line(
      Vec2(player.right, player.bottom),
      Vec2(mouseAABB.right, mouseAABB.bottom),
    ).draw(canvas, lineColor);
  }

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) {
    mouseAABB.position.set(mouseX - 16, mouseY - 32);
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    mouseAABB.position.set(mouseX - 16, mouseY - 32);

    if (CollisionDetector.shapeToShape(mouseAABB, player)) {
      // Change player shape, but only between Circle and AABB
    } else if (CollisionDetector.shapeToShape(mouseAABB, colliders[0])) {
      // Change colliders[0] shape, but only between Circle and AABB
    } else {
      player.position.setFrom(mouseAABB.position);
    }
  }

  @override
  void dispose() {}
}
