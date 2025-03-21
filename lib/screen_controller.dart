import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tremble/utils/types.dart';

abstract class ScreenController {
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    done();
  }

  void setup(BuildContext context, double width, double height);
  void resize(double width, double height) {}

  void mouseMove(int pointerID, double mouseX, double mouseY) {}
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {}
  void mouseReleased(int pointerID) {}
  void mouseScroll(Offset scrollOffset) {}

  void keyDown(LogicalKeyboardKey key) {}
  void keyUp(LogicalKeyboardKey key) {}

  void update(double deltaTime);
  void draw(Canvas canvas, Size size);

  void dispose();
}
