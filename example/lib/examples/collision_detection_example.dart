import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class CollisionDetectionExample extends ScreenController {
  static const int _shapeCount = 3;

  final mid = Vec2(400, 300);

  late Shape middle;
  late Shape mouseShape;

  int _middleIndex = 0;
  int _mouseIndex = 1;

  Shape _makeMiddle() => switch (_middleIndex) {
        0 => AABB(mid - Vec2(45, 30), width: 90, height: 60),
        1 => Circle(mid, radius: 35),
        _ => Line(mid - Vec2(90, 30), mid + Vec2(90, 30)),
      };

  Shape _makeMouse() => switch (_mouseIndex) {
        0 => AABB(Vec2.zero(), width: 60, height: 90),
        1 => Circle(Vec2.zero(), radius: 30),
        _ => Line(Vec2.zero(), Vec2.zero()),
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
    final colliding = CollisionDetector.shapeToShape(middle, mouseShape);
    if (colliding) {
      canvas.drawColor(
        const Color.fromARGB(255, 25, 71, 28),
        BlendMode.src,
      );
    }

    middle.draw(canvas, Colors.white);
    mouseShape.draw(canvas, Colors.white70);
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
