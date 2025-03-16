import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:tremble/screen_controller.dart';

class GamePainter extends CustomPainter {
  GamePainter({
    required this.controller,
    required this.listener,
  }) : super(repaint: listener);

  final ScreenController controller;
  final Listenable listener;

  @override
  void paint(Canvas canvas, Size size) => controller.draw(canvas, size);

  @override
  bool shouldRepaint(GamePainter oldDelegate) => oldDelegate.controller != controller;
}
