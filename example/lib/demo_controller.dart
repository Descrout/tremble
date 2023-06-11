import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremble/screen_controller.dart';

class DemoController extends ScreenController {
  late double mX;
  late double mY;

  double mouseX = 0;
  double mouseY = 0;
  bool mouseDown = false;

  final positions = <Offset>[];

  final keys = <LogicalKeyboardKey>{};

  @override
  void setup(double width, double height) {
    mX = width / 2;
    mY = height / 2;

    final maxSize = max(mX, mY);

    for (double i = 0; i < pi * 2; i += 0.05) {
      positions.add(Offset(mX + cos(i) * maxSize, mY + sin(i) * maxSize));
    }
  }

  @override
  void resize(double width, double height) {}

  @override
  void update(double deltaTime) {
    if (mouseDown) {
      mX += (mouseX - mX) * 0.05;
      mY += (mouseY - mY) * 0.05;
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawColor(Colors.black, BlendMode.src);

    final mouseOffset = Offset(mX, mY);
    canvas.drawCircle(Offset(mouseX, mouseY), 30, Paint()..color = Colors.red);

    final linePaint = Paint()
      ..color = mouseDown ? Colors.red : Colors.blue
      ..strokeWidth = keys.contains(LogicalKeyboardKey.space) ? 5 : 1;
    for (final pos in positions) {
      canvas.drawLine(pos, mouseOffset, linePaint);
    }
  }

  @override
  void mouseMove(double mouseX, double mouseY) {
    this.mouseX = mouseX;
    this.mouseY = mouseY;
  }

  @override
  void mousePressed() {
    mouseDown = true;
  }

  @override
  void mouseReleased() {
    mouseDown = false;
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    keys.add(key);
  }

  @override
  void keyUp(LogicalKeyboardKey key) {
    keys.remove(key);
  }

  @override
  void dispose() {}
}
