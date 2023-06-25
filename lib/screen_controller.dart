import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremble/types.dart';

abstract class ScreenController {
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    done();
  }

  void setup(double width, double height);
  void resize(double width, double height) {}

  void mouseMove(double mouseX, double mouseY) {}
  void mousePressed() {}
  void mouseReleased() {}

  void keyDown(LogicalKeyboardKey key) {}
  void keyUp(LogicalKeyboardKey key) {}

  void update(double deltaTime);
  void draw(Canvas canvas, Size size);

  void dispose();
}
