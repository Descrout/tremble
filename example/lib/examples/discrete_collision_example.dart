import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class DiscreteCollisionExample extends ScreenController {
  static const int _shapeCount = 2;

  final mid = Vec2(400, 300);

  late Shape middle;
  late Shape mouseShape;

  int _middleIndex = 0;
  int _mouseIndex = 0;

  Shape _makeMiddle() => switch (_middleIndex) {
        0 => AABB(mid - Vec2(45, 30), width: 90, height: 60),
        _ => Circle(mid, radius: 35),
      };

  Shape _makeMouse() => switch (_mouseIndex) {
        0 => AABB(Vec2.zero(), width: 60, height: 90),
        _ => Circle(Vec2.zero(), radius: 30),
      };

  @override
  void setup(BuildContext context, double width, double height) {
    middle = _makeMiddle();
    mouseShape = _makeMouse();
  }

  @override
  void update(double deltaTime) {}

  @override
  void draw(Canvas canvas, Size size) {
    middle.draw(canvas, Colors.white);
    mouseShape.draw(canvas, Colors.blue.withAlpha(180));

    if (_middleIndex == _mouseIndex) {
      final pen = Minkowski.getPenetration(Minkowski.difference(mouseShape, middle));
      if (pen != null) {
        final shape = mouseShape.clone();
        shape.position.add(pen);
        shape.draw(canvas, Colors.red);
      }
    } else {
      final mouseIsCircle = mouseShape is Circle;
      final circle = (mouseIsCircle ? mouseShape : middle) as Circle;
      final aabb = (mouseIsCircle ? middle : mouseShape) as AABB;
      Vec2 pen = Vec2.zero();
      if (CollisionDetector.circleToRect(circle, aabb, out: pen)) {
        if (pen.isZero) {
          pen = Minkowski.getPenetration(Minkowski.difference(mouseShape, middle))!;
        } else if (!mouseIsCircle) {
          pen.scale(-1);
        }
        final shape = mouseShape.clone();
        shape.position.add(pen);
        shape.draw(canvas, Colors.red);
        pen.draw(canvas, Colors.white, origin: circle.position.offset());
      }
    }
  }

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) {
    mouseShape.position.set(mouseX, mouseY);
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    if (button == 1) {
      _mouseIndex = (_mouseIndex + 1) % _shapeCount;
      mouseShape = _makeMouse();
    } else if (button == 2) {
      _middleIndex = (_middleIndex + 1) % _shapeCount;
      middle = _makeMiddle();
    }
    mouseShape.position.set(mouseX, mouseY);
  }

  @override
  void dispose() {}
}
