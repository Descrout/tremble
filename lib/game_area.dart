import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremble/game_ticker.dart';
import 'package:tremble/screen_controller.dart';

class GameArea extends StatefulWidget {
  const GameArea({super.key, required this.controller});

  final ScreenController controller;

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  @override
  void initState() {
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    super.initState();
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyDownEvent) {
      widget.controller.keyDown(key);
    } else if (event is KeyUpEvent) {
      widget.controller.keyUp(key);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: GestureDetector(
        onPanStart: (_) => widget.controller.mousePressed(),
        onPanEnd: (_) => widget.controller.mouseReleased(),
        onPanUpdate: (event) =>
            widget.controller.mouseMove(event.localPosition.dx, event.localPosition.dy),
        child: MouseRegion(
          onHover: (event) =>
              widget.controller.mouseMove(event.localPosition.dx, event.localPosition.dy),
          child: LayoutBuilder(builder: (context, constraints) {
            return GameTicker(
              controller: widget.controller,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }
}
