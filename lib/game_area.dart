import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremble/game_ticker.dart';
import 'package:tremble/screen_controller.dart';

class GameArea extends StatefulWidget {
  const GameArea({
    super.key,
    required this.controller,
    this.loadingBuilder,
  });

  final ScreenController controller;
  final Widget Function(BuildContext context, double progress)? loadingBuilder;

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  final preloadController = StreamController<double>();
  bool loaded = false;

  @override
  void initState() {
    widget.controller.preload(preloadController.sink.add, onDone);
    super.initState();
  }

  void onDone() {
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    loaded = true;
    preloadController.close();
    setState(() {});
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
    return loaded
        ? ClipRRect(
            child: Listener(
              onPointerDown: (event) => widget.controller.mousePressed(
                  event.pointer, event.buttons, event.localPosition.dx, event.localPosition.dy),
              onPointerUp: (event) => widget.controller.mouseReleased(event.pointer),
              onPointerHover: (event) => widget.controller
                  .mouseMove(event.pointer, event.localPosition.dx, event.localPosition.dy),
              onPointerMove: (event) => widget.controller
                  .mouseMove(event.pointer, event.localPosition.dx, event.localPosition.dy),
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) widget.controller.mouseScroll(event.scrollDelta);
              },
              child: LayoutBuilder(builder: (context, constraints) {
                return GameTicker(
                  controller: widget.controller,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                );
              }),
            ),
          )
        : StreamBuilder(
            stream: preloadController.stream,
            builder: (context, snapshot) {
              return widget.loadingBuilder?.call(context, snapshot.data ?? 0.0) ??
                  const Center(child: CircularProgressIndicator());
            });
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    preloadController.close();
    super.dispose();
  }
}
