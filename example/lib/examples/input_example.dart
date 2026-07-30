import 'package:flutter/material.dart' hide Animation;
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';

class InputExample extends ScreenController {
  final mouse = Vec2.zero();
  final mouseText = CanvasText();

  final keys = <LogicalKeyboardKey>{};
  final latestKey = CanvasText(text: "Press any key to see !");
  final currentKeys = CanvasText();

  @override
  void setup(BuildContext context, double width, double height) {}

  @override
  void update(double deltaTime) {
    mouseText.text = "mouseX: ${mouse.x.toInt()}\nmouseY: ${mouse.y.toInt()}";

    final str = StringBuffer("Currently Holding:\n");
    bool holding = false;
    for (final key in keys) {
      holding = true;
      str.writeln(key == LogicalKeyboardKey.space ? "Space" : key.keyLabel);
    }
    if (!holding) str.write("NONE");
    currentKeys.text = str.toString();
    currentKeys.style = TextStyle(color: holding ? Colors.yellow : Colors.white);
  }

  @override
  void draw(Canvas canvas, Size size) {
    mouseText.draw(canvas, mouse);
    latestKey.draw(canvas, Vec2(size.width * 0.5 - 80, 32));
    currentKeys.draw(canvas, Vec2(size.width * 0.5 - 80, 72));
  }

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) {
    mouse.set(mouseX, mouseY);
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    mouse.set(mouseX, mouseY);
    mouseText.style = const TextStyle(color: Colors.red);
  }

  @override
  void mouseReleased(int pointerID) {
    mouseText.style = const TextStyle(color: Colors.white);
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    keys.add(key);
    latestKey.text =
        "Latest Key Press:\n${key == LogicalKeyboardKey.space ? "Space" : key.keyLabel}";
  }

  @override
  void keyUp(LogicalKeyboardKey key) {
    keys.remove(key);
  }

  @override
  void dispose() {}
}
